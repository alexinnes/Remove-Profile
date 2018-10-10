﻿ls
<#
.Synopsis
   Removes user profiles from computer without the use of delprof
.DESCRIPTION
    Uses the WMI to remove a user account from a station either locally or remotely. It checks to make sure the profile is not loaded before removing it.
    The Remove-WMIObject removes everything related so will delete the users profile folder.
.EXAMPLE
   Remove-Profile -Computer "Test-Computer" -Username "Alex"
#>
function Remove-Profile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=1)]
            #Default Param is the local computer.
            $computer = $env:COMPUTERNAME,
        [Parameter(Mandatory=$True, Position=0)]
            [string]$Username

    )

    begin {
        #Checks to see if the profile folder is on the computer.
        IF(!(Test-Path -path "\\$computer\c$\Users\$username")){
            Write-Error -Exception "Cannot find user profile, please confrm $Username is on $Computer" -ErrorAction Stop
        }
        $localProfilePath = "C:\\Users\\$username"
    }

    process {
        #Gets the profile
        $wmiQuery = "SELECT * FROM Win32_UserProfile WHERE localpath = '$localProfilePath'"
        $profile = Get-WmiObject -Query $WMIQuery -ComputerName $computer
        If($profile.loaded){
            Write-Error "Cannot delete profile, profile is currently loaded." -ErrorAction Stop
        }
        #Pass the profile object and remove everything associated to it.
        Remove-WmiObject -InputObject $profile
    }

    end {
    }
}