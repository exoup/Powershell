function Get-WinRMStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [Parameter()]
        [ValidateSet("Start","Stop")]
        $Action
        )
    if ($Action) {
        if ($Action -eq "Start") {
        Get-Service -ComputerName $ComputerName -Name WinRM|Start-Service
        }
        elseif ($Action -eq "Stop") {
        Get-Service -ComputerName $ComputerName -Name WinRM|Stop-Service -Force
        }
    }
    Get-Service -ComputerName $ComputerName -Name WinRM
}