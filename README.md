# GenTwoImageTools
PowerShell Tools for Generation 2 Images

## Synopsis
This module provides tools to quickly convert a WIM into  bootable VHD/VHDX

## Description
Creating Patched Images or just a baseline VHDX from a CD has in the past required MDT to deploy to a machine, patch and then capture the images.

Using MDT is time consuming. Converting the WIM directly to a VHDX is more efficient.

In the past this was accomplished with Convert-WindowsImage.ps1 https://gallery.technet.microsoft.com/scriptcenter/Convert-WindowsImageps1-0fe23a8f

While that is a great tool, I found it had many shortcomings
* It's one huge file (as single purpose PowerShell script go)
* It's buggy (Most of them have been fixed recently)
* It's not a Module (This being my biggest gripe)


Jeffrey Hicks wrote two great articles on the process of creating a Gen2 VHDX and populating it from a WIM
* http://www.altaro.com/hyper-v/creating-generation-2-disk-powershell/
* http://www.altaro.com/hyper-v/customizing-generation-2-vhdx/

These are the starting point for this module. 

### Requirements
This should work on a base install of Windows client or server. (tested on Windows 10)
It's recommended to have the Hyper-V PowerShell tools installed.
* Microsoft-Hyper-V-Management-PowerShell
On windows 10 the There are two features recommended
* Microsoft-Hyper-V-Services
* Microsoft-Hyper-V-Management-PowerShell

## Functions (I'm bad a naming, so i'm open to better names)

```
NAME
    Initialize-VHDPartition
    
SYNOPSIS
    Create VHD(X) with partitions needed to be bootable
    
    
SYNTAX
    Initialize-VHDPartition [-Path] <String> [-Size <UInt64>] [-Dynamic] -DiskLayout <String> 
    [-Passthru] [-RecoveryTools] [-RecoveryImage] [-force] [-WhatIf] [-Confirm] 
    [<CommonParameters>]
    
    
DESCRIPTION
    This command will create a VHD or VHDX file. Supported layours are: BIOS, UEFO or 
    WindowsToGo. 
    
    To create a recovery partitions use -RecoveryTools and -RecoveryImage
    

PARAMETERS
    -Path <String>
        Path to the new VHDX file (Must end in .vhdx)
        
    -Size <UInt64>
        Size in Bytes (Default 40B)
        
    -Dynamic [<SwitchParameter>]
        Create Dynamic disk
        
    -DiskLayout <String>
        Specifies whether to build the image for BIOS (MBR), UEFI (GPT), or WindowsToGo (MBR).
        Generation 1 VMs require BIOS (MBR) images.  Generation 2 VMs require UEFI (GPT) images.
        Windows To Go images will boot in UEFI or BIOS
        
    -Passthru [<SwitchParameter>]
        Output the disk image object
        
    -RecoveryTools [<SwitchParameter>]
        Create the Recovery Environment Tools Partition. Only valid on UEFI layout
        
    -RecoveryImage [<SwitchParameter>]
        Create the Recovery Environment Tools and Recovery Image Partitions. Only valid on UEFI 
        layout
        
    -force [<SwitchParameter>]
        Force the overwrite of existing files
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Initialize-VHDPartition d:\disks\disk001.vhdx -dynamic -size 30GB -DiskLayout BIOS
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Initialize-VHDPartition d:\disks\disk001.vhdx -dynamic -size 40GB -DiskLayout UEFI 
    -RecoveryTools   
  ```
  
  ```
NAME
    Set-VHDPartition
    
SYNOPSIS
    Sets the content of a VHD(X) using a source WIM or ISO
    
    
SYNTAX
    Set-VHDPartition [-Path] <String> [-SourcePath] <String> [-Index <Int32>] [-Unattend 
    <String>] [-NativeBoot] [-Feature <String[]>] [-Driver <String[]>] [-Package <String[]>] 
    [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    This command will copy the content of the SourcePath ISO or WIM and populate the 
    partitions found in the VHD(X) You must supply the path to the VHD(X) file and a 
    valid WIM/ISO. You should also include the index number for the Windows Edition 
    to install. If two Recovery partitions are present the source WIM will be copied 
    to the recovery partition. Optionally, you can also specify an XML file to be 
    inserted into the OS partition as unattend.xml, any Drivers, WindowsUpdate (MSU)
    or Optional Features you want installed.
    CAUTION: This command will replace the content partitions.
    

PARAMETERS
    -Path <String>
        Path to VHDX
        
    -SourcePath <String>
        Path to WIM or ISO used to populate VHDX
        
    -Index <Int32>
        Index of image inside of WIM (Default 1)
        
    -Unattend <String>
        Path to file to copy inside of VHD(X) as C:\unattent.xml
        
    -NativeBoot [<SwitchParameter>]
        Native Boot does not have the boot code inside the VHD(x) it must exist on the physical 
        disk.
        
    -Feature <String[]>
        Featurs to turn on (in DISM format)
        
    -Driver <String[]>
        Path to drivers to inject
        
    -Package <String[]>
        Path of packages to install via DSIM
        
    -Force [<SwitchParameter>]
        Bypass the warning and about lost data
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Set-Gen2BootDiskFromWim -Path D:\vhd\demo3.vhdx -SourcePath 
    D:\wim\Win2012R2-Install.wim -Index 1 -verbose
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Set-Gen2BootDiskFromWim -Path D:\vhd\demo3.vhdx -SourcePath 
    D:\wim\Win2012R2-Install.wim -Confirm:$false -force -Verbose  
  
  ```
  
  ```
  
NAME
    Convert-Wim2VHD
    
SYNOPSIS
    Create a VHDX and populate it from a WIM
    
    
SYNTAX
    Convert-Wim2VHD [-Path] <String> [-Size <UInt64>] [-Dynamic] -DiskLayout <String> 
    [-RecoveryTools] [-RecoveryImage] [-force] [-SourcePath] <String> [-Index <Int32>] [-Unattend 
    <String>] [-NativeBoot] [-Feature <String[]>] [-Driver <String[]>] [-Package <String[]>] 
    [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    This command will update partitions for a Generate 2 VHDX file, configured for UEFI. 
    You must supply the path to the VHDX file and a valid WIM. You should also
    include the index number for the Windows Edition to install.
    

PARAMETERS
    -Path <String>
        Path to the new VHDX file (Must end in .vhdx)
        
    -Size <UInt64>
        Size in Bytes (Default 40B)
        
    -Dynamic [<SwitchParameter>]
        Create Dynamic disk
        
    -DiskLayout <String>
        Specifies whether to build the image for BIOS (MBR), UEFI (GPT), or WindowsToGo (MBR).
        Generation 1 VMs require BIOS (MBR) images.  Generation 2 VMs require UEFI (GPT) images.
        Windows To Go images will boot in UEFI or BIOS
        
    -RecoveryTools [<SwitchParameter>]
        Create the Recovery Environment Tools Partition. Only valid on UEFI layout
        
    -RecoveryImage [<SwitchParameter>]
        Create the Recovery Environment Tools and Recovery Image Partitions. Only valid on UEFI 
        layout
        
    -force [<SwitchParameter>]
        Force the overwrite of existing files
        
    -SourcePath <String>
        Path to WIM or ISO used to populate VHDX
        
    -Index <Int32>
        Index of image inside of WIM (Default 1)
        
    -Unattend <String>
        Path to file to copy inside of VHD(X) as C:\unattent.xml
        
    -NativeBoot [<SwitchParameter>]
        Native Boot does not have the boot code inside the VHD(x) it must exist on the physical 
        disk.
        
    -Feature <String[]>
        Features to turn on (in DISM format)
        
    -Driver <String[]>
        Path to drivers to inject
        
    -Package <String[]>
        Path of packages to install via DSIM
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Convert-WIM2VHDX -Path c:\windows8.vhdx -WimPath d:\Source\install.wim -Recovery
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>Convert-WIM2VHDX -Path c:\windowsServer.vhdx -WimPath d:\Source\install.wim -index 3 
    -Size 40GB -force
	```

	```
	NAME
    New-UnattendXml
    
SYNOPSIS
    Create a new basic Unattend.xml
    
    
SYNTAX
    New-UnattendXml [-AdminPassword] <String> [-Path <String>] [-LogonCount <Int32>] [-ScriptPath <String>] 
    [-TimeZone <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Creates a new Unattend.xml and sets the admin password, Skips any prompts, logs in a set number of times 
    (default 0) and starts a powershell script (default c:\pstemp\firstrun.ps1).
    If no Path is provided a the file will be created in a temp folder and the path returned.
    

PARAMETERS
    -AdminPassword <String>
        The password to have unattnd.xml set the local Administrator to
        
    -Path <String>
        Output Path
        
    -LogonCount <Int32>
        Number of times that the local Administrator account should automaticaly login (default 1)
        
    -ScriptPath <String>
        Script to run on autologin (default: %SystemDrive%\PSTemp\FirstRun.ps1 )
        
    -TimeZone <String>
        set new machine to this timezone (default Central Standard Time)
        
    -WhatIf [<SwitchParameter>]
        
    -Confirm [<SwitchParameter>]
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>New-UnattendXml -AdminPassword 'P@ssword' -logonCount 1
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS C:\>New-UnattendXml -Path c:\temp\Unattent.xml -AdminPassword 'P@ssword' -logonCount 100 -ScriptPath 
    c:\pstemp\firstrun.ps1
    ```
	