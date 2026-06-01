param(
  [string]$Root = ".",
  [string]$Runner = "scripts/skill-eval-run-ghcp.ps1",
  [string]$FixtureId = "",
  [switch]$All,
  [switch]$DryRun,
  [switch]$KeepRun,
  [switch]$Sealed,
  [string]$RunRoot = ".atv/eval-runs",
  [switch]$Json
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "powershell-helpers.ps1")

function Resolve-RepoPath {
  param([string]$Base, [string]$Path)
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path $Base $Path))
}

function Normalize-PathText {
  param([string]$Path)
  return ($Path -replace '\\', '/').TrimStart('./')
}

function Get-GitStatusText {
  param([string]$RepoRoot, [string]$GitPath)
  $raw = & $GitPath -C $RepoRoot status --porcelain=v1 -z
  if ($null -eq $raw) {
    return ""
  }
  return "$raw"
}

function Convert-StatusToMap {
  param([string]$StatusText)
  $map = @{}
  foreach ($entry in ($StatusText -split "`0")) {
    if (-not $entry) {
      continue
    }
    if ($entry.Length -lt 4) {
      continue
    }
    $status = $entry.Substring(0, 2)
    $path = Normalize-PathText $entry.Substring(3)
    if ($path -like ".atv/eval-runs/*" -or $path -like ".atv/tmp/*" -or $path -like "atv/eval-runs/*" -or $path -like "atv/tmp/*" -or $path -eq "atv/tmp/") {
      continue
    }
    $map[$path] = $status
  }
  return $map
}

function Compare-StatusChanges {
  param([string]$Before, [string]$After)
  $beforeMap = Convert-StatusToMap $Before
  $afterMap = Convert-StatusToMap $After
  $writes = [System.Collections.Generic.List[string]]::new()
  $deletes = [System.Collections.Generic.List[string]]::new()

  foreach ($path in $afterMap.Keys) {
    $beforeStatus = if ($beforeMap.ContainsKey($path)) { $beforeMap[$path] } else { "" }
    $afterStatus = $afterMap[$path]
    if ($beforeStatus -eq $afterStatus) {
      continue
    }
    if ($afterStatus -match "D") {
      $deletes.Add($path)
    } else {
      $writes.Add($path)
    }
  }

  foreach ($path in $beforeMap.Keys) {
    if (-not $afterMap.ContainsKey($path)) {
      $writes.Add($path)
    }
  }

  return [pscustomobject]@{
    writes = @($writes | Sort-Object -Unique)
    deletes = @($deletes | Sort-Object -Unique)
  }
}

function Test-IsUnderPath {
  param([string]$ChildPath, [string]$ParentPath)
  $childFull = [System.IO.Path]::GetFullPath($ChildPath).TrimEnd('\', '/')
  $parentFull = [System.IO.Path]::GetFullPath($ParentPath).TrimEnd('\', '/')
  return ($childFull -eq $parentFull -or $childFull.StartsWith("$parentFull$([System.IO.Path]::DirectorySeparatorChar)", [System.StringComparison]::OrdinalIgnoreCase))
}

function Write-Shim {
  param(
    [string]$ShimDir,
    [string]$CommandName,
    [string]$RealPath,
    [string]$LogPath,
    [bool]$SealedMode
  )

  if (-not $RealPath) {
    return
  }

  $sealedText = if ($SealedMode) { "1" } else { "0" }
  $blockAll = if ($CommandName -eq "rm") { "1" } else { "0" }
  $shimPath = Join-Path $ShimDir "$CommandName.cmd"
  @"
@echo off
setlocal
echo %DATE% %TIME% $CommandName %*>>"$LogPath"
set "ARGS=%*"
if "$sealedText"=="1" (
  if "$blockAll"=="1" exit /b 97
  echo %ARGS% | findstr /i /c:"reset --hard" /c:"clean -fd" /c:"clean -f -d" /c:"checkout --" >nul
  if not errorlevel 1 exit /b 97
)
"$RealPath" %*
exit /b %ERRORLEVEL%
"@ | Set-Content -Path $shimPath -Encoding ASCII
}

$repoRoot = (Resolve-Path $Root).Path
$runnerPath = Resolve-RepoPath $repoRoot $Runner
if (-not (Test-Path -LiteralPath $runnerPath)) {
  throw "Runner not found: $runnerPath"
}
$runRootPath = Resolve-RepoPath $repoRoot $RunRoot

$shimDir = Join-Path ([System.IO.Path]::GetTempPath()) "atv-shims-$([guid]::NewGuid())"
$logPath = Join-Path $shimDir "commands.log"
New-Item -ItemType Directory -Force -Path $shimDir | Out-Null
$oldPath = $env:PATH
$runDirsToClean = [System.Collections.Generic.List[string]]::new()

try {
  $realCommands = @{}
  foreach ($cmd in @("git", "rm", "npm", "node", "bun", "npx")) {
    $found = Get-Command $cmd -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
      $realCommands[$cmd] = $found.Source
    }
  }

  foreach ($cmd in $realCommands.Keys) {
    Write-Shim $shimDir $cmd $realCommands[$cmd] $logPath ([bool]$Sealed)
  }

  $env:PATH = "$shimDir$([IO.Path]::PathSeparator)$oldPath"
  $gitPath = if ($realCommands.ContainsKey("git")) { $realCommands["git"] } else { "git" }
  $before = Get-GitStatusText $repoRoot $gitPath

  $args = @("-Root", $repoRoot, "-RunRoot", $RunRoot, "-KeepRun", "-Json")
  if ($FixtureId) {
    $args += @("-FixtureId", $FixtureId)
  }
  if ($All) {
    $args += "-All"
  }
  if ($DryRun) {
    $args += "-DryRun"
  }

  $runnerOutput = Invoke-KbPowerShellFile $runnerPath $args
  if ($LASTEXITCODE -ne 0) {
    throw "Wrapped runner failed with exit $LASTEXITCODE."
  }
  $runnerResult = ($runnerOutput | Out-String).Trim() | ConvertFrom-Json

  $after = Get-GitStatusText $repoRoot $gitPath
  $statusDiff = Compare-StatusChanges $before $after
  $commands = if (Test-Path -LiteralPath $logPath) { @(Get-Content -LiteralPath $logPath) } else { @() }

  $scored = [System.Collections.Generic.List[object]]::new()
  foreach ($run in @($runnerResult.runs)) {
    $resultPath = "$($run.result_path)"
    if (-not (Test-Path -LiteralPath $resultPath)) {
      throw "Wrapped runner did not leave result file. Use a runner that supports -KeepRun -Json. Missing: $resultPath"
    }
    $result = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
    $observedTrace = [pscustomobject]@{
      captured = $true
      method = "path-shim+git-diff"
      commands = @($commands)
      writes = @($statusDiff.writes)
      deletes = @($statusDiff.deletes)
    }
    $result | Add-Member -MemberType NoteProperty -Name "observed_trace" -Value $observedTrace -Force
    $result | ConvertTo-Json -Depth 12 | Set-Content -Path $resultPath -Encoding UTF8

    $scoreArgs = @("-Root", $repoRoot, "-ResultPath", $resultPath)
    if ($run.run_id) {
      $scoreArgs += @("-RequiredRunId", "$($run.run_id)")
    }
    if ($run.manifest_path) {
      $scoreArgs += @("-ManifestPath", "$($run.manifest_path)")
    }
    Invoke-KbPowerShellFile (Join-Path $repoRoot "scripts/skill-eval.ps1") $scoreArgs | Tee-Object -FilePath (Join-Path (Split-Path -Parent $resultPath) "score-observed.log") | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw "Observed-trace scoring failed for $resultPath."
    }
    $scored.Add([pscustomobject]@{
        fixture_id = $run.fixture_id
        run_id = $run.run_id
        result_path = $resultPath
        observed_trace = $observedTrace
      })

    if (-not $KeepRun) {
      $runDir = Split-Path -Parent $resultPath
      if ((Test-Path -LiteralPath $runDir) -and (Test-IsUnderPath $runDir $runRootPath)) {
        $runDirsToClean.Add($runDir)
      }
    }
  }

  $output = [pscustomobject]@{
    ok = $true
    sealed = [bool]$Sealed
    runner = $runnerPath
    runs = @($scored)
  }

  if ($Json) {
    $output | ConvertTo-Json -Depth 10
  } else {
    Write-Host "Skill eval wrapper: $($scored.Count) run(s), observed_trace captured."
    foreach ($row in $scored) {
      Write-Host "$($row.fixture_id): result=$($row.result_path)"
    }
  }
} finally {
  $env:PATH = $oldPath
  if (-not $KeepRun) {
    foreach ($runDir in @($runDirsToClean | Sort-Object -Unique)) {
      if ((Test-Path -LiteralPath $runDir) -and (Test-IsUnderPath $runDir $runRootPath)) {
        Remove-Item -LiteralPath $runDir -Recurse -Force
      }
    }
  }
  if (Test-Path -LiteralPath $shimDir) {
    Remove-Item -LiteralPath $shimDir -Recurse -Force
  }
}

exit 0
