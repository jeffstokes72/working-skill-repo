param(
  [ValidateSet("codex", "copilot", "agents", "all")]
  [string]$Target = "all",
  [string]$Source = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$InstallRoot = $HOME
)

$ErrorActionPreference = "Stop"

function Copy-DirectoryContents {
  param([string]$From, [string]$To)
  New-Item -ItemType Directory -Force -Path $To | Out-Null
  Get-ChildItem -LiteralPath $From | Copy-Item -Destination $To -Recurse -Force
}

function Install-Codex {
  Copy-DirectoryContents (Join-Path $Source ".github\skills") (Join-Path $InstallRoot ".codex\skills")
  Copy-DirectoryContents (Join-Path $Source ".github\agents") (Join-Path $InstallRoot ".codex\agents")
}

function Install-Copilot {
  Copy-DirectoryContents (Join-Path $Source ".github\skills") (Join-Path $InstallRoot ".copilot\skills")
  Copy-DirectoryContents (Join-Path $Source ".github\agents") (Join-Path $InstallRoot ".copilot\agents")
}

function Install-Agents {
  Copy-DirectoryContents (Join-Path $Source ".github\skills") (Join-Path $InstallRoot ".agents\skills")
}

switch ($Target) {
  "codex" { Install-Codex }
  "copilot" { Install-Copilot }
  "agents" { Install-Agents }
  "all" {
    Install-Codex
    Install-Copilot
    Install-Agents
  }
}

Write-Output "Installed KB skills from $Source to target '$Target'."
