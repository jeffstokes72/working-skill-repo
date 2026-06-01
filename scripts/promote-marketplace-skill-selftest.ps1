param(
  [string]$Root = "."
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

function Write-TextFile {
  param([string]$Path, [string]$Content)
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
  Set-Content -Path $Path -Value $Content -Encoding UTF8
}

function New-TestConfig {
  param([string]$MarketplaceRoot, [string]$ApprovedSkills = "skills")
  [pscustomobject]@{
    schema_version = 1
    marketplace = [pscustomobject]@{
      id = "selftest-marketplace"
      local_root = ($MarketplaceRoot -replace '\\', '/')
      remote = ""
      trust_model = "private-approved-catalog"
      directories = [pscustomobject]@{
        approved_skills = $ApprovedSkills
        pipelines = "pipelines"
        harnesses = "harnesses"
        approved_catalog = "catalog/approved-skills.json"
        quarantine_catalog = "catalog/quarantined-skills.json"
        quarantine = "quarantine"
        scripts = "scripts"
      }
    }
    project_local_paths = [pscustomobject]@{
      skills = ".github/skills"
    }
    quarantine_firebreak = [pscustomobject]@{
      never_load_from_quarantine = $true
      additional_active_skill_roots = @()
    }
  }
}

function Invoke-Promotion {
  param(
    [string]$RepoRoot,
    [string]$ConfigPath,
    [string]$SourcePath,
    [string]$GlobalRoot,
    [switch]$ExpectFailure
  )

  $previousErrorActionPreference = $ErrorActionPreference
  if ($ExpectFailure) {
    $ErrorActionPreference = "Continue"
  }
  try {
    Invoke-KbPowerShellFile (Join-Path $RepoRoot "scripts/promote-marketplace-skill.ps1") @(
      "-Root", $RepoRoot,
      "-ConfigPath", $ConfigPath,
      "-Source", $SourcePath,
      "-SkillId", "selftest-skill",
      "-ApprovalReason", "selftest approval",
      "-ApprovedBy", "selftest",
      "-SourceType", "selftest",
      "-InstallTargets", "codex",
      "-CodexSkillsRoot", $GlobalRoot,
      "-Approved",
      "-Json"
    ) *> $null
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }

  $exit = $LASTEXITCODE
  if ($ExpectFailure) {
    if ($exit -eq 0) {
      throw "Expected promotion to fail, but it succeeded."
    }
  } elseif ($exit -ne 0) {
    throw "Expected promotion to pass, got exit $exit."
  }
}

$repoRoot = (Resolve-Path $Root).Path
$tempRoot = Join-Path $repoRoot ".atv/tmp/promote-marketplace-skill-selftest"
$sourceRoot = Join-Path $tempRoot "source/selftest-skill"
$marketplaceRoot = Join-Path $tempRoot "marketplace"
$globalRoot = Join-Path $tempRoot "globals/codex"
$configPath = Join-Path $tempRoot "config.json"
$badConfigPath = Join-Path $tempRoot "bad-config.json"

if (Test-Path -LiteralPath $tempRoot) {
  Remove-Item -LiteralPath $tempRoot -Recurse -Force
}

try {
  New-Item -ItemType Directory -Force -Path $sourceRoot, $marketplaceRoot, $globalRoot | Out-Null
  Write-TextFile (Join-Path $sourceRoot "SKILL.md") @'
---
name: selftest-skill
description: Selftest fixture skill for marketplace promotion.
argument-hint: "[selftest]"
---

# Selftest Skill

Used only by `promote-marketplace-skill-selftest.ps1`.
'@

  New-Item -ItemType Directory -Force -Path (Join-Path $marketplaceRoot "catalog"), (Join-Path $marketplaceRoot "quarantine"), (Join-Path $marketplaceRoot "skills") | Out-Null
  Write-TextFile (Join-Path $marketplaceRoot "catalog/approved-skills.json") '{"schemaVersion":1,"skills":[]}'
  Write-TextFile (Join-Path $marketplaceRoot "catalog/quarantined-skills.json") '{"schemaVersion":1,"skills":[]}'

  New-TestConfig $marketplaceRoot | ConvertTo-Json -Depth 12 | Set-Content -Path $configPath -Encoding UTF8
  Invoke-Promotion $repoRoot $configPath $sourceRoot $globalRoot

  $approvedSkill = Join-Path $marketplaceRoot "skills/selftest-skill/SKILL.md"
  $syncedSkill = Join-Path $globalRoot "selftest-skill/SKILL.md"
  if (-not (Test-Path -LiteralPath $approvedSkill)) {
    throw "Approved skill copy was not created."
  }
  if (-not (Test-Path -LiteralPath $syncedSkill)) {
    throw "Global sync copy was not created."
  }

  $approvedHash = (Get-FileHash -LiteralPath $approvedSkill -Algorithm SHA256).Hash.ToLowerInvariant()
  $syncedHash = (Get-FileHash -LiteralPath $syncedSkill -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($approvedHash -ne $syncedHash) {
    throw "Synced skill hash mismatch."
  }

  $catalog = Get-Content -Raw -LiteralPath (Join-Path $marketplaceRoot "catalog/approved-skills.json") | ConvertFrom-Json
  $entry = @($catalog.skills | Where-Object { $_.id -eq "selftest-skill" }) | Select-Object -First 1
  if (-not $entry) {
    throw "Approved catalog entry was not written."
  }
  if ($entry.sha256 -ne $approvedHash) {
    throw "Approved catalog hash mismatch."
  }

  New-TestConfig $marketplaceRoot "quarantine/approved-skills" | ConvertTo-Json -Depth 12 | Set-Content -Path $badConfigPath -Encoding UTF8
  Invoke-Promotion $repoRoot $badConfigPath $sourceRoot $globalRoot -ExpectFailure

  Write-Host "Marketplace promotion selftest: happy path promoted and synced; quarantine approved path failed."
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}

exit 0
