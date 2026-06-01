function Get-KbPowerShellInvocation {
  $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($pwsh) {
    return @($pwsh.Source, "-NoProfile", "-File")
  }
  $windowsPowerShell = Get-Command powershell -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($windowsPowerShell) {
    return @($windowsPowerShell.Source, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File")
  }
  throw "Neither pwsh nor powershell is available."
}

function Get-KbPowerShellFileCommand {
  $invocation = Get-KbPowerShellInvocation
  $command = (($invocation | ForEach-Object {
        if ($_ -match '\s') { "`"$_`"" } else { $_ }
      }) -join " ")
  return "& $command"
}

function Invoke-KbPowerShellFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [string[]]$Arguments = @()
  )
  $invocation = Get-KbPowerShellInvocation
  $exe = $invocation[0]
  $prefix = @($invocation | Select-Object -Skip 1)
  & $exe @prefix $Path @Arguments
}
