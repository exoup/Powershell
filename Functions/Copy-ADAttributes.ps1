Function Copy-ADAttributes {
<#
.SYNOPSIS

Copies AD descriptor attributes from one AD user to another.

.DESCRIPTION

The Copy-ADAttributes function copies the Description, Office, StreetAddress, City, State, PostalCode, County, Title, Department, and Company attributes From one Active Directory user To another.

The From(Identity) parameter specifies the Active Directory user to copy FROM.
The To(Target) parameter specifies the Active Directory user to copy TO.

Manager, MemberOf, and Confirm are switch parameters.

Manager will prompt you to enter the name(e.g. John Smith) of an active directory user to set as the manager for the To(Target) AD user.

MemberOf will copy all MemberOf groups From(Identity) to To(Target) user.

Confirm will ask you (Y/N) to confirm each change before it is made.

.INPUTS

System.String
    Usernames as strings for From and To.

.OUTPUTS

System.String
    Or none.

.EXAMPLE

PS> Copy-ADAttributes -From CourageTheDog -To ScoobyDoo
Copied AD attributes from user CourageTheDog to user ScoobyDoo.

.EXAMPLE

PS> Copy-ADAttributes -Identity CourageTheDog -Target Pluto -Manager -MemberOf -Confirm
Copy AD Attributes from user CourageTheDog to user Pluto? (Y/N): Y
Copied AD attributes from user CourageTheDog to user Pluto.
Enter name of user Pluto's manager here: Courage
Set user Pluto's manager as CN=Courage The. CowardlyDog,OU=Test,DC=Domain,DC=com? (Y/N): Y
Set user Pluto's manager as CN=Courage The. CowardlyDog,OU=Test,DC=Domain,DC=com.
Copy AD Group Memberships from user CourageTheDog to user Pluto? (Y/N): Y
Copied MemberOf membership groups from user CourageTheDog to user Pluto.

.EXAMPLE
PS> Copy-ADAttributes -Identity CourageTheDog -Target DonaldDuck -Manager
#Example of fuzzy manager matching.#

Copied AD attributes from user CourageTheDog to user DonaldDuck.
Enter name of user DonaldDuck's manager here: Cour
Found 3 results for Cour. Please choose one.
Did you mean Court Jester? (Y/N): N
Did you mean Courier Fox? (Y/N): N
Did you mean Courage The. CowardlyDog? (Y/N): Y
Set user DonaldDuck's manager as CN=Courage The. CowardlyDog,OU=Test,DC=Domain,DC=com.

.NOTES
Author: Joseph Y
Website: https://github.com/exoup
Version: 1.0
TODO: Refactor/Comment. It can be a bit verbose. Maybe fix that.
#>
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,
               Position=0)]
    [Alias("Identity")]
    [ValidateNotNull()]
    [string]
    $From,

    [Parameter(Mandatory=$true,
               Position=1)]
    [Alias("Target")]
    [ValidateNotNull()]
    [string]
    $To,

    [Parameter()]
    [Switch]
    $Manager,

    [Parameter()]
    [Switch]
    $MemberOf,
    
    [Parameter()]
    [Switch]
    $Confirm
    )

begin {
    function Test-NullOrWhiteSpace ([string]$String) {
        [string]::IsNullOrWhiteSpace($String)
    }
    $SelectedProperties="Description","Office","StreetAddress","City","State","PostalCode","Country","Title","Department","Company","MemberOf"
    try {
        $FromProperties=Get-ADUser -Identity:$From -Properties $SelectedProperties
        $SplatProperties=@{
            "City"=$FromProperties.City
            "Company"=$FromProperties.Company
            "Country"=$FromProperties.Country
            "Department"=$FromProperties.Department
            "Description"=$FromProperties.Description
            "Office"=$FromProperties.Office
            "PostalCode"=$FromProperties.PostalCode
            "State"=$FromProperties.State
            "StreetAddress"=$FromProperties.StreetAddress
            "Title"=$FromProperties.Title
        }
        $FromUserGroups=$FromProperties.MemberOf
    } catch {
    $_
    }
}#endbegin

process {
    if (!$Confirm) {
        Set-ADUser -Identity:$To @SplatProperties
        Write-Host "Copied AD attributes from user $($From) to user $($To)."
    } else {
        do {
            $Answer=Read-Host "Copy AD Attributes from user $($From) to user $($To)? (Y/N)"
            if ($Answer.ToLower() -eq "y") {
                Set-ADUser -Identity:$To @SplatProperties
                Write-Host "Copied AD attributes from user $($From) to user $($To)."
            } elseif ($Answer.ToLower() -eq "n") { Break }
        } until ($Answer.ToLower() -eq "y" -or $Answer.ToLower() -eq "n")
    }
    if ($Manager) {
        $ManagerPrompt=Read-Host "Enter name of user $($To)'s manager here"
        if (Test-NullOrWhiteSpace -String $ManagerPrompt) { 
            do { 
                $ForceManagerPrompt=Read-Host "Manager name can not be empty. Please enter a name"
                if (!(Test-NullOrWhiteSpace -String $ForceManagerPrompt)) {
                    $ManagerPrompt=$ForceManagerPrompt
                    }
                } until (!(Test-NullOrWhiteSpace -String $ManagerPrompt))
            }
        $ManagerADResults=Get-ADUser -Filter "name -like '*$($ManagerPrompt)*'"
        if ($ManagerADResults.count -gt 1) {
            Write-Host "Found $($ManagerADResults.count) results for $($ManagerPrompt). Please choose one."
            foreach ($Result in $ManagerADResults) {
                $Answer=Read-Host "Did you mean $($Result.name)? (Y/N)"
                if ($Answer.ToLower() -eq "y") {
                    $SelectedManager=$Result.DistinguishedName
                    break
                    }
                }
            } else {
            $SelectedManager=$ManagerADResults.DistinguishedName
            }
        if (!$Confirm) {
            if (!(Test-NullOrWhiteSpace -String $SelectedManager)) {
                Set-ADUser -Identity:$To -Manager $SelectedManager
                Write-Host "Set user $($To)'s manager as $($SelectedManager)."
            } else {
                Write-Host "Manager info for $($To) not found."
                break
            }
        } else {
            if (!(Test-NullOrWhiteSpace -String $SelectedManager)) {
            do {
                $Answer=Read-Host "Set user $($To)'s manager as $($SelectedManager)? (Y/N)"
                if ($Answer.ToLower() -eq "y") {
                    Set-ADUser -Identity:$To -Manager $SelectedManager
                    Write-Host "Set user $($To)'s manager as $($SelectedManager)."
                } elseif ($Answer.ToLower() -eq "n") { Break }
            } until ($Answer.ToLower() -eq "y" -or $Answer.ToLower() -eq "n")
            } else {
            Write-Host "Manager info for $($To) not found."
            break
        }
        }
    }

    if ($MemberOf) {
        if (!$Confirm) {
            foreach ($Group in $FromUserGroups) {
                Add-ADGroupMember -Identity:$Group -Members $To
            }
            Write-Host "Copied MemberOf groups from user $($From) to user $($To)."
        } else {
            do {
                $Answer=Read-Host "Copy AD Group Memberships from user $($From) to user $($To)? (Y/N)"
                if ($Answer.ToLower() -eq "y") {
                    foreach ($Group in $FromUserGroups) {
                        Add-ADGroupMember -Identity:$Group -Members $To
                    }
                } elseif ($Answer.ToLower() -eq "n") { Break }
                Write-Host "Copied MemberOf membership groups from user $($From) to user $($To)."
            } until ($Answer.ToLower() -eq "y" -or $Answer.ToLower() -eq "n")
        }
    }
} #endprocess
} #endfunc