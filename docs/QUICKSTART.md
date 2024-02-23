## installation using `windows/windows_installer.ps1` script

- **NOTE:** CLARA works with Windows 10+.
    - specifically, you'll need to use PowerShell 5.1+, which is packaged with W10+ by default.
- **NOTE:** You'll be downloading a lot of large files, so make sure you have 110+ GB of space in `C:\` prior to running the installer script.
    - the Llama 13b repo alone, which the installer script downloads, will contain nearly 100 GB of files.
- **NOTE:** if you already have your TensorRT-LLM environment installed and set up on Windows, you can skip using `windows_installer.ps1` and check out the [manual setup steps](#manual-setup) instead.
- **NOTE:** the installer script makes changes to your Windows environment. make sure you're okay with changes to PowerShell, Windows environment variables, python, and python packages. you could always try setting up CLARA on a virtual machine first.

1. run PowerShell as Administrator.

2. download `windows\windows_installer.ps1` from the latest commit to `main` or via the latest GitHub release source code `.zip` file.

3. run the installer script:

    ```powershell
    .\windows_installer.ps1
    ```

    - **NOTE:** the installer script is interactive at a few points! check in on it occasionally to see if user input is needed. 
        1. you will first be asked if you consent to your `PATH` being modified. 
        2. soon after, you will be prompted to log in to GitHub using the CLI or your web browser (if git SCM is installed).
        3. later on, you will be asked to confirm that you manually installed cuDNN as per TensorRT-LLM's documentation.
        4. later still, you will be prompted to input your huggingface credentials to download Llama 13b.

    - in my experience, downloading and installing of CUDA is the longest portion of the installer. if it's hanging there for a while, try hitting enter once to see if PowerShell is waiting for input.

4. wait for the script to finish. This might take a few hours, especially if your connection isn't very fast.

5. once the installation finishes, go back to the [how to use section](../README.md/#how-to-use) to begin using CLARA!

## manual setup

**NOTE:** these manual steps assume that you have worked with TensorRT-LLM and are comfortable with building and running inference on models using TensorRT-LLM. these steps are only recommended if you have a good reason for not using the installation script/you are very experienced with TensorRT-LLM.

- first, ensure you have:
    
    1. cloned the TensorRT-LLM `rel` branch: https://github.com/NVIDIA/TensorRT-LLM/tree/rel

    2. installed 0.7.1 the TensorRT-LLM python package and all required dependencies
        - this repo was built with support for version 0.7.1, which is contained in the TensorRT-LLM `rel` branch at the time of writing.

    3. downloaded a chat-optimized llama 2 model from huggingface
        - for example, if you have the hardware for it, you could download something as large as [Llama-2-70b-chat-hf](https://huggingface.co/meta-llama/Llama-2-70b-chat-hf) and use it with CLARA.
        
    3. built an optimzied TensorRT-LLM llama model using `TensorRT-LLM\examples\build.py`

    4. you have cloned the CLARA repo (this repo)

- now that your environment is set up, edit `call_model.py`:

    1. change the following 3 lines to point to your local directories:

        ```python
        run_script_path = os.path.join(os.getenv('TENSORRT_LLM_DIR', 'default_path_if_not_set'), "examples", "run.py")
        engine_dir = os.getenv('TRT_ENGINE_DIR', 'default_path_if_not_set')
        tokenizer_dir = os.getenv('LLAMA_MODEL_DIR', 'default_path_if_not_set')
        ```

        - for example, if you cloned the TensorRT-LLM repo into `C:\`, `run_script_path` would be set to `"C:\TensorRT-LLM\examples` like this:

            ```python
            run_script_path = "C:/TensorRT-LLM/examples"
            ```

        - your `engine_dir` is where the output from your TensorRT-LLM `build.py` script is located.
        - your `tokenizer_dir` is where you cloned whatever Llama repo you chose from huggingface.

    2. set your $claraRepoPath environment variable to your local CLARA repo path:

        ```powershell
        [System.Environment]::SetEnvironmentVariable('claraRepoPath', '<the_path_to_your_local_CLARA_repo>', [System.EnvironmentVariableTarget]::User)
        ```
        
        - you're setting the `$claraRepoPath` environment variable so the `autocomplete_handler` module knows where to find the `call_model.py` script.

    3. check if your PowerShell profile exists by running:

        ```powershell
        Test-Path $PROFILE
        ```

        - if it returns `$false`, move to the next step to create one. if `$true`, skip the next step.

    4. create your PowerShell profile if it doesn't exist:

        ```powershell
        New-Item -path $PROFILE -type file -force
        ```

    5. open your PowerShell profile in a text editor. you can use notepad or any editor you prefer. here's how you'd open it in notepad:

        ```powershell
        notepad $PROFILE
        ```

    6. in notepad, add the import command for this repo's autocomplete_handler module:

        ```powershell
        Import-Module "$env:claraRepoPath\powershell_module\autocomplete_handler.psm1"
        ```

        remember to replace <the_path_to_your_local_CLARA_repo> in your `$claraRepoPath` environment variable setup with the actual path where your CLARA repo is located.
        save the changes and close the editor.

    7. to make sure everything's set up correctly, close and reopen your PowerShell terminal. check if the module loads automatically by running:

        ```powershell
        Get-Module -ListAvailable
        ```

        - look for your module in the list to confirm it's available for use.

    8. go back to the [how to use section](../README.md/#how-to-use) to begin using CLARA!