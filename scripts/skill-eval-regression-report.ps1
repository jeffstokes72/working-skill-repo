param(
  [string]$Root = ".",
  [string]$RunRoot = ".atv/eval-runs",
  [string]$BaselinePath = "",
  [string]$OutputPath = "",
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

function Get-FileSizeOrNull {
  param([string]$Path)
  if ($Path -and (Test-Path $Path)) {
    return (Get-Item $Path).Length
  }
  return $null
}

function Get-StatusCounts {
  param($Rows)
  $counts = @{}
  foreach ($row in @($Rows)) {
    $status = "$($row.status)"
    if (-not $counts.ContainsKey($status)) {
      $counts[$status] = 0
    }
    $counts[$status] += 1
  }
  return $counts
}

$repoRoot = (Resolve-Path $Root).Path
$runRootFull = Resolve-RepoPath $repoRoot $RunRoot
if (-not (Test-Path $runRootFull)) {
  throw "RunRoot does not exist: $RunRoot"
}

$rows = [System.Collections.Generic.List[object]]::new()
$summaryFiles = @(Get-ChildItem $runRootFull -Recurse -Filter "summary.json" | Sort-Object FullName)

foreach ($summaryFile in $summaryFiles) {
  $summary = Get-Content $summaryFile.FullName -Raw | ConvertFrom-Json
  foreach ($result in @($summary.results)) {
    $resultPath = "$($result.result_path)"
    $stdoutPath = "$($result.stdout)"
    $stderrPath = "$($result.stderr)"
    $rows.Add([pscustomobject]@{
      source = $summaryFile.FullName
      corpus_id = "$($summary.corpus_id)"
      runtime = "$($result.runtime)"
      fixture_id = "$($result.fixture_id)"
      mode = "$($result.mode)"
      status = "$($result.status)"
      exit_code = $result.exit_code
      duration_ms = $result.duration_ms
      result_path = $resultPath
      result_bytes = Get-FileSizeOrNull $resultPath
      stdout_bytes = Get-FileSizeOrNull $stdoutPath
      stderr_bytes = Get-FileSizeOrNull $stderrPath
    })
  }
}

if ($rows.Count -eq 0) {
  $resultFiles = @(Get-ChildItem $runRootFull -Recurse -Filter "result.json" | Sort-Object FullName)
  foreach ($resultFile in $resultFiles) {
    $result = Get-Content $resultFile.FullName -Raw | ConvertFrom-Json
    $runtime = if ($resultFile.FullName -match "ghcp") { "ghcp" } elseif ($resultFile.FullName -match "codex") { "codex" } else { "unknown" }
    $rows.Add([pscustomobject]@{
      source = $resultFile.FullName
      corpus_id = ""
      runtime = $runtime
      fixture_id = "$($result.fixture_id)"
      mode = if ($resultFile.FullName -match "dry-run") { "dry-run" } else { "live" }
      status = "pass"
      exit_code = 0
      duration_ms = $null
      result_path = $resultFile.FullName
      result_bytes = (Get-Item $resultFile.FullName).Length
      stdout_bytes = $null
      stderr_bytes = $null
    })
  }
}

$statusCounts = Get-StatusCounts $rows
$passCount = if ($statusCounts.ContainsKey("pass")) { $statusCounts["pass"] } else { 0 }
$report = [pscustomobject]@{
  generated_at = (Get-Date).ToString("o")
  run_root = $runRootFull
  row_count = $rows.Count
  pass_count = $passCount
  non_pass_count = $rows.Count - $passCount
  status_counts = $statusCounts
  total_result_bytes = (@($rows | ForEach-Object { if ($_.result_bytes) { [int64]$_.result_bytes } else { 0 } }) | Measure-Object -Sum).Sum
  total_stdout_bytes = (@($rows | ForEach-Object { if ($_.stdout_bytes) { [int64]$_.stdout_bytes } else { 0 } }) | Measure-Object -Sum).Sum
  total_stderr_bytes = (@($rows | ForEach-Object { if ($_.stderr_bytes) { [int64]$_.stderr_bytes } else { 0 } }) | Measure-Object -Sum).Sum
  rows = $rows
  comparison = $null
}

if ($BaselinePath) {
  $baselineFull = Resolve-RepoPath $repoRoot $BaselinePath
  if (-not (Test-Path $baselineFull)) {
    throw "BaselinePath does not exist: $BaselinePath"
  }
  $baseline = Get-Content $baselineFull -Raw | ConvertFrom-Json
  $report.comparison = [pscustomobject]@{
    baseline = $baselineFull
    row_count_delta = $report.row_count - [int]$baseline.row_count
    pass_count_delta = $report.pass_count - [int]$baseline.pass_count
    non_pass_count_delta = $report.non_pass_count - [int]$baseline.non_pass_count
    total_result_bytes_delta = [int64]$report.total_result_bytes - [int64]$baseline.total_result_bytes
  }
}

if (-not $OutputPath) {
  $outputDir = Join-Path $runRootFull "reports"
  New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
  $OutputPath = Join-Path $outputDir ("skill-eval-regression-{0}.json" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
}
$outputFull = Resolve-RepoPath $repoRoot $OutputPath
$report | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFull -Encoding UTF8

$markdownPath = [System.IO.Path]::ChangeExtension($outputFull, ".md")
$lines = @(
  "# Skill Eval Regression Report",
  "",
  "- Generated: $($report.generated_at)",
  "- Run root: $($report.run_root)",
  "- Rows: $($report.row_count)",
  "- Pass: $($report.pass_count)",
  "- Non-pass: $($report.non_pass_count)",
  "- Result bytes: $($report.total_result_bytes)",
  "",
  "| Runtime | Fixture | Mode | Status | Duration ms | Result bytes |",
  "|---|---|---|---|---:|---:|"
)
foreach ($row in $rows) {
  $lines += "| $($row.runtime) | $($row.fixture_id) | $($row.mode) | $($row.status) | $($row.duration_ms) | $($row.result_bytes) |"
}
if ($report.comparison) {
  $lines += ""
  $lines += "## Baseline Comparison"
  $lines += ""
  $lines += "- Baseline: $($report.comparison.baseline)"
  $lines += "- Row count delta: $($report.comparison.row_count_delta)"
  $lines += "- Pass count delta: $($report.comparison.pass_count_delta)"
  $lines += "- Non-pass count delta: $($report.comparison.non_pass_count_delta)"
  $lines += "- Result bytes delta: $($report.comparison.total_result_bytes_delta)"
}
$lines | Set-Content -Path $markdownPath -Encoding UTF8

if ($Json) {
  $report | ConvertTo-Json -Depth 10
} else {
  Write-Host "Skill eval regression report: rows=$($report.row_count) pass=$($report.pass_count) non_pass=$($report.non_pass_count)"
  Write-Host "Report: $outputFull"
  Write-Host "Markdown: $markdownPath"
}

exit 0
