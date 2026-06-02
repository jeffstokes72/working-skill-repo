param(
  [Parameter(Mandatory=$true)][string]$LedgerPath,
  [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $LedgerPath)) {
  throw "Ledger not found: $LedgerPath"
}

$parsedEntries = Get-Content $LedgerPath -Raw | ConvertFrom-Json
$entries = @($parsedEntries | ForEach-Object { $_ })
$activeStates = @("active", "claimed", "writing")
$releaseStates = @("done", "skipped", "requeued", "released")
$ownersByPath = @{}
$collisions = [System.Collections.Generic.List[object]]::new()

foreach ($entry in $entries) {
  foreach ($field in @("slice_id", "path", "status")) {
    if (-not ($entry.PSObject.Properties.Name -contains $field)) {
      throw "Ledger entry missing '$field'."
    }
  }

  $path = "$($entry.path)".Replace("\", "/").ToLowerInvariant()
  $status = "$($entry.status)".ToLowerInvariant()
  $sliceId = "$($entry.slice_id)"

  if ($releaseStates -contains $status) {
    if ($ownersByPath.ContainsKey($path) -and $ownersByPath[$path] -eq $sliceId) {
      $ownersByPath.Remove($path)
    }
    continue
  }

  if ($activeStates -notcontains $status) {
    continue
  }

  if ($ownersByPath.ContainsKey($path) -and $ownersByPath[$path] -ne $sliceId) {
    $collisions.Add([pscustomobject]@{
      path = $path
      owner = $ownersByPath[$path]
      contender = $sliceId
    })
    continue
  }

  $ownersByPath[$path] = $sliceId
}

$result = [pscustomobject]@{
  ok = ($collisions.Count -eq 0)
  active_leases = @($ownersByPath.GetEnumerator() | Sort-Object Name | ForEach-Object {
    [pscustomobject]@{ path = $_.Key; slice_id = $_.Value }
  })
  collisions = @($collisions)
}

if ($Json) {
  $result | ConvertTo-Json -Depth 8
} elseif ($result.ok) {
  "scope lease: ok"
} else {
  "scope lease: collision"
}

if (-not $result.ok) { exit 2 }
