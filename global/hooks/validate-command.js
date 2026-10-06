#!/usr/bin/env node

/**
 * PreToolUse hook: validate-command   (BLOCKING, fails OPEN on internal errors)
 *
 * Validates Bash commands before execution and blocks destructive operations: filesystem
 * destruction, privilege escalation, remote code execution pipes, infra destroy commands
 * (terraform/pulumi/cdk/cloud CLIs), destructive git commands (reset --hard, push --force,
 * clean -f, branch -D...), and, when enabled, destructive SQL / Supabase operations.
 *
 * Event / matcher : PreToolUse / Bash                  (timeout 5)
 * Exit codes      : 0 allow, 2 block (Claude Code requires 2 to block).
 *                   Empty or invalid JSON on stdin exits 1 (non-blocking error).
 *                   An internal bug exits 0: a validator bug must not block all work (the
 *                   harness permission system remains the fallback).
 * Manual test     : echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | node validate-command.js
 *
 * Environment:
 *   CLAUDE_DB_PROTECT_DIRS   regex tested against the working directory. When it matches, the
 *                            destructive SQL/Supabase patterns are enforced. Example for a
 *                            production-data repo: "/my-saas(/|$|-)". Unset = DB rules off,
 *                            so unrelated sandboxes are not blocked.
 *   CLAUDE_DB_PROTECT=1      enforce the DB rules everywhere.
 *   CLAUDE_DB_SAFE_TOOL      optional hint printed in DB block messages: the safe admin script
 *                            the agent should use instead.
 *   CLAUDE_SECURITY_LOG      log file for decisions (default ~/.claude/security.log),
 *                            "off" disables logging. Commands are truncated to 500 chars.
 */

const fs = require('fs');
const path = require('path');

// Comprehensive dangerous command patterns database
const SECURITY_RULES = {
  // Critical system destruction commands
  CRITICAL_COMMANDS: [
    "del",
    "format",
    "mkfs",
    "shred",
    "dd",
    "fdisk",
    "parted",
    "gparted",
    "cfdisk",
  ],

  // Privilege escalation and system access
  PRIVILEGE_COMMANDS: [
    "sudo",
    "su",
    "passwd",
    "chpasswd",
    "usermod",
    "setuid",
    "setgid",
    // chmod/chown/chgrp allowed in safe forms; dangerous forms caught by DANGEROUS_PATTERNS below
  ],

  // Network and remote access tools
  NETWORK_COMMANDS: [
    "nc",
    "netcat",
    "nmap",
    "telnet",
    "ssh-keygen",
    "iptables",
    "ufw",
    "firewall-cmd",
    "ipfw",
  ],

  // System service and process manipulation
  SYSTEM_COMMANDS: [
    "systemctl",
    "service",
    "mount",
    "umount",
    "swapon",
    "swapoff",
    // kill/killall/pkill allowed for normal process management; dangerous forms caught by DANGEROUS_PATTERNS below
  ],

  // Dangerous regex patterns
  DANGEROUS_PATTERNS: [
    // File system destruction: block rm -rf with absolute paths
    /rm\s+.*-rf\s*\/\s*$/i, // rm -rf ending at root directory
    /rm\s+.*-rf\s*\/\w+/i, // rm -rf with any absolute path
    /rm\s+.*-rf\s*\/etc/i, // rm -rf in /etc
    /rm\s+.*-rf\s*\/usr/i, // rm -rf in /usr
    /rm\s+.*-rf\s*\/bin/i, // rm -rf in /bin
    /rm\s+.*-rf\s*\/sys/i, // rm -rf in /sys
    /rm\s+.*-rf\s*\/proc/i, // rm -rf in /proc
    /rm\s+.*-rf\s*\/boot/i, // rm -rf in /boot
    /rm\s+.*-rf\s*\/home\/[^\/]*\s*$/i, // rm -rf entire home directory
    /rm\s+.*-rf\s*\.\.+\//i, // rm -rf with parent directory traversal
    /rm\s+.*-rf\s*\*.*\*/i, // rm -rf with multiple wildcards
    /rm\s+.*-rf\s*\$\w+/i, // rm -rf with variables (could be dangerous)
    />\s*\/dev\/(sda|hda|nvme)/i,
    /dd\s+.*of=\/dev\//i,
    /shred\s+.*\/dev\//i,
    /mkfs\.\w+\s+\/dev\//i,

    // Fork bomb and resource exhaustion
    /:\(\)\{\s*:\|:&\s*\};:/,
    /while\s+true\s*;\s*do.*done/i,
    /for\s*\(\(\s*;\s*;\s*\)\)/i,

    // Command injection and chaining (rm excluded: rm -rf dangerous paths are caught above)
    /;\s*(dd|mkfs|format)/i,
    /&&\s*(dd|mkfs|format)/i,
    /\|\|\s*(dd|mkfs|format)/i,

    // Remote code execution
    /\|\s*(sh|bash|zsh|fish)$/i,
    /(wget|curl)\s+.*\|\s*(sh|bash)/i,
    /(wget|curl)\s+.*-O-.*\|\s*(sh|bash)/i,

    // Command substitution with dangerous commands
    // Note: use \bdd\b to avoid matching variable names containing "dd" (e.g. random IDs containing "dd")
    /`\s*rm\s+/i,
    /\$\(\s*rm\s+/i,
    /`\s*dd\s+if=/i,
    /\$\(\s*dd\s+if=/i,

    // Sensitive file access
    /cat\s+\/etc\/(passwd|shadow|sudoers)/i,
    />\s*\/etc\/(passwd|shadow|sudoers)/i,
    /echo\s+.*>>\s*\/etc\/(passwd|shadow|sudoers)/i,

    // Network exfiltration
    /\|\s*nc\s+\S+\s+\d+/i,
    /curl\s+.*-d.*\$\(/i,
    /wget\s+.*--post-data.*\$\(/i,

    // Log manipulation
    />\s*\/var\/log\//i,
    /rm\s+\/var\/log\//i,
    /echo\s+.*>\s*~?\/?\.bash_history/i,

    // Backdoor creation
    /nc\s+.*-l.*-e/i,
    /nc\s+.*-e.*-l/i,
    /ncat\s+.*--exec/i,
    /ssh-keygen.*authorized_keys/i,

    // Crypto mining and malicious downloads
    /(wget|curl).*\.(sh|py|pl|exe|bin).*\|\s*(sh|bash|python)/i,
    /(xmrig|ccminer|cgminer|bfgminer)/i,

    // Hardware direct access
    /cat\s+\/dev\/(mem|kmem)/i,
    /echo\s+.*>\s*\/dev\/(mem|kmem)/i,

    // Kernel module manipulation
    /(insmod|rmmod|modprobe)\s+/i,

    // Cron job manipulation
    /crontab\s+-e/i,
    /echo\s+.*>>\s*\/var\/spool\/cron/i,

    // Environment variable exposure
    /env\s*\|\s*grep.*PASSWORD/i,
    /printenv.*PASSWORD/i,

    // Dangerous chmod forms: setuid (4xxx), setgid (2xxx), world-writable (777)
    /chmod\s+4[0-7]{3}\b/i,          // setuid bit: chmod 4755, 4777, etc.
    /chmod\s+2[0-7]{3}\b/i,          // setgid bit: chmod 2755, etc.
    /chmod\s+777\b/i,                 // world writable+executable
    /chmod\s+.*-R\s+777\b/i,         // recursive 777
    /chmod\s+.*([aug]\+s|o\+w)/i,    // symbolic setuid/setgid/world-write

    // Dangerous kill forms (killing init/PID 1, or mass-kill all processes)
    /kill\s+(-9\s+)?1\b/i,       // kill PID 1 (init/systemd)
    /pkill\s+-9\s+-1\b/i,        // kill all processes
    /killall\s+-9\s+systemd/i,   // kill systemd
  ],

  // Paths that should never be written to
  PROTECTED_PATHS: [
    "/etc/",
    "/usr/",
    "/bin/",
    "/sbin/",
    "/boot/",
    "/sys/",
    "/proc/",
    "/dev/",
    "/root/",
  ],
};

class CommandValidator {
  constructor() {
    const configured = process.env.CLAUDE_SECURITY_LOG;
    this.logDisabled = configured === "off";
    this.logFile =
      configured && configured !== "off"
        ? configured
        : path.join(process.env.HOME || require("os").homedir(), ".claude", "security.log");
  }

  /**
   * Main validation function
   */
  validate(command, toolName = "Unknown", cwdHint = null) {
    const result = {
      isValid: true,
      severity: "LOW",
      violations: [],
      sanitizedCommand: command,
    };

    if (!command || typeof command !== "string") {
      result.isValid = false;
      result.violations.push("Invalid command format");
      return result;
    }

    // Normalize command for analysis
    const normalizedCmd = command.trim().toLowerCase();
    const cmdParts = normalizedCmd.split(/\s+/);
    const mainCommand = cmdParts[0];

    // Check against critical commands
    if (SECURITY_RULES.CRITICAL_COMMANDS.includes(mainCommand)) {
      result.isValid = false;
      result.severity = "CRITICAL";
      result.violations.push(`Critical dangerous command: ${mainCommand}`);
    }

    // Check privilege escalation commands
    if (SECURITY_RULES.PRIVILEGE_COMMANDS.includes(mainCommand)) {
      result.isValid = false;
      result.severity = "HIGH";
      result.violations.push(`Privilege escalation command: ${mainCommand}`);
    }

    // Check network commands
    if (SECURITY_RULES.NETWORK_COMMANDS.includes(mainCommand)) {
      result.isValid = false;
      result.severity = "HIGH";
      result.violations.push(`Network/remote access command: ${mainCommand}`);
    }

    // Check system commands
    if (SECURITY_RULES.SYSTEM_COMMANDS.includes(mainCommand)) {
      result.isValid = false;
      result.severity = "HIGH";
      result.violations.push(`System manipulation command: ${mainCommand}`);
    }

    // Check dangerous patterns
    for (const pattern of SECURITY_RULES.DANGEROUS_PATTERNS) {
      if (pattern.test(command)) {
        result.isValid = false;
        result.severity = "CRITICAL";
        result.violations.push(`Dangerous pattern detected: ${pattern.source}`);
      }
    }

    // Check for protected path WRITES only: reads/executes are fine (OS perms protect anyway)
    // Blocks: `echo x > /etc/hosts`, `tee /usr/bin/evil`, `cp mal /sbin/`
    // Allows: `/opt/homebrew/bin/npx`, `/usr/bin/python3 script.py`, `cat /etc/hosts`
    for (const protectedPath of SECURITY_RULES.PROTECTED_PATHS) {
      if (!command.includes(protectedPath)) continue;

      // /dev/null, /dev/stderr, /dev/stdout are always safe
      if (protectedPath === "/dev/" && /\/dev\/(null|stderr|stdout)\b/.test(command)) continue;

      // Only block if the protected path is the DESTINATION of a write operation
      const escapedPath = protectedPath.replace(/\//g, "\\/");
      const writeToProtected = new RegExp(
        "(?:>>?|\\btee\\b|\\bcp\\b|\\binstall\\b|\\bmv\\b)\\s+[^|;&\\n]*" + escapedPath,
        "i"
      );
      if (writeToProtected.test(command)) {
        result.isValid = false;
        result.severity = "HIGH";
        result.violations.push(`Write to protected path: ${protectedPath}`);
      }
    }

    // ================================================================
    // INFRASTRUCTURE / TERRAFORM DESTRUCTIVE OPERATIONS
    // Known incident class: an agent deleted a production database by replacing a Terraform
    // state file with an older version. These operations are irreversible on cloud infra
    // (AWS, GCP, Vercel...).
    // ================================================================
    const INFRA_DESTRUCTIVE_PATTERNS = [
      { pattern: /terraform\s+destroy\b/i, label: 'terraform destroy (destroys the whole infrastructure)' },
      { pattern: /terraform\s+apply\s+.*-destroy\b/i, label: 'terraform apply -destroy' },
      { pattern: /terraform\s+state\s+(rm|remove|replace-provider|push)\b/i, label: 'terraform state mutation (known production-database incident class)' },
      { pattern: /terraform\s+workspace\s+delete\b/i, label: 'terraform workspace delete' },
      { pattern: /pulumi\s+destroy\b/i, label: 'pulumi destroy' },
      { pattern: /cdk\s+destroy\b/i, label: 'cdk destroy' },
      { pattern: /aws\s+.*\s+delete\b/i, label: 'aws CLI delete operation' },
      { pattern: /gcloud\s+.*\s+delete\b/i, label: 'gcloud delete operation' },
      { pattern: /vercel\s+(remove|rm)\b/i, label: 'vercel remove project/deployment' },
      { pattern: /fly\s+(destroy|delete)\b/i, label: 'fly.io destroy app' },
      { pattern: /heroku\s+apps:destroy\b/i, label: 'heroku apps:destroy' },
      { pattern: /docker\s+(system\s+prune|volume\s+rm|network\s+rm)\b/i, label: 'docker destructive cleanup' },
    ];

    for (const { pattern, label } of INFRA_DESTRUCTIVE_PATTERNS) {
      if (pattern.test(command)) {
        result.isValid = false;
        result.severity = 'CRITICAL';
        result.violations.push(
          `INFRA PROTECTION: ${label}. ` +
          `Irreversible operation on cloud infrastructure. ` +
          `Ask the user for explicit confirmation before running it.`
        );
      }
    }

    // ================================================================
    // GIT DESTRUCTIVE OPERATIONS
    // Hard-to-reverse git commands that can destroy work or history.
    // User must confirm these via Claude's permission system, not bypass.
    // ================================================================
    const GIT_DESTRUCTIVE_PATTERNS = [
      { pattern: /git\s+reset\s+--hard\b/i, label: 'git reset --hard (discards uncommitted changes)' },
      { pattern: /git\s+push\s+.*--force(?!-with-lease)\b/i, label: 'git push --force (can overwrite upstream history)' },
      { pattern: /git\s+push\s+.*-f\b(?!-with-lease)/i, label: 'git push -f (can overwrite upstream history)' },
      { pattern: /git\s+clean\s+(-\S+\s+)*-[a-zA-Z]*f/i, label: 'git clean -f (permanently deletes untracked files)' },
      { pattern: /git\s+checkout\s+--\s+\./i, label: 'git checkout -- . (discards all working tree changes)' },
      { pattern: /git\s+restore\s+\.\b/i, label: 'git restore . (discards all working tree changes)' },
      { pattern: /git\s+branch\s+-D\b/i, label: 'git branch -D (force-deletes branch without merge check)' },
      { pattern: /git\s+rebase\s+.*--onto\b/i, label: 'git rebase --onto (rewrites branch history)' },
      { pattern: /git\s+filter-branch\b/i, label: 'git filter-branch (rewrites entire repo history)' },
    ];

    for (const { pattern, label } of GIT_DESTRUCTIVE_PATTERNS) {
      if (pattern.test(command)) {
        result.isValid = false;
        result.severity = 'HIGH';
        result.violations.push(
          `GIT DESTRUCTIVE: ${label}. ` +
          `This operation is hard to reverse. Confirm explicitly before proceeding.`
        );
      }
    }

    // ================================================================
    // DATABASE / SUPABASE DESTRUCTIVE OPERATIONS
    // These patterns catch any attempt to delete, drop, or truncate
    // data in Supabase or Postgres, whether via SQL, JS SDK, or admin API.
    // Opt-in per project (see CLAUDE_DB_PROTECT_DIRS in the header).
    // ================================================================
    const DB_DESTRUCTIVE_PATTERNS = [
      // SQL destructive statements
      { pattern: /DELETE\s+FROM\s+/i, label: 'SQL DELETE FROM' },
      { pattern: /DROP\s+(TABLE|SCHEMA|DATABASE|INDEX|VIEW|FUNCTION|TRIGGER|POLICY)/i, label: 'SQL DROP' },
      { pattern: /TRUNCATE\s+(TABLE\s+)?/i, label: 'SQL TRUNCATE' },
      { pattern: /ALTER\s+TABLE\s+\S+\s+DROP\s+COLUMN/i, label: 'SQL DROP COLUMN' },

      // Supabase JS SDK destructive calls: only match Supabase chain context, not generic JS .delete()
      { pattern: /supabase.*\.delete\(\)|\.from\s*\([^)]+\).*\.delete\(\)/i, label: 'Supabase .delete()' },
      { pattern: /admin\.deleteUser/i, label: 'Supabase admin.deleteUser()' },
      { pattern: /auth\.admin\.deleteUser/i, label: 'Supabase auth.admin.deleteUser()' },
      { pattern: /admin\.updateUserById\(.*\{.*banned/i, label: 'Supabase admin ban user' },

      // Supabase CLI destructive commands
      { pattern: /supabase\s+db\s+reset/i, label: 'Supabase DB reset' },
      { pattern: /supabase\s+db\s+push\s+--force/i, label: 'Supabase DB force push' },
      { pattern: /supabase\s+migration\s+repair/i, label: 'Supabase migration repair' },

      // psql / pg_dump destructive
      { pattern: /psql\s+.*-c\s+['"]?\s*DELETE/i, label: 'psql DELETE' },
      { pattern: /psql\s+.*-c\s+['"]?\s*DROP/i, label: 'psql DROP' },
      { pattern: /psql\s+.*-c\s+['"]?\s*TRUNCATE/i, label: 'psql TRUNCATE' },

      // Mass update without WHERE (dangerous), uses [\s\S]* to work across multiple lines
      { pattern: /UPDATE\s+\S+\s+SET\b(?![\s\S]*WHERE)/i, label: 'SQL UPDATE without WHERE clause' },
    ];

    // Scope: DB protection is opt-in. Sandboxes and unrelated repos do not need a blanket block.
    const cwd = cwdHint || process.cwd(); // payload cwd follows `cd` inside the session
    let dbProtected = process.env.CLAUDE_DB_PROTECT === "1";
    if (!dbProtected && process.env.CLAUDE_DB_PROTECT_DIRS) {
      try {
        dbProtected = new RegExp(process.env.CLAUDE_DB_PROTECT_DIRS, "i").test(cwd);
      } catch (e) {
        dbProtected = false; // invalid regex: ignore rather than block everything
      }
    }

    if (dbProtected) {
      for (const { pattern, label } of DB_DESTRUCTIVE_PATTERNS) {
        if (pattern.test(command)) {
          result.isValid = false;
          result.severity = 'CRITICAL';
          result.violations.push(
            `DATABASE PROTECTION: ${label} detected. ` +
            `Destructive DB operations are blocked in this project.` +
            (process.env.CLAUDE_DB_SAFE_TOOL
              ? ` Use the safe admin tool instead: ${process.env.CLAUDE_DB_SAFE_TOOL}`
              : ` Ask the user for explicit confirmation, or run it yourself outside the agent.`)
          );
        }
      }
    }

    // Additional safety checks
    if (command.length > 2000) {
      result.isValid = false;
      result.severity = "MEDIUM";
      result.violations.push("Command too long (potential buffer overflow)");
    }

    // Check for true binary content: null bytes and non-printable ASCII control chars only.
    // Deliberately excludes \x80-\xFF (Latin-1 extended, accented characters, HTML entities)
    // so that heredocs with HTML or non-English content are not blocked.
    if (/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/.test(command)) {
      result.isValid = false;
      result.severity = "HIGH";
      result.violations.push("Binary or encoded content detected");
    }

    return result;
  }

  /**
   * Log security events
   */
  logSecurityEvent(command, toolName, result, sessionId = null) {
    if (this.logDisabled) return;
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      sessionId,
      toolName,
      command: command.substring(0, 500), // Truncate for logs
      blocked: !result.isValid,
      severity: result.severity,
      violations: result.violations,
      source: "claude-code-hook",
    };

    try {
      // Ensure log directory exists
      const logDir = path.dirname(this.logFile);
      if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir, { recursive: true });
      }

      // Write to log file
      const logLine = JSON.stringify(logEntry) + "\n";
      fs.appendFileSync(this.logFile, logLine);

      // Also output to stderr for immediate visibility
      console.error(
        `[SECURITY] ${result.isValid ? "ALLOWED" : "BLOCKED"}: ${command.substring(0, 100)}`
      );
    } catch (error) {
      console.error("Failed to write security log:", error);
    }
  }
}

/**
 * Main execution function
 */
async function main() {
  const validator = new CommandValidator();

  try {
    // Read hook input from stdin
    let input = '';

    for await (const chunk of process.stdin) {
      input += chunk;
    }

    if (!input.trim()) {
      console.error("No input received from stdin");
      process.exit(1);
    }

    // Parse Claude Code hook JSON format
    let hookData;
    try {
      hookData = JSON.parse(input);
    } catch (error) {
      console.error("Invalid JSON input:", error.message);
      process.exit(1);
    }

    const toolName = hookData.tool_name || "Unknown";
    const toolInput = hookData.tool_input || {};
    const sessionId = hookData.session_id || null;

    // Only validate Bash commands for now
    if (toolName !== "Bash") {
      console.log(`Skipping validation for tool: ${toolName}`);
      process.exit(0);
    }

    const command = toolInput.command;
    if (!command) {
      console.error("No command found in tool input");
      process.exit(1);
    }

    // Validate the command
    const result = validator.validate(command, toolName, hookData.cwd);

    // Log the security event
    validator.logSecurityEvent(command, toolName, result, sessionId);

    // Output result and exit with appropriate code
    if (result.isValid) {
      console.log("Command validation passed");
      process.exit(0); // Allow execution
    } else {
      console.error(
        `Command validation failed: ${result.violations.join(", ")}`
      );
      console.error(`Severity: ${result.severity}`);
      process.exit(2); // Block execution (Claude Code requires exit code 2)
    }
  } catch (error) {
    console.error("Validation script error (allowing command):", error);
    // Fail open on script internal errors: a validator bug should not block all work
    // Dangerous commands are blocked by Claude Code's own permission system as fallback
    process.exit(0);
  }
}

// Execute main function
main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(2);
});
