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
        [Parameter(
            Mandatory=$false,
            Position=1,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True 
        )]
        [Alias("Computer", "__SERVER", "IPAddress")]
        $computer = $env:COMPUTERNAME,

        [Parameter(
            Mandatory=$True,
            Position=0
        )]
        [string]$username

    )

    begin {
        
        #Check to see if the computer is actually online
        $onlineCheck = Test-Connection -ComputerName $computer -Count 2 -Quiet
        IF(!($onlineCheck)){
            Write-Error "$computer is not Online."
        }

        #Checks to see if the profile folder is on the computer.
        IF(!(Test-Path -path "\\$computer\c$\Users\$username")){
            Write-Error -Exception "Cannot find user profile, please confrm $username is on $computer" -ErrorAction Stop
        }
        
        $localProfilePath = "C:\\Users\\$username"
    }

    process {
        #Gets the profile
        $wmiQuery = "SELECT * FROM Win32_UserProfile WHERE localpath = '$localProfilePath'"
        $profile = Get-WmiObject -Query $wmiQuery -ComputerName $computer
        If($profile.loaded){
            Write-Error "Cannot delete profile, profile is currently loaded." -ErrorAction Stop
        }

        #Pass the profile object and remove everything associated to it.
        Remove-WmiObject -InputObject $profile -ErrorAction SilentlyContinue 

        #final check
        $finalCheck = Get-WmiObject -Query $wmiQuery -ComputerName $computer
        If(!($finalCheck -eq $null)){
            Write-Error  "User $($username) has NOT been removed from $computer"
        }
    }

    end {
    }
}