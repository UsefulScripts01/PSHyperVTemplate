## VmModule

#### 1. Load in current session

Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/VmModule.psm1" -OutFile "C:\Windows\Temp\VmModule.psm1"
Import-Module -Name "C:\Windows\Temp\VmModule.psm1"
```


#### 2. Installation

To install VMModule on your system follow these steps:
- Download VmModule.ps1 to `.\Documents\WindowsPowerShell\` or any other location
- Locate the PowerShell profile file `.\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- If you can't find the profile file, create a new one `New-Item -Path $profile -Type File -Force`
- Edit the file and insert the command `Import-Module -Name "~\Documents\WindowsPowerShell\VmModule.psm1"`


#### 3. Default settings for a new machine

The default settings for a new VM are stored in `.\Desktop\VmTemplate.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<NewVmachine>
    <Name>VM_</Name>
    <Generation>2</Generation>
    <SecureBoot>0</SecureBoot>
    <Memory>
        <Size>8</Size>
        <Minimum>1</Minimum>
        <Maximum>16</Maximum>
    </Memory>
    <CPU>
        <Count>4</Count>
        <MigrateToPhysical>1</MigrateToPhysical>
    </CPU>
    <HardDrive>
        <Size>100</Size>
        <Path>C:\Users\Public\Documents\Hyper-V\Virtual hard disks\</Path>
    </HardDrive>
    <DVD>
        <ISO>C:\MDT\Boot\LiteTouchPE_x64.iso</ISO>
    </DVD>
    <Network>
        <VirtualSwitch>Default Switch</VirtualSwitch>
    </Network>
    <AutoCheckpoints>0</AutoCheckpoints>
</NewVmachine>
```

#### 4. Parameters

You can define your own parameter values or use the predefined ones from the VmTemplate.xml file.

`-Generation` - [string] Generation of a new machine (1 or 2, default is 2) \
`-Start` - [switch] Start the machine after creation \
`-Name` - [string] Name of a new machne (default is "VM_no") \
`-ISO` - [string] Boot ISO file path


#### 5. Examples

Example 1: Simple, all parameters from the xml template.
```powershell
New-Vmachine
```
Example 2: Generation 2. Start after creation.
```powershell
New-Vmachine -Generation 2 -Start
```
Example 3: Generation 1.
```powershell
New-Vmachine -Generation 1
```
Example 4: Generation 1, boot from the ISO file defined in the parameter.
```powershell
New-Vmachine -Generation 1 -Name "MachineName" -ISO "C:\installation.iso"
```
Example 5: Remove selected machine.
```powershell
Remove-Vmachine -Name "MachineName"
```
