Function Copy-ADAttributes {
<#
.SYNOPSIS

Copies AD descriptor attributes from one AD user to another.

.DESCRIPTION

The Copy-ADAttributes function copies the Description, Office, StreetAddress, City, State, PostalCode, County, Title, Department, and Company attributes From one Active Directory user To another.
Additional functionality built in to add manager, copy member groups, and confirmation to avoid accidental overwrites.

.PARAMETER From

The From(Identity) parameter specifies the Active Directory user to copy FROM.
Username or full name.

.PARAMETER To

The To(Target) parameter specifies the Active Directory user to copy TO.
Username or full name.

.PARAMETER Manager

The Manager parameter specifies the Active Directory user to to choose MANAGER from.
Username or full name.

.PARAMETER MemberOf

MemberOf will copy all MemberOf groups From(Identity) to To(Target) user.

.PARAMETER Confirm

Confirm will ask you (Y/N) to confirm each change before it is made. Plus some additional colorful text.

.INPUTS

System.String

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
Set user Pluto's manager as Courage The. CowardlyDog? (Y/N): Y
Set user Pluto's manager as Courage The. CowardlyDog.
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
Version: 1.2
TODO: Less ugly? Module?
#>
[CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,
               Position=0)]
    [Alias("Identity")]
    [ValidatePattern("^\w+")]
    [String]
    $From,

    [Parameter(Mandatory=$true,
               Position=1)]
    [Alias("Target")]
    [ValidatePattern("^\w+")]
    [String]
    $To,

    [Parameter(Position=2)]
    [ValidatePattern("^\w+")]
    [String]
    $Manager,

    [Parameter()]
    [Switch]
    $MemberOf,
    
    [Parameter()]
    [Switch]
    $Confirm
    )#endparam
    begin {
    #Defining super necessary function
        Function Confirm-Host {
    <#
    .SYNOPSIS

    Prompts user to confirm only yes or no.

    .DESCRIPTION

    Prompts a user to confirm yes or no only. Accepts scriptblocks as parameters to define action upon answer. Default output is true or false.

    .PARAMETER YesBlock

    Default=$True
    Alias=YesAction
    Also accepts a script block as input to determine action taken upon yes.

    .PARAMETER NoBlock

    Default=$False
    Alias=NoAction
    Also accepts a script block as input to determine action taken upon no.

    .INPUTS

    [System.String]
    [System.Management.Automation.ScriptBlock]

    .OUTPUTS

    [System.Obkect]
    Otherwise, specify your own output using scriptblocks.

    .EXAMPLE

    PS> Confirm-Host
    Please select yes or no. (Y/N): Y
    True

    .EXAMPLE

    PS> Confirm-Host -Prompt "Would you like to know what fruit we have? (Y/N)" -YesBlock {$fruits=("Apples","Oranges","Bananas","Pears","Mangoes");$fruits}
    Would you like to know what fruit we have? (Y/N): y
    Apples
    Oranges
    Bananas
    Pears
    Mangoes

    .EXAMPLE

    PS> Confirm-Host -Prompt "Would you like to know what fruit we have? (Y/N)" -YesBlock {$fruits=("Apples","Oranges","Bananas","Pears","Mangoes");$fruits} -NoBlock {"Good bye then!"}
    Would you like to know what fruit we have? (Y/N): n
    Good bye then!

    .NOTES
    Author: Joseph Y
    Website: https://github.com/exoup
    Version: 1.0
    #>
        Param (
        [Parameter(Mandatory=$False,
                   Position=0)]
        [String]$Prompt="Please select yes or no. (Y/N)",

        [Parameter(Mandatory=$False,
                   ValueFromPipeline,
                   Position=1)]
        [Alias("YesAction")]
        [ScriptBlock]$YesBlock={$True},

        [Parameter(Mandatory=$False,
                   ValueFromPipeline,
                   Position=2)]
        [Alias("NoAction")]
        [ScriptBlock]$NoBlock={$False}
        )

        do {
            $Answer=Read-Host -Prompt $Prompt
            if ($Answer.ToLower() -eq "y") {
                Invoke-Command -ScriptBlock $YesBlock
            } elseif ($Answer.ToLower() -eq "n") {
                Invoke-Command -ScriptBlock $NoBlock
            }
        } until ($Answer.ToLower() -eq "y" -or $Answer.ToLower() -eq "n") {
        }  
    }
    #Unnecessary function but for readability. Colorful text 'easier'!
    function Write-Color([String[]]$Text, [ConsoleColor[]]$Color) {
    for ($i = 0; $i -lt $Text.Length; $i++) {
        Write-Host $Text[$i] -Foreground $Color[$i] -NoNewLine
        }
        Write-Host
    }
    #####
    #Unnecessary function to list changes side by side.
    Function Compare-ArraysByHeader([array]$FirstInput,[array]$SecondInput,[string]$HeaderSeparator='=',[string]$ChangeSeparator='==>') {
    #Finding the longest array so we can count up to it.
    if ($FirstInput.Count -lt $SecondInput.Count) { $LineCount=$SecondInput.Count;$LineCheck=$SecondInput } else { $LineCount=$FirstInput.Count;$LineCheck=$FirstInput }
    #Checking that there is a header separator from the longest array.
    if ($LineCheck[0] -notlike "*$($HeaderSeparator)*") { "Line header separator could not be found.";break }
    for ($ln=0;$ln -lt $LineCount; $ln++) {
        #Actually getting header this time.
        if ($FirstInput[$ln] -ne $Null -and $SecondInput[$ln] -ne $Null) {
            $FirstSplit,$FirstContent=$FirstInput[$ln].Split($HeaderSeparator,2)
            $SecondSplit,$SecondContent=$SecondInput[$ln].Split($HeaderSeparator,2)
            if ($FirstSplit -eq $SecondSplit) {
            $Header=$FirstSplit+": "
            } else { $Header="Test: " }
        } elseif ($FirstInput[$ln] -eq $Null -and $SecondInput[$ln] -ne $Null) {
            $SecondSplit,$SecondContent=$SecondInput[$ln].Split($HeaderSeparator,2)
            $FirstSplit,$FirstContent=$SecondSplit,""
            $Header=$SecondSplit+": "
        } elseif ($FirstInput[$ln] -ne $Null -and $SecondInput[$ln] -eq $Null) {
            $FirstSplit,$FirstContent=$FirstInput[$ln].Split($HeaderSeparator,2)
            $SecondSplit,$SecondContent=$FirstSplit,""
            $Header=$FirstSplit+": "
        } else { break }
                Write-Host $Header -NoNewline
                Write-Host $FirstContent -ForegroundColor Yellow -NoNewline
                Write-Host " $ChangeSeparator " -NoNewline
                Write-Host $SecondContent -ForegroundColor Green
        }
    }
    ####Properties we want.
    $SelectedProperties="Description","Office","StreetAddress","City","State","PostalCode","Country","Title","Department","Company","MemberOf"
    #Getting users via username or full name.
    $FromADResults=@(Get-ADUser -Filter "name -like '$From' -or samaccountname -like '*$From*'" -Properties $SelectedProperties)
    $ToADResults=@(Get-ADUser -Filter "name -like '$To' -or samaccountname -like '*$To*'" -Properties $SelectedProperties)
    #Selecting FROM user from multiple results or less. 
    if ($FromADResults.count -gt 1) {
        Write-Host "From: Multiple results for $($From) found. Please choose one."
        foreach ($FromUser in $FromADResults) {
            if (!($FromUserSelected)) {
                Confirm-Host -Prompt "Did you mean $($FromUser.name)? (Y/N)" `
                             -YesBlock {
                             $Script:FromUserSelected=$FromUser
                             } `
                             -NoAction { break }
            }
        }
    } elseif ($FromADResults.count -eq 1) { 
    $FromUserSelected=$FromADResults 
    } #Cleaning up stuff.
    if ($FromADResults.count -eq 0 -or (!($FromUserSelected))) {
    Write-Host "No user for $($From) found."
    if ($FromUserSelected) { Remove-Variable -Name FromUserSelected -Scope Script -ea 0}
    break
    }
    #Selecting TO user from multiple results or less. 
    if ($ToADResults.count -gt 1) {
        Write-Host "To: Multiple results for $($To) found. Please choose one."
        foreach ($ToUser in $ToADResults) {
            if (!($ToUserSelected)) {
                Confirm-Host -Prompt "Did you mean $($ToUser.name)? (Y/N)" `
                             -YesBlock {
                             $Script:ToUserSelected=$ToUser
                             } `
                             -NoAction { break }
            }
        }
    } elseif ($ToADResults.count -eq 1) { 
    $ToUserSelected=$ToADResults 
    } #Cleaning up stuff.
    if ($ToADResults.count -eq 0 -or (!($ToUserSelected))) {
    Write-Host "No user for $($To) found."
    if ($ToUserSelected) { Remove-Variable -Name ToUserSelected -Scope Script -ea 0}
    if ($FromUserSelected) { Remove-Variable -Name FromUserSelected -Scope Script -ea 0}
    break
    }
    #Select Manager user from multiple results or less.
    if ($Manager) {
    $ManagerADResults=@(Get-ADUser -Filter "name -like '$Manager' -or samaccountname -like '*$Manager*'")
    if ($ManagerADResults.count -gt 1) {
        Write-Host "Manager: Multiple results for $($Manager) found. Please choose one."
        foreach ($ManagerUser in $ManagerADResults) {
            if (!($ManagerUserSelected)) {
                Confirm-Host -Prompt "Did you mean $($ManagerUser.name)? (Y/N)" `
                             -YesBlock {
                             $Script:ManagerUserSelected=$ManagerUser
                             } `
                             -NoAction { break }
            }
        }
    } elseif ($ManagerADResults.count -eq 1) { 
    $ManagerUserSelected=$ManagerADResults 
    } #Cleaning up stuff.
    if ($ManagerADResults.count -eq 0 -or (!($ManagerUserSelected))) {
    Write-Host "No user for $($Manager) found."
    if ($ToUserSelected) { Remove-Variable -Name ToUserSelected -Scope Script -ea 0}
    if ($FromUserSelected) { Remove-Variable -Name FromUserSelected -Scope Script -ea 0}
    if ($ManagerUserSelected) { Remove-Variable -Name ManagerUserSelected -Scope Script -ea 0}
    break
    }
    }
    #Here we're storing some additional stuff for later.
        $FromSplatProperties=@{
        "City"=$FromUserSelected.City
        "Company"=$FromUserSelected.Company
        "Country"=$FromUserSelected.Country
        "Department"=$FromUserSelected.Department
        "Description"=$FromUserSelected.Description
        "Office"=$FromUserSelected.Office
        "PostalCode"=$FromUserSelected.PostalCode
        "State"=$FromUserSelected.State
        "StreetAddress"=$FromUserSelected.StreetAddress
        "Title"=$FromUserSelected.Title
        }
    #For updating membergroups.
    $FromUserSelectedGroups=$FromUserSelected.MemberOf
    $ToUserSelectedGroups=$ToUserSelected.MemberOf
    #For keeping track of membergroup changes.
    $FromArray=@(foreach ($Group in $FromUserSelectedGroups) {"Group=$($Group)"})
    $ToArray=@(foreach ($Group in $ToUserSelectedGroups) {"Group=$($Group)"})
    #For keeping track of manager changes.
    $ManSelectArray=@("Manager=$($ManagerUserSelected.name)")
    $ManToArray=@("Manager=$($ToUserSelected.Manager)")
    #For keeping track of changes made to AD attributes.
    $BeforeChangeToArray=@(
        "City=$($ToUserSelected.City)"
        "Company=$($ToUserSelected.Company)"
        "Country=$($ToUserSelected.Country)"
        "Department=$($ToUserSelected.Department)"
        "Description=$($ToUserSelected.Description)"
        "Office=$($ToUserSelected.Office)"
        "PostalCode=$($ToUserSelected.PostalCode)"
        "State=$($ToUserSelected.State)"
        "StreetAddress=$($ToUserSelected.StreetAddress)"
        "Title=$($ToUserSelected.Title)"
        )
    $AfterChangeToArray=@(
        "City=$($FromUserSelected.City)"
        "Company=$($FromUserSelected.Company)"
        "Country=$($FromUserSelected.Country)"
        "Department=$($FromUserSelected.Department)"
        "Description=$($FromUserSelected.Description)"
        "Office=$($FromUserSelected.Office)"
        "PostalCode=$($FromUserSelected.PostalCode)"
        "State=$($FromUserSelected.State)"
        "StreetAddress=$($FromUserSelected.StreetAddress)"
        "Title=$($FromUserSelected.Title)"
        )
    }#endbegin
    process {
        #Starting with copying AD properties. Confirmation optional.
        if (!$Confirm) {
            Set-ADUser -Identity:$ToUserSelected.samaccountname @FromSplatProperties 
            Write-Color -Text "Copied AD attributes from user ","$($FromUserSelected.name)"," to user ","$($ToUserSelected.name)","." -Color "White","Yellow","White","Green","White"
        } else { #Displaying the changed stuff.
            Compare-ArraysByHeader -FirstInput $BeforeChangeToArray -SecondInput $AfterChangeToArray
            "`n"
            Confirm-Host -Prompt "Copy AD Attributes from user $($FromUserSelected.name) to user $($ToUserSelected.name)? (Y/N)" `
                         -YesBlock {
                            Set-ADUser -Identity:$ToUserSelected.samaccountname @FromSplatProperties 
                            Write-Color -Text "Copied AD attributes from user ","$($FromUserSelected.name)"," to user ","$($ToUserSelected.name)","." -Color "White","Yellow","White","Green","White"
                        } `
                     -NoAction { break }
        }
        #Doing these in separate sections so we can break on individual steps. i.e. NOT setting AD properties but setting manager and groups.
        #Manager
        if ($Manager) {
            if (!$Confirm) {
                Set-ADUser -Identity:$ToUserSelected.samaccountname -Manager $ManagerUserSelected.DistinguishedName 
                Write-Color -Text "Set user ","$($ToUserSelected.name)'s"," manager as ","$($ManagerUserSelected.name)","." -Color "White","Green","White","Yellow","White"
            } else { #Displaying the changed stuff.
                Compare-ArraysByHeader -FirstInput $ManToArray -SecondInput $ManSelectArray
                Confirm-Host -Prompt "Set user $($ToUserSelected.name)'s manager as $($ManagerUserSelected.name)? (Y/N)" `
                             -YesBlock {
                                Set-ADUser -Identity:$ToUserSelected.samaccountname -Manager $ManagerUserSelected.DistinguishedName 
                                Write-Color -Text "Set user ","$($ToUserSelected.name)'s"," manager as ","$($ManagerUserSelected.name)","." -Color "White","Green","White","Yellow","White"
                             } `
                             -NoAction { break }
            }
        }
        #MemberOf Groups
        if ($MemberOf) {
            if (!$Confirm) {
                foreach ($Group in $FromUserSelectedGroups) {
                    Add-ADGroupMember -Identity:$Group -Members $ToUserSelected.samaccountname 
                }
                Write-Color -Text "Copied membership groups from user ","$($FromUserSelected.name)"," to user ","$($ToUserSelected.name)","." -Color "White","Yellow","White","Green","White"
            } else { #Displaying the changed stuff.
                Compare-ArraysByHeader -FirstInput $ToArray -SecondInput $FromArray
                "`n"
                Confirm-Host -Prompt "Copy AD Group Memberships from user $($FromUserSelected.name) to user $($ToUserSelected.name)? (Y/N)" `
                             -YesBlock {
                                foreach ($Group in $FromUserSelectedGroups) {
                                    Add-ADGroupMember -Identity:$Group -Members $ToUserSelected.samaccountname
                                }
                                Write-Color -Text "Copied membership groups from user ","$($FromUserSelected.name)"," to user ","$($ToUserSelected.name)","." -Color "White","Yellow","White","Green","White"
                             } `
                             -NoAction { break }
            }
        }
    }#endprocess
    end {
    #Cleanup duty
    if ($ToUserSelected) { Remove-Variable -Name ToUserSelected -Scope Script -ea 0}
    if ($FromUserSelected) { Remove-Variable -Name FromUserSelected -Scope Script -ea 0}
    if ($ManagerUserSelected) { Remove-Variable -Name ManagerUserSelected -Scope Script -ea 0}
    }#endend
}#endfunc