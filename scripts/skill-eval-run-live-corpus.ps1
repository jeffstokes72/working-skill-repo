param(
  [string]$Root = ".",
  [string]$ConfigPath = "config/skill-quality.json",
  [string]$FixtureId = "",
  [switch]$All,
  [string[]]$Runtime = @("codex", "ghcp"),
  [switch]$DryRun,
  [switch]$KeepRun,
  [string]$RunRoot = ".atv/eval-runs",
  [string]$Model = "",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Resolve-RepoPath {
  param([string]$Base, [string]$Path)
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }
  return (Join-Path $Base $Path)
}

function ConvertTo-JsonFile {
  param($Object, [string]$Path, [int]$Depth = 12)
  $Object | ConvertTo-Json -Depth $Depth | Set-Content -Path $Path -Encoding UTF8
}

function Read-JsonObjectFromText {
  param([string]$Text)
  $trimmed = $Text.Trim()
  try {
    return ($trimmed | ConvertFrom-Json)
  } catch {
    $match = [regex]::Match($trimmed, '(?s)\{.*\}')
    if ($match.Success) {
      return ($match.Value | ConvertFrom-Json)
    }
    throw
  }
}

function Join-ProcessArguments {
  param([string[]]$Arguments)
  $quoted = foreach ($arg in $Arguments) {
    if ($null -eq $arg) {
      '""'
    } elseif ($arg -match '[\s"]') {
      '"' + ($arg -replace '"', '\"') + '"'
    } else {
      $arg
    }
  }
  return ($quoted -join " ")
}

function Invoke-Adapter {
  param(
    [string]$RepoRoot,
    [string]$ScriptPath,
    [string[]]$Arguments,
    [string]$StdoutPath,
    [string]$StderrPath
  )

  $psi = [System.Diagnostics.ProcessStartInfo]::new()
  $psi.FileName = "powershell"
  $psi.Arguments = Join-ProcessArguments (@("-ExecutionPolicy", "Bypass", "-File", $ScriptPath) + $Arguments)
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $psi.WorkingDirectory = $RepoRoot

  $process = [System.Diagnostics.Process]::new()
  $process.StartInfo = $psi
  [void]$process.Start()
  $stdout = $process.StandardOutput.ReadToEnd()
  $stderr = $process.StandardError.ReadToEnd()
  $process.WaitForExit()

  $stdout | Set-Content -Path $StdoutPath -Encoding UTF8
  $stderr | Set-Content -Path $StderrPath -Encoding UTF8

  return [pscustomobject]@{
    exit_code = $process.ExitCode
    stdout = $stdout
    stderr = $stderr
  }
}

function Get-StatusFromFailure {
  param([string]$Text)
  if ($Text -match '(?i)unavailable|not logged in|login|authenticate|authentication|unauthorized|forbidden|subscription|license|policy') {
    return "runtime-unavailable"
  }
  if ($Text -match '(?i)json|parse|schema|missing required field') {
    return "invalid-json"
  }
  if ($Text -match '(?i)skill-eval scoring failed|ERROR \[') {
    return "score-failed"
  }
  return "adapter-failed"
}

if (-not $FixtureId -and -not $All) {
  throw "Pass -FixtureId <id> or -All."
}

$repoRoot = (Resolve-Path $Root).Path
$runRootFull = Resolve-RepoPath $repoRoot $RunRoot
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$corpusId = "$timestamp-live-corpus"
if ($DryRun) {
  $corpusId = "$timestamp-live-corpus-dry-run"
}
$corpusDir = Join-Path $runRootFull $corpusId
New-Item -ItemType Directory -Force -Path $corpusDir | Out-Null

$normalizedRuntimes = @()
foreach ($runtimeItem in $Runtime) {
  foreach ($part in ("$runtimeItem" -split ",")) {
    $trimmed = $part.Trim().ToLowerInvariant()
    if ($trimmed) {
      $normalizedRuntimes += $trimmed
    }
  }
}
$normalizedRuntimes = @($normalizedRuntimes | Select-Object -Unique)

$rows = [System.Collections.Generic.List[object]]::new()

foreach ($runtimeName in $normalizedRuntimes) {
  if (@("codex", "ghcp") -notcontains $runtimeName) {
    throw "Unknown runtime '$runtimeName'. Expected codex or ghcp."
  }

  $adapterPath = Join-Path $repoRoot "scripts/skill-eval-run-$runtimeName.ps1"
  $stdoutPath = Join-Path $corpusDir "$runtimeName.stdout.log"
  $stderrPath = Join-Path $corpusDir "$runtimeName.stderr.log"

  if (-not (Test-Path $adapterPath)) {
    $rows.Add([pscustomobject]@{
      runtime = $runtimeName
      fixture_id = if ($FixtureId) { $FixtureId } else { "*" }
      mode = if ($DryRun) { "dry-run" } else { "live" }
      status = "adapter-missing"
      exit_code = $null
      result_path = ""
      stdout = ""
      stderr = ""
    })
    continue
  }

  $adapterArgs = @("-Root", $repoRoot, "-ConfigPath", $ConfigPath, "-RunRoot", $RunRoot, "-Json")
  if ($FixtureId) {
    $adapterArgs += @("-FixtureId", $FixtureId)
  }
  if ($All) {
    $adapterArgs += "-All"
  }
  if ($DryRun) {
    $adapterArgs += "-DryRun"
  }
  if ($KeepRun) {
    $adapterArgs += "-KeepRun"
  }
  if ($Model) {
    $adapterArgs += @("-Model", $Model)
  }

  $started = Get-Date
  $adapter = Invoke-Adapter $repoRoot $adapterPath $adapterArgs $stdoutPath $stderrPath
  $durationMs = [int]((Get-Date) - $started).TotalMilliseconds

  if ($adapter.exit_code -eq 0) {
    $parsed = Read-JsonObjectFromText $adapter.stdout
    foreach ($run in @($parsed.runs)) {
      $rows.Add([pscustomobject]@{
        runtime = $runtimeName
        fixture_id = "$($run.fixture_id)"
        mode = "$($run.mode)"
        status = "pass"
        exit_code = 0
        duration_ms = $durationMs
        result_path = "$($run.result_path)"
        stdout = $stdoutPath
        stderr = $stderrPath
      })
    }
  } else {
    $combined = "$($adapter.stdout)`n$($adapter.stderr)"
    $rows.Add([pscustomobject]@{
      runtime = $runtimeName
      fixture_id = if ($FixtureId) { $FixtureId } else { "*" }
      mode = if ($DryRun) { "dry-run" } else { "live" }
      status = Get-StatusFromFailure $combined
      exit_code = $adapter.exit_code
      duration_ms = $durationMs
      result_path = ""
      stdout = $stdoutPath
      stderr = $stderrPath
    })
  }
}

$summary = [pscustomobject]@{
  ok = (($rows | Where-Object { $_.status -ne "pass" }).Count -eq 0)
  corpus_id = $corpusId
  mode = if ($DryRun) { "dry-run" } else { "live" }
  runtimes = $normalizedRuntimes
  result_count = $rows.Count
  results = $rows
}

$summaryPath = Join-Path $corpusDir "summary.json"
ConvertTo-JsonFile $summary $summaryPath

$markdownPath = Join-Path $corpusDir "summary.md"
$lines = @(
  "# Skill Eval Live Corpus Summary",
  "",
  "- Corpus: $corpusId",
  "- Mode: $($summary.mode)",
  "- OK: $($summary.ok)",
  "",
  "| Runtime | Fixture | Mode | Status | Exit | Result |",
  "|---|---|---|---|---:|---|"
)
foreach ($row in $rows) {
  $lines += "| $($row.runtime) | $($row.fixture_id) | $($row.mode) | $($row.status) | $($row.exit_code) | $($row.result_path) |"
}
$lines | Set-Content -Path $markdownPath -Encoding UTF8

if ($Json) {
  $summary | ConvertTo-Json -Depth 8
} else {
  Write-Host "Skill eval live corpus: $($rows.Count) run(s), ok=$($summary.ok), summary=$summaryPath"
  foreach ($row in $rows) {
    Write-Host "$($row.runtime)/$($row.fixture_id): mode=$($row.mode) status=$($row.status) result=$($row.result_path)"
  }
}

if (-not $summary.ok) {
  exit 1
}

exit 0
