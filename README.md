## VmModule

#### 1. Load in current session

Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/VMModule.psm1" -OutFile "C:\Windows\Temp\VmModule.psm1"
Import-Module -Name "C:\Windows\Temp\VmModule.psm1"
```


#### 2. Installation

To install VMModule on your system follow these steps:
- Download VmModule.ps1 to `.\Documents\WindowsPowerShell\` or any other location
- Locate the PowerShell profile file `.\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- If you can't find the profile file, create a new one `New-Item -Path $profile -Type File -Force`
- Edit the file and insert the command `Import-Module -Name "~\Documents\WindowsPowerShell\VmModule.psm1"`


#### 3. Default settings for a new machine

The default settings for a new VM are stored in `.\Documents\WindowsPowerShell\VmModule.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<NewVmachine>
    <!-- New-VMachine deault parameters -->
    <MemorySize>8</MemorySize><!-- values in GB -->
    <VhdSize>100</VhdSize><!-- values in GB -->
    <VhdPath>C:\ProgramData\Microsoft\Windows\Virtual Hard Disks</VhdPath><!-- VHDX storage location -->
    <ISO>C:\MDT\Boot\LiteTouchPE_x64.iso</ISO><!-- boot ISO location -->
    <SecureBoot>1</SecureBoot><!-- switch 0/1 -->
    <AutoCheckpoints>0</AutoCheckpoints><!-- switch 0/1 -->
</NewVmachine>
```

#### 4. Examples



