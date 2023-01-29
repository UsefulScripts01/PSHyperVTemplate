
# NEW HYPER-V MACHINE
function New-Vmachine {
    param (
        [Parameter(Mandatory)] [string]$Generation,
        [Parameter()] [switch]$Start,
        [Parameter()] [string]$Name,
        [Parameter()] [string]$ISO
    )
    # verify that the VmModule.xml exist
    if (!(Test-Path -Path "~\Documents\WindowsPowerShell\VmModule.xml")) {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/VmModule.xml" -OutFile "~\Documents\WindowsPowerShell\VmModule.xml"
    }
    [XML]$Set = Get-Content -Path "~\Documents\WindowsPowerShell\VmModule.xml"
    
    # vm name
    if ($Name) { $VMName = $Name } # from parameter
    else {
        # Name for a new VM (first available)
        $VMLastNumber = ((Get-Vm -Name "VM*").Name | Measure-Object -Maximum).Count
        $VMLastNumber ++
        $VMName = "VM_$VMLastNumber"
    }

    $RamSize = 1073741824 * ($Set.NewVmachine.MemorySize) # memory size to bytes
    $VhdSize = 1073741824 * ($Set.NewVmachine.VhdSize) # vhd size to bytes
    $VhdPath = Join-Path -Path $Set.NewVmachine.VhdPath -ChildPath "$VMName.vhdx" # path from xml

    # boot ISO
    if ($ISO) { $VMBootISO = $ISO } # from parameter
    else { $VMBootISO = $Set.NewVmachine.ISO } # from XML

    # switch for the "Generation" parameter
    Switch ($Generation) {
        "1" {
            # create VM - generation 1
            # script wil attach the existing VHDX (with the same name as VM) instead of creating a new one
            if (!(Test-Path -Path $VhdPath)) {
                New-VM -Name "$VMName" -Generation 1 -MemoryStartupBytes $RamSize -NewVHDPath $VhdPath -NewVHDSizeBytes $VhdSize -SwitchName "Default Switch" -BootDevice CD
            }
            else {
                New-VM -Name $VMName -Generation 1 -MemoryStartupBytes $RamSize -SwitchName "Default Switch" -VHDPath $VhdPath -BootDevice CD
            }
            Set-VMDvdDrive -VMName $VMName -Path $VMBootISO
        }
        "2" {
            # create VM - generation 2
            if (!(Test-Path -Path $VhdPath)) {
                New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $RamSize -NewVHDPath $VhdPath -NewVHDSizeBytes $VhdSize -SwitchName "Default Switch"
                Add-VMDvdDrive -VMName $VMName -Path $VMBootISO
                $DVD = Get-VMDVDDrive -VMName $VMName
                Set-VMFirmware $VMName -FirstBootDevice $DVD
            }
            else {
                New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $RamSize -VHDPath $VhdPath -SwitchName "Default Switch"
                Add-VMDvdDrive -VMName $VMName -Path $VMBootISO
                $DVD = Get-VMDVDDrive -VMName $VMName
                Set-VMFirmware $VMName -FirstBootDevice $DVD
            }
        }
    }

    # secure boot
    if ((Get-VM  -Name $VMName).Generation -eq "2") {
        switch ($Set.NewVmachine.SecureBoot) {
            0 { Set-VMFirmware -VMName $VMName -EnableSecureBoot OFF }
            1 { Set-VMFirmware -VMName $VMName -EnableSecureBoot ON }
        }
    }

    # automatic checkpoints
    switch ($Set.NewVmachine.AutoCheckpoints) {
        0 { Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $false }
        1 { Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $true }
    }
    
    # "start" switch
    if ($Start) { Start-VM -Name $VMName }
}
Export-ModuleMember -Function New-Vmachine

# DELETE HYPER-V MACHINE AND VHDX
function Remove-Vmachine {
    param (
        [Parameter(Mandatory)] [string]$Name
    )
    switch ([System.Environment]::OSVersion.Platform) {
        Win32NT {
            if ((Get-VM).Name.Contains($Name)) {
                $Vhdx = (Get-VMHardDiskDrive -VMName $Name).Path
                Remove-VM -Name $Name
                Start-Sleep -Seconds 2
                Remove-Item -Path $Vhdx
            }
            else { Write-Warning "Machine $Name does not exist.." }
        }
        Unix { Write-Warning "Remove-Vmachine is available only in Win32NT environment.." }
    }
}
Export-ModuleMember -Function Remove-Vmachine
