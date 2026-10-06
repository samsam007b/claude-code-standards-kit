#!/usr/bin/env node
/**
 * audit-page-overflow.mjs: detect content cut off at the bottom of a paginated HTML document.
 *
 * Usage: node audit-page-overflow.mjs <document.html> [--json] [--min=20] [--chrome=<path>]
 * Environment: CHROME_BIN (path to a Chrome/Chromium binary, optional)
 *
 * Not a hook. Run it by hand or from CI on documents meant for print/PDF.
 * Exit codes: 0 = no page cut, 2 = at least one page cut, 3 = inconclusive
 * (no Chrome, probe did not run, fonts not loaded). Never read 3 as green.
 *
 * Why this exists
 * ---------------
 * Document templates often set the page content container to `flex: 1; overflow: hidden`
 * and put the footer outside it. Anything that overflows is then cut with NO visible sign:
 * the footer renders fine, text-presence checks stay green, and pdftotext may even extract
 * the clipped text. Only a geometric measurement inside the rendering engine is reliable:
 *   - hard cut:   scrollHeight > clientHeight on the clipping container
 *   - tight page: distance between the last child's bottom and the container's bottom
 *
 * Zero npm dependencies: injects a probe into a temporary copy of the HTML, has headless
 * Chrome measure it, and reads the result back through the <title> via --dump-dom.
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
  console.error('Usage: node audit-page-overflow.mjs <document.html> [--json] [--min=20] [--chrome=<path>]')
  process.exit(1)
}
const filePath = resolve(file)
if (!existsSync(filePath)) {
  console.error(`File not found: ${filePath}`)
  process.exit(1)
}

const CHROMES = [
  chromeArg && chromeArg.slice(9),
  process.env.CHROME_BIN,
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/Applications/Chromium.app/Contents/MacOS/Chromium',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
  '/usr/bin/chromium-browser',
].filter(Boolean)
const chrome = CHROMES.find((p) => existsSync(p))
if (!chrome) {
  console.error('Chrome/Chromium not found. Cut-off check IMPOSSIBLE, do not conclude green.')
  process.exit(3)
}

// Probe injected into the page. Measures every clipping container (overflow != visible)
// large enough to be a page content area. Reports hard cut plus residual slack.
const PROBE = `
<script>
(function () {
  function measure(fontsReady) {
    var out = [];
    var all = document.querySelectorAll('body *');
    var pageSel = '[class*="page"], [class*="sheet"], [class*="a4"]';
    for (var i = 0; i < all.length; i++) {
      var el = all[i];
      var cs = getComputedStyle(el);
      if (cs.overflowY === 'visible') continue;
      if (el.clientHeight < 150) continue;          // too small to be a page content area
      if (!el.children.length) continue;

      var page = el.closest(pageSel) || el;
      var idx = Array.prototype.indexOf.call(document.querySelectorAll(pageSel), page);

      var padBottom = parseFloat(cs.paddingBottom) || 0;
      var clipped = Math.max(0, el.scrollHeight - el.clientHeight);

      // slack: container bottom minus bottom of the last visible child
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
    // Keep only the innermost container: the page wrapper encloses the content area and
    // would yield a second measurement that is always zero.
    var inner = out.filter(function (r) {
      return !out.some(function (o) { return o !== r && r.el.contains(o.el); });
    }).map(function (r) { delete r.el; return r; });
    document.title = '__OVF__' + JSON.stringify({ fontsReady: !!fontsReady, rows: inner }) + '__END__';
  }
  function go() {
    // Measuring BEFORE web fonts load skews every height: only report once fonts.ready resolves.
    var f = (document.fonts && document.fonts.ready) ? document.fonts.ready : Promise.resolve();
    f.then(function () { measure(true); }, function () { measure(false); });
  }
  if (document.readyState === 'complete') go();
  else window.addEventListener('load', go);
})();
</script>
`

// Probed copy, written next to the source so relative asset paths keep working.
const dir = dirname(filePath)
const probedPath = join(dir, `.ovf-probe-${process.pid}-${basename(filePath)}`)
let html = readFileSync(filePath, 'utf-8')
html = html.includes('</body>') ? html.replace('</body>', `${PROBE}</body>`) : html + PROBE
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
  console.error('Probe did not run (Chrome did not render the page). Check INCONCLUSIVE.')
  process.exit(3)
}

let payload
try {
  payload = JSON.parse(m[1].replace(/&quot;/g, '"').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>'))
} catch {
  console.error('Probe result unreadable. Check INCONCLUSIVE.')
  process.exit(3)
}
const rows = payload.rows || []
if (!payload.fontsReady) {
  console.error('Web fonts not loaded at measurement time: heights unreliable, check INCONCLUSIVE.')
  process.exit(3)
}

// One row per page: the most constrained container.
const byPage = new Map()
for (const r of rows) {
  const prev = byPage.get(r.page)
  if (!prev || (r.slack ?? 1e9) < (prev.slack ?? 1e9)) byPage.set(r.page, r)
}
const pages = [...byPage.values()].sort((a, b) => a.page - b.page)

// Slack threshold: absolute floor, raised to a quarter of the page's reserved bottom padding
// (a landscape page reserves less than a portrait one, so the threshold follows).
const threshold = (p) => Math.max(minSlack, Math.round(p.padBottom * 0.25))

// slack < 0 = content really outside the sheet, cut by overflow:hidden -> BLOCKING
// padBottom === 0 = full-bleed layout (cover, plate): content touches the edge by design.
const cut = pages.filter((p) => p.slack !== null && p.slack < 0)
const tight = pages.filter((p) => p.slack !== null && p.padBottom > 0 && p.slack >= 0 && p.slack < threshold(p))

if (asJson) {
  console.log(JSON.stringify({ file: basename(filePath), minSlack, pages, cut, tight }, null, 2))
  process.exit(cut.length ? 2 : 0)
}

const name = basename(filePath)
const bar = '='.repeat(66)
console.log('')
console.log(bar)
console.log(`  PAGE BOTTOM: ${name}`)
console.log(`  ${pages.length} page(s) measured, slack floor: ${minSlack}px, raised to a quarter of the reserve`)
console.log(bar)

if (cut.length) {
  console.log('')
  console.log(`  CONTENT CUT (${cut.length}), BLOCKING:`)
  for (const p of cut) {
    console.log(`  [x] page ${p.page}: ${-p.slack}px outside the sheet, cut without trace (${p.tag})`)
  }
  console.log('      Shorten the page or loosen the density (cell padding, line height).')
  console.log('      Checking that the text exists in the PDF proves NOTHING: overflow:hidden cuts')
  console.log('      at display time while pdftotext may still extract the text.')
}

if (tight.length) {
  console.log('')
  console.log(`  SLACK TOO LOW (${tight.length}), the last block almost touches the footer:`)
  for (const p of tight) {
    console.log(`  [!] page ${p.page}: ${p.slack}px below the last block, threshold ${threshold(p)}px (reserve ${p.padBottom}px)`)
  }
}

const ok = pages.filter((p) => !cut.includes(p) && !tight.includes(p))
if (ok.length) {
  console.log('')
  console.log(`  HEALTHY PAGES (${ok.length}):`)
  console.log(`  [ok] ${ok.map((p) => `${p.page}:${p.slack === null ? '-' : p.slack + 'px'}`).join('  ')}`)
}

const eaten = pages.filter((p) => p.clipped > 0 && !cut.includes(p))
if (eaten.length) {
  console.log('')
  console.log('  For information, pages that run into the bottom reserve:')
  console.log(`    ${eaten.map((p) => `${p.page} (${p.clipped}px)`).join(', ')}`)
}

console.log('')
console.log(`  VERDICT: ${cut.length ? 'BLOCKING, page(s) cut' : tight.length ? 'PASS, tighten margins' : 'PASS'}`)
console.log('')
console.log(bar)
console.log('')

process.exit(cut.length ? 2 : 0)
