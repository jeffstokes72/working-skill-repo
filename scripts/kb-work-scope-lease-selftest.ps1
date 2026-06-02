Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$script = Join-Path $root "scripts/kb-work-scope-lease.ps1"
$temp = Join-Path $root ".atv/scope-lease-selftest-$([guid]::NewGuid())"
New-Item -ItemType Directory -Path $temp -Force | Out-Null

function Get-ChildPowerShell {
  $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
  if ($pwsh) {
    return [pscustomobject]@{ Command = $pwsh.Source; BaseArgs = @("-NoProfile") }
  }
  $win = Get-Command powershell -ErrorAction SilentlyContinue
  if ($win) {
    return [pscustomobject]@{ Command = $win.Source; BaseArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass") }
  }
  throw "Neither pwsh nor powershell is available."
}

$childPowerShell = Get-ChildPowerShell

function Write-Ledger {
  param([string]$Name, [object[]]$Entries)
  $path = Join-Path $temp $Name
  $Entries | ConvertTo-Json -Depth 8 | Set-Content -Path $path -Encoding UTF8
  return $path
}

function Invoke-Lease {
  param([string]$Path, [int]$ExpectedExit = 0)
  $args = @($childPowerShell.BaseArgs) + @("-File", $script, "-LedgerPath", $Path, "-Json")
  $output = & $childPowerShell.Command @args
  $exit = $LASTEXITCODE
  if ($exit -ne $ExpectedExit) {
    throw "Expected exit $ExpectedExit for $Path, got $exit. Output: $output"
  }
  if ($output) { return ($output | ConvertFrom-Json) }
  return $null
}

try {
  $disjoint = Write-Ledger "disjoint.json" @(
    [pscustomobject]@{ slice_id = "slice-001"; path = "src/a.ts"; status = "active" },
    [pscustomobject]@{ slice_id = "slice-002"; path = "src/b.ts"; status = "active" }
  )
  $result = Invoke-Lease $disjoint
  if (-not $result.ok -or @($result.active_leases).Count -ne 2) {
    throw "Disjoint active leases should pass."
  }

  $collision = Write-Ledger "collision.json" @(
    [pscustomobject]@{ slice_id = "slice-001"; path = "src/shared.ts"; status = "active" },
    [pscustomobject]@{ slice_id = "slice-002"; path = "src/shared.ts"; status = "active" }
  )
  $result = Invoke-Lease $collision 2
  if ($result.ok -or @($result.collisions).Count -ne 1) {
    throw "Overlapping active leases should fail."
  }

  $released = Write-Ledger "released.json" @(
    [pscustomobject]@{ slice_id = "slice-001"; path = "src/shared.ts"; status = "active" },
    [pscustomobject]@{ slice_id = "slice-001"; path = "src/shared.ts"; status = "done" },
    [pscustomobject]@{ slice_id = "slice-002"; path = "src/shared.ts"; status = "active" }
  )
  $result = Invoke-Lease $released
  if (-not $result.ok -or @($result.active_leases).Count -ne 1 -or $result.active_leases[0].slice_id -ne "slice-002") {
    throw "Released lease should allow the next slice."
  }

  $requeued = Write-Ledger "requeued.json" @(
    [pscustomobject]@{ slice_id = "slice-001"; path = "src/shared.ts"; status = "claimed" },
    [pscustomobject]@{ slice_id = "slice-001"; path = "src/shared.ts"; status = "requeued" },
    [pscustomobject]@{ slice_id = "slice-002"; path = "src/shared.ts"; status = "writing" }
  )
  $result = Invoke-Lease $requeued
  if (-not $result.ok -or $result.active_leases[0].slice_id -ne "slice-002") {
    throw "Requeued lease should release the path."
  }

  Write-Output "kb-work scope-lease selftest: passed"
} finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
