# CLARA
**C**ommand **L**ine **A**ssistant with **R**tx **A**cceleration

## overview
CLARA transforms plain english instructions into actionable CLI commands. optimized for NVIDIA Ampere hardware with the "llama2-13b-chat-hf" model, CLARA converts simple english instructions into PowerShell commands with the press of your `tab` key!

## installation
see [quickstart](docs/QUICKSTART.md) for installation steps with CLARA's easy-to-use installer.

## features
- **model:** uses [llama2-13b-chat-hf](https://huggingface.co/meta-llama/Llama-2-13b-chat-hf) for command generation
- **functionality:** use plain english instructions and let CLARA do the heavy-lifting of converting your words to PowerShell commands

## how to use
1. after you've successfully installed CLARA, press `control+u` together to enable Clara.
    - you'll see `PS <your_current_folder>> CLARAMode Activated` in PowerShell
    - note: you'll also notice that when CLARA is enabled, your PowerShell prompt is changed to a green `PSC*`.
2. enter a plain english directive that you want PowerShell to perform, and press tab when you're done so CLARA can generate PowerShell commands for you.
    - note: there will be a bit of a delay while the TRT runs Llama 13b and generates a response to your instruction.
    - examples (you can try typing these into your PowerShell and pressing `tab` to see what Llama 13b generates):

        ```plaintext
        create a new directory in the current directory called Salutations, navigate into it, run git init inside of it
        tell me who the current Windows user is
        tell me all installed commands
        list all processes that start with W
        create a new directory called new_dir, copy call_model.py from current directory into it
        show me my entire command history
        output the contents of README.md in the current directory
        ```

3. if you're satisfied with what the model has come up with, hit enter to run your command.
4. (optional) disable CLARA by pressing `control+u` together once more.

## repo structure

```plaintext
docs/
│   QUICKSTART.md             # This guide to quickly begin using the repository
powershell_module/
│   autocomplete_handler.psm1 # PowerShell module for handling autocomplete functionality
windows/
│   windows_installer.ps1     # PowerShell script for environment setup on Windows
.gitattributes
.gitignore
call_model.py                 # Script to process English directives and call llama 13b
README.md                     # README for CLARA
```
