#!/usr/bin/env node

/**
 * Safe DB Operation: generic destructive-operation gate
 *
 * This is a deliberately minimal, generic version. The project-specific
 * script it is modeled on hardcoded one product's table schema (table
 * names, columns, a single Supabase project). That cannot be shipped in a
 * public kit without re-exposing someone's schema, so this version is
 * config-driven instead: you describe your own tables in a JSON config
 * file, nothing about any real project is embedded here.
 *
 * What it guarantees:
 *   1. Dry-run by default. Without --execute, it only shows what a
 *      deletion WOULD touch (the record found + row counts in related
 *      tables) and never writes anything.
 *   2. Explicit confirmation. With --execute, it still prints the same
 *      plan, then generates a random code you must type back within
 *      30 seconds before any delete runs. There is no flag that skips
 *      the code.
 *   3. A journal. Every requested, cancelled or completed operation is
 *      appended as one JSON line to the log file, so there's always a
 *      record of who ran what and when (see CLAUDE_DB_SAFE_LOG below).
 *
 * Usage:
 *   node safe-db-operation.js <operation> <identifier> [--config path] [--execute]
 *
 * Example:
 *   node safe-db-operation.js delete-account user@example.com
 *   node safe-db-operation.js delete-account user@example.com --execute
 *
 * Config file (JSON; see safe-db-operation.config.example.json next to this
 * file). One operation = one main table + the related tables that cascade:
 *   {
 *     "operations": {
 *       "delete-account": {
 *         "table": "users",
 *         "idColumn": "id",
 *         "lookupColumn": "email",
 *         "relatedTables": [
 *           { "name": "orders", "column": "user_id" },
 *           { "name": "sessions", "column": "user_id" }
 *         ]
 *       }
 *     }
 *   }
 *
 * Env:
 *   CLAUDE_DB_SAFE_CONFIG   path to the config file
 *                           (default: ./safe-db-operation.config.json)
 *   CLAUDE_DB_SAFE_LOG      journal file (default: ~/.claude/data-operations.log)
 *   SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY
 *                           connection for the Supabase JS client. Swap
 *                           createClient() below for your own driver
 *                           (plain pg, Prisma, ...) if you are not on
 *                           Supabase, the confirmation/dry-run/log logic
 *                           around it does not change.
 *
 * This is the script global/hooks/validate-command.js points
 * CLAUDE_DB_SAFE_TOOL at: the hook blocks a raw destructive DB command
 * typed directly in Bash and tells the model to run this script instead,
 * so every destructive DB operation goes through the same gate.
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const readline = require('readline');

// ─── Config ─────────────────────────────────────────────────────────────────

const CONFIG_PATH =
  process.env.CLAUDE_DB_SAFE_CONFIG || path.join(process.cwd(), 'safe-db-operation.config.json');
const LOG_FILE =
  process.env.CLAUDE_DB_SAFE_LOG || path.join(os.homedir(), '.claude', 'data-operations.log');
const TIMEOUT_MS = 30_000;
const CODE_LENGTH = 6;

// ─── Helpers ────────────────────────────────────────────────────────────────

function generateCode() {
  return Math.random().toString().slice(2, 2 + CODE_LENGTH);
}

function log(entry) {
  const line = JSON.stringify({ ...entry, timestamp: new Date().toISOString() }) + '\n';
  try {
    fs.appendFileSync(LOG_FILE, line);
  } catch {
    fs.mkdirSync(path.dirname(LOG_FILE), { recursive: true });
    fs.appendFileSync(LOG_FILE, line);
  }
}

function loadConfig() {
  if (!fs.existsSync(CONFIG_PATH)) {
    console.error(`\x1b[31mNo config file at ${CONFIG_PATH}.\x1b[0m`);
    console.error('Copy safe-db-operation.config.example.json and describe your own tables, or set CLAUDE_DB_SAFE_CONFIG.');
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf-8'));
}

async function askUser(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => {
    const timer = setTimeout(() => {
      console.log('\n\x1b[31mTimeout: operation cancelled for safety.\x1b[0m');
      log({ action: 'TIMEOUT', question });
      rl.close();
      process.exit(1);
    }, TIMEOUT_MS);

    rl.question(question, (answer) => {
      clearTimeout(timer);
      rl.close();
      resolve(answer.trim());
    });
  });
}

function createClient() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) {
    console.error('\x1b[31mMissing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY.\x1b[0m');
    console.error('Swap createClient() for your own driver if you are not on Supabase.');
    process.exit(1);
  }
  const { createClient: createSupabaseClient } = require('@supabase/supabase-js');
  return createSupabaseClient(url, key);
}

// ─── Core flow ──────────────────────────────────────────────────────────────

async function run(operationName, identifier, { execute }) {
  const config = loadConfig();
  const op = config.operations && config.operations[operationName];
  if (!op) {
    console.error(`\x1b[31mUnknown operation "${operationName}".\x1b[0m`);
    console.error(`Defined in ${CONFIG_PATH}: ${Object.keys(config.operations || {}).join(', ') || '(none)'}`);
    process.exit(1);
  }

  const client = createClient();
  const { table, idColumn, lookupColumn, relatedTables = [] } = op;

  console.log('\n\x1b[36m━━━ SAFE DB OPERATION ━━━━━━━━━━━━━━━━━━━━━━━━━━━━\x1b[0m');
  console.log(`Operation: \x1b[1m${operationName}\x1b[0m   Looking up: \x1b[1m${identifier}\x1b[0m in \x1b[1m${table}\x1b[0m\n`);

  const lookupCol = lookupColumn || idColumn;
  const { data: rows, error } = await client.from(table).select('*').eq(lookupCol, identifier).limit(1);
  if (error) {
    console.error('\x1b[31mLookup failed:\x1b[0m', error.message);
    process.exit(1);
  }
  const record = rows && rows[0];
  if (!record) {
    console.log(`\x1b[33mNo row found for ${identifier} in ${table}.\x1b[0m`);
    process.exit(0);
  }
  const recordId = record[idColumn];

  console.log('\x1b[1mRecord found:\x1b[0m', JSON.stringify(record, null, 2), '\n');

  console.log('\x1b[1mRelated rows that would be affected:\x1b[0m');
  let totalRows = 0;
  const affected = [];
  for (const { name, column } of relatedTables) {
    const { data, error: relErr } = await client.from(name).select('*', { count: 'exact', head: true }).eq(column, recordId);
    if (relErr) {
      console.log(`  ${name}: \x1b[33m(error: ${relErr.message})\x1b[0m`);
      continue;
    }
    const count = (data && data.length) || 0;
    console.log(`  ${count > 0 ? '\x1b[31m' : ''}${name}: ${count} row(s)${count > 0 ? '\x1b[0m' : ''}`);
    if (count > 0) {
      affected.push({ name, column });
      totalRows += count;
    }
  }
  console.log(`\n  Total: ${totalRows} related row(s) across ${affected.length} table(s), + 1 row in ${table}\n`);

  log({ action: 'PLAN', operation: operationName, identifier, table, recordId, totalRows, execute: !!execute });

  if (!execute) {
    console.log('\x1b[90mDry-run only (default). Nothing was deleted. Re-run with --execute to proceed.\x1b[0m\n');
    process.exit(0);
  }

  const code = generateCode();
  console.log('\x1b[41m\x1b[37m\x1b[1m ⚠  DESTRUCTIVE OPERATION  \x1b[0m');
  console.log(`\x1b[31mThis will permanently delete the row above and all related rows listed.\x1b[0m`);
  console.log(`\x1b[31mThis action CANNOT be undone.\x1b[0m\n`);
  console.log(`To confirm, type this code: \x1b[1m\x1b[33m${code}\x1b[0m`);
  console.log('(You have 30 seconds)\n');

  log({ action: 'CONFIRMATION_REQUESTED', operation: operationName, identifier, code });

  const answer = await askUser('Confirmation code: ');
  if (answer !== code) {
    console.log('\n\x1b[32mWrong code, operation CANCELLED. Nothing was modified.\x1b[0m');
    log({ action: 'CANCELLED', operation: operationName, identifier, reason: 'wrong_code' });
    process.exit(0);
  }

  console.log('\n\x1b[33mDeleting...\x1b[0m');
  for (const { name, column } of affected) {
    const { error: delErr } = await client.from(name).delete().eq(column, recordId);
    console.log(`  ${name}: ${delErr ? '\x1b[31mERROR - ' + delErr.message + '\x1b[0m' : '\x1b[32mdeleted\x1b[0m'}`);
  }
  const { error: mainErr } = await client.from(table).delete().eq(idColumn, recordId);
  console.log(`  ${table}: ${mainErr ? '\x1b[31mERROR - ' + mainErr.message + '\x1b[0m' : '\x1b[32mdeleted\x1b[0m'}`);

  log({ action: 'COMPLETED', operation: operationName, identifier, recordId, totalRows });
  console.log(`\n\x1b[32mDone.\x1b[0m \x1b[90mLogged to ${LOG_FILE}\x1b[0m\n`);
}

// ─── CLI ────────────────────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);
  const execute = args.includes('--execute');
  const configIdx = args.indexOf('--config');
  if (configIdx !== -1 && args[configIdx + 1]) {
    process.env.CLAUDE_DB_SAFE_CONFIG = args[configIdx + 1];
  }
  const positional = args.filter((a, i) => !a.startsWith('--') && args[i - 1] !== '--config');
  const [operation, identifier] = positional;

  if (!operation || !identifier) {
    console.log('\nUsage: node safe-db-operation.js <operation> <identifier> [--config path] [--execute]\n');
    console.log('Dry-run by default (no --execute): shows the plan, deletes nothing.\n');
    process.exit(operation ? 1 : 0);
  }

  run(operation, identifier, { execute }).catch((err) => {
    console.error('\x1b[31mFatal error:\x1b[0m', err.message);
    log({ action: 'ERROR', operation, error: err.message });
    process.exit(1);
  });
}

if (require.main === module) {
  main();
}

module.exports = { loadConfig, CONFIG_PATH };
