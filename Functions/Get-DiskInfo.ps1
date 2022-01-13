Function Get-DiskInfo {
Param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [Alias("CimSession","CN")]
    [string[]]
    $ComputerName
)
Begin {
if (!$ComputerName) {$Disks=Get-CimInstance -Class Win32_LogicalDisk|select *} else {
$Disks=Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $ComputerName|select *
}
}
Process {
$GetDisks=foreach ($Disk in $Disks) {
        if ($Disk.Size -ne $null) {
            $Disk|Select @{n='Computer';e={$_.SystemName}},
            @{n='DriveLetter';e={$_.DeviceID}},
            @{n='DiskSize';e={"$([math]::round($_.Size/1GB,2)) GB"}},
            @{n='DiskFree';e={"$([math]::round($_.FreeSpace/1GB,2)) GB"}},
            @{n='PercentFree';e={[math]::round(($_.FreeSpace/$_.Size)*100)}},
            @{n='SystemDrive';e={if($_.DeviceID -eq $env:SystemDrive){"Yes"}else{"No"}}},
            @{n='VolumeName';e={$_.VolumeName}}
        }
    }
}
End {
$GetDisks
}
}