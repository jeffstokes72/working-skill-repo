param()

$ErrorActionPreference = "Stop"

function Write-TextFile {
  param([string]$Path, [string]$Text)
  $dir = Split-Path $Path -Parent
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
  $Text | Set-Content -Path $Path -Encoding UTF8
}

function Assert-Class {
  param($Report, [string]$Skill, [string]$Expected)
  $row = @($Report.rows | Where-Object { $_.skill -eq $Skill }) | Select-Object -First 1
  if (-not $row) {
    throw "missing row for $Skill"
  }
  if ($row.classification -ne $Expected) {
    throw "expected $Skill to be $Expected, got $($row.classification)"
  }
}

$root = Join-Path ([System.IO.Path]::GetTempPath()) "atv-delta-$([guid]::NewGuid())"
$config = Join-Path $root "atv-upstream-delta.json"
try {
  New-Item -ItemType Directory -Force -Path $root | Out-Null
  git -C $root init | Out-Null
  git -C $root config user.email test@example.com | Out-Null
  git -C $root config user.name "ATV Delta Test" | Out-Null

  Write-TextFile (Join-Path $root ".github/skills/atv-security/SKILL.md") "uses osv-scanner"
  Write-TextFile (Join-Path $root ".github/skills/kb-start/SKILL.md") "kb"
  Write-TextFile (Join-Path $root ".github/skills/ce-review/SKILL.md") "ce"
  Write-TextFile (Join-Path $root ".github/skills/lfg/SKILL.md") "lfg"
  Write-TextFile (Join-Path $root ".github/skills/native-skill/SKILL.md") "native"
  Write-TextFile (Join-Path $root ".github/skills/mystery/SKILL.md") "mystery"
  git -C $root add . | Out-Null
  git -C $root commit -m "base" | Out-Null
  git -C $root branch base | Out-Null
  git -C $root checkout -b upstream | Out-Null

  Write-TextFile (Join-Path $root ".github/skills/atv-security/SKILL.md") "security without scanner"
  Write-TextFile (Join-Path $root ".github/skills/kb-start/SKILL.md") "kb upstream"
  Write-TextFile (Join-Path $root ".github/skills/ce-review/SKILL.md") "ce upstream"
  Write-TextFile (Join-Path $root ".github/skills/lfg/SKILL.md") "lfg upstream"
  Write-TextFile (Join-Path $root ".github/skills/native-skill/SKILL.md") "native upstream"
  Write-TextFile (Join-Path $root ".github/skills/mystery/SKILL.md") "mystery upstream"
  git -C $root add . | Out-Null
  git -C $root commit -m "upstream" | Out-Null

  @"
{
  "schema_version": 1,
  "kb_owned": ["kb-*"],
  "shared_overlap": ["ce-review"],
  "superseded_workflows": ["lfg"],
  "atv_native": ["atv-security", "native-*"],
  "security_sensitive": ["atv-security"]
}
"@ | Set-Content -Path $config -Encoding UTF8

  $before = git -C $root status --short
  $script = Join-Path $PSScriptRoot "atv-upstream-delta.ps1"
  $jsonText = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -AtvRepo $root -BaseRef base -UpstreamRef upstream -ConfigPath $config -Json
  if ($LASTEXITCODE -ne 0) {
    throw "atv-upstream-delta exited nonzero"
  }
  $after = git -C $root status --short
  if (($before -join "`n") -ne ($after -join "`n")) {
    throw "delta report mutated git status"
  }

  $report = ($jsonText -join "`n") | ConvertFrom-Json
  Assert-Class $report "kb-start" "kb-owned-reject"
  Assert-Class $report "ce-review" "shared-overlap-review"
  Assert-Class $report "lfg" "superseded-workflow-reject"
  Assert-Class $report "native-skill" "atv-native-candidate"
  Assert-Class $report "mystery" "unknown-review"
  $security = @($report.rows | Where-Object { $_.skill -eq "atv-security" }) | Select-Object -First 1
  if (-not $security -or @($security.warnings).Count -lt 1) {
    throw "expected atv-security security warning"
  }
} finally {
  Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "atv-upstream-delta selftest passed"
exit 0
