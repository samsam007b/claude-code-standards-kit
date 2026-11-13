#!/usr/bin/env node

/**
 * Safe Database Operation Script: Data Protection Layer 1
 *
 * This script is the ONLY sanctioned way to perform destructive database
 * operations (delete user, drop table, etc.) from the terminal.
 *
 * Security features:
 *   1. Shows exactly what will be affected BEFORE any action
 *   2. Generates a random 6-digit confirmation code
 *   3. Requires the user to type the code to proceed
 *   4. Logs everything to ~/.claude/data-operations.log
 *   5. 30-second timeout: if no confirmation, operation is cancelled
 *
 * Usage:
 *   node ~/.claude/scripts/safe-db-operation.js delete-user <email>
 *   node ~/.claude/scripts/safe-db-operation.js delete-user <uuid>
 *
 * This script requires SUPABASE_SERVICE_ROLE_KEY in .env.local
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// ─── Config ─────────────────────────────────────────────────────────────────

const LOG_FILE = path.join(process.env.HOME, '.claude', 'data-operations.log');
const TIMEOUT_MS = 30_000; // 30 seconds to confirm
const CODE_LENGTH = 6;

// ─── Helpers ────────────────────────────────────────────────────────────────

function generateCode() {
  return Array.from({ length: CODE_LENGTH }, () => require('node:crypto').randomInt(10)).join('');
}

function log(entry) {
  const line = JSON.stringify({ ...entry, timestamp: new Date().toISOString() }) + '\n';
  try {
    fs.appendFileSync(LOG_FILE, line);
  } catch {
    // Log dir might not exist yet
    fs.mkdirSync(path.dirname(LOG_FILE), { recursive: true });
    fs.appendFileSync(LOG_FILE, line);
  }
}

function loadEnv() {
  // Walk up from cwd to find .env.local
  let dir = process.cwd();
  for (let i = 0; i < 10; i++) {
    const envPath = path.join(dir, '.env.local');
    if (fs.existsSync(envPath)) {
      const content = fs.readFileSync(envPath, 'utf-8');
      const vars = {};
      for (const line of content.split('\n')) {
        const match = line.match(/^([A-Z_]+)\s*=\s*"?([^"]*)"?$/);
        if (match) vars[match[1]] = match[2];
      }
      return vars;
    }
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return {};
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

function createSupabase(env) {
  const { createClient } = require(path.join(process.cwd(), 'node_modules', '@supabase/supabase-js'));
  return createClient(env.NEXT_PUBLIC_SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);
}

// ─── Operations ─────────────────────────────────────────────────────────────

async function deleteUser(identifier) {
  const env = loadEnv();
  if (!env.NEXT_PUBLIC_SUPABASE_URL || !env.SUPABASE_SERVICE_ROLE_KEY) {
    console.error('\x1b[31mMissing SUPABASE env vars. Run from project root with .env.local\x1b[0m');
    process.exit(1);
  }

  const supabase = createSupabase(env);

  // ── Step 1: Find user ──
  console.log('\n\x1b[36m━━━ SAFE DELETE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━\x1b[0m');
  console.log(`Looking up: \x1b[1m${identifier}\x1b[0m\n`);

  const { data: { users }, error } = await supabase.auth.admin.listUsers();
  if (error) { console.error('Error listing users:', error.message); process.exit(1); }

  const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);
  const user = users.find(u => isUUID ? u.id === identifier : u.email === identifier);

  if (!user) {
    console.log(`\x1b[33mUser "${identifier}" not found.\x1b[0m`);
    process.exit(0);
  }

  // ── Step 2: Show what will be affected ──
  console.log('\x1b[1mUser found:\x1b[0m');
  console.log(`  ID:         ${user.id}`);
  console.log(`  Email:      ${user.email}`);
  console.log(`  Created:    ${user.created_at}`);
  console.log(`  Last login: ${user.last_sign_in_at || 'never'}`);
  console.log('');

  const tables = [
    { name: 'users', col: 'id' },
    { name: 'user_profiles', col: 'user_id' },
    { name: 'property_members', col: 'user_id' },
    { name: 'properties', col: 'owner_id' },
    { name: 'conversations', col: 'user_id' },
    { name: 'messages', col: 'sender_id' },
    { name: 'rent_payment_declarations', col: 'user_id' },
    { name: 'matching_preferences', col: 'user_id' },
  ];

  console.log('\x1b[1mRelated data that will be deleted:\x1b[0m');
  let totalRows = 0;
  const affectedTables = [];
  for (const { name, col } of tables) {
    const { data, error: e } = await supabase.from(name).select('id', { count: 'exact' }).eq(col, user.id);
    const count = data?.length || 0;
    if (e && e.code !== '42P01') { // Ignore "table not found"
      console.log(`  ${name}: \x1b[33m(error: ${e.message})\x1b[0m`);
    } else if (count > 0) {
      console.log(`  \x1b[31m${name}: ${count} rows\x1b[0m`);
      affectedTables.push({ name, col, count });
      totalRows += count;
    } else {
      console.log(`  ${name}: 0 rows`);
    }
  }

  console.log(`\n  \x1b[1mTotal: ${totalRows} rows across ${affectedTables.length} tables\x1b[0m`);
  console.log(`  + 1 auth.users record\n`);

  // ── Step 3: Confirmation code ──
  const code = generateCode();
  console.log('\x1b[41m\x1b[37m\x1b[1m ⚠  DESTRUCTIVE OPERATION  \x1b[0m');
  console.log(`\x1b[31mThis will permanently delete ALL data for ${user.email}.\x1b[0m`);
  console.log(`\x1b[31mThis action CANNOT be undone.\x1b[0m\n`);
  console.log(`To confirm, type this code: \x1b[1m\x1b[33m${code}\x1b[0m`);
  console.log(`(You have 30 seconds)\n`);

  log({ action: 'DELETE_USER_REQUESTED', email: user.email, userId: user.id, totalRows });

  const answer = await askUser('Confirmation code: ');

  if (answer !== code) {
    console.log('\n\x1b[32mWrong code: operation CANCELLED. No data was modified.\x1b[0m');
    log({ action: 'DELETE_USER_CANCELLED', email: user.email, reason: 'wrong_code' });
    process.exit(0);
  }

  // ── Step 4: Execute deletion ──
  console.log('\n\x1b[33mDeleting...\x1b[0m');

  for (const { name, col } of affectedTables) {
    const { error: delErr } = await supabase.from(name).delete().eq(col, user.id);
    if (delErr) {
      console.log(`  ${name}: \x1b[31mERROR - ${delErr.message}\x1b[0m`);
    } else {
      console.log(`  ${name}: \x1b[32mdeleted\x1b[0m`);
    }
  }

  // Delete from users table if not already in affectedTables
  if (!affectedTables.find(t => t.name === 'users')) {
    const { error: userErr } = await supabase.from('users').delete().eq('id', user.id);
    console.log(`  users: ${userErr ? '\x1b[31mERROR - ' + userErr.message + '\x1b[0m' : '\x1b[32mdeleted\x1b[0m'}`);
  }

  // Delete auth user last
  const { error: authErr } = await supabase.auth.admin.deleteUser(user.id);
  console.log(`  auth.users: ${authErr ? '\x1b[31mERROR - ' + authErr.message + '\x1b[0m' : '\x1b[32mdeleted\x1b[0m'}`);

  log({ action: 'DELETE_USER_COMPLETED', email: user.email, userId: user.id, totalRows });

  console.log(`\n\x1b[32m${user.email} has been completely removed.\x1b[0m`);
  console.log(`\x1b[90mLogged to ${LOG_FILE}\x1b[0m\n`);
}

// ─── CLI Router ─────────────────────────────────────────────────────────────

const [,, operation, ...args] = process.argv;

const OPERATIONS = {
  'delete-user': {
    fn: deleteUser,
    usage: 'delete-user <email|uuid>',
    desc: 'Permanently delete a user and all related data',
  },
};

if (!operation || !OPERATIONS[operation]) {
  console.log('\n\x1b[36m━━━ SAFE DB OPERATIONS ━━━━━━━━━━━━━━━━━━━━━\x1b[0m\n');
  console.log('Available operations:\n');
  for (const [name, { usage, desc }] of Object.entries(OPERATIONS)) {
    console.log(`  node safe-db-operation.js ${usage}`);
    console.log(`    ${desc}\n`);
  }
  console.log('\x1b[90mAll operations require confirmation and are logged.\x1b[0m\n');
  process.exit(0);
}

OPERATIONS[operation].fn(args[0]).catch(err => {
  console.error('\x1b[31mFatal error:\x1b[0m', err.message);
  log({ action: 'ERROR', operation, error: err.message });
  process.exit(1);
});
