# Define a variable to track the state of CLARA mode
$global:CLARAMode = $false

function Invoke-ModelBasedTabCompletion {
    [CmdletBinding()]
    param($key, $arg)

    $buffer = $null
    $cursor = $null
    [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref]$buffer, [ref]$cursor)
    $commandLine = $buffer.Substring(0, $cursor)

    # Process the command using LLM only if the command line input has changed
    if ($global:previousCommandLine -ne $commandLine) {
        $global:previousCommandLine = $commandLine

        $claraRepoPath = $env:CLARA_REPO_PATH
        if (-not $claraRepoPath) {
            Write-Host "CLARA_REPO_PATH environment variable is not set. Cannot locate the CLARA repository."
            return
        }

        $scriptPath = Join-Path -Path $claraRepoPath -ChildPath "call_model.py"
        $outputDir = Join-Path -Path $claraRepoPath -ChildPath "output"
        $outputFile = Join-Path -Path $outputDir -ChildPath "output.txt"

        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }

        $command = "python `"$scriptPath`" `"$commandLine`""
        Invoke-Expression $command

        $global:commandReplacement = Get-Content $outputFile -Raw
    }

    if ($global:commandReplacement) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
        [Microsoft.PowerShell.PSConsoleReadLine]::KillLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($global:commandReplacement)
    }
}

# Function to toggle the CLARA mode
function Invoke-CLARAMode {
    $global:CLARAMode = -not $global:CLARAMode
    # Update the Tab key behavior based on the CLARA mode state
    if ($global:CLARAMode) {
        Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
            Invoke-ModelBasedTabCompletion
        }
        Write-Host "CLARAMode Activated" -ForegroundColor Green
    } else {
        Set-PSReadLineKeyHandler -Key Tab -Function TabCompleteNext
        Write-Host "CLARAMode Deactivated" -ForegroundColor Yellow
    }    
    # Force the prompt to refresh
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

# Initially, set Tab to invoke the default completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    Set-PSReadLineKeyHandler -Key Tab -Function TabCompleteNext
}

# Bind the toggle function to a hotkey
Set-PSReadLineKeyHandler -Chord 'Ctrl+u' -ScriptBlock {
    Invoke-CLARAMode
}

# Custom prompt function
function Prompt {
    if ($global:CLARAMode) {
        # If CLARA mode is activated, display 'PS*' in green instead of the usual 'PS'
        Write-Host "PSC*" -NoNewline -ForegroundColor Green
    } else {
        # If CLARA mode is not activated, display the usual 'PS'
        Write-Host "PS" -NoNewline
    }
    $currentPath = " " + $(Get-Location) + "> "
    return $currentPath
}