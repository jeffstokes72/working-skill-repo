param(
  [string]$Root = ".",
  [string]$ConfigPath = "config/skill-marketplace.json"
)

$ErrorActionPreference = "Stop"

function Resolve-RepoPath {
  param([string]$Base, [string]$Path)
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path $Base $Path))
}

function Invoke-Firebreak {
  param([string]$RepoRoot, [string]$Config)
  & powershell -ExecutionPolicy Bypass -File (Join-Path $RepoRoot "scripts/skill-marketplace-firebreak.ps1") -Root $RepoRoot -ConfigPath $Config | Out-Null
  return $LASTEXITCODE
}

$repoRoot = (Resolve-Path $Root).Path
$configFullPath = Resolve-RepoPath $repoRoot $ConfigPath
$tempRoot = Join-Path $repoRoot ".atv/tmp/skill-marketplace-firebreak-selftest"
$badConfigPath = Join-Path $tempRoot "bad-config.json"
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

try {
  $validExit = Invoke-Firebreak $repoRoot $ConfigPath
  if ($validExit -ne 0) {
    throw "Expected valid marketplace firebreak config to pass, got exit $validExit."
  }

  $config = Get-Content $configFullPath -Raw | ConvertFrom-Json
  $quarantinePath = Join-Path "$($config.marketplace.local_root)" "$($config.marketplace.directories.quarantine)"
  if (-not ($config.PSObject.Properties.Name -contains "quarantine_firebreak")) {
    $config | Add-Member -MemberType NoteProperty -Name "quarantine_firebreak" -Value ([pscustomobject]@{})
  }
  $config.quarantine_firebreak | Add-Member -MemberType NoteProperty -Name "never_load_from_quarantine" -Value $true -Force
  $config.quarantine_firebreak | Add-Member -MemberType NoteProperty -Name "additional_active_skill_roots" -Value @($quarantinePath) -Force
  $config | ConvertTo-Json -Depth 12 | Set-Content -Path $badConfigPath -Encoding UTF8

  $badConfigRelative = ".atv/tmp/skill-marketplace-firebreak-selftest/bad-config.json"
  $badExit = Invoke-Firebreak $repoRoot $badConfigRelative
  if ($badExit -eq 0) {
    throw "Expected marketplace firebreak to fail when an active skill root points at quarantine."
  }

  Write-Host "Skill marketplace firebreak selftest: valid config passed; quarantined active root failed."
} finally {
  if (Test-Path $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}

exit 0
