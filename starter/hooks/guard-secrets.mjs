#!/usr/bin/env node
// Guardrail 2: stops Claude from writing a real-looking secret (API key, token, private key) into a file.
// Secrets belong in a .env file that is listed in .gitignore, never in code or notes you may share.
// Exit 2 = block. Plain Node, no dependencies, works on macOS, Linux and Windows.
import { readFileSync, existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join, basename } from 'node:path';

export const PATTERNS = [
  { id: 'anthropic-key', re: /sk-ant-[A-Za-z0-9_-]{20,}/ },
  { id: 'openai-style-key', re: /\bsk-[A-Za-z0-9]{32,}\b/ },
  { id: 'github-token', re: /\bgh[pousr]_[A-Za-z0-9]{30,}\b/ },
  { id: 'aws-access-key', re: /\bAKIA[0-9A-Z]{16}\b/ },
  { id: 'google-api-key', re: /\bAIza[0-9A-Za-z_-]{35}\b/ },
  { id: 'slack-token', re: /\bxox[baprs]-[A-Za-z0-9-]{10,}\b/ },
  { id: 'private-key', re: /-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----/ },
];

// Files where secrets are expected to live.
export function isSecretsFile(path) {
  const n = basename(path || '');
  return /^\.env(\.(local|development|production|test|staging)(\.local)?)?$/.test(n);
}

export function check(path, content) {
  if (isSecretsFile(path)) return null;
  for (const p of PATTERNS) if (p.re.test(content)) return p;
  return null;
}

function language() {
  try {
    const p = join(homedir(), '.claude', 'kit', 'profile.json');
    if (existsSync(p)) return JSON.parse(readFileSync(p, 'utf8')).language === 'fr' ? 'fr' : 'en';
  } catch { /* default */ }
  return 'en';
}

function main() {
  let input = {};
  try { input = JSON.parse(readFileSync(0, 'utf8')); } catch { process.exit(0); }
  const ti = input?.tool_input ?? {};
  const edits = Array.isArray(ti.edits) ? ti.edits.map((e) => e?.new_string) : [];
  const content = [ti.content, ti.new_string, ti.new_source, ...edits].filter((x) => typeof x === 'string').join('\n');
  if (!content) process.exit(0);
  const hit = check(ti.file_path ?? ti.notebook_path, content);
  if (!hit) process.exit(0);
  const msg = language() === 'fr'
    ? `Écriture bloquée (${hit.id}) : le texte ressemble à un vrai secret. Rangez-le dans un fichier .env listé dans .gitignore et lisez-le depuis une variable d'environnement. Voir /explain guardrail.`
    : `Write blocked (${hit.id}): the text looks like a real secret. Put it in a .env file listed in .gitignore and read it from an environment variable. See /explain guardrail.`;
  process.stderr.write(msg + '\n');
  process.exit(2);
}

if (import.meta.url === `file://${process.argv[1]}` || process.argv[1]?.endsWith('guard-secrets.mjs')) main();
