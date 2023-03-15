
# NEW HYPER-V MACHINE
function New-Vmachine {
    param (
        [Parameter(Mandatory = $false)][string]$Template,
        [Parameter(Mandatory = $false)][string]$Generation,
        [Parameter(Mandatory = $false)][switch]$Start,
        [Parameter(Mandatory = $false)][string]$Name,
        [Parameter(Mandatory = $false)][string]$ISO,
        [Parameter(Mandatory = $false)][switch]$RunManager
    )
    $Env = [System.Environment]::OSVersion.Platform
    if ($Env -match "Win32NT") {
        # verify that the VmModule.xml exist
        if (!(Test-Path -Path "C:\Temp\VmTemplates")) { New-Item -Path "C:\Temp\VmTemplates" -ItemType Directory }
        if (!(Test-Path -Path "C:\Temp\VmTemplates\DefaultTemplate.xml")) { Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/DefaultTemplate.xml" -OutFile "C:\Temp\VmTemplates\DefaultTemplate.xml" }

        # import template xml
        if ($Template -and ($Template -match ".xml")) { [XML]$Set = Get-Content -Path "~\Desktop\DefaultTemplates\$Template" }
        elseif ($Template -and ($Template -notmatch ".xml")) { [XML]$Set = Get-Content -Path "~\Desktop\DefaultTemplates\${Template}.xml" }
        else { [XML]$Set = Get-Content -Path "~\Desktop\DefaultTemplates\DefaultTemplate.xml" }

        # VM name
        if ($Name) { $VMName = $Name }
        elseif (!$Name) {
            $AutoName = $Set.NewVmachine.Name
            $VMLastNumber = ((Get-Vm -Name $AutoName*).Name | Measure-Object -Maximum).Count
            $VMLastNumber ++
            $VMName = "${AutoName}${VMLastNumber}"
        }

        # memory
        $RamSize = 1073741824 * ($Set.NewVmachine.Memory.Size)
        $MinimumRAM = 1073741824 * ($Set.NewVmachine.Memory.Minimum)
        $MaximumRAM = 1073741824 * ($Set.NewVmachine.Memory.Maximum)

        $VhdSize = 1073741824 * ($Set.NewVmachine.HardDrive.Size) # vhd size to bytes
        $VhdPath = Join-Path -Path $Set.NewVmachine.HardDrive.Path -ChildPath "$VMName.vhdx" # path from xml

        # boot ISO
        if ($ISO) { $VMBootISO = $ISO }
        elseif (!$ISO) { $VMBootISO = $Set.NewVmachine.DVD.ISO }

        # generation
        if (!$Generation) { $Generation = $Set.NewVmachine.Generation }
        Switch ($Generation) {
            1 {
                # create VM - generation 1
                # script wil attach the existing VHDX (with the same name as VM) instead of creating a new one
                if (!(Test-Path -Path $VhdPath)) { New-VM -Name $VMName -Generation 1 -MemoryStartupBytes $RamSize -NewVHDPath $VhdPath -NewVHDSizeBytes $VhdSize -BootDevice CD }
                else { New-VM -Name $VMName -Generation 1 -MemoryStartupBytes $RamSize -VHDPath $VhdPath -BootDevice CD }
                Set-VMDvdDrive -VMName $VMName -Path $VMBootISO
            }
            2 {
                # create VM - generation 2
                if (!(Test-Path -Path $VhdPath)) { New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $RamSize -NewVHDPath $VhdPath -NewVHDSizeBytes $VhdSize }
                else { New-VM -Name $VMName -Generation 2 -MemoryStartupBytes $RamSize -VHDPath $VhdPath }
                Add-VMDvdDrive -VMName $VMName -Path $VMBootISO
                $DVD = Get-VMDVDDrive -VMName $VMName
                Set-VMFirmware $VMName -FirstBootDevice $DVD
            }
        }
        
        # CHANGE SETTINGS ON AN EXISTING MACHINE
        # secure boot
        if ((Get-VM  -Name $VMName).Generation -eq "2") {
            switch ($Set.NewVmachine.SecureBoot) {
                0 { Set-VMFirmware -VMName $VMName -EnableSecureBoot OFF }
                1 { Set-VMFirmware -VMName $VMName -EnableSecureBoot ON }
            }
        }

        # processor
        switch ($Set.NewVmachine.CPU.MigrateToPhysical) {
            0 { Set-VMProcessor -VMName $VMName -Count $Set.NewVmachine.CPU.Count -CompatibilityForMigrationEnabled $false }
            1 { Set-VMProcessor -VMName $VMName -Count $Set.NewVmachine.CPU.Count -CompatibilityForMigrationEnabled $true }
        }

        # min/max ram size
        Set-VMMemory $VMName -DynamicMemoryEnabled $true -MinimumBytes $MinimumRAM -StartupBytes $RamSize -MaximumBytes $MaximumRAM -Priority 80 -Buffer 20

        # automatic checkpoints
        switch ($Set.NewVmachine.AutoCheckpoints) {
            0 { Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $false }
            1 { Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $true }
        }

        # network
        $NetAdapter = (Get-VMNetworkAdapter -VMName $VMName).Name
        Connect-VMNetworkAdapter -VMName $VMName -Name $NetAdapter -SwitchName $Set.NewVmachine.Network.VirtualSwitch

        # "start" switch
        if ($Start) { Start-VM -Name $VMName }
        elseif (!$Start) {
            switch ($Set.NewVmachine.AutoStart) {
                0 { }
                1 { Start-VM -Name $VMName }
            }
        }

        # automatic run hyper-v manager
        if ($RunManager) { Start-Process -FilePath "virtmgmt.msc" }
        elseif (!$RunManager) {
            switch ($Set.NewVmachine.AutoRunManager) {
                0 { }
                1 { Start-Process -FilePath "virtmgmt.msc" }
            }
        }

        # Collected error log will be used in FinishProcess.ps1 (Get-ErrorLog)
        if (!$Error.Count.Equals(0)) {
            $DateTime = Get-Date -Format "dd.MM.yyyy HH:mm"
            foreach ($Entry in $Error) {
                Add-Content -Value "$DateTime - $VMName - $Entry" -Path "~\Desktop\VM-ErrorLog.log" -Force
            }
        }

    }
    else { Write-Warning "New-Vmachine is available only in Win32NT environment.." }
}
Export-ModuleMember -Function New-Vmachine

# DELETE HYPER-V MACHINE AND VHDX
function Remove-Vmachine {
    param (
        [Parameter(Mandatory = $true)][string]$Name
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
