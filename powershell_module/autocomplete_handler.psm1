# Define a variable to track the state of CLARA mode
$global:CLARAMode = $false

function Invoke-ModelBasedTabCompletion {
    [CmdletBinding()]
    param($key, $arg)

    $buffer = $null
    $cursor = $null
    [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref]$buffer, [ref]$cursor)
    $commandLine = $buffer.Substring(0, $cursor)

    # Ensuring the command line is processed only if changed, but error messages are always evaluated
    if ($global:previousCommandLine -ne $commandLine -or $true) {
        $global:previousCommandLine = $commandLine

        $claraRepoPath = $env:CLARA_REPO_PATH
        if (-not $claraRepoPath) {
            Write-Host "`nCLARA_REPO_PATH environment variable is not set. Cannot locate the CLARA repository." -ForegroundColor Red
            # Continue to allow subsequent checks even after displaying error
            return
        }

        $scriptPath = Join-Path -Path $claraRepoPath -ChildPath "call_model.py"
        $outputDir = Join-Path -Path $claraRepoPath -ChildPath "output"
        $outputFile = Join-Path -Path $outputDir -ChildPath "output.txt"

        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }

        if (Test-Path $scriptPath) {
            $command = "python `"$scriptPath`" `"$commandLine`" 2>&1"
            $stderr = Invoke-Expression $command | Out-String

            if ($LASTEXITCODE -ne 0 -or $stderr) {
                Write-Host "`nFailed to execute call_model.py. Error: $stderr" -ForegroundColor Red
                # Do not return; continue to allow for Tab completion attempts
            }
        } else {
            Write-Host "`nNo call_model.py found. Verify your `$claraRepoPath` correctly points to the CLARA repo's call_model.py script." -ForegroundColor Red
            # Do not return; continue to allow for Tab completion attempts
        }

        $global:commandReplacement = Get-Content $outputFile -Raw
    }

    if ($global:commandReplacement) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
        [Microsoft.PowerShell.PSConsoleReadLine]::KillLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($global:commandReplacement)
    }
}

# Function to toggle the CLARA mode
function Toggle-CLARAMode {
    $global:CLARAMode = -not $global:CLARAMode
    if ($global:CLARAMode) {
        Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
            Invoke-ModelBasedTabCompletion
        }
        Write-Host "CLARAMode Activated" -ForegroundColor Green
    } else {
        Set-PSReadLineKeyHandler -Key Tab -Function TabCompleteNext
        Write-Host "CLARAMode Deactivated" -ForegroundColor Yellow
    }    
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    Set-PSReadLineKeyHandler -Key Tab -Function TabCompleteNext
}

Set-PSReadLineKeyHandler -Chord 'Ctrl+u' -ScriptBlock {
    Toggle-CLARAMode
}

function Prompt {
    if ($global:CLARAMode) {
        Write-Host "PSC*" -NoNewline -ForegroundColor Green
    } else {
        Write-Host "PS" -NoNewline
    }
    $currentPath = " " + $(Get-Location) + "> "
    return $currentPath
}
