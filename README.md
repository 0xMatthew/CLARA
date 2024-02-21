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
1. **input:** type a PowerShell task you want done in english.
    - example: `create a new directory in the current directory called HelloWorld, navigate into it, run git init inside of it`
2. **suggest:** press `tab` to convert english instructions to PowerShell commands.
    - note: there will be a bit of a delay while the model generates a response to your instruction(s).
3. **run:** if you're satisfied with what the model has come up with, hit enter to run your command!

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
