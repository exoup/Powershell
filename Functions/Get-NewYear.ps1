Function Get-NewYear {
Param(
    [Parameter(Mandatory=$false)]
    [switch]
    $DaysSince
)

Begin {
$Year=(Get-Date).year
$NewYear=Get-Date -Date 01/01/$Year -DisplayHint Date
}
Process {
$DaysAgo=((Get-Date)-($NewYear)).days
}
End {
if ($DaysSince) { return $DaysAgo }
return $NewYear
}
}#End Get-NewYear Function