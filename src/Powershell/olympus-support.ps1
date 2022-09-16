param (
   [string] $repoRoot = "."
)

$repoRoot = Resolve-Path -Path $repoRoot
Write-Host "bct-olympus-integration = $repoRoot"

$modes = @(
   'sql',
   'mqtt',
   'rabbit',
   'rabbitmq',
   'infrastructure',
   'prometheus',   
   'auth-tomes',
   'platform',
   'reveos2',
   'platform-tools',
   'reveos2-tools',
   'ocelot-gateway',
   'gui-shell'
)


function Start-Olympus {

   param (
      [switch] $Update
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



function Stop-Olympus {
   foreach ($mode in $modes) {
      if ($mode -eq 'platform') {
         docker compose -p "bct-enterpriseplatform" down --remove-orphans -v
      }
      else {
         docker compose -p "bct-enterpriseplatform-${mode}" down --remove-orphans -v
      }
   }

   # any stragglers?
   $stragglers = docker container ls --filter name=bct-* --format='{{.Names}}'
   foreach ($service in $stragglers) {
      docker compose -p "bct-enterpriseplatform-${service}" down --remove-orphans -v
   }

   docker ps
}

function Clear-Olympus {

   $containers = docker container ls --filter name=bct-* --format "{{.ID}}"
   foreach ($container in $containers) {
      Write-Host "Container: {$container}"
      docker stop $container 
      docker rm $container
      Write-Host $result
   }
   
   Write-Host "Clearing volumes..."
   docker volume prune -f 
   Write-Host "Clearing containers..."
   docker container prune -f 
   Write-Host "Clearing images..."
   docker image prune -f 
   docker ps
}



