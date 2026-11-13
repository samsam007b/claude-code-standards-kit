#!/usr/bin/env node
/**
 * audit-page-overflow.mjs: detects content truncated at the bottom of the page in a paginated HTML
 * Usage: node audit-page-overflow.mjs <document.html> [--json] [--min=20] [--chrome=<path>]
 *
 * Why this script exists
 * ----------------------
 * Document templates set the content container to `flex:1; overflow:hidden`
 * and place the page footer outside that container. As a result, anything that overflows is cut
 * WITHOUT ANY SIGN. The footer still renders perfectly, scores stay green,
 * and pdftotext sometimes still extracts the cut text. A text-presence check
 * therefore sees nothing wrong.
 *
 * The only reliable measure is geometric, inside the rendering engine:
 *   - hard truncation: scrollHeight > clientHeight on the clipping container
 *   - page too tight: distance between the bottom of the last child and the bottom of the container
 *
 * Zero npm dependencies: injects a probe into a temporary copy of the HTML, has it measured
 * by headless Chrome, and retrieves the result via the <title> with --dump-dom.
 *
 * Exit codes: 0 = no page cut · 2 = at least one page cut
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
  console.error(`File not found: ${filePath}`)
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
  console.error('Chrome/Chromium not found. Truncation check IMPOSSIBLE, do not conclude it is green.')
  process.exit(3)
}

// ── Probe injected into the page ───────────────────────────────────────────
// Measures each container that clips (overflow != visible) and is large enough to
// be a page content area. Returns hard truncation + residual margin.
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
      if (el.clientHeight < 150) continue;          // too small to be a page area
      if (!el.children.length) continue;

      // page index: rank of the nearest page container
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

      // residual margin: container bottom minus bottom of the last visible child
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
    // keep only the innermost container: the page wrapper encloses
    // the content area and would produce a second measurement, always zero
    var inner = out.filter(function (r) {
      return !out.some(function (o) { return o !== r && r.el.contains(o.el); });
    }).map(function (r) { delete r.el; return r; });
    document.title = '__OVF__' + JSON.stringify({ fontsReady: !!fontsReady, rows: inner }) + '__END__';
  }
  function go() {
    // Measuring BEFORE web fonts load skews the whole height calculation:
    // the result is only written once document.fonts.ready has resolved.
    var f = (document.fonts && document.fonts.ready) ? document.fonts.ready : Promise.resolve();
    f.then(function () { measure(true); }, function () { measure(false); });
  }
  if (document.readyState === 'complete') go();
  else window.addEventListener('load', go);
})();
</script>
`

// ── Probed copy, in the source folder to keep relative paths ──
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
  console.error('Probe not executed (Chrome did not render the page). Check INCONCLUSIVE.')
  process.exit(3)
}

let payload
try {
  payload = JSON.parse(m[1].replace(/&quot;/g, '"').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>'))
} catch {
  console.error('Unreadable probe result. Check INCONCLUSIVE.')
  process.exit(3)
}
const rows = payload.rows || []
if (!payload.fontsReady) {
  console.error('Web fonts not loaded at measurement time: unreliable heights, check INCONCLUSIVE.')
  process.exit(3)
}

// One row per page: the most constrained container
const byPage = new Map()
for (const r of rows) {
  const prev = byPage.get(r.page)
  if (!prev || (r.slack ?? 1e9) < (prev.slack ?? 1e9)) byPage.set(r.page, r)
}
const pages = [...byPage.values()].sort((a, b) => a.page - b.page)

// Margin threshold: absolute floor, raised to a quarter of the reserve planned by the page.
// A landscape page reserves less than a portrait page, the threshold follows.
const threshold = (p) => Math.max(minSlack, Math.round(p.padBottom * 0.25))

// slack < 0  = content really off the sheet, cut by overflow:hidden  → BLOCKING
// eaten > 0  = content that has moved into the bottom-of-page reserve → information
const cut = pages.filter((p) => p.slack !== null && p.slack < 0)
// padBottom === 0: full-page layout (cover, plate), the content touches
// the edge by design, no margin to require.
const tight = pages.filter((p) => p.slack !== null && p.padBottom > 0 && p.slack >= 0 && p.slack < threshold(p))

if (asJson) {
  console.log(JSON.stringify({ file: basename(filePath), minSlack, pages, cut, tight }, null, 2))
  process.exit(cut.length ? 2 : 0)
}

const name = basename(filePath)
console.log('')
console.log('╔══════════════════════════════════════════════════════════════════')
console.log(`║  PAGE BOTTOM: ${name}`)
console.log(`║  ${pages.length} page(s) measured · margin floor: ${minSlack}px, raised to a quarter of the reserve`)
console.log('╠══════════════════════════════════════════════════════════════════')

if (cut.length) {
  console.log('║')
  console.log(`║  CUT CONTENT (${cut.length}), BLOCKING:`)
  for (const p of cut) {
    console.log(`║  ✗ page ${p.page}: ${-p.slack}px off the sheet, cut without a trace (${p.tag})`)
  }
  console.log('║    → shorten the page, or loosen the density (cell padding, line spacing).')
  console.log('║      Checking that the text is present in the PDF proves NOTHING: overflow:hidden cuts')
  console.log('║      at display time while pdftotext still extracts the text.')
}

if (tight.length) {
  console.log('║')
  console.log(`║  MARGIN TOO SMALL (${tight.length}): the last block almost touches the page footer:`)
  for (const p of tight) {
    console.log(`║  ⚠ page ${p.page}: ${p.slack}px below the last block, threshold ${threshold(p)}px (planned reserve ${p.padBottom}px)`)
  }
}

const ok = pages.filter((p) => !cut.includes(p) && !tight.includes(p))
if (ok.length) {
  console.log('║')
  console.log(`║  HEALTHY PAGES (${ok.length}):`)
  console.log(`║  ✓ ${ok.map((p) => `${p.page}:${p.slack === null ? '-' : p.slack + 'px'}`).join('  ')}`)
}

const eaten = pages.filter((p) => p.clipped > 0 && !cut.includes(p))
if (eaten.length) {
  console.log('║')
  console.log(`║  For information, pages that extend into the bottom-of-page reserve:`)
  console.log(`║    ${eaten.map((p) => `${p.page} (${p.clipped}px)`).join(', ')}`)
}

console.log('║')
console.log(`║  VERDICT: ${cut.length ? 'BLOCKING, page(s) cut' : tight.length ? 'PASS, margins to tighten' : 'PASS'}`)
console.log('║')
console.log('╚══════════════════════════════════════════════════════════════════')
console.log('')

process.exit(cut.length ? 2 : 0)
