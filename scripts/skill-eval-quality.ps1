param(
  [string]$Root = ".",
  [string]$QualityRoot = "evals/skill-eval/quality",
  [string]$QualityPath = "",
  [int]$MinScore = 3,
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

function Has-Property {
  param($Object, [string]$Name)
  return ($Object -and ($Object.PSObject.Properties.Name -contains $Name))
}

function Add-Issue {
  param([System.Collections.Generic.List[object]]$List, [string]$CaseId, [string]$Message)
  $List.Add([pscustomobject]@{ case = $CaseId; message = $Message })
}

function Get-QualityFiles {
  param([string]$RepoRoot, [string]$QualityRoot, [string]$QualityPath)
  if ($QualityPath) {
    $full = Resolve-RepoPath $RepoRoot $QualityPath
    if (-not (Test-Path $full)) {
      throw "QualityPath does not exist: $QualityPath"
    }
    return @(Get-Item $full)
  }
  $root = Resolve-RepoPath $RepoRoot $QualityRoot
  if (-not (Test-Path $root)) {
    throw "QualityRoot does not exist: $QualityRoot"
  }
  return @(Get-ChildItem $root -Filter "*.json" | Sort-Object Name)
}

function Test-QualityCase {
  param($Case, [int]$MinScore)
  $issues = [System.Collections.Generic.List[object]]::new()
  $caseId = if (Has-Property $Case "id") { "$($Case.id)" } else { "<missing-id>" }
  $required = @("completeness", "maintainability", "relevance", "proof_quality", "right_sized_ceremony")

  if (-not (Has-Property $Case "quality")) {
    Add-Issue $issues $caseId "Missing quality object."
    return $issues
  }

  foreach ($dimension in $required) {
    if (-not (Has-Property $Case.quality $dimension)) {
      Add-Issue $issues $caseId "Missing quality dimension '$dimension'."
      continue
    }
    $entry = $Case.quality.$dimension
    foreach ($field in @("score", "judge", "reason")) {
      if (-not (Has-Property $entry $field)) {
        Add-Issue $issues $caseId "Missing '$field' for quality dimension '$dimension'."
      }
    }
    if (Has-Property $entry "judge") {
      $judge = "$($entry.judge)"
      if (@("deterministic", "llm-judged", "human-only") -notcontains $judge) {
        Add-Issue $issues $caseId "Invalid judge '$judge' for quality dimension '$dimension'."
      }
    }
    if (Has-Property $entry "score") {
      $score = [int]$entry.score
      if ($score -lt 0 -or $score -gt 5) {
        Add-Issue $issues $caseId "Score for '$dimension' must be 0-5."
      } elseif ($score -lt $MinScore) {
        Add-Issue $issues $caseId "Quality dimension '$dimension' scored $score, below threshold $MinScore."
      }
    }
  }

  return $issues
}

$repoRoot = (Resolve-Path $Root).Path
$qualityFiles = Get-QualityFiles $repoRoot $QualityRoot $QualityPath
$allIssues = [System.Collections.Generic.List[object]]::new()
$rows = [System.Collections.Generic.List[object]]::new()
$selfTestMode = -not $QualityPath

foreach ($file in $qualityFiles) {
  $case = Get-Content $file.FullName -Raw | ConvertFrom-Json
  $issues = @(Test-QualityCase $case $MinScore)
  $actualPass = ($issues.Count -eq 0)
  $expectedOutcome = if ((Has-Property $case "expected_result") -and $case.expected_result) { "$($case.expected_result)" } else { "pass" }
  $expectedPass = ($expectedOutcome -eq "pass")

  if ($selfTestMode -and ($actualPass -ne $expectedPass)) {
    if ($expectedPass) {
      Add-Issue $allIssues $file.Name "Self-test expected pass but quality scorer found issues."
    } else {
      Add-Issue $allIssues $file.Name "Self-test expected failure but quality scorer passed it."
    }
  }

  foreach ($issue in $issues) {
    if (-not $selfTestMode -or $expectedPass) {
      $allIssues.Add($issue)
    }
  }

  $rows.Add([pscustomobject]@{
    file = $file.Name
    case_id = if (Has-Property $case "id") { $case.id } else { "" }
    expected_result = $expectedOutcome
    actual_result = if ($actualPass) { "pass" } else { "fail" }
    issue_count = $issues.Count
  })
}

$output = [pscustomobject]@{
  ok = ($allIssues.Count -eq 0)
  case_count = $qualityFiles.Count
  selftest = $selfTestMode
  min_score = $MinScore
  results = $rows
  issues = $allIssues
}

if ($Json) {
  $output | ConvertTo-Json -Depth 8
} else {
  $mode = if ($selfTestMode) { "selftest" } else { "quality cases" }
  Write-Host "Skill quality eval: $($qualityFiles.Count) $mode, $($allIssues.Count) issues"
  foreach ($row in $rows) {
    Write-Host "$($row.file): case=$($row.case_id) expected=$($row.expected_result) actual=$($row.actual_result) issues=$($row.issue_count)"
  }
  foreach ($issue in $allIssues) {
    Write-Host "ERROR [$($issue.case)] $($issue.message)"
  }
}

if ($allIssues.Count -gt 0) {
  exit 1
}

exit 0
