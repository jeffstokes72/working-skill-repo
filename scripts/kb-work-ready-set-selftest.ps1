Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$script = Join-Path $root "scripts/kb-work-ready-set.ps1"
$temp = Join-Path $root ".atv/ready-set-selftest-$([guid]::NewGuid())"
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

function Write-Manifest {
  param([string]$Name, [string]$Body)
  $path = Join-Path $temp $Name
  Set-Content -Path $path -Value $Body -Encoding UTF8
  return $path
}

function Invoke-ReadySet {
  param([string]$Path, [int]$ExpectedExit = 0)
  $args = @($childPowerShell.BaseArgs) + @("-File", $script, "-ManifestPath", $Path, "-Json")
  $output = & $childPowerShell.Command @args
  $exit = $LASTEXITCODE
  if ($exit -ne $ExpectedExit) {
    throw "Expected exit $ExpectedExit for $Path, got $exit. Output: $output"
  }
  if ($output) { return ($output | ConvertFrom-Json) }
  return $null
}

try {
  $parallel = Write-Manifest "parallel.md" @'
---
type: kb-manifest
slices:
  - id: slice-001
    blockers: []
    status: pending
    hitl: false
    can_continue_other_slices: true
  - id: slice-002
    blockers: []
    status: pending
    hitl: false
    can_continue_other_slices: true
  - id: slice-003
    blockers: [slice-001]
    status: pending
    hitl: false
    can_continue_other_slices: true
---
'@
  $result = Invoke-ReadySet $parallel
  if (@($result.ready) -join "," -ne "slice-001,slice-002") {
    throw "Parallel ready set mismatch: $(@($result.ready) -join ',')"
  }

  $serial = Write-Manifest "serial.md" @'
---
type: kb-manifest
slices:
  - id: slice-001
    blockers: []
    status: pending
    hitl: false
    can_continue_other_slices: false
  - id: slice-002
    blockers: []
    status: pending
    hitl: false
    can_continue_other_slices: true
---
'@
  $result = Invoke-ReadySet $serial
  if (@($result.ready) -join "," -ne "slice-002") {
    throw "Serial exclusion mismatch: $(@($result.ready) -join ',')"
  }

  $singleSerial = Write-Manifest "single-serial.md" @'
---
type: kb-manifest
slices:
  - id: slice-001
    blockers: []
    status: pending
    hitl: false
    can_continue_other_slices: false
---
'@
  $result = Invoke-ReadySet $singleSerial
  if (@($result.ready) -join "," -ne "slice-001") {
    throw "Single serial ready mismatch: $(@($result.ready) -join ',')"
  }

  $states = Write-Manifest "states.md" @'
---
type: kb-manifest
slices:
  - id: slice-001
    blockers: []
    status: done
    hitl: false
    can_continue_other_slices: true
  - id: slice-002
    blockers: []
    status: skipped
    hitl: false
    can_continue_other_slices: true
  - id: slice-003
    blockers: []
    status: blocked
    hitl: false
    can_continue_other_slices: true
  - id: slice-004
    blockers: [slice-001, slice-002]
    status: pending
    hitl: false
    can_continue_other_slices: true
---
'@
  $result = Invoke-ReadySet $states
  if (@($result.ready) -join "," -ne "slice-004") {
    throw "State filtering mismatch: $(@($result.ready) -join ',')"
  }

  $cycle = Write-Manifest "cycle.md" @'
---
type: kb-manifest
slices:
  - id: slice-001
    blockers: [slice-002]
    status: pending
    hitl: false
    can_continue_other_slices: true
  - id: slice-002
    blockers: [slice-001]
    status: pending
    hitl: false
    can_continue_other_slices: true
---
'@
  $null = Invoke-ReadySet $cycle 2

  Write-Output "kb-work ready-set selftest: passed"
} finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
