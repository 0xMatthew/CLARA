function Invoke-ModelBasedTabCompletion {
    [CmdletBinding()]
    param($key, $arg)

    $buffer = $null
    $cursor = $null
    [Microsoft.Powershell.PSConsoleReadLine]::GetBufferState([ref]$buffer, [ref]$cursor)
    $commandLine = $buffer.Substring(0, $cursor)

    # Ensure the model is only called once per unique command line input
    if (-not $global:previousCommandLine -or $global:previousCommandLine -ne $commandLine) {
        $global:previousCommandLine = $commandLine

        # Define paths and parameters
        $scriptPath = "E:\LLMs\github\LLLARRI\call_model.py"
        $outputDir = "E:\LLMs\github\LLLARRI\output\"
        $outputFile = Join-Path -Path $outputDir -ChildPath "output.txt"

        # Ensure the output directory exists
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir | Out-Null
        }

        # Call the Python script with the current command line as input
        $command = "python `"$scriptPath`" `"$commandLine`""
        Invoke-Expression $command

        # Read the output file
        $global:commandReplacement = Get-Content $outputFile -Raw
    }

    if ($global:commandReplacement) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0)
        [Microsoft.PowerShell.PSConsoleReadLine]::KillLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($global:commandReplacement)
    }
}

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    Invoke-ModelBasedTabCompletion
}
