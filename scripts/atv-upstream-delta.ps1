param(
  [string]$AtvRepo = "E:\all-the-vibes",
  [string]$BaseRef = "HEAD",
  [string]$UpstreamRef = "upstream/main",
  [string]$ConfigPath = "config/atv-upstream-delta.json",
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

function Invoke-Git {
  param([string]$Repo, [string[]]$Arguments, [switch]$AllowFailure)
  $output = & git -C $Repo @Arguments 2>&1
  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0 -and -not $AllowFailure) {
    throw "git $($Arguments -join ' ') failed ($exitCode): $($output -join "`n")"
  }
  return [pscustomobject]@{ exit_code = $exitCode; output = @($output) }
}

function Test-GitRef {
  param([string]$Repo, [string]$Ref)
  $result = Invoke-Git $Repo @("rev-parse", "--verify", "$Ref^{commit}") -AllowFailure
  return ($result.exit_code -eq 0)
}

function Test-Pattern {
  param([string]$Value, [string[]]$Patterns)
  foreach ($pattern in $Patterns) {
    $regex = "^" + ([regex]::Escape($pattern) -replace "\\\*", ".*") + "$"
    if ($Value -match $regex) {
      return $true
    }
  }
  return $false
}

function Get-SkillNameFromPath {
  param([string]$Path)
  $normalized = $Path -replace "\\", "/"
  $patterns = @(
    "^\.github/skills/([^/]+)/",
    "^pkg/scaffold/templates/skills/([^/]+)/",
    "^plugins/atv-everything/skills/([^/]+)/"
  )
  foreach ($pattern in $patterns) {
    if ($normalized -match $pattern) {
      return $Matches[1]
    }
  }
  return ""
}

function Get-DeltaClass {
  param([string]$Skill, $Config)
  if (Test-Pattern $Skill @($Config.kb_owned)) {
    return "kb-owned-reject"
  }
  if (Test-Pattern $Skill @($Config.shared_overlap)) {
    return "shared-overlap-review"
  }
  if (Test-Pattern $Skill @($Config.superseded_workflows)) {
    return "superseded-workflow-reject"
  }
  if (Test-Pattern $Skill @($Config.atv_native)) {
    return "atv-native-candidate"
  }
  return "unknown-review"
}

function Get-SecurityWarnings {
  param([string]$Repo, [string]$Base, [string]$Upstream, [string]$Skill, [string[]]$Paths, $Config)
  $warnings = @()
  if (-not (Test-Pattern $Skill @($Config.security_sensitive))) {
    return $warnings
  }

  $warnings += "security-sensitive skill; compare OSV/security proof before accepting upstream changes"
  $diff = Invoke-Git $Repo (@("diff", "--unified=0", "$Base..$Upstream", "--") + $Paths) -AllowFailure
  $diffText = $diff.output -join "`n"
  if ($diffText -match "(?im)^-.*osv") {
    $warnings += "possible OSV proof removal detected in upstream delta"
  }
  return $warnings
}

$repoRoot = (Resolve-Path ".").Path
$configFullPath = Resolve-RepoPath $repoRoot $ConfigPath
if (-not (Test-Path $configFullPath)) {
  throw "Config not found: $ConfigPath"
}
$config = Get-Content $configFullPath -Raw | ConvertFrom-Json

if (-not (Test-Path $AtvRepo)) {
  $result = [pscustomobject]@{
    ok = $true
    status = "skipped-explicit"
    reason = "ATV repo not found: $AtvRepo"
    rows = @()
  }
  if ($Json) { $result | ConvertTo-Json -Depth 8 } else { Write-Host $result.reason }
  exit 0
}

$atvFull = (Resolve-Path $AtvRepo).Path
if (-not (Test-GitRef $atvFull $BaseRef)) {
  $result = [pscustomobject]@{
    ok = $true
    status = "skipped-explicit"
    reason = "Base ref not found: $BaseRef"
    rows = @()
  }
  if ($Json) { $result | ConvertTo-Json -Depth 8 } else { Write-Host $result.reason }
  exit 0
}
if (-not (Test-GitRef $atvFull $UpstreamRef)) {
  $result = [pscustomobject]@{
    ok = $true
    status = "skipped-explicit"
    reason = "Upstream ref not found: $UpstreamRef"
    rows = @()
  }
  if ($Json) { $result | ConvertTo-Json -Depth 8 } else { Write-Host $result.reason }
  exit 0
}

$paths = @(".github/skills", "pkg/scaffold/templates/skills", "plugins/atv-everything/skills")
$diff = Invoke-Git $atvFull (@("diff", "--name-status", "--find-renames", "$BaseRef..$UpstreamRef", "--") + $paths)
$pathRows = [System.Collections.Generic.List[object]]::new()
foreach ($line in $diff.output) {
  if (-not "$line".Trim()) {
    continue
  }
  $parts = "$line" -split "`t"
  $status = $parts[0]
  $path = $parts[$parts.Count - 1]
  $skill = Get-SkillNameFromPath $path
  if (-not $skill) {
    continue
  }
  $pathRows.Add([pscustomobject]@{ status = $status; path = $path; skill = $skill })
}

$rows = [System.Collections.Generic.List[object]]::new()
foreach ($group in ($pathRows | Group-Object skill | Sort-Object Name)) {
  $skill = $group.Name
  $skillPaths = @($group.Group | Select-Object -ExpandProperty path | Sort-Object -Unique)
  $rows.Add([pscustomobject]@{
      skill = $skill
      classification = Get-DeltaClass $skill $config
      paths = $skillPaths
      statuses = @($group.Group | Select-Object -ExpandProperty status | Sort-Object -Unique)
      warnings = @(Get-SecurityWarnings $atvFull $BaseRef $UpstreamRef $skill $skillPaths $config)
    })
}

$result = [pscustomobject]@{
  ok = $true
  status = "reported"
  generated_at = (Get-Date).ToString("o")
  atv_repo = $atvFull
  base_ref = $BaseRef
  upstream_ref = $UpstreamRef
  no_apply = $true
  rows = $rows
}

if ($Json) {
  $result | ConvertTo-Json -Depth 10
} else {
  Write-Host "ATV upstream delta: status=$($result.status) rows=$($rows.Count) no_apply=true"
  foreach ($group in ($rows | Group-Object classification | Sort-Object Name)) {
    Write-Host "$($group.Name): $($group.Count)"
  }
  foreach ($row in $rows) {
    Write-Host "$($row.classification) $($row.skill): $(@($row.paths) -join ', ')"
    foreach ($warning in @($row.warnings)) {
      Write-Host "WARN [$($row.skill)] $warning"
    }
  }
}

exit 0
