Function Store-Console {
begin {
    if (!(Test-Path -Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force
        "Existing PowerShell profile not found. Created."
    }
$ConWidth=[console]::WindowWidth
$ConHeight=[console]::WindowHeight
$BufferWidth=[console]::BufferWidth
}#endbegin
process {
$ProfileContent=Get-Content -Path $PROFILE -Force
$ConWidthLineNum=(($ProfileContent|Select-String '\$ConWidth').LineNumber)
$ConHeightLineNum=(($ProfileContent|Select-String '\$ConHeight').LineNumber)
$BufferWidthLineNum=(($ProfileContent|Select-String '\$BufferWidth').LineNumber)
if ($ConWidthLineNum) {$ProfileContent[($ConWidthLineNum)-1]="`$ConWidth=$ConWidth"}else{$ProfileContent+="`$ConWidth=$ConWidth"}
if ($ConHeightLineNum) {$ProfileContent[($ConHeightLineNum)-1]="`$ConHeight=$ConHeight"}else{$ProfileContent+="`$ConHeight=$ConHeight"}
if ($BufferWidthLineNum) {$ProfileContent[($BufferWidthLineNum)-1]="`$BufferWidth=$BufferWidth"}else{$ProfileContent+="`$BufferWidth=$BufferWidth"}
}#endprocess
end {
$ProfileContent|Set-Content -Path $PROFILE
"Console dimensions stored."
}#endend
}#endfunc

Function Update-Console {
begin {
    $ProfileContent=Get-Content -Path $PROFILE -Force
    $ConWidthLineNum=(($ProfileContent|Select-String '\$ConWidth').LineNumber)
    $ConHeightLineNum=(($ProfileContent|Select-String '\$ConHeight').LineNumber)
    $BufferWidthLineNum=(($ProfileContent|Select-String '\$BufferWidth').LineNumber)
}
process {
    [console]::WindowWidth=($ProfileContent[$ConWidthLineNum-1] -split "=")[-1]
    [console]::WindowHeight=($ProfileContent[$ConHeightLineNum-1] -split "=")[-1]
    [console]::BufferWidth=($ProfileContent[$BufferWidthLineNum-1] -split "=")[-1]
}
end {
    "Console dimensions updated."
}
}#endfunc