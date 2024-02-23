## removal guide

to disable CLARA, open a new PowerShell terminal and type `notepad $PROFILE`. this will open up your PowerShell profile in notepad.

look for a line that says `Import-Module "C:\Users\<your_username>\Documents\WindowsPowerShell\Modules\autocomplete_handler\autocomplete_handler.psm1"`, and comment it out with a `#` (or delete it, if you prefer) like so:

```powershell
#Import-Module "C:\Users\<your_username>\Documents\WindowsPowerShell\Modules\autocomplete_handler\autocomplete_handler.psm1"
```

open a new PowerShell window, and you're back to how PowerShell was before installing CLARA.
