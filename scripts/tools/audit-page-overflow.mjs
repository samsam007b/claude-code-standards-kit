#!/usr/bin/env node
/**
 * audit-page-overflow.mjs — Détecte le contenu tronqué par le bas de page dans un HTML paginé
 * Usage : node audit-page-overflow.mjs <document.html> [--json] [--min=20] [--chrome=<path>]
 *
 * Pourquoi ce script existe
 * -------------------------
 * Les templates documentaires posent le conteneur de contenu en `flex:1; overflow:hidden`
 * et sortent le pied de page de ce conteneur. Conséquence : tout ce qui dépasse est coupé
 * SANS AUCUN SIGNE. Le pied de page reste parfaitement rendu, les scores restent au vert,
 * et pdftotext extrait parfois quand même le texte coupé. Un contrôle par présence de texte
 * ne voit donc rien (incident CG-PAID-002, pages 3, 12 et 17, septembre 2026).
 *
 * La seule mesure fiable est géométrique, dans le moteur de rendu :
 *   - troncature dure  : scrollHeight > clientHeight sur le conteneur qui clippe
 *   - page trop serrée : distance entre le bas du dernier enfant et le bas du conteneur
 *
 * Zéro dépendance npm : injecte une sonde dans une copie temporaire du HTML, la fait mesurer
 * par Chrome headless, et récupère le résultat via le <title> avec --dump-dom.
 *
 * Codes de sortie : 0 = aucune page coupée · 2 = au moins une page coupée
 */

import { readFileSync, writeFileSync, existsSync, rmSync } from 'fs'
import { execFileSync } from 'child_process'
import { resolve, dirname, basename, join } from 'path'

const args = process.argv.slice(2)
const file = args.find((a) => !a.startsWith('--'))
const asJson = args.includes('--json')
const minSlack = Number((args.find((a) => a.startsWith('--min=')) || '--min=20').slice(6))
const chromeArg = args.find((a) => a.startsWith('--chrome='))

if (!file) {
  console.error('Usage: node audit-page-overflow.mjs <document.html> [--json] [--min=20]')
  process.exit(1)
}
const filePath = resolve(file)
if (!existsSync(filePath)) {
  console.error(`Fichier introuvable : ${filePath}`)
  process.exit(1)
}

const CHROMES = [
  chromeArg && chromeArg.slice(9),
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/Applications/Chromium.app/Contents/MacOS/Chromium',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
].filter(Boolean)
const chrome = CHROMES.find((p) => existsSync(p))
if (!chrome) {
  console.error('Chrome/Chromium introuvable. Contrôle de troncature IMPOSSIBLE, ne pas conclure au vert.')
  process.exit(3)
}

// ── Sonde injectée dans la page ────────────────────────────────────────────
// Mesure chaque conteneur qui clippe (overflow != visible) et assez grand pour
// être une zone de contenu de page. Retourne troncature dure + marge résiduelle.
const PROBE = `
<script>
(function () {
  function measure(fontsReady) {
    var out = [];
    var all = document.querySelectorAll('body *');
    for (var i = 0; i < all.length; i++) {
      var el = all[i];
      var cs = getComputedStyle(el);
      var oy = cs.overflowY;
      if (oy === 'visible') continue;
      if (el.clientHeight < 150) continue;          // trop petit pour être une zone de page
      if (!el.children.length) continue;

      // index de page : rang du conteneur de page le plus proche
      var page = el.closest('[class*="page"], [class*="sheet"], [class*="a4"]') || el;
      var siblings = page.parentElement
        ? Array.prototype.filter.call(page.parentElement.children, function (n) {
            return n.className && String(n.className) === String(page.className);
          })
        : [];
      var idx = Array.prototype.indexOf.call(
        document.querySelectorAll('[class*="page"], [class*="sheet"], [class*="a4"]'), page
      );

      var padBottom = parseFloat(cs.paddingBottom) || 0;
      var clipped = Math.max(0, el.scrollHeight - el.clientHeight);

      // marge résiduelle : bas du conteneur moins bas du dernier enfant visible
      var box = el.getBoundingClientRect();
      var lastBottom = -Infinity;
      for (var k = 0; k < el.children.length; k++) {
        var r = el.children[k].getBoundingClientRect();
        if (r.height === 0 && r.width === 0) continue;
        if (r.bottom > lastBottom) lastBottom = r.bottom;
      }
      var slack = lastBottom === -Infinity ? null : Math.round(box.bottom - lastBottom);

      out.push({
        el: el,
        page: idx + 1,
        tag: el.tagName.toLowerCase() + (el.className ? '.' + String(el.className).trim().split(/\\s+/).join('.') : ''),
        clipped: Math.round(clipped),
        slack: slack,
        padBottom: Math.round(padBottom),
        height: Math.round(el.clientHeight)
      });
    }
    // ne garder que le conteneur le plus interne : le wrapper de page englobe
    // la zone de contenu et produirait une seconde mesure, toujours à zéro
    var inner = out.filter(function (r) {
      return !out.some(function (o) { return o !== r && r.el.contains(o.el); });
    }).map(function (r) { delete r.el; return r; });
    document.title = '__OVF__' + JSON.stringify({ fontsReady: !!fontsReady, rows: inner }) + '__END__';
  }
  function go() {
    // Mesurer AVANT le chargement des polices web fausse tout le calcul de hauteur :
    // on n'écrit le résultat qu'une fois document.fonts.ready résolu.
    var f = (document.fonts && document.fonts.ready) ? document.fonts.ready : Promise.resolve();
    f.then(function () { measure(true); }, function () { measure(false); });
  }
  if (document.readyState === 'complete') go();
  else window.addEventListener('load', go);
})();
</script>
`

// ── Copie sondée, dans le dossier source pour garder les chemins relatifs ──
const dir = dirname(filePath)
const probedPath = join(dir, `.ovf-probe-${process.pid}-${basename(filePath)}`)
let html = readFileSync(filePath, 'utf-8')
html = html.includes('</body>')
  ? html.replace('</body>', `${PROBE}</body>`)
  : html + PROBE
writeFileSync(probedPath, html)

let dom = ''
try {
  dom = execFileSync(
    chrome,
    [
      '--headless',
      '--disable-gpu',
      '--no-sandbox',
      '--hide-scrollbars',
      '--no-first-run',
      '--no-default-browser-check',
      '--virtual-time-budget=8000',
      '--dump-dom',
      `file://${probedPath}`,
    ],
    { encoding: 'utf-8', maxBuffer: 1024 * 1024 * 64, stdio: ['ignore', 'pipe', 'ignore'] }
  )
} catch (e) {
  dom = (e.stdout || '').toString()
} finally {
  rmSync(probedPath, { force: true })
}

const m = dom.match(/__OVF__(.*?)__END__/s)
if (!m) {
  console.error('Sonde non exécutée (Chrome n\'a pas rendu la page). Contrôle NON concluant.')
  process.exit(3)
}

let payload
try {
  payload = JSON.parse(m[1].replace(/&quot;/g, '"').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>'))
} catch {
  console.error('Résultat de sonde illisible. Contrôle NON concluant.')
  process.exit(3)
}
const rows = payload.rows || []
if (!payload.fontsReady) {
  console.error('Polices web non chargées au moment de la mesure : hauteurs non fiables, contrôle NON concluant.')
  process.exit(3)
}

// Une seule ligne par page : le conteneur le plus contraint
const byPage = new Map()
for (const r of rows) {
  const prev = byPage.get(r.page)
  if (!prev || (r.slack ?? 1e9) < (prev.slack ?? 1e9)) byPage.set(r.page, r)
}
const pages = [...byPage.values()].sort((a, b) => a.page - b.page)

// Seuil de marge : plancher absolu, relevé au quart de la réserve prévue par la page.
// Une page paysage réserve moins qu'une page portrait, le seuil suit.
const threshold = (p) => Math.max(minSlack, Math.round(p.padBottom * 0.25))

// slack < 0  = contenu réellement hors feuille, coupé par overflow:hidden  → BLOQUANT
// eaten > 0  = contenu descendu dans la réserve de bas de page             → information
const cut = pages.filter((p) => p.slack !== null && p.slack < 0)
// padBottom === 0 : mise en page pleine page (couverture, planche), le contenu touche
// le bord par construction, pas de marge à exiger.
const tight = pages.filter((p) => p.slack !== null && p.padBottom > 0 && p.slack >= 0 && p.slack < threshold(p))

if (asJson) {
  console.log(JSON.stringify({ file: basename(filePath), minSlack, pages, cut, tight }, null, 2))
  process.exit(cut.length ? 2 : 0)
}

const name = basename(filePath)
console.log('')
console.log('╔══════════════════════════════════════════════════════════════════')
console.log(`║  BAS DE PAGE — ${name}`)
console.log(`║  ${pages.length} page(s) mesurée(s) · plancher de marge : ${minSlack}px, relevé au quart de la réserve`)
console.log('╠══════════════════════════════════════════════════════════════════')

if (cut.length) {
  console.log('║')
  console.log(`║  CONTENU COUPÉ (${cut.length}) — BLOQUANT :`)
  for (const p of cut) {
    console.log(`║  ✗ page ${p.page} : ${-p.slack}px hors feuille, coupés sans trace (${p.tag})`)
  }
  console.log('║    → raccourcir la page, ou desserrer la densité (padding des cellules, interlignes).')
  console.log('║      Vérifier la présence du texte dans le PDF ne prouve RIEN : overflow:hidden coupe')
  console.log('║      à l\'affichage alors que pdftotext extrait encore le texte.')
}

if (tight.length) {
  console.log('║')
  console.log(`║  MARGE TROP FAIBLE (${tight.length}) — le dernier bloc touche presque le pied de page :`)
  for (const p of tight) {
    console.log(`║  ⚠ page ${p.page} : ${p.slack}px sous le dernier bloc, seuil ${threshold(p)}px (réserve prévue ${p.padBottom}px)`)
  }
}

const ok = pages.filter((p) => !cut.includes(p) && !tight.includes(p))
if (ok.length) {
  console.log('║')
  console.log(`║  PAGES SAINES (${ok.length}) :`)
  console.log(`║  ✓ ${ok.map((p) => `${p.page}:${p.slack === null ? '-' : p.slack + 'px'}`).join('  ')}`)
}

const eaten = pages.filter((p) => p.clipped > 0 && !cut.includes(p))
if (eaten.length) {
  console.log('║')
  console.log(`║  Pour information, pages qui descendent dans la réserve de bas de page :`)
  console.log(`║    ${eaten.map((p) => `${p.page} (${p.clipped}px)`).join(', ')}`)
}

console.log('║')
console.log(`║  VERDICT : ${cut.length ? 'BLOQUANT, page(s) coupée(s)' : tight.length ? 'PASSE, marges à resserrer' : 'PASSE'}`)
console.log('║')
console.log('╚══════════════════════════════════════════════════════════════════')
console.log('')

process.exit(cut.length ? 2 : 0)
