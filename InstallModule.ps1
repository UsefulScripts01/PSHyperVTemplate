<#
.SYNOPSIS
    Install VmModule
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
#>

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/VmModule.psm1" -OutFile "$HOME\Documents\VmModule.psm1"
if (!$PROFILE) { New-Item -Path $PROFILE -Type File -Force }
if ($PROFILE) { Add-Content -Value "Import-Module -Name $HOME\Documents\VmModule.psm1" -Path $PROFILE -Force }