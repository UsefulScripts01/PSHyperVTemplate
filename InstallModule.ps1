<#
.SYNOPSIS
    Install VmModule
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
#>

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/PSHyperVTemplate.psm1" -OutFile "$HOME\Documents\PSHyperVTemplate.psm1"
if (!$PROFILE) { New-Item -Path $PROFILE -Type File -Force }
if ($PROFILE) {
    Add-Content -Value "# Import PowerShell Profile"
    Add-Content -Value "Import-Module -Name $HOME\Documents\PSHyperVTemplate.psm1" -Path $PROFILE -Force
}