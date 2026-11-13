# Starter setup for Claude Code (Windows). Stage 1: machine tier, native (no WSL2 needed).
# Stage 2 happens inside Claude Code with /welcome (or /pro-samuel).
#
# Usage: powershell -ExecutionPolicy Bypass -File .\setup.ps1 [-Lang en|fr] [-ProSamuel] [-DryRun]
#   -Lang       language of the messages (default: from the system culture, else en)
#   -ProSamuel  direct mode: one recap, one confirmation, no explanations
#   -DryRun     show what would be done, change nothing
# The advanced tier (19 bash hooks) needs WSL2: see docs/WINDOWS.md.
param(
  [ValidateSet('en','fr')][string]$Lang = $(if ((Get-Culture).TwoLetterISOLanguageName -eq 'fr') { 'fr' } else { 'en' }),
  [switch]$ProSamuel,
  [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function T($en, $fr) { if ($Lang -eq 'fr') { $fr } else { $en } }
function Say($en, $fr) { Write-Host (T $en $fr) }
function Run([scriptblock]$Block, [string]$Label) {
  if ($DryRun) { Write-Host "  [dry-run] $Label" } else { & $Block }
}
function Ask($en, $fr) {
  $a = Read-Host ("{0} [y/N]" -f (T $en $fr))
  return $a -match '^(y|yes|o|oui)$'
}

# id, winget id, command to test, description (en/fr)
$Tools = @(
  @{ Name='git';    Winget='Git.Git';              Cmd='git';
     En='Git: records every version of your files so you can go back.';
     Fr="Git : garde toutes les versions de vos fichiers pour pouvoir revenir en arriere." },
  @{ Name='node';   Winget='OpenJS.NodeJS.LTS';    Cmd='node';
     En='Node.js: the engine Claude Code and Playwright run on.';
     Fr="Node.js : le moteur sur lequel tournent Claude Code et Playwright." },
  @{ Name='python'; Winget='Python.Python.3.12';   Cmd='python';
     En='Python: a language many scripts and tools use.';
     Fr="Python : un langage utilise par de nombreux scripts et outils." },
  @{ Name='claude'; Winget=$null;                  Cmd='claude';
     En='Claude Code: the assistant itself, in your terminal.';
     Fr="Claude Code : l'assistant lui-meme, dans votre terminal." }
)

function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

function Install-Tool($tool) {
  if ($tool.Name -eq 'claude') {
    Run { npm install -g '@anthropic-ai/claude-code' } 'npm install -g @anthropic-ai/claude-code'
  } else {
    Run { winget install --id $tool.Winget -e --accept-source-agreements --accept-package-agreements } "winget install $($tool.Winget)"
  }
}

if (-not (Have 'winget')) {
  Say 'winget is missing. Update "App Installer" from the Microsoft Store, then rerun this script.' `
      'winget est absent. Mettez a jour "Programme d''installation d''application" depuis le Microsoft Store, puis relancez ce script.'
  exit 1
}

Say 'Checking your machine...' 'Verification de votre machine...'
$Missing = @()
foreach ($tool in $Tools) {
  if (Have $tool.Cmd) { Write-Host "  ok  $($tool.Name)" } else { Write-Host "  --  $($tool.Name)"; $Missing += $tool }
}

if ($Missing.Count -gt 0) {
  if ($ProSamuel) {
    Write-Host ((T 'To install: ' 'A installer : ') + ($Missing.Name -join ', '))
    if (Ask 'Proceed?' 'Continuer ?') {
      foreach ($tool in $Missing) { Install-Tool $tool }
    } else { Say 'Stopped, nothing changed.' 'Arret, rien n''a ete modifie.'; exit 0 }
  } else {
    foreach ($tool in $Missing) {
      Write-Host ''
      Write-Host (T $tool.En $tool.Fr)
      if (Ask 'Install it?' 'L''installer ?') { Install-Tool $tool }
      else { Say 'Skipped. Claude Code needs git, node and claude to work fully.' 'Ignore. Claude Code a besoin de git, node et claude pour fonctionner pleinement.' }
    }
  }
  Say 'If a tool is not found afterwards, close and reopen the terminal (the PATH refreshes).' `
      'Si un outil reste introuvable ensuite, fermez et rouvrez le terminal (le PATH se met a jour).'
} else {
  Say 'Everything needed is already installed.' 'Tout le necessaire est deja installe.'
}

# Starter skills and glossary: copied, never overwritten.
$Dest = Join-Path $HOME '.claude'
function Copy-New($src, $dst) {
  if (Test-Path $dst) { Write-Host "  keep  $dst" }
  else {
    Run { New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null; Copy-Item -Recurse $src $dst } "copy $src -> $dst"
    Write-Host "  add   $dst"
  }
}
Write-Host ''
Say 'Adding the starter skills...' 'Ajout des skills de demarrage...'
foreach ($s in 'welcome','explain','pro-samuel') { Copy-New (Join-Path $Root "skills\$s") (Join-Path $Dest "skills\$s") }
Copy-New (Join-Path $Root 'docs\glossary') (Join-Path $Dest 'kit\glossary')
Copy-New (Join-Path $Root 'starter\hooks') (Join-Path $Dest 'kit\hooks')   # guardrails: registered later by /welcome, only after a yes

# Minimal profile, only if none exists. /welcome completes it.
$Profile = Join-Path $Dest 'kit\profile.json'
if (-not (Test-Path $Profile)) {
  $mode = if ($ProSamuel) { 'pro' } else { 'learner' }
  $json = [ordered]@{ language=$Lang; mode=$mode; level=$null; terms_seen=@() } | ConvertTo-Json
  Run { New-Item -ItemType Directory -Force -Path (Split-Path $Profile) | Out-Null; Set-Content -Path $Profile -Value $json -Encoding UTF8 } "write $Profile"
}

Write-Host ''
if ($ProSamuel) { Say 'Done. Run: claude   then type: /pro-samuel' 'Termine. Lancez : claude   puis tapez : /pro-samuel' }
else            { Say 'Done. Run: claude   then type: /welcome'    'Termine. Lancez : claude   puis tapez : /welcome' }
