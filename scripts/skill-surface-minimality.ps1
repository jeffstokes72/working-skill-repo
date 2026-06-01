param(
  [string]$Root = ".",
  [string]$SkillRoot = ".github/skills",
  [string]$AgentRoot = ".github/agents",
  [int]$TrimLineThreshold = 250,
  [string[]]$HotPathSkills = @("kb-start", "kb-map", "kb-brainstorm", "kb-plan", "kb-work", "kb-complete", "kb-review", "kb-check"),
  [string[]]$ProtectedSkills = @("kb-review", "ce-review", "ce-compound", "ce-compound-refresh", "document-review"),
  [string[]]$ProtectedAgents = @(),
  [string[]]$UnusedCandidatePatterns = @("ce-ideate", "ce-plan", "ce-work", "lfg", "slfg", "workflows-*"),
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

function Get-TextTokenEstimate {
  param([string]$Text)
  return @($Text -split "\s+" | Where-Object { $_ }).Count
}

function Get-AgentName {
  param([System.IO.FileInfo]$File)
  return ($File.BaseName -replace "\.agent$", "")
}

function Test-TokenReference {
  param([string]$Text, [string]$Name)
  $escaped = [regex]::Escape($Name)
  return [regex]::IsMatch($Text, "(?i)(^|[^A-Za-z0-9_-])$escaped([^A-Za-z0-9_-]|$)")
}

function Test-NamePattern {
  param([string]$Name, [string[]]$Patterns)
  foreach ($pattern in $Patterns) {
    $regex = "^" + ([regex]::Escape($pattern) -replace "\\\*", ".*") + "$"
    if ($Name -match $regex) {
      return $true
    }
  }
  return $false
}

$repoRoot = (Resolve-Path $Root).Path
$skillRootFull = Resolve-RepoPath $repoRoot $SkillRoot
$agentRootFull = Resolve-RepoPath $repoRoot $AgentRoot

if (-not (Test-Path $skillRootFull)) {
  throw "Skill root not found: $SkillRoot"
}

$skillFiles = @(Get-ChildItem $skillRootFull -Directory | Sort-Object Name | ForEach-Object {
    $skillPath = Join-Path $_.FullName "SKILL.md"
    if (Test-Path $skillPath) {
      $content = Get-Content $skillPath -Raw
      [pscustomobject]@{
        name = $_.Name
        path = $skillPath
        content = $content
        lines = @($content -split "`r?`n").Count
        token_estimate = Get-TextTokenEstimate $content
      }
    }
  })

$agentFiles = @()
if (Test-Path $agentRootFull) {
  $agentFiles = @(Get-ChildItem $agentRootFull -Filter "*.agent.md" -File | Sort-Object Name | ForEach-Object {
      $content = Get-Content $_.FullName -Raw
      [pscustomobject]@{
        name = Get-AgentName $_
        path = $_.FullName
        content = $content
        lines = @($content -split "`r?`n").Count
        token_estimate = Get-TextTokenEstimate $content
      }
    })
}

$skillNames = @($skillFiles | Select-Object -ExpandProperty name)
$skillReferences = @{}
foreach ($skill in $skillFiles) {
  $refs = @()
  foreach ($candidate in $skillNames) {
    if ($candidate -ne $skill.name -and (Test-TokenReference $skill.content $candidate)) {
      $refs += $candidate
    }
  }
  $skillReferences[$skill.name] = @($refs | Sort-Object -Unique)
}

$agentReferences = @{}
foreach ($agent in $agentFiles) {
  $refs = @()
  foreach ($skill in $skillFiles) {
    if (Test-TokenReference $skill.content $agent.name) {
      $refs += $skill.name
    }
  }
  $agentReferences[$agent.name] = @($refs | Sort-Object -Unique)
}

$skillRows = [System.Collections.Generic.List[object]]::new()
foreach ($skill in $skillFiles) {
  $referencedBy = @($skillReferences.Keys | Where-Object { @($skillReferences[$_]) -contains $skill.name } | Sort-Object)
  $classification = "conditional"
  $reason = "referenced by workflow skills or available as an explicit lane"
  if ($ProtectedSkills -contains $skill.name) {
    $classification = "protected"
    $reason = "protected by repo policy; do not delete unless callers and docs are rewritten"
  } elseif ($HotPathSkills -contains $skill.name) {
    $classification = "required"
    $reason = "hot-path KB workflow skill"
  } elseif ($referencedBy.Count -eq 0 -and (Test-NamePattern $skill.name $UnusedCandidatePatterns)) {
    $classification = "unused-candidate"
    $reason = "matches superseded workflow pattern and has no static inbound skill reference; cold-storage review only"
  } elseif ($skill.lines -gt $TrimLineThreshold) {
    $classification = "trim-candidate"
    $reason = "over trim threshold; review for lazy-loading or line reduction before deletion"
  } elseif ($referencedBy.Count -eq 0) {
    $classification = "unproven"
    $reason = "no static inbound skill reference found; runtime usage may still exist"
  }

  $skillRows.Add([pscustomobject]@{
      kind = "skill"
      name = $skill.name
      classification = $classification
      reason = $reason
      lines = $skill.lines
      token_estimate = $skill.token_estimate
      referenced_by = $referencedBy
      references = @($skillReferences[$skill.name])
    })
}

$agentRows = [System.Collections.Generic.List[object]]::new()
foreach ($agent in $agentFiles) {
  $referencedBy = @($agentReferences[$agent.name])
  $hotRefs = @($referencedBy | Where-Object { $HotPathSkills -contains $_ })
  $classification = "unproven"
  $reason = "no static skill reference found; do not delete without runtime proof"
  if ($ProtectedAgents -contains $agent.name) {
    $classification = "protected"
    $reason = "protected by repo policy; do not delete unless dispatch policy is rewritten"
  } elseif ($hotRefs.Count -gt 0) {
    $classification = "required"
    $reason = "referenced by hot-path skill(s): $($hotRefs -join ', ')"
  } elseif ($referencedBy.Count -gt 0) {
    $classification = "conditional"
    $reason = "referenced by non-hot-path skill(s): $($referencedBy -join ', ')"
  } elseif ($agent.lines -gt $TrimLineThreshold) {
    $classification = "trim-candidate"
    $reason = "unreferenced and over trim threshold; cold-storage review candidate"
  }

  $agentRows.Add([pscustomobject]@{
      kind = "agent"
      name = $agent.name
      classification = $classification
      reason = $reason
      lines = $agent.lines
      token_estimate = $agent.token_estimate
      referenced_by = $referencedBy
      references = @()
    })
}

$allRows = @($skillRows) + @($agentRows)
$coldStorage = @($allRows | Where-Object { @("unproven", "unused-candidate", "trim-candidate") -contains $_.classification } | Sort-Object kind, name)
$report = [pscustomobject]@{
  generated_at = (Get-Date).ToString("o")
  root = $repoRoot
  skill_root = $skillRootFull
  agent_root = $agentRootFull
  static_only = $true
  labels = @("protected", "required", "conditional", "unproven", "unused-candidate", "trim-candidate")
  skill_classifications = $skillRows
  agent_classifications = $agentRows
  cold_storage_candidates = $coldStorage
}

if ($Json) {
  $report | ConvertTo-Json -Depth 8
} else {
  Write-Host "Skill surface minimality report: static-only=true"
  Write-Host "Skills: $($skillRows.Count); agents: $($agentRows.Count); cold-storage candidates: $($coldStorage.Count)"
  foreach ($group in ($allRows | Group-Object classification | Sort-Object Name)) {
    Write-Host "$($group.Name): $($group.Count)"
  }
  if ($coldStorage.Count -gt 0) {
    Write-Host ""
    Write-Host "Cold-storage candidates, not deletion approvals:"
    foreach ($row in $coldStorage) {
      Write-Host "$($row.classification) [$($row.kind)] $($row.name): $($row.reason)"
    }
  }
}

exit 0
