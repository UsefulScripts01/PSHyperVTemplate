# download PSHyperVModule.psm1
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/PSHyperVTemplate.psm1" -OutFile "$HOME\Documents\PSHyperVTemplate.psm1"

#  Check if a PowerShell module file exists and create one if necessary
if (!$PROFILE) { New-Item -Path $PROFILE -Type File -Force }

# Add "Import-Module" command to PS module
if ($PROFILE) {
    Add-Content -Value "# Import PSHyperVTemplate.psm1"
    Add-Content -Value "Import-Module -Name $HOME\Documents\PSHyperVTemplate.psm1" -Path $PROFILE -Force
}