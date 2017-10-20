Import-Module -Name posh-git

function Test-Administrator {
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
    $origLastExitCode = $LASTEXITCODE
    Write-VcsStatus

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower()))
    {
        $curPath = "~" + $curPath.SubString($Home.Length)
    }

    Write-Host $curPath -ForegroundColor Blue
    $LASTEXITCODE = $origLastExitCode
    Write-Host "$([char]0x2601)  " -NoNewLine -ForegroundColor Green

    return " "
}

Import-Module posh-git
$global:GitPromptSettings.BeforeText = '<'
$global:GitPromptSettings.AfterText  = '> '


Set HOME=C:\Users\zholt

function vim {
    $Currentlocation=Get-Location
    $volume = $Currentlocation.tostring() + ":/mnt/workspace"
    docker pull zakjholt/vim
    docker run -it --rm -v "$volume" zakjholt/vim
}

function gco ($message) {
    git commit -m $message
}

function ga {
    git add .        
}
