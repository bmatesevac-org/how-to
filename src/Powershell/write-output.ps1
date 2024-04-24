


function Get-SomeValue {
   Write-Output("Some Value");
   return $true
}

function Get-AnotherValue {
   Write-Host("Some other Value");
   return $true
}


$rc1 = Get-SomeValue;
$rc2 = Get-AnotherValue;

Write-Host("-----------------------")
Write-Host($rc1);
Write-Host($rc2);

