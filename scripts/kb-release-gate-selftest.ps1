param()

$ErrorActionPreference = "Stop"

function New-TestRepo {
  param([bool]$FailKbCheck)

  $root = Join-Path ([System.IO.Path]::GetTempPath()) "kb-release-gate-$([guid]::NewGuid())"
  New-Item -ItemType Directory -Force -Path $root | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $root ".github/skills/kb-check/scripts") | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $root "scripts") | Out-Null

  $kbCheckExit = if ($FailKbCheck) { "exit 7" } else { "exit 0" }
  @"
param([switch]`$All)
if (-not `$All) { throw "expected -All" }
$kbCheckExit
"@ | Set-Content -Path (Join-Path $root ".github/skills/kb-check/scripts/kb-check.ps1") -Encoding UTF8

  @"
param()
exit 0
"@ | Set-Content -Path (Join-Path $root "scripts/skill-sync-report.ps1") -Encoding UTF8

  git -C $root init | Out-Null
  git -C $root config user.email test@example.com | Out-Null
  git -C $root config user.name "Release Gate Test" | Out-Null
  git -C $root add . | Out-Null
  git -C $root commit -m "fixture" | Out-Null
  return $root
}

function Invoke-Gate {
  param([string]$Root, [string]$Profile)

  $gate = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts/kb-release-gate.ps1"
  if (-not (Test-Path $gate)) {
    $gate = Join-Path $PSScriptRoot "kb-release-gate.ps1"
  }
  $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $gate -Root $Root -Profile $Profile -Json 2>&1
  $exitCode = $LASTEXITCODE
  $json = ($output -join "`n") | ConvertFrom-Json
  return [pscustomobject]@{ exit_code = $exitCode; result = $json }
}

$successRoot = New-TestRepo -FailKbCheck $false
$failureRoot = New-TestRepo -FailKbCheck $true

try {
  $local = Invoke-Gate -Root $successRoot -Profile "local-release"
  if ($local.exit_code -ne 0 -or -not $local.result.ok) {
    throw "local-release should pass with successful required checks"
  }
  if (@($local.result.results | Where-Object { $_.name -eq "live-codex-ghcp-corpus" }).Count -ne 0) {
    throw "local-release must not include live corpus checks"
  }
  $skipped = @($local.result.results | Where-Object { $_.status -eq "skipped-explicit" })
  if ($skipped.Count -lt 1) {
    throw "local-release should label unavailable optional checks as skipped-explicit"
  }

  $live = Invoke-Gate -Root $successRoot -Profile "live-release"
  if ($live.exit_code -ne 0 -or -not $live.result.ok) {
    throw "live-release should pass when live corpus runner is explicitly unavailable"
  }
  $liveCorpus = @($live.result.results | Where-Object { $_.name -eq "live-codex-ghcp-corpus" }) | Select-Object -First 1
  if (-not $liveCorpus -or $liveCorpus.status -ne "skipped-explicit") {
    throw "live-release should report unavailable live corpus as skipped-explicit"
  }

  $failed = Invoke-Gate -Root $failureRoot -Profile "local-release"
  if ($failed.exit_code -eq 0 -or $failed.result.ok) {
    throw "required kb-check failure should make the gate fail"
  }
  $failedKbCheck = @($failed.result.results | Where-Object { $_.name -eq "kb-check-all" }) | Select-Object -First 1
  if (-not $failedKbCheck -or $failedKbCheck.status -ne "failed") {
    throw "required kb-check failure was not reported as failed"
  }
} finally {
  Remove-Item -LiteralPath $successRoot -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $failureRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "kb-release-gate selftest passed"
exit 0
