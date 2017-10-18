Import-Module -Name posh-git

function Test-Administrator {
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
  $realLASTEXITCODE = $LASTEXITCODE

  Write-Host

  # Reset color, which can be messed up by Enable-GitColors
  $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

  if (Test-Administrator) {
    # Use different username if elevated
    Write-Host "(Elevated) " -NoNewline -ForegroundColor White
  }

  if ($s -ne $null) {
    # color for PSSessions
    Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
    Write-Host ") " -NoNewline -ForegroundColor DarkGray
  }

  Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\', '\\'), "~") -NoNewline -ForegroundColor Blue

  $global:LASTEXITCODE = $realLASTEXITCODE

  Write-VcsStatus

  Write-Host ""

  Write-Host "$([char]0x2601)  " -NoNewLine -ForegroundColor Green

  return " "
}


Set HOME=C:\Users\zholt

function vim {
    $Currentlocation=Get-Location
    $volume = $Currentlocation.tostring() + ":/mnt/workspace"
    docker pull zakjholt/vim
    docker run -it --rm -v "$volume" zakjholt/vim
}
