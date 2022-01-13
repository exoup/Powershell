Start-Transcript logs\swlog.txt -append
#Declaring some variables
$URL="https://www.shipworks.com/download-customer/"
$HTML=Invoke-WebRequest $URL -UseBasicParsing
$DownloadPath="Path\To\Save\Here"
$SWJson="ShipworksVars.json"
$WebhookURI="Slack\Webhook\Here"
#PDQ Application directories
$PDQInventory="PDQ\Inventory\Path\Here.exe"
$PDQDeploy="PDQ\Deploy\Path\Here.exe"
#New Shipworks version information. Updates every run.
$NewPattern='<h3>(?<Version>\d+\.\d+\.\d+.\d+\s*\(\d+/\d+/\d{4}\))</h3>'
$NewMatches=(($HTML).content|Select-String $NewPattern -AllMatches).Matches|select -First 10
$NewVersion=(($NewMatches.Groups|where {$_.Name -like 'Version'}).Value[0] -split " \(.*\)")[0].tostring()
$NewFullVersion=($NewMatches.Groups|where {$_.Name -like 'Version'}).Value[0]
$NewDownload=($HTML.Links|Where id -like 'downloadShipworks').href
$NewName=$NewDownload.Split("/")[3]
#Creating empty JSON file for later storage.
if (Test-Path $SWJson -PathType Leaf) {
    Write-Host "Json file found."
} else {
    Write-Host "Json file not found. Generating."
    $Current = @{
        Current = @{
            Pattern=""
            Matches=""
            Version=""
            FullVersion=""
            Download=""
            Name=""
            }
        }
(ConvertTo-Json -InputObject $Current)|Out-file $SWJson
}
#Loading JSON file.
$LoadedJson=Get-Content $SWJson|ConvertFrom-Json
#Comparing new version to current version. Downloading/Updating if it exists.
if ($LoadedJson.Current.Version -lt $NewVersion) {
    Write-Host "Newer version of Shipworks found. Downloading."
#Updating JSON file.
    $LoadedJson.current.pattern=$NewPattern
    $LoadedJson.current.matches=$NewMatches
    $LoadedJson.current.version=$NewVersion
    $LoadedJson.current.fullversion=$NewFullVersion
    $LoadedJson.current.download=$NewDownload
    $LoadedJson.current.name=$NewName
    $LoadedJson|ConvertTo-Json|Set-Content $SWJson
    Invoke-WebRequest -Uri $NewDownload -OutFile $DownloadPath\$NewName
#Updating PDQ Variables.
    & $PDQInventory UpdateCustomVariable -Name SWVariableNameHere -Value $NewVersion
    & $PDQDeploy UpdateCustomVariable -Name SWVariableNameHere -Value $NewVersion
    } else {
    Write-Host "Current version of Shipworks is most recent."
	Stop-Transcript
    Exit
    }
#Slack notification stuff. ConvertTo-Json doesn't work so great with JSON arrays so.. just putting actual JSON here. Gross.
$Body=@"
{
    "attachments": [
        {
            "color": "#FFA600",
            "fallback": "Shipworks version $NewVersion has been <$URL|released> and automatically downloaded.",
            "pretext": "Shipworks version $NewVersion has been <$URL|released> and automatically downloaded.",
            "fields": [
                {
                    "value": "Manual download available <$NewDownload|here>.",
                    "short": false
                },
            ],

        }
    ]
}
"@
try {
    Invoke-RestMethod -Uri $WebhookURI -Method Post -Body $Body -ContentType 'application/json' | Out-Null
} catch {
    Write-Error "Could not post to Slack."
}
Stop-Transcript
