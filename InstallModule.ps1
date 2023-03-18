if (!(Test-Path -Path "$PSHOME\Modules\PSHyperVTemplate")) {
    New-Item -Path "$PSHOME\Modules\" -Name "PSHyperVTemplate" -ItemType Directory
}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/PSHyperVTemplate.psm1" -OutFile "$PSHOME\Modules\PSHyperVTemplate\PSHyperVTemplate.psm1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/PsModules/main/PSHyperVTemplate.psd1" -OutFile "$PSHOME\Modules\PSHyperVTemplate\PSHyperVTemplate.psd1"
