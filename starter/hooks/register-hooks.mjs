#!/usr/bin/env node
// Registers the two starter guardrails in ~/.claude/settings.json.
// Safe by design: backs up the file first, merges (never overwrites), idempotent, `--remove` undoes it.
// Usage: node register-hooks.mjs [--remove] [--dry-run] [--settings <path>]
import { readFileSync, writeFileSync, existsSync, copyFileSync, mkdirSync } from 'node:fs';
import { homedir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const args = process.argv.slice(2);
const remove = args.includes('--remove');
const dry = args.includes('--dry-run');
const si = args.indexOf('--settings');
const settingsPath = si >= 0 ? args[si + 1] : join(homedir(), '.claude', 'settings.json');
const here = dirname(fileURLToPath(import.meta.url));

const q = (p) => `"${p.replace(/"/g, '\\"')}"`;
const entries = [
  { matcher: 'Bash', file: 'guard-destructive.mjs' },
  { matcher: 'Write|Edit', file: 'guard-secrets.mjs' },
].map((e) => ({ matcher: e.matcher, command: `node ${q(join(here, e.file))}`, file: e.file }));

let settings = {};
if (existsSync(settingsPath)) {
  try { settings = JSON.parse(readFileSync(settingsPath, 'utf8')); }
  catch { console.error(`Cannot read ${settingsPath} as JSON. Nothing changed.`); process.exit(1); }
}
settings.hooks ??= {};
settings.hooks.PreToolUse ??= [];
const pre = settings.hooks.PreToolUse;
const isOurs = (h) => entries.some((e) => h.command?.includes(e.file));

let changed = 0;
if (remove) {
  for (const group of pre) {
    const before = group.hooks?.length ?? 0;
    group.hooks = (group.hooks ?? []).filter((h) => !isOurs(h));
    changed += before - group.hooks.length;
  }
  settings.hooks.PreToolUse = pre.filter((g) => (g.hooks ?? []).length > 0);
} else {
  for (const e of entries) {
    const present = pre.some((g) => (g.hooks ?? []).some((h) => h.command === e.command));
    if (present) continue;
    pre.push({ matcher: e.matcher, hooks: [{ type: 'command', command: e.command, timeout: 5 }] });
    changed++;
  }
}

if (changed === 0) { console.log(remove ? 'Nothing to remove.' : 'Guardrails already registered.'); process.exit(0); }
if (dry) { console.log(`[dry-run] would ${remove ? 'remove' : 'add'} ${changed} hook(s) in ${settingsPath}`); process.exit(0); }

mkdirSync(dirname(settingsPath), { recursive: true });
if (existsSync(settingsPath)) copyFileSync(settingsPath, `${settingsPath}.kit-backup`);
writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log(`${remove ? 'Removed' : 'Added'} ${changed} hook(s). Backup: ${settingsPath}.kit-backup`);
