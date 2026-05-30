param(
  [string]$Root = ".",
  [string]$ClaimRoot = "evals/skill-eval/claims",
  [string]$ClaimPath = "",
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
  param(
    [System.Collections.Generic.List[object]]$List,
    [string]$CaseId,
    [string]$Message
  )
  $List.Add([pscustomobject]@{ case = $CaseId; message = $Message })
}

function Normalize-Text {
  param([string]$Value)
  if ($null -eq $Value) {
    $Value = ""
  }
  return (($Value -replace "\s+", " ").Trim().ToLowerInvariant())
}

function Test-ContainsAny {
  param($Items, [string]$Expected)
  $needle = Normalize-Text $Expected
  foreach ($item in @($Items)) {
    if ((Normalize-Text "$item").Contains($needle)) {
      return $true
    }
  }
  return $false
}

function Get-ClaimFiles {
  param([string]$RepoRoot, [string]$ClaimRoot, [string]$ClaimPath)
  if ($ClaimPath) {
    $full = Resolve-RepoPath $RepoRoot $ClaimPath
    if (-not (Test-Path $full)) {
      throw "ClaimPath does not exist: $ClaimPath"
    }
    return @(Get-Item $full)
  }
  $root = Resolve-RepoPath $RepoRoot $ClaimRoot
  if (-not (Test-Path $root)) {
    throw "ClaimRoot does not exist: $ClaimRoot"
  }
  return @(Get-ChildItem $root -Filter "*.json" | Sort-Object Name)
}

function Test-ClaimCase {
  param([string]$RepoRoot, $Case)
  $issues = [System.Collections.Generic.List[object]]::new()
  $ambiguous = [System.Collections.Generic.List[object]]::new()
  $caseId = if (Has-Property $Case "id") { "$($Case.id)" } else { "<missing-id>" }
  $trace = if (Has-Property $Case "trace") { $Case.trace } else { [pscustomobject]@{ files_read = @(); commands = @(); tools = @() } }

  foreach ($claim in @($Case.claims)) {
    $type = "$($claim.type)"
    $claimText = if (Has-Property $claim "claim") { "$($claim.claim)" } else { $type }

    if ($type -eq "ambiguous") {
      $ambiguous.Add([pscustomobject]@{
        claim = $claimText
        reason = if (Has-Property $claim "reason") { "$($claim.reason)" } else { "No deterministic verifier supplied." }
      })
      continue
    }

    if ($type -eq "file_exists") {
      $path = "$($claim.path)"
      $expected = if (Has-Property $claim "expected") { [bool]$claim.expected } else { $true }
      $actual = Test-Path (Resolve-RepoPath $RepoRoot $path)
      if ($actual -ne $expected) {
        Add-Issue $issues $caseId "Claim check failed: $claimText"
      }
      continue
    }

    if ($type -eq "command_ran") {
      $contains = "$($claim.contains)"
      $expected = if (Has-Property $claim "expected") { [bool]$claim.expected } else { $true }
      $actual = Test-ContainsAny $trace.commands $contains
      if ($actual -ne $expected) {
        Add-Issue $issues $caseId "Claim check failed: $claimText"
      }
      continue
    }

    if ($type -eq "file_read") {
      $contains = "$($claim.contains)"
      $expected = if (Has-Property $claim "expected") { [bool]$claim.expected } else { $true }
      $actual = Test-ContainsAny $trace.files_read $contains
      if ($actual -ne $expected) {
        Add-Issue $issues $caseId "Claim check failed: $claimText"
      }
      continue
    }

    Add-Issue $issues $caseId "Unknown claim type '$type'."
  }

  return [pscustomobject]@{ case_id = $caseId; issues = $issues; ambiguous = $ambiguous }
}

$repoRoot = (Resolve-Path $Root).Path
$claimFiles = Get-ClaimFiles $repoRoot $ClaimRoot $ClaimPath
$allIssues = [System.Collections.Generic.List[object]]::new()
$rows = [System.Collections.Generic.List[object]]::new()
$selfTestMode = -not $ClaimPath

foreach ($file in $claimFiles) {
  $case = Get-Content $file.FullName -Raw | ConvertFrom-Json
  $result = Test-ClaimCase $repoRoot $case
  $actualPass = ($result.issues.Count -eq 0)
  $expectedOutcome = if ((Has-Property $case "expected_result") -and $case.expected_result) { "$($case.expected_result)" } else { "pass" }
  $expectedPass = ($expectedOutcome -eq "pass")

  if ($selfTestMode -and ($actualPass -ne $expectedPass)) {
    if ($expectedPass) {
      Add-Issue $allIssues $file.Name "Self-test expected pass but claim verifier found issues."
    } else {
      Add-Issue $allIssues $file.Name "Self-test expected failure but claim verifier passed it."
    }
  }

  foreach ($issue in @($result.issues)) {
    if (-not $selfTestMode -or $expectedPass) {
      $allIssues.Add($issue)
    }
  }

  $rows.Add([pscustomobject]@{
    file = $file.Name
    case_id = $result.case_id
    expected_result = $expectedOutcome
    actual_result = if ($actualPass) { "pass" } else { "fail" }
    issue_count = $result.issues.Count
    ambiguous_count = $result.ambiguous.Count
  })
}

$output = [pscustomobject]@{
  ok = ($allIssues.Count -eq 0)
  case_count = $claimFiles.Count
  selftest = $selfTestMode
  results = $rows
  issues = $allIssues
}

if ($Json) {
  $output | ConvertTo-Json -Depth 8
} else {
  $mode = if ($selfTestMode) { "selftest" } else { "claims" }
  Write-Host "Skill claim eval: $($claimFiles.Count) $mode files, $($allIssues.Count) issues"
  foreach ($row in $rows) {
    Write-Host "$($row.file): case=$($row.case_id) expected=$($row.expected_result) actual=$($row.actual_result) issues=$($row.issue_count) ambiguous=$($row.ambiguous_count)"
  }
  foreach ($issue in $allIssues) {
    Write-Host "ERROR [$($issue.case)] $($issue.message)"
  }
}

if ($allIssues.Count -gt 0) {
  exit 1
}

exit 0
