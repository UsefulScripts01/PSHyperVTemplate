## VmModule

#### 1. Load only incurrent session

Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/VMModule.psm1" -OutFile "C:\Windows\Temp\VmModule.psm1"
Import-Module -Name "C:\Windows\Temp\VmModule.psm1"
```


#### 2. Permanent installation

To install VMModule on your system follow these steps:
- Download VmModule.ps1 to `.\Documents\WindowsPowerShell\` or any other location
- Locate the PowerShell profile file `.\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- If you can't find the profile file, create a new one `New-Item -Path $profile -Type File -Force`
- Edit file and insert command `Import-Module -Name "~\Documents\VmModule.psm1"

