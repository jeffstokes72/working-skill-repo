param()

$ErrorActionPreference = "Stop"

function Write-TextFile {
  param([string]$Path, [string]$Text)
  $dir = Split-Path $Path -Parent
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
  $Text | Set-Content -Path $Path -Encoding UTF8
}

$root = Join-Path ([System.IO.Path]::GetTempPath()) "skill-minimality-$([guid]::NewGuid())"
try {
  Write-TextFile (Join-Path $root ".github/skills/kb-start/SKILL.md") @"
---
name: kb-start
description: route requests
---
Use correctness-reviewer and kb-work.
"@

  Write-TextFile (Join-Path $root ".github/skills/kb-work/SKILL.md") @"
---
name: kb-work
description: run work
---
Run plans and call conditional-reviewer for special checks.
"@

  Write-TextFile (Join-Path $root ".github/skills/feature-lane/SKILL.md") @"
---
name: feature-lane
description: optional lane
---
Use conditional-reviewer when needed.
"@

  Write-TextFile (Join-Path $root ".github/skills/ce-review/SKILL.md") @"
---
name: ce-review
description: protected generalized review skill
---
Protected even when static inbound references are absent.
"@

  Write-TextFile (Join-Path $root ".github/skills/giant-skill/SKILL.md") @"
---
name: giant-skill
description: large skill
---
one
two
three
four
five
six
seven
"@

  Write-TextFile (Join-Path $root ".github/skills/workflows-old/SKILL.md") @"
---
name: workflows-old
description: superseded workflow
---
old alias
"@

  Write-TextFile (Join-Path $root ".github/agents/correctness-reviewer.agent.md") "required"
  Write-TextFile (Join-Path $root ".github/agents/conditional-reviewer.agent.md") "conditional"
  Write-TextFile (Join-Path $root ".github/agents/unreferenced-reviewer.agent.md") "unproven"

  $script = Join-Path $PSScriptRoot "skill-surface-minimality.ps1"
  $jsonText = & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Root $root -TrimLineThreshold 6 -Json
  if ($LASTEXITCODE -ne 0) {
    throw "minimality report exited nonzero"
  }
  $report = ($jsonText -join "`n") | ConvertFrom-Json

  $requiredAgent = @($report.agent_classifications | Where-Object { $_.name -eq "correctness-reviewer" }) | Select-Object -First 1
  if (-not $requiredAgent -or $requiredAgent.classification -ne "required") {
    throw "expected correctness-reviewer to be required"
  }

  $conditionalAgent = @($report.agent_classifications | Where-Object { $_.name -eq "conditional-reviewer" }) | Select-Object -First 1
  if (-not $conditionalAgent -or $conditionalAgent.classification -ne "required") {
    throw "expected conditional-reviewer to be required because kb-work is hot path"
  }

  $unprovenAgent = @($report.agent_classifications | Where-Object { $_.name -eq "unreferenced-reviewer" }) | Select-Object -First 1
  if (-not $unprovenAgent -or $unprovenAgent.classification -ne "unproven") {
    throw "expected unreferenced-reviewer to be unproven"
  }

  $trimSkill = @($report.skill_classifications | Where-Object { $_.name -eq "giant-skill" }) | Select-Object -First 1
  if (-not $trimSkill -or $trimSkill.classification -ne "trim-candidate") {
    throw "expected giant-skill to be trim-candidate"
  }

  $unusedSkill = @($report.skill_classifications | Where-Object { $_.name -eq "workflows-old" }) | Select-Object -First 1
  if (-not $unusedSkill -or $unusedSkill.classification -ne "unused-candidate") {
    throw "expected workflows-old to be unused-candidate"
  }

  $protectedSkill = @($report.skill_classifications | Where-Object { $_.name -eq "ce-review" }) | Select-Object -First 1
  if (-not $protectedSkill -or $protectedSkill.classification -ne "protected") {
    throw "expected ce-review to be protected"
  }

  $coldNames = @($report.cold_storage_candidates | Select-Object -ExpandProperty name)
  if ($coldNames -notcontains "unreferenced-reviewer" -or $coldNames -notcontains "giant-skill" -or $coldNames -notcontains "workflows-old") {
    throw "expected cold-storage candidates to include unproven and trim candidates"
  }
  if ($coldNames -contains "ce-review") {
    throw "protected skill should not appear in cold-storage candidates"
  }
} finally {
  Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "skill-surface-minimality selftest passed"
exit 0
