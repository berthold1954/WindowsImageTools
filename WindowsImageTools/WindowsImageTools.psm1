#requires -Version 2 -Modules Storage
#requires -RunAsAdministrator

# Check for New-VHD
$VHDCmdlets = $true
if (-not (get-module hyper-v -ListAvailable))
{
    $VHDCmdlets = $false
    write-warning '[Module : WindowsImageTools] Hyper-V Module Not Installed: '
}
if ([environment]::OSVersion.Version.Major -ge 10 -and 
    (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Services).state -eq 'Disabled')
{
    $VHDCmdlets = $false
    write-warning '[Module : WindowsImageTools] Hyper-v Services on windows 10 not installed'
}

if (-not ($VHDCmdlets))
{
    write-warning '[Module : WindowsImageTools] *-VHD cmdlets not avalible Loading WIN2VHD Class'    
    . $PSScriptRoot\Functions\Wim2VHDClass.ps1

}

# Import functions
. $PSScriptRoot\Functions\HelperFunctions.ps1
. $PSScriptRoot\Functions\Convert-Wim2VHD.ps1
. $PSScriptRoot\Functions\Initialize-VHDPartition.ps1
. $PSScriptRoot\Functions\Set-VHDPartition.ps1
