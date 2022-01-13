Function Get-Doodle {
Param(
    [Parameter(Mandatory=$false)]
    [string[]]
    $Search,

    [Parameter()]
    [Switch[]]
    $Random
)

Begin {
$ProgressPreference = 'SilentlyContinue'
$DoodleURI='https://www.google.com/doodles'
$Doodles=Invoke-WebRequest -Uri $DoodleURI
$DoodlePattern='(<img alt="(?<alt>.*)" src="\/\/(?<src>.*)">|<img src="\/\/(?<src>.*)" alt="(?<alt>.*)">)'
}#End Begin

Process {
$DailyDoodles=($Doodles.images).outerHTML|Select-String -AllMatches -Pattern $DoodlePattern
$DoodleList=foreach ($Doodle in $DailyDoodles) {
    [PSCustomObject]@{
        'Title'=($Doodle.matches.groups.where{$_.name -like 'alt'}.value)
        'DoodleURL'=($Doodle.matches.groups.where{$_.name -like 'src'}.value)
        }
    }
}#End Process

End {
"Today's Daily Doodle:",($DoodleList.DoodleURL)[0] -join (' ');"Doodle Title:",($DoodleList.Title)[0] -join (' ');return
}#End End
}#End Get-Doodle Func