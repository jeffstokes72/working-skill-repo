param(
  [string]$Root = ".",
  [string]$ConfigPath = "config/skill-marketplace.json",
  [switch]$Json
)

$ErrorActionPreference = "Stop"

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

function Add-Issue {
  param($Issues, [string]$Kind, [string]$Path, [string]$Message)
  $Issues.Add([pscustomobject]@{
      kind = $Kind
      path = $Path
      message = $Message
    })
}

function Get-StringProperty {
  param($Object, [string]$Name)
  if ($Object -and ($Object.PSObject.Properties.Name -contains $Name)) {
    return "$($Object.$Name)"
  }
  return ""
}

function Get-KnownSkillRoots {
  param($Config, [string]$RepoRoot, [string]$MarketplaceRoot)

  $roots = [System.Collections.Generic.List[string]]::new()
  $projectSkillPath = Get-StringProperty $Config.project_local_paths "skills"
  if ($projectSkillPath) {
    $roots.Add((Resolve-RepoPath $RepoRoot $projectSkillPath))
  }

  $approvedSkills = Get-StringProperty $Config.marketplace.directories "approved_skills"
  if ($approvedSkills) {
    $roots.Add((Resolve-MarketplacePath $MarketplaceRoot $approvedSkills))
  }

  if ($env:USERPROFILE) {
    foreach ($relative in @(".codex\skills", ".copilot\skills", ".agents\skills")) {
      $roots.Add([System.IO.Path]::GetFullPath((Join-Path $env:USERPROFILE $relative)))
    }
  }

  if ($Config.quarantine_firebreak -and ($Config.quarantine_firebreak.PSObject.Properties.Name -contains "additional_active_skill_roots")) {
    foreach ($root in @($Config.quarantine_firebreak.additional_active_skill_roots)) {
      if ("$root") {
        $roots.Add((Resolve-RepoPath $RepoRoot "$root"))
      }
    }
  }

  return @($roots | Select-Object -Unique)
}

function Test-SkillRoot {
  param([string]$RootPath, [string]$QuarantinePath, $Issues)

  if (Test-PathUnder $RootPath $QuarantinePath) {
    Add-Issue $Issues "active-root-in-quarantine" $RootPath "Active or approved skill roots must never point into marketplace quarantine."
  }

  if (-not (Test-Path $RootPath)) {
    return
  }

  $rootItem = Get-Item -LiteralPath $RootPath -Force
  $items = @($rootItem) + @(Get-ChildItem -LiteralPath $RootPath -Directory -Force -ErrorAction SilentlyContinue)
  foreach ($item in $items) {
    if (Test-PathUnder $item.FullName $QuarantinePath) {
      Add-Issue $Issues "skill-path-in-quarantine" $item.FullName "A loadable skill path is inside marketplace quarantine."
    }

    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -and ($item.PSObject.Properties.Name -contains "Target")) {
      foreach ($target in @($item.Target)) {
        if (-not "$target") {
          continue
        }
        $targetPath = if ([System.IO.Path]::IsPathRooted("$target")) {
          [System.IO.Path]::GetFullPath("$target")
        } else {
          [System.IO.Path]::GetFullPath((Join-Path (Split-Path $item.FullName -Parent) "$target"))
        }
        if (Test-PathUnder $targetPath $QuarantinePath) {
          Add-Issue $Issues "skill-link-target-in-quarantine" $item.FullName "A loadable skill directory links into marketplace quarantine."
        }
      }
    }
  }
}

function Test-ApprovedCatalog {
  param(
    [string]$MarketplaceRoot,
    [string]$ApprovedCatalogPath,
    [string]$ApprovedSkillsPath,
    [string]$QuarantinePath,
    $Issues
  )

  if (-not (Test-Path $ApprovedCatalogPath)) {
    return
  }

  $catalog = Get-Content $ApprovedCatalogPath -Raw | ConvertFrom-Json
  foreach ($skill in @($catalog.skills)) {
    $name = Get-StringProperty $skill "name"
    $status = Get-StringProperty $skill "status"
    if ($status -and ($status -ne "approved")) {
      Add-Issue $Issues "approved-catalog-status" $ApprovedCatalogPath "Approved catalog entry '$name' has non-approved status '$status'."
    }

    foreach ($field in @("marketplacePath", "localPath", "path")) {
      $value = Get-StringProperty $skill $field
      if (-not $value) {
        continue
      }
      $resolved = Resolve-MarketplacePath $MarketplaceRoot $value
      if (Test-PathUnder $resolved $QuarantinePath) {
        Add-Issue $Issues "approved-catalog-quarantine-path" $resolved "Approved catalog entry '$name' resolves field '$field' into quarantine."
      }
      if (($field -eq "marketplacePath") -and (-not (Test-PathUnder $resolved $ApprovedSkillsPath))) {
        Add-Issue $Issues "approved-catalog-outside-approved-skills" $resolved "Approved catalog entry '$name' must resolve marketplacePath under approved skills."
      }
    }

    if ($skill.source) {
      $sourcePath = Get-StringProperty $skill.source "path"
      if ($sourcePath) {
        $resolvedSource = Resolve-MarketplacePath $MarketplaceRoot $sourcePath
        if (Test-PathUnder $resolvedSource $QuarantinePath) {
          Add-Issue $Issues "approved-source-in-quarantine" $resolvedSource "Approved catalog entry '$name' cannot load from quarantine as its source path."
        }
      }
    }
  }
}

function Test-QuarantineCatalog {
  param([string]$QuarantineCatalogPath, $Issues)

  if (-not (Test-Path $QuarantineCatalogPath)) {
    return
  }

  $catalog = Get-Content $QuarantineCatalogPath -Raw | ConvertFrom-Json
  foreach ($skill in @($catalog.skills)) {
    $name = Get-StringProperty $skill "name"
    $status = (Get-StringProperty $skill "status").ToLowerInvariant()
    if ($status -eq "approved") {
      Add-Issue $Issues "quarantine-entry-approved" $QuarantineCatalogPath "Quarantine catalog entry '$name' is marked approved; move it to the approved catalog after review instead."
    }
  }
}

$repoRoot = (Resolve-Path $Root).Path
$configFullPath = Resolve-RepoPath $repoRoot $ConfigPath
if (-not (Test-Path $configFullPath)) {
  throw "Marketplace config not found: $configFullPath"
}

$config = Get-Content $configFullPath -Raw | ConvertFrom-Json
$marketplaceRoot = Resolve-RepoPath $repoRoot "$($config.marketplace.local_root)"
$quarantinePath = Resolve-MarketplacePath $marketplaceRoot "$($config.marketplace.directories.quarantine)"
$approvedSkillsPath = Resolve-MarketplacePath $marketplaceRoot "$($config.marketplace.directories.approved_skills)"
$approvedCatalogPath = Resolve-MarketplacePath $marketplaceRoot "$($config.marketplace.directories.approved_catalog)"
$quarantineCatalogPath = Resolve-MarketplacePath $marketplaceRoot "$($config.marketplace.directories.quarantine_catalog)"

$issues = [System.Collections.Generic.List[object]]::new()

if (-not $config.quarantine_firebreak -or -not [bool]$config.quarantine_firebreak.never_load_from_quarantine) {
  Add-Issue $issues "missing-firebreak-policy" $configFullPath "Config must set quarantine_firebreak.never_load_from_quarantine=true."
}

$checkedRoots = @(Get-KnownSkillRoots $config $repoRoot $marketplaceRoot)
foreach ($rootPath in $checkedRoots) {
  Test-SkillRoot $rootPath $quarantinePath $issues
}

Test-ApprovedCatalog $marketplaceRoot $approvedCatalogPath $approvedSkillsPath $quarantinePath $issues
Test-QuarantineCatalog $quarantineCatalogPath $issues

$result = [pscustomobject]@{
  ok = ($issues.Count -eq 0)
  marketplace_root = $marketplaceRoot
  quarantine_path = $quarantinePath
  checked_skill_roots = $checkedRoots
  issue_count = $issues.Count
  issues = $issues
}

if ($Json) {
  $result | ConvertTo-Json -Depth 8
} else {
  Write-Host "Skill marketplace firebreak: issues=$($issues.Count)"
  Write-Host "quarantine=$quarantinePath"
  foreach ($issue in $issues) {
    Write-Host "ERROR [$($issue.kind)] $($issue.path): $($issue.message)"
  }
}

if ($issues.Count -gt 0) {
  exit 1
}

exit 0
