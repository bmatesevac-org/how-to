


# bctdev@lin-oly-dev-001.centralus.cloudapp.azure.com


function Enter-Server {
   param(
      [Parameter(Mandatory = $true)]   
      [string] $Server,
      [Parameter(Mandatory = $true)]   
      [string] $Alias
   )

   $secretsFolder = "${HOME}/.secrets"
   $user = Get-Content "$secretsFolder/${Alias}-ssh-username";
   $password = Get-Content "$secretsFolder/${Alias}-ssh-password";

   plink -ssh $Server -l $user -pw $password
}


function Enter-QA {
   Enter-Server -Server "lin-oly-qa-001.centralus.cloudapp.azure.com" -Alias "qa"
}
function Enter-STG {
   Enter-Server -Server "lin-oly-st-001.centralus.cloudapp.azure.com" -Alias "stg"
}




