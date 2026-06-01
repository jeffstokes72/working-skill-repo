param(
  [string]$Root = ".",
  [string]$ConfigPath = "config/skill-marketplace.json",
  [Parameter(Mandatory = $true)][string]$Source,
  [string]$SkillId = "",
  [Parameter(Mandatory = $true)][string]$ApprovalReason,
  [string]$ApprovedBy = $env:USERNAME,
  [string]$SourceType = "local-reviewed",
  [string]$UpstreamRepo = "",
  [string[]]$InstallTargets = @(),
  [string]$CodexSkillsRoot = "$env:USERPROFILE\.codex\skills",
  [string]$CopilotSkillsRoot = "$env:USERPROFILE\.copilot\skills",
  [string]$AgentsSkillsRoot = "$env:USERPROFILE\.agents\skills",
  [switch]$Approved,
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

function Resolve-MarketplacePath {
  param([string]$MarketplaceRoot, [string]$Path)
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path $MarketplaceRoot $Path))
}

function Normalize-PathText {
  param([string]$Path)
  return ([System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/') -replace '/', '\').ToLowerInvariant()
}

function Test-PathUnder {
  param([string]$Path, [string]$Parent)
  $pathText = Normalize-PathText $Path
  $parentText = Normalize-PathText $Parent
  return (($pathText -eq $parentText) -or $pathText.StartsWith("$parentText\"))
}

function Get-FrontmatterValue {
  param([string]$Content, [string]$Field)
  if ($Content -notmatch '(?s)^---\s*(.*?)\s*---') {
    return $null
  }
  $frontmatter = $Matches[1]
  foreach ($line in ($frontmatter -split "`r?`n")) {
    if ($line -match "^\s*$([regex]::Escape($Field))\s*:\s*(.+?)\s*$") {
      return $Matches[1].Trim().Trim("'").Trim('"')
    }
  }
  return $null
}

function Copy-SkillDirectory {
  param([string]$SourceDir, [string]$DestinationDir, [string]$RequiredParent)

  if (-not (Test-PathUnder $DestinationDir $RequiredParent)) {
    throw "Refusing to write outside approved skills path: $DestinationDir"
  }

  if ((Normalize-PathText $SourceDir) -eq (Normalize-PathText $DestinationDir)) {
    return
  }

  if (Test-Path -LiteralPath $DestinationDir) {
    Remove-Item -LiteralPath $DestinationDir -Recurse -Force
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $DestinationDir) | Out-Null
  Copy-Item -LiteralPath $SourceDir -Destination $DestinationDir -Recurse -Force
}

function Read-Catalog {
  param([string]$Path)
  if (Test-Path -LiteralPath $Path) {
    return (Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json)
  }
  return [pscustomobject]@{
    schemaVersion = 1
    skills = @()
  }
}

function Write-Catalog {
  param($Catalog, [string]$Path)
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
  $Catalog | ConvertTo-Json -Depth 12 | Set-Content -Path $Path -Encoding UTF8
  $null = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
}

function Get-TargetRoot {
  param([string]$Target)
  switch ($Target.ToLowerInvariant()) {
    "codex" { return $CodexSkillsRoot }
    "copilot" { return $CopilotSkillsRoot }
    "agents" { return $AgentsSkillsRoot }
    default { throw "Unknown install target '$Target'. Use codex, copilot, agents, or omit -InstallTargets." }
  }
}

if (-not $Approved) {
  throw "Promotion requires explicit -Approved after human review. Refusing to mutate marketplace/catalog/globals."
}

$repoRoot = (Resolve-Path $Root).Path
$configFullPath = Resolve-RepoPath $repoRoot $ConfigPath
if (-not (Test-Path -LiteralPath $configFullPath)) {
  throw "Marketplace config not found: $configFullPath"
}

$config = Get-Content -Raw -LiteralPath $configFullPath | ConvertFrom-Json
$marketplaceRoot = Resolve-RepoPath $repoRoot "$($config.marketplace.local_root)"
$approvedSkillsPath = Resolve-MarketplacePath $marketplaceRoot "$($config.marketplace.directories.approved_skills)"
$approvedCatalogPath = Resolve-MarketplacePath $marketplaceRoot "$($config.marketplace.directories.approved_catalog)"
$quarantinePath = Resolve-MarketplacePath $marketplaceRoot "$($config.marketplace.directories.quarantine)"

$sourcePath = Resolve-RepoPath $repoRoot $Source
if (-not (Test-Path -LiteralPath $sourcePath)) {
  throw "Source skill path not found: $sourcePath"
}

$sourceItem = Get-Item -LiteralPath $sourcePath
$sourceDir = if ($sourceItem.PSIsContainer) { $sourceItem.FullName } else { Split-Path -Parent $sourceItem.FullName }
$sourceSkillFile = Join-Path $sourceDir "SKILL.md"
if (-not (Test-Path -LiteralPath $sourceSkillFile)) {
  throw "Source skill is missing SKILL.md: $sourceSkillFile"
}

$skillContent = Get-Content -Raw -LiteralPath $sourceSkillFile
$declaredName = Get-FrontmatterValue $skillContent "name"
$declaredDescription = Get-FrontmatterValue $skillContent "description"
if (-not $declaredName) {
  throw "Source SKILL.md is missing frontmatter field 'name'."
}
if (-not $declaredDescription) {
  throw "Source SKILL.md is missing frontmatter field 'description'."
}

if (-not $SkillId) {
  $SkillId = Split-Path -Leaf $sourceDir
}
if ($declaredName -ne $SkillId) {
  throw "Source SKILL.md frontmatter name '$declaredName' does not match SkillId '$SkillId'."
}

$destinationDir = Resolve-MarketplacePath $marketplaceRoot (Join-Path "$($config.marketplace.directories.approved_skills)" $SkillId)
if (Test-PathUnder $destinationDir $quarantinePath) {
  throw "Refusing to place approved skill under quarantine: $destinationDir"
}

Copy-SkillDirectory $sourceDir $destinationDir $approvedSkillsPath

$destinationSkillFile = Join-Path $destinationDir "SKILL.md"
$sha256 = (Get-FileHash -LiteralPath $destinationSkillFile -Algorithm SHA256).Hash.ToLowerInvariant()

$catalog = Read-Catalog $approvedCatalogPath
$existingSkills = @($catalog.skills | Where-Object { $_.id -ne $SkillId })
$sourceRecord = [ordered]@{
  type = $SourceType
  path = ($sourceDir -replace '\\', '/')
}
if ($UpstreamRepo) {
  $sourceRecord["upstreamRepo"] = ($UpstreamRepo -replace '\\', '/')
}

$entry = [ordered]@{
  id = $SkillId
  status = "approved"
  source = $sourceRecord
  marketplacePath = "skills/$SkillId"
  sha256 = $sha256
  approvedBy = $ApprovedBy
  approvedAt = (Get-Date -Format "yyyy-MM-dd")
  approvalReason = $ApprovalReason
  evidence = [ordered]@{
    proofCommands = @(
      "Get-FileHash $($sourceSkillFile -replace '\\', '/') -Algorithm SHA256",
      "Get-FileHash $($destinationSkillFile -replace '\\', '/') -Algorithm SHA256"
    )
  }
}

$catalog.skills = @($existingSkills + @([pscustomobject]$entry))
Write-Catalog $catalog $approvedCatalogPath

$synced = [System.Collections.Generic.List[object]]::new()
$normalizedTargets = @($InstallTargets | Where-Object { $_ -and ($_.ToLowerInvariant() -ne "none") })
foreach ($target in $normalizedTargets) {
  $targetRoot = [System.IO.Path]::GetFullPath((Get-TargetRoot $target))
  $targetDir = [System.IO.Path]::GetFullPath((Join-Path $targetRoot $SkillId))
  if (Test-PathUnder $targetDir $quarantinePath) {
    throw "Refusing to sync a runtime skill target into quarantine: $targetDir"
  }
  Copy-SkillDirectory $destinationDir $targetDir $targetRoot
  $targetHash = (Get-FileHash -LiteralPath (Join-Path $targetDir "SKILL.md") -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($targetHash -ne $sha256) {
    throw "Hash mismatch after syncing '$target': expected $sha256, got $targetHash"
  }
  $synced.Add([pscustomobject]@{
      target = $target
      path = $targetDir
      sha256 = $targetHash
    })
}

$catalogCheck = Get-Content -Raw -LiteralPath $approvedCatalogPath | ConvertFrom-Json
$catalogEntry = @($catalogCheck.skills | Where-Object { $_.id -eq $SkillId }) | Select-Object -First 1
if (-not $catalogEntry) {
  throw "Catalog entry missing after promotion: $SkillId"
}
if ($catalogEntry.sha256 -ne $sha256) {
  throw "Catalog hash mismatch after promotion: expected $sha256, got $($catalogEntry.sha256)"
}

$firebreakScript = Join-Path $repoRoot "scripts/skill-marketplace-firebreak.ps1"
if (-not (Test-Path -LiteralPath $firebreakScript)) {
  throw "Firebreak script not found: $firebreakScript"
}
Invoke-KbPowerShellFile $firebreakScript @("-Root", $repoRoot, "-ConfigPath", $ConfigPath) | Out-Null
if ($LASTEXITCODE -ne 0) {
  throw "Marketplace firebreak failed after promotion."
}

$result = [pscustomobject]@{
  ok = $true
  skill_id = $SkillId
  source = $sourceDir
  marketplace_path = $destinationDir
  catalog_path = $approvedCatalogPath
  sha256 = $sha256
  install_targets = @($synced)
  firebreak = "passed"
}

if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  Write-Host "Promoted marketplace skill: $SkillId"
  Write-Host "marketplace=$destinationDir"
  Write-Host "sha256=$sha256"
  if ($synced.Count -gt 0) {
    foreach ($target in $synced) {
      Write-Host "synced=$($target.target) path=$($target.path)"
    }
  } else {
    Write-Host "synced=none"
  }
  Write-Host "firebreak=passed"
}

exit 0
