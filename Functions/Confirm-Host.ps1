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