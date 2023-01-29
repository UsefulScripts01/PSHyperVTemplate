## VMModule

#### 1. Load VMModule only incurrent session

Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/VMModule.psm1" -OutFile "C:\Windows\Temp\VMModule.psm1"
Import-Module -Name "C:\Windows\Temp\VMModule.psm1"
```


#### 2. Permanent installation

To install VMModule on your system follow these steps:
- Download 
- Create the PowerShell profile file `New-Item -Path $profile -Type File -Force`
