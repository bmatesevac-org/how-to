param (
   [string] $repoRoot = "."
)

$repoRoot = Resolve-Path -Path $repoRoot
Write-Host "bct-olympus-integration = $repoRoot"

$modes = @(
   'sql',
   'mqtt',
   'rabbit',
   'infrastructure',
   'auth-tomes',
   'platform',
   'reveos2',
   'platform-tools',
   'reveos2-tools',
   'ocelot-gateway'
)


function Start-Olympus {

   param (
      [switch] $Update,
   )

   get-item env:EP_*
   Push-Location $repoRoot
      if ($Update.IsPresent) {
         # default is to update
         ./localdev.ps1
      }
      else {
         ./localdev.ps1 -NoUpdate
      }
   Pop-Location      
   docker ps               
}


function Start-Olympus-Custom {

   param (
      [switch] $Update,
      [switch] $MultiDeviceTypes
   )


   Push-Location $repoRoot

   ./set-develop-env.ps1
   ./set-tomesprovider-env.ps1
   ./set-aadprovider-env.ps1
   
   $env:EP_AUTHORITY = "http://host.docker.internal:9980"

   get-item env:EP_*

   ./docker-login.ps1

   if ($Update.IsPresent) {
      ./compose.ps1 -mode pull
   }

   foreach ($mode in $modes) {
      if ($MultiDeviceTypes.IsPresent) {
         if ($mode -ne "platform-tools") {
            ./compose.ps1 -mode $mode
         }
      }
      else {
         ./compose.ps1 -mode $mode
      }

      if ($mode -eq 'sql') {
         .\create-temptomes.ps1
      }
   }

   # insert extra device types
   if ($MultiDeviceTypes.IsPresent) {
      Start-Sleep -Seconds 5
      $epTenantId = $env:EP_TENANT_ID
      $env:EP_TENANT_ID = "TEMP_TENANT_ID"
      ./compose.ps1 -mode "platform-tools"
      Start-Sleep -Seconds 5
      docker compose -p "bct-enterpriseplatform-platform-tools" down --remove-orphans -v      
      $env:EP_TENANT_ID = $epTenantId;
      ./compose.ps1 -mode "platform-tools"
   }



      
   Pop-Location      
   docker ps               
}

function Stop-Olympus {
   foreach ($mode in $modes) {
      if ($mode -eq 'platform') {
         docker compose -p "bct-enterpriseplatform" down --remove-orphans -v
      }
      else {
         docker compose -p "bct-enterpriseplatform-${mode}" down --remove-orphans -v
      }
   }
   docker ps
}

function Clear-Olympus {

   $containers = docker container ls --filter name=bct-* --format "{{.ID}}"
   foreach ($container in $containers) {
      docker stop $container 
      Write-Host $result
   }
   

   docker volume prune -f 
   docker container prune -f 
   docker image prune -f 
}

