param(
  [ValidateSet("local-release", "live-release")]
  [string]$Profile = "local-release",
  [string]$Root = ".",
  [switch]$Json
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "powershell-helpers.ps1")

function Resolve-RepoPath {
  param([string]$Base, [string]$Path)
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }
  return (Join-Path $Base $Path)
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

function Invoke-KbGateProcess {
  param(
    [string]$RepoRoot,
    [string]$FileName,
    [string[]]$Arguments
  )

  $psi = [System.Diagnostics.ProcessStartInfo]::new()
  $psi.FileName = $FileName
  $psi.Arguments = Join-ProcessArguments $Arguments
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $psi.WorkingDirectory = $RepoRoot

  $process = [System.Diagnostics.Process]::new()
  $process.StartInfo = $psi
  [void]$process.Start()
  $stdoutTask = $process.StandardOutput.ReadToEndAsync()
  $stderrTask = $process.StandardError.ReadToEndAsync()
  $process.WaitForExit()

  return [pscustomobject]@{
    exit_code = $process.ExitCode
    stdout = $stdoutTask.Result
    stderr = $stderrTask.Result
  }
}

function New-Check {
  param(
    [string]$Name,
    [string]$Command,
    [string]$Confidence,
    [bool]$Required,
    [scriptblock]$Run,
    [scriptblock]$Available = { $true },
    [string]$SkipReason = ""
  )

  return [pscustomobject]@{
    name = $Name
    command = $Command
    confidence = $Confidence
    required = $Required
    run = $Run
    available = $Available
    skip_reason = $SkipReason
  }
}

function Invoke-Check {
  param($Check)

  if (-not (& $Check.available)) {
    return [pscustomobject]@{
      name = $Check.name
      status = "skipped-explicit"
      confidence = $Check.confidence
      required = [bool]$Check.required
      command = $Check.command
      exit_code = $null
      notes = $Check.skip_reason
    }
  }

  $started = Get-Date
  $result = & $Check.run
  $durationMs = [int]((Get-Date) - $started).TotalMilliseconds
  $combined = "$($result.stdout)`n$($result.stderr)".Trim()
  $status = if ($result.exit_code -eq 0) { "passed" } else { "failed" }

  return [pscustomobject]@{
    name = $Check.name
    status = $status
    confidence = $Check.confidence
    required = [bool]$Check.required
    command = $Check.command
    exit_code = $result.exit_code
    duration_ms = $durationMs
    notes = if ($combined.Length -gt 800) { $combined.Substring(0, 800) } else { $combined }
  }
}

$repoRoot = (Resolve-Path $Root).Path
$psInvocation = Get-KbPowerShellInvocation
$psExe = $psInvocation[0]
$psArgs = @($psInvocation | Select-Object -Skip 1)

$kbCheck = Resolve-RepoPath $repoRoot ".github/skills/kb-check/scripts/kb-check.ps1"
$syncReport = Resolve-RepoPath $repoRoot "scripts/skill-sync-report.ps1"
$minimalityReport = Resolve-RepoPath $repoRoot "scripts/skill-surface-minimality.ps1"
$upstreamDelta = Resolve-RepoPath $repoRoot "scripts/atv-upstream-delta.ps1"
$liveCorpus = Resolve-RepoPath $repoRoot "scripts/skill-eval-run-live-corpus.ps1"

$checks = [System.Collections.Generic.List[object]]::new()
$checks.Add((New-Check `
      -Name "kb-check-all" `
      -Command ".github\skills\kb-check\scripts\kb-check.ps1 -All" `
      -Confidence "deterministic-local" `
      -Required $true `
      -Available { Test-Path $kbCheck } `
      -SkipReason "required kb-check script missing" `
      -Run { Invoke-KbGateProcess $repoRoot $psExe (@($psArgs) + @($kbCheck, "-All")) }))

$checks.Add((New-Check `
      -Name "skill-sync-report" `
      -Command "scripts\skill-sync-report.ps1" `
      -Confidence "deterministic-local" `
      -Required $true `
      -Available { Test-Path $syncReport } `
      -SkipReason "required sync report script missing" `
      -Run { Invoke-KbGateProcess $repoRoot $psExe (@($psArgs) + @($syncReport)) }))

$checks.Add((New-Check `
      -Name "git-diff-check" `
      -Command "git diff --check" `
      -Confidence "deterministic-local" `
      -Required $true `
      -Available { [bool](Get-Command git -ErrorAction SilentlyContinue) } `
      -SkipReason "git unavailable" `
      -Run { Invoke-KbGateProcess $repoRoot "git" @("diff", "--check") }))

$checks.Add((New-Check `
      -Name "skill-surface-minimality" `
      -Command "scripts\skill-surface-minimality.ps1 -Json" `
      -Confidence "static-report" `
      -Required $false `
      -Available { Test-Path $minimalityReport } `
      -SkipReason "minimality report script not present in this checkout" `
      -Run { Invoke-KbGateProcess $repoRoot $psExe (@($psArgs) + @($minimalityReport, "-Json")) }))

$checks.Add((New-Check `
      -Name "atv-upstream-delta" `
      -Command "scripts\atv-upstream-delta.ps1 -Json" `
      -Confidence "read-only-git-diff" `
      -Required $false `
      -Available { (Test-Path $upstreamDelta) -and (Test-Path "E:\all-the-vibes") } `
      -SkipReason "ATV repo or upstream delta script unavailable" `
      -Run { Invoke-KbGateProcess $repoRoot $psExe (@($psArgs) + @($upstreamDelta, "-Json")) }))

if ($Profile -eq "live-release") {
  $checks.Add((New-Check `
        -Name "live-codex-ghcp-corpus" `
        -Command "scripts\skill-eval-run-live-corpus.ps1 -All -Runtime codex,ghcp" `
        -Confidence "live-model-explicit" `
        -Required $false `
        -Available { Test-Path $liveCorpus } `
        -SkipReason "live corpus runner unavailable" `
        -Run { Invoke-KbGateProcess $repoRoot $psExe (@($psArgs) + @($liveCorpus, "-All", "-Runtime", "codex,ghcp")) }))
}

$results = [System.Collections.Generic.List[object]]::new()
foreach ($check in $checks) {
  $results.Add((Invoke-Check $check))
}

$failedRequired = @($results | Where-Object { $_.required -and $_.status -ne "passed" })
$failedOptional = @($results | Where-Object { (-not $_.required) -and $_.status -eq "failed" })
$summary = [pscustomobject]@{
  ok = ($failedRequired.Count -eq 0 -and $failedOptional.Count -eq 0)
  profile = $Profile
  generated_at = (Get-Date).ToString("o")
  result_count = $results.Count
  required_failures = $failedRequired.Count
  optional_failures = $failedOptional.Count
  results = $results
}

if ($Json) {
  $summary | ConvertTo-Json -Depth 8
} else {
  Write-Host "KB release gate: profile=$Profile ok=$($summary.ok)"
  foreach ($result in $results) {
    $requiredLabel = if ($result.required) { "required" } else { "optional" }
    Write-Host "$($result.status) [$requiredLabel/$($result.confidence)] $($result.name): $($result.command)"
    if ($result.status -ne "passed" -and $result.notes) {
      Write-Host "  $($result.notes)"
    }
  }
}

if (-not $summary.ok) {
  exit 1
}

exit 0
