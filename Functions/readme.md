### PowerShell Functions
------------
- Get-DiskInfo
    - Everyone creates their own disk info function in PowerShell, right?
    - `Get-DiskInfo [[-ComputerName] <string[]>]  [<CommonParameters>]`
    - Gets a variety of disk storage information.
    
- Get-NewYear
    - `Get-NewYear [-DaysSince]  [<CommonParameters>]`
    - Gets date info for the most recent New Year's day.
    - `-DaysSince` gets the days since the most recent New Year's day.
    
- Get-Doodle
    - `Get-Doodle [[-Search] <string[]>] [[-Random] <switch[]>]  [<CommonParameters>]`
    - Gets today's daily Doodle as told by the google.com/doodles website.
    - More funcitonality to come.

- Generate-PassPhrase
    - `Generate-PassPhrase [[-NonAlphaNumeric] <Int32>] [-Copy] [<CommonParameters>]`
    - Generates a random passphrase from a supplied list in the function.
    
- Store-Console
- Update-Console
    - `Store-Console`
    - `Update-Console`
    - Stores the current size of the console into the $profile.
    - Changed the current size of the console to match the stored info in the $profile.
    - Not particularly useful for anyone but me.
 
 - Get-WinRMStatus
    - `Get-WinRMStatus [-ComputerName] <string> [[-Action] {Start | Stop}]  [<CommonParameters>]`
    - Gets status of WinRM on a remote system. Can also start/stop the service.
    - Could easily be adapted to be used for any service.
   
 - Copy-ADAttributes
    - `Copy-ADAttributes [-From(Identity)] <String> [-To(Target)] <String> [-Manager] [-MemberOf] [-Confirm] [<CommonParameters>]`
    - Copies specific AD attributes to a different user. Fuzzy manager matching. Other stuff. Will refactor.
    -  See help info for help.