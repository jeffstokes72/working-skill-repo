param(
  [Parameter(Mandatory=$true)][string]$ManifestPath,
  [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-BlockerList {
  param([string]$Value)
  $trimmed = $Value.Trim()
  if ($trimmed -eq "[]" -or $trimmed -eq "") { return @() }
  if ($trimmed.StartsWith("[") -and $trimmed.EndsWith("]")) {
    $inner = $trimmed.Substring(1, $trimmed.Length - 2).Trim()
    if ($inner -eq "") { return @() }
    return @($inner -split "," | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ })
  }
  return @($trimmed.Trim('"').Trim("'"))
}

function Get-ManifestSlices {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    throw "Manifest not found: $Path"
  }

  $slices = [System.Collections.Generic.List[object]]::new()
  $current = $null
  foreach ($line in Get-Content $Path) {
    if ($line -match '^\s*-\s+id:\s*(.+?)\s*$') {
      if ($current) { $slices.Add([pscustomobject]$current) }
      $current = [ordered]@{
        id = $Matches[1].Trim().Trim('"').Trim("'")
        blockers = @()
        status = ""
        can_continue_other_slices = $true
        hitl = $false
      }
      continue
    }
    if (-not $current) { continue }
    if ($line -match '^\s+blockers:\s*(.+?)\s*$') {
      $current.blockers = @(Get-BlockerList $Matches[1])
    } elseif ($line -match '^\s+status:\s*(.+?)\s*$') {
      $current.status = $Matches[1].Trim().Trim('"').Trim("'")
    } elseif ($line -match '^\s+can_continue_other_slices:\s*(.+?)\s*$') {
      $current.can_continue_other_slices = [bool]::Parse($Matches[1].Trim())
    } elseif ($line -match '^\s+hitl:\s*(.+?)\s*$') {
      $current.hitl = [bool]::Parse($Matches[1].Trim())
    }
  }
  if ($current) { $slices.Add([pscustomobject]$current) }
  return @($slices)
}

function Test-Cycles {
  param($Slices)
  $byId = @{}
  foreach ($slice in $Slices) { $byId[$slice.id] = $slice }
  $visiting = @{}
  $visited = @{}
  $cycle = [System.Collections.Generic.List[string]]::new()

  function Visit {
    param([string]$Id)
    if ($visited.ContainsKey($Id)) { return $false }
    if ($visiting.ContainsKey($Id)) {
      $cycle.Add($Id)
      return $true
    }
    if (-not $byId.ContainsKey($Id)) { return $false }
    $visiting[$Id] = $true
    foreach ($blocker in @($byId[$Id].blockers)) {
      if (Visit $blocker) {
        $cycle.Add($Id)
        return $true
      }
    }
    $visiting.Remove($Id)
    $visited[$Id] = $true
    return $false
  }

  foreach ($slice in $Slices) {
    if (Visit $slice.id) {
      [array]::Reverse($cycle)
      return @($cycle)
    }
  }
  return @()
}

$slices = @(Get-ManifestSlices $ManifestPath)
$ids = @($slices | ForEach-Object { $_.id })
$missing = [System.Collections.Generic.List[object]]::new()
foreach ($slice in $slices) {
  foreach ($blocker in @($slice.blockers)) {
    if ($ids -notcontains $blocker) {
      $missing.Add([pscustomobject]@{ slice = $slice.id; blocker = $blocker })
    }
  }
}
if ($missing.Count -gt 0) {
  $result = [pscustomobject]@{
    ok = $false
    reason = "missing-blocker"
    missing_blockers = @($missing)
    ready = @()
  }
  if ($Json) { $result | ConvertTo-Json -Depth 8 } else { "missing blocker" }
  exit 2
}

$cycle = @(Test-Cycles $slices)
if ($cycle.Count -gt 0) {
  $result = [pscustomobject]@{
    ok = $false
    reason = "cycle"
    cycle = @($cycle)
    ready = @()
  }
  if ($Json) { $result | ConvertTo-Json -Depth 8 } else { "cycle: $($cycle -join ' -> ')" }
  exit 2
}

$doneStates = @("done", "skipped")
$terminalOrWaiting = @("done", "skipped", "blocked", "human-required", "parked", "in_progress")
$runnable = @()
foreach ($slice in $slices) {
  if ($terminalOrWaiting -contains $slice.status) { continue }
  if ($slice.status -ne "pending") { continue }
  $ready = $true
  foreach ($blocker in @($slice.blockers)) {
    $blockerSlice = $slices | Where-Object { $_.id -eq $blocker } | Select-Object -First 1
    if ($doneStates -notcontains $blockerSlice.status) {
      $ready = $false
      break
    }
  }
  if ($ready) { $runnable += $slice }
}

$readySet = @()
if ($runnable.Count -eq 1) {
  $readySet = @($runnable[0])
} else {
  $readySet = @($runnable | Where-Object { $_.can_continue_other_slices -and -not $_.hitl })
}
$excludedSerial = @()
if ($runnable.Count -gt 1) {
  $excludedSerial = @($runnable | Where-Object { -not $_.can_continue_other_slices -or $_.hitl })
}

$result = [pscustomobject]@{
  ok = $true
  reason = "ready"
  ready = @($readySet | ForEach-Object { $_.id })
  runnable = @($runnable | ForEach-Object { $_.id })
  excluded_serial = @($excludedSerial | ForEach-Object { $_.id })
}

if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  $result.ready -join [Environment]::NewLine
}
