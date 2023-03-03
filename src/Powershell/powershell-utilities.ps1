
if (!(Get-Module -Name SqlServer -ListAvailable)) {
   $null = Install-Module -Name SqlServer -Scope CurrentUser -AllowClobber -Force
}
$null = Import-Module -Name SqlServer -Force

function Wait-ForSqlServer {
   $Parameters = @{
      ServerInstance = 'localhost, 1433';
      Username       = 'sa';
      Password       = 'DevTools1!';
      Query          = 'SELECT 1'
   }
   Write-Output "Waiting for SQL server availability..."
   for (; ; ) {
      Try {
         $null = Invoke-Sqlcmd @Parameters -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
         if ($? -eq $true) {
            break;
         }
      }
      Catch {
      }
      Start-Sleep -Seconds 3
   }
}

function Wait-ForDockerServices {
   param (
      $Services = @(),
      $Timeout = (New-TimeSpan -Seconds 10)
   )

   $stopwatch = [System.Diagnostics.Stopwatch]::new()
   $stopwatch.Start();

   for (; ; ) {

      $notReadyServices = "";
      foreach ($serviceName in $Services) {

         $ready = $true;
         $dockerOutput = docker inspect --format '{{.Name}};{{.State.Status}};{{.State.Health}}' $serviceName
         $dockerOutputs = $dockerOutput.Split(";")          
         Write-Output "output: $dockerOutput"

         if ([string]::IsNullOrEmpty($dockerOutput) -or (-not $dockerOutput.Contains($serviceName))) {
            $ready = $false
         }

         $health = $dockerOutputs[2];
         if ($health -ne '<nil>') {
            if ($health.Contains('unhealthy')) {
               throw "Service $serviceName is unhealthy."
            }
            if (-not $health.Contains('healthy')) {
               $ready = $false
            }                
         }

         if (-not $dockerOutputs[1].Contains('running')) {
            $ready = $false
         }     

         if (-not $ready) {
            $notReadyServices += "$serviceName, "
         }
      }
      
      if ([string]::IsNullOrEmpty($notReadyServices)) {
         return
      }
    
      if ($stopwatch.Elapsed -gt $timeout) {
         throw "Timeout $timeout exceeded waiting for services (${notReadyServices})."
      }

      Start-Sleep -s 1
    
   }

}

#
# Example: $urlActive = Wait-ForUrl -Url 'http://localhost:4200' -Timeout $timeout  -ErrorAction SilentlyContinue -WarningAction SilentlyContinue 
#

function Wait-ForUrl {

   param(
      [Parameter(Mandatory = $true)]      
      [string]
      $Url,
      $Timeout = (New-TimeSpan -Seconds 120)      
   ) 

   $stopwatch = [System.Diagnostics.Stopwatch]::new()
   $stopwatch.Start();

   for (; ; ) {
      $httpRequest = [System.Net.WebRequest]::Create($Url)
      $httpResponse = $httpRequest.GetResponse()
      if ($httpResponse -ne $null) {
         $httpStatus = [int]$httpResponse.StatusCode
         $httpResponse.Close();
         if ($httpStatus -eq 200) {
            return $true;
         }
      }

      if ($stopwatch.Elapsed -gt $Timeout) {
         Write-Host "Timeout $timeout exceeded waiting for url ($Url}."
         return $false;
      }      
      Start-Sleep -Seconds 1
   }
   $rc;
}

function Clear-Docker {
   Write-Host "Stopping all processes..."
   docker ps -a -q | % { docker stop $_ }
   Write-Host "Removing all processes..."
   docker ps -a -q | % { docker rm $_ }
   Write-Host "Removing all images..."
   #docker images --filter "dangling=true" -q --no-trunc | % { docker rmi $_ -f }
   docker images -q --no-trunc | % { docker rmi $_ -f }
   Write-Host "Removing all volumes..."
   docker volume ls -qf dangling=true | % { docker volume rm $_ }
   docker system prune -a
}

function Clear-Images {

   param(
      [Parameter(Mandatory = $true)]      
      $Filter = ""
   )

   $images = docker image ls --format='{{.Repository}}:{{.Tag}}' | Select-String $Filter 
   foreach ($image in $images) {
      Write-Output "Deleting: $image"
      docker rmi -f $image
   }   
}
