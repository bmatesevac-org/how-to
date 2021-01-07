



Write-Output "Checking for EXPECTED-ENV-VAR"
# An env variable EXPECTED-ENV-VAR is passed in from the program
# It should show in this output
$output = Get-Item Env:EXPECTED*
Write-Output $output
Write-Output "Checking for EXPECTED-ENV-VAR complete."
