# NEW HYPER-V MACHINE
function New-Vmachine {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    
    param (
        [Parameter(Mandatory = $false)] [switch]$Start,
        [Parameter(Mandatory = $true)] [string]$Generation,
        [Parameter(Mandatory = $false)] [string]$Name,
        [Parameter(Mandatory = $false)] [string]$ISO
    )
    # Vm Name
    if ($Name) { $VMName = $Name }
    else {
        # Name for a new VM (first available)
        $VMLastNumber = ((Get-Vm -Name "Win10*").Name | Measure-Object -Maximum).Count
        $VMLastNumber ++
        $VMName = "VM_$VMLastNumber"
    }

    # BOOT ISO
    if ($ISO) { $VMBootPath = $ISO } # From parameter
    else { $VMBootPath = Get-ChildItem -Path "C:\MDT\Boot\*.iso" } # Default

    # VHDX
    $VhdxPath = "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks"

    # Switch for the "Generation" parameter
    Switch ($Generation) {
        "1" {
            # Create VM - Generation 1
            # Script wil attach the existing VHDX (with the same name as VM) instead of creating a new one
            if (!(Test-Path -Path "$VhdxPath\$VMName.vhdx")) {
                New-VM -Name "$VMName" -Generation 1 -MemoryStartupBytes 8GB -NewVHDPath "$Vhdxpath\$VMName.vhdx" -NewVHDSizeBytes 100GB -SwitchName "Default Switch" -BootDevice CD
            }
            else {
                New-VM -Name $VMName -Generation 1 -MemoryStartupBytes 8GB -SwitchName "Default Switch" -VHDPath "$Vhdxpath\$VMName.vhdx" -BootDevice CD
            }
            Set-VMDvdDrive -VMName $VMName -Path $VMBootPath
        }
        "2" {
            # Create VM - Generation 2
            if (!(Test-Path -Path "$VhdxPath\$VMName.vhdx")) {
                New-VM -Name $VMName -Generation 2 -MemoryStartupBytes 8GB -NewVHDPath "$Vhdxpath\$VMName.vhdx" -NewVHDSizeBytes 100GB -SwitchName "Default Switch"
                Add-VMDvdDrive -VMName $VMName -Path $VMBootPath
                $DVD = Get-VMDVDDrive -VMName $VMName
                Set-VMFirmware $VMName -FirstBootDevice $DVD
            }
            else {
                New-VM -Name $VMName -Generation 2 -MemoryStartupBytes 8GB -VHDPath "$Vhdxpath\$VMName.vhdx" -SwitchName "Default Switch"
                Add-VMDvdDrive -VMName $VMName -Path $VMBootPath
                $DVD = Get-VMDVDDrive -VMName $VMName
                Set-VMFirmware $VMName -FirstBootDevice $DVD
            }
        }
    }
    # Setup a new VM
    Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $False

    # "START" switch
    if ($Start) { Start-VM -Name $VMName }
}
Export-ModuleMember -Function New-Vmachine

function Remove-Vmachine {
    param (
        [Parameter(Mandatory = $true)] [string]$Name
    )
    switch ([System.Environment]::OSVersion.Platform) {
        Win32NT {
            if ((Get-VM).Name.Contains($Name)) {
                #$Vhdx = (Get-VMHardDiskDrive -VMName $Name).Path
                Get-VMHardDiskDrive -VMName $Name | Remove-VMHardDiskDrive
                Remove-VM -Name $Name
            }
            else { Write-Warning "Machine $Name does not exist.." }
        }
        Unix { Write-Warning "Remove-Vmachine is available only in Win32NT environment.." }
    }
}
Export-ModuleMember -Function Remove-Vmachine
