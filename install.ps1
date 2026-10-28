# freebuff-superpowers installer for Windows PowerShell 5.1+.
#
# Copies the skills into .agents\skills (or ~\.agents\skills) and writes the bootstrap
# block into the project's AGENTS.md, replacing it in place on later runs.
[CmdletBinding()]
param(
  [switch]$Global,
  [string]$Dir = (Get-Location).Path,
  [switch]$NoBootstrap,
  [switch]$Force,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$StartMarker = '<!-- freebuff-superpowers:start -->'
$EndMarker = '<!-- freebuff-superpowers:end -->'
$SourceSkills = Join-Path $PSScriptRoot 'skills'
$SourceBootstrap = Join-Path $PSScriptRoot 'bootstrap.md'

if (-not (Test-Path $SourceBootstrap)) { throw "missing $SourceBootstrap" }
if (-not (Test-Path $SourceSkills)) { throw "missing $SourceSkills" }

function Get-BootstrapBlock([string]$SkillsRoot) {
  $text = [System.IO.File]::ReadAllText($SourceBootstrap)
  $match = [regex]::Match($text, '(?s)```markdown\r?\n(.*?)\r?\n```')
  if (-not $match.Success) { throw 'bootstrap.md has no fenced markdown example' }
  $block = $match.Groups[1].Value -replace "\r\n", "`n"
  # Keep the block's line endings consistent with a native Windows AGENTS.md.
  $block = $block -replace "`n", "`r`n"
  return $block.Replace('<SKILLS_ROOT>', $SkillsRoot)
}

function Write-Bootstrap([string]$File, [string]$SkillsRoot) {
  $block = Get-BootstrapBlock $SkillsRoot

  if (-not (Test-Path $File)) {
    if ($DryRun) { Write-Host 'AGENTS.md: would be created'; return }
    [System.IO.File]::WriteAllText($File, $block + "`r`n")
    Write-Host 'AGENTS.md: created'
    return
  }

  $current = [System.IO.File]::ReadAllText($File)
  $hasStart = $current.Contains($StartMarker)
  $hasEnd = $current.Contains($EndMarker)

  if ($hasStart -ne $hasEnd) {
    throw "$File has only one freebuff-superpowers marker. Remove the stray marker and run again."
  }

  if ($hasStart) {
    $start = $current.IndexOf($StartMarker)
    $end = $current.IndexOf($EndMarker) + $EndMarker.Length
    $next = $current.Substring(0, $start) + $block + $current.Substring($end)
    if ($next -eq $current) { Write-Host 'AGENTS.md: unchanged'; return }
    if ($DryRun) { Write-Host 'AGENTS.md: would be updated'; return }
    [System.IO.File]::WriteAllText($File, $next)
    Write-Host 'AGENTS.md: updated'
    return
  }

  $trimmed = $current.TrimEnd()
  $next = if ($trimmed.Length -gt 0) { $trimmed + "`r`n`r`n" + $block + "`r`n" } else { $block + "`r`n" }
  if ($DryRun) { Write-Host 'AGENTS.md: would be appended'; return }
  [System.IO.File]::WriteAllText($File, $next)
  Write-Host 'AGENTS.md: appended'
}

$skills = @(Get-ChildItem -Path $SourceSkills -Directory | Sort-Object Name)
if ($skills.Count -eq 0) { throw "no skills found in $SourceSkills" }
foreach ($skill in $skills) {
  if (-not (Test-Path (Join-Path $skill.FullName 'SKILL.md'))) {
    throw "skills/$($skill.Name) has no SKILL.md"
  }
}

if ($Global) {
  $target = Join-Path $HOME '.agents\skills'
  $skillsRoot = ((Join-Path $HOME '.agents/skills') -replace '\\', '/')
} else {
  $projectRoot = (Resolve-Path -Path $Dir).Path
  $target = Join-Path $projectRoot '.agents\skills'
  $skillsRoot = '.agents/skills'
}

Write-Host ("freebuff-superpowers: {0} skills ({1})" -f $skills.Count, (($skills | ForEach-Object { $_.Name }) -join ', '))
$suffix = if ($DryRun) { '  [dry run]' } else { '' }
Write-Host ("target:  {0}{1}" -f $target, $suffix)

if (-not $DryRun) {
  New-Item -ItemType Directory -Force -Path $target | Out-Null
}

foreach ($skill in $skills) {
  $destination = Join-Path $target $skill.Name
  $exists = Test-Path $destination

  if ($exists -and -not $Force) {
    Write-Host ("  = {0} (exists, kept -- use -Force to replace)" -f $skill.Name)
    continue
  }

  if ($exists) {
    Write-Host ("  ~ {0} (replaced)" -f $skill.Name)
    if (-not $DryRun) { Remove-Item -Recurse -Force $destination }
  } else {
    Write-Host ("  + {0}" -f $skill.Name)
  }

  if (-not $DryRun) {
    Copy-Item -Recurse -Force $skill.FullName $destination
  }
}

if ($NoBootstrap) {
  Write-Host 'AGENTS.md: skipped (-NoBootstrap)'
} else {
  $projectRoot = (Resolve-Path -Path $Dir).Path
  Write-Bootstrap (Join-Path $projectRoot 'AGENTS.md') $skillsRoot
}

if ($DryRun) {
  Write-Host ''
  Write-Host 'Dry run: nothing was written.'
  exit 0
}

Write-Host ''
Write-Host 'Next:'
Write-Host '  1. Start a new Freebuff session so the skills are discovered.'
Write-Host '  2. Confirm they loaded: /skill:brainstorming   (or /skill:using-superpowers)'
Write-Host '  3. Then just describe the work. The AGENTS.md block is what makes the agent reach'
Write-Host '     for a skill instead of jumping straight to code.'
