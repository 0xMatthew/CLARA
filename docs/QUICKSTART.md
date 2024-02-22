## Installation Guide

- **Windows**: 
    - This repo is compatible with Windows 10+. Specifically, you'll need to use PowerShell 5.1+, which W10 ships with. 
    - Execute `./windows/windows_installer.ps1` with Administrator privileges. This script automates the setup process, including the installation of dependencies and environment configuration. Follow along with program, as there will be some points where manual interaction from the user is expected in order for the installation to continue.
    - The build script is interactive at a few points. Let it install in the background, and occasionally check in on it to see if input is needed.
    - Make sure to have plenty of space on your C:\ drive, as the build process requires downloading quite a few large files.