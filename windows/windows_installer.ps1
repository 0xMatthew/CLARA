# PowerShell script to set up environment and install necessary tools

# Ensure script is running with administrative privileges
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Please run this script as an Administrator!"
    Break
}

# Check if Chocolatey is already installed
If (-NOT (Get-Command choco -ErrorAction SilentlyContinue))
{
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    # Add TLS 1.2 without overriding existing protocols
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
Else
{
    Write-Host "Chocolatey is already installed."
}

# Import Chocolatey profile to refresh environment variables in the current session
# This line is added right after Chocolatey installation to ensure the environment is updated
Try {
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction Stop
} Catch {
    Write-Host "Unable to import Chocolatey profile. Some commands might not be recognized in the current session."
}

# Check if pyenv-win is installed and install if not
$pyenvWinInstalled = choco list --local-only | Select-String "pyenv-win"
if (-not $pyenvWinInstalled) {
    Write-Host "Installing pyenv-win..."
    choco install pyenv-win -y
} else {
    Write-Host "pyenv-win is already installed."
}

refreshenv

function Move-PyenvToTop {
    param($EnvVarName)
    $path = [Environment]::GetEnvironmentVariable($EnvVarName, "User")
    $paths = $path -split ';' | Where-Object { $_ -ne '' } | ForEach-Object { $_.TrimEnd('\') }
    $pyenvPaths = $paths | Where-Object { $_ -like '*\pyenv-win\*' }
    $otherPaths = $paths | Where-Object { $_ -notlike '*\pyenv-win\*' }
    $newPath = ($pyenvPaths + $otherPaths) -join ';'
    [Environment]::SetEnvironmentVariable($EnvVarName, $newPath, "User")
}

# Warning and confirmation before modifying PATH
Write-Host "WARNING: This script will modify your PATH environment variable to prioritize pyenv. This is necessary for proper operation of Python versions managed by pyenv."
Write-Host "It is recommended to review the changes after script execution to ensure your environment remains configured as expected."
Write-Host "Please ensure you understand this change before proceeding."

# Pause execution for user confirmation
$userConfirmation = Read-Host "Do you want to proceed with the PATH modification? (yes/no)"
if ($userConfirmation -ne 'yes') {
    Write-Host "PATH modification aborted by user. Exiting script."
    Exit
}

# Reorder PATH to prioritize pyenv
Move-PyenvToTop "PATH"

# Refresh environment to recognize new PATH order
refreshenv

# Install Python using pyenv (replace with available version if necessary)
$pythonVersion = "3.10.5"
If (-NOT (pyenv versions -q | Select-String -Pattern $pythonVersion))
{
    Write-Host "Installing Python $pythonVersion..."
    pyenv install $pythonVersion
    pyenv global $pythonVersion
    pyenv rehash
}
Else
{
    Write-Host "Python $pythonVersion is already installed."
    pyenv global $pythonVersion
    pyenv rehash
}

# Verify Python installation
python --version

# Install Git
Write-Host "Installing Git..."
choco install git -y

# Refresh environment after Git installation
refreshenv

# Define a dynamic path for cloning the repository
$githubPath = Join-Path -Path $env:ProgramFiles -ChildPath "github"
if (-not (Test-Path $githubPath)) {
    New-Item -Path $githubPath -ItemType Directory | Out-Null
}

# Dynamically set the CLARA repo path based on the script's execution location
$claraRepoPath = Join-Path -Path $githubPath -ChildPath "CLARA"

# Clone the CLARA repository
Write-Host "Cloning CLARA repository..."
Set-Location $githubPath
git clone https://github.com/0xMatthew/CLARA.git $claraRepoPath

# Set an environment variable to the CLARA repository path
[Environment]::SetEnvironmentVariable("CLARA_REPO_PATH", $claraRepoPath, [System.EnvironmentVariableTarget]::User)
refreshenv

# Install Git LFS
Write-Host "Installing Git LFS..."
choco install git-lfs -y

# Might need to add line to prompt user to hit enter here

# Refresh environment after Git LFS installation
refreshenv

# Clone TensorRT-LLM repository
Write-Host "Cloning TensorRT-LLM repository..."
$githubPath = Join-Path -Path $env:ProgramFiles -ChildPath "github"
New-Item -Path $githubPath -ItemType Directory -Force
Set-Location $githubPath
git clone -b rel https://github.com/NVIDIA/TensorRT-LLM.git
Set-Location TensorRT-LLM

# Run setup_env.ps1 with -skipPython flag
Write-Host "Running TensorRT-LLM setup..."
.\windows\setup_env.ps1 -skipPython

# Install tensorrt_llm package
Write-Host "Installing tensorrt_llm package..."
pip install tensorrt_llm==0.7.1 --extra-index-url https://pypi.nvidia.com --extra-index-url https://download.pytorch.org/whl/cu121

# Display the link prominently 
Write-Host "Please manually install cuDNN. Follow the instructions in the TensorRT-LLM documentation:"
Write-Host "https://github.com/NVIDIA/TensorRT-LLM/tree/rel/windows#cudnn"
Write-Host "" # Add an empty line for spacing

# Prompt and wait for confirmation
Write-Host "Type 'installed' once completed."
do {
    $userInput = Read-Host "Have you installed cuDNN? (Type 'installed' to continue)"
} while ($userInput -ne 'installed')

# Ensure the Hugging Face directory exists
$huggingFaceDir = Join-Path -Path $githubPath -ChildPath "hugging_face"
if (-not (Test-Path $huggingFaceDir)) {
    New-Item -Path $huggingFaceDir -ItemType Directory | Out-Null
}
Set-Location $huggingFaceDir

# Initialize Git LFS
git lfs install

# Clone the Llama-2-13b-chat-hf model with placeholder for authentication
Write-Host "Cloning Llama-2-13b-chat-hf from Hugging Face. Please provide your Hugging Face authentication token when prompted."

# Reminder for authentication
Write-Host "Remember: The password prompt is asking for your Hugging Face authentication token."

git clone https://huggingface.co/meta-llama/Llama-2-13b-chat-hf

# Build the model
$modelDir = Join-Path -Path $huggingFaceDir -ChildPath "Llama-2-13b-chat-hf"
$outputDir = Join-Path -Path $env:ProgramFiles -ChildPath "TRT_engine"
$tensorRTLLMDir = Join-Path -Path $githubPath -ChildPath "TensorRT-LLM"
$buildScriptPath = Join-Path -Path $tensorRTLLMDir -ChildPath "examples\llama\build.py"

# Ensure the build script exists
if (Test-Path $buildScriptPath) {
    Write-Host "Building the model. This might take some time..."
    python $buildScriptPath --model_dir $modelDir --dtype float16 --remove_input_padding --use_gpt_attention_plugin float16 --enable_context_fmha --use_gemm_plugin float16 --use_weight_only --output_dir $outputDir --weight_only_precision int8
} else {
    Write-Host "Build script not found at $buildScriptPath. Please verify the path."
}

# Final message for build completion
Write-Host "Model build completed."

# Determine module path within user profile
$modulePath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell\Modules\autocomplete_handler"

# Check if the module directory exists, if not, create it
If (-not (Test-Path $modulePath)) {
    New-Item -ItemType Directory -Path $modulePath | Out-Null
    Write-Host "Module directory created at $modulePath"
}

# Define the source and destination paths for the module
$sourceModulePath = Join-Path -Path $claraRepoPath -ChildPath "powershell_module\autocomplete_handler.psm1"
$destinationModulePath = Join-Path -Path $modulePath -ChildPath "autocomplete_handler.psm1"

# Copy the module file to the destination
Copy-Item -Path $sourceModulePath -Destination $destinationModulePath -Force
Write-Host "Module autocomplete_handler.psm1 copied to $modulePath"

# PowerShell profile path for the current user - adjust for PowerShell Core if necessary
$profilePath = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Module file path
$moduleFilePath = Join-Path -Path $modulePath -ChildPath "autocomplete_handler.psm1"

# Check if the profile exists, if not, create it
If (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force
}

# Add the import command to the profile, ensuring not to duplicate it
$importCommand = "Import-Module `"$moduleFilePath`""
If (Select-String -Path $profilePath -Pattern ([regex]::Escape($importCommand)) -Quiet) {
    Write-Host "Module import already exists in the profile."
} Else {
    Add-Content -Path $profilePath -Value $importCommand
    Write-Host "Added module import to $profilePath"
}

refreshenv

# Inform the user
Write-Host "The autocomplete module is now loaded."

# Setting environment variables for use in call_model.py
[Environment]::SetEnvironmentVariable("TENSORRT_LLM_DIR", $tensorRTLLMDir, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("TRT_ENGINE_DIR", $outputDir, [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("LLAMA_MODEL_DIR", $modelDir, [System.EnvironmentVariableTarget]::User)

refreshenv

# Final confirmation message
Write-Host "CLARA has successfully installed! Press control+u to activate CLARA. Then, in plain-english, type what you want PowerShell to do. When ready, press tab to have CLARA to convert your instruction to PowerShell commands."