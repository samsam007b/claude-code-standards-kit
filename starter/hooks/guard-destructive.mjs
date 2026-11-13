#!/usr/bin/env node
// Guardrail 1: blocks destructive shell commands before Claude runs them.
// Claude Code passes the tool call as JSON on stdin. Exit 2 = block, stderr = message shown to Claude.
// Plain Node, no dependencies: works the same on macOS, Linux and Windows.
import { readFileSync, existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

export const RULES = [
  { id: 'rm-root-home', re: /\brm\s+(-[a-zA-Z]*[rf][a-zA-Z]*\s+)+(\/|~|\$HOME|\*)\/?\*?(\s|$)/,
    en: 'Deleting the root, your home folder or everything in the current folder.',
    fr: "Suppression de la racine, de votre dossier personnel ou de tout le dossier courant." },
  { id: 'git-force-main', re: /\bgit\s+push\b[^\n]*(--force\b|-f\b)[^\n]*\b(main|master)\b|\bgit\s+push\b[^\n]*\b(main|master)\b[^\n]*(--force\b|\s-f\b)/,
    en: 'Force-pushing to main or master rewrites shared history.',
    fr: "Un push forcé sur main ou master réécrit l'historique partagé." },
  { id: 'git-reset-hard', re: /\bgit\s+reset\s+--hard\b/,
    en: 'git reset --hard throws away uncommitted work for good.',
    fr: "git reset --hard supprime définitivement le travail non enregistré." },
  { id: 'sql-drop', re: /\bdrop\s+(database|table|schema)\b/i,
    en: 'Dropping a database, table or schema.',
    fr: "Suppression d'une base, d'une table ou d'un schéma." },
  { id: 'chmod-777', re: /\bchmod\s+(-R\s+)?777\b/,
    en: 'chmod 777 gives everyone full access to the files.',
    fr: "chmod 777 donne à tout le monde un accès complet aux fichiers." },
  { id: 'pipe-to-shell', re: /\b(curl|wget)\b[^\n|]*\|\s*(sudo\s+)?(ba|z)?sh\b/,
    en: 'Running a downloaded script without reading it first (curl | sh).',
    fr: "Exécution d'un script téléchargé sans l'avoir lu (curl | sh)." },
  { id: 'disk-write', re: /\b(mkfs(\.\w+)?|dd\s+[^\n]*of=\/dev\/)/,
    en: 'Writing directly to a disk device.',
    fr: "Écriture directe sur un disque." },
  { id: 'win-format-del', re: /\b(format\s+[a-z]:|del\s+\/[sq]\s+[^\n]*[a-z]:\\|rd\s+\/s\s+\/q\s+[a-z]:\\)/i,
    en: 'Wiping a Windows drive or folder tree.',
    fr: "Effacement d'un lecteur ou d'une arborescence Windows." },
];

// Normalise so quoting, ${HOME} and long options do not slip past the patterns.
export function normalize(command) {
  return command
    .replace(/["']/g, '')
    .replace(/\$\{HOME\}/g, '$HOME')
    .replace(/--recursive\b/g, '-r')
    .replace(/--force\b/g, '-f')
    .replace(/(\bgit\s+push\b[^\n]*\s)\+(\S*\b(main|master)\b)/g, '$1-f $2')
    .replace(/refs\/heads\//g, '');
}

export function check(command) {
  const norm = normalize(command);
  for (const r of RULES) if (r.re.test(command) || r.re.test(norm)) return r;
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
  const command = input?.tool_input?.command;
  if (typeof command !== 'string') process.exit(0);
  const hit = check(command);
  if (!hit) process.exit(0);
  const lang = language();
  const head = lang === 'fr' ? 'Commande bloquée par le garde-fou' : 'Command blocked by the guardrail';
  const tail = lang === 'fr'
    ? "Si c'est voulu, expliquez pourquoi à l'utilisateur et laissez-le lancer la commande lui-même. Voir /explain guardrail."
    : 'If this is really intended, explain why to the user and let them run it themselves. See /explain guardrail.';
  process.stderr.write(`${head} (${hit.id}): ${hit[lang]}\n${tail}\n`);
  process.exit(2);
}

if (import.meta.url === `file://${process.argv[1]}` || process.argv[1]?.endsWith('guard-destructive.mjs')) main();
