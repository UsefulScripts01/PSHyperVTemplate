## PSHyperVTemplate

### Create Hyper-V virtual machines from XML templates.



### Installation

Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).

```powershell
Install-Module -Name PSHyperVTemplate
Import-Module -Name PSHyperVTemplate
```

<hr>

### Default settings for a new machine

The default settings for a new VM are stored in `"C:\Temp\VmTemplates\DefaultTemplate.xml"`. Copy this file to create additional templates.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<NewVmachine>
    <Name>VM</Name>
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
    <AutoStart>0</AutoStart>
    <AutoCheckpoints>0</AutoCheckpoints>
    <AutoRunManager>0</AutoRunManager>
</NewVmachine>
```

<hr>

### Parameters

You can define your own parameter values or use the predefined ones from the VmTemplate.xml file.

`-Template` - [string] Chose XML template to use \
`-Name` - [string] Name of a new machne (default is "VM_no") \
`-Generation` - [string] Generation of a new machine (1 or 2, default is 2) \
`-ISO` - [string] Boot ISO file path \
`-Start` - [switch] Start the machine after creation \
`-RunManager` - [switch] Run Hyper-V Manager

<hr>

### Examples

Example 1: Simple, all parameters from the DefaultTemplate.xml.
```powershell
New-Vmachine
```
Example 2: Generation 2. Start after creation.
```powershell
New-Vmachine -Generation 2 -Start
```
Example 3: Generation 1. Use the "Linux.xml" template file..
```powershell
New-Vmachine -Generation 1 -Template "Linux"
```
Example 4: Generation 1, boot from the ISO file defined in the parameter.
```powershell
New-Vmachine -Generation 1 -Name "MachineName" -ISO "C:\installation.iso"
```
Example 5: Remove selected machine.
```powershell
Remove-Vmachine -Name "MachineName"
```
