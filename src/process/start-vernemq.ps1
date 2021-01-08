param (
    [Parameter(Mandatory=$true)][string]$config
)

# In the case of cert and nocert options, ALLOW_ANONYMOUS=on.
# So, presenting a password (valid or invalid) makes no difference.

$Env:DEVCOMM_MQTT_ADMIN_PASSWORD="pass"
$Env:DEVCOMM_MQTT_ALLOW_ANONYMOUS="on"
$Env:DEVCOMM_MQTT_REQUIRE_CERTIFICATE="off"

docker-compose -f ./docker-compose-vernemq.yaml down

If ($config -eq "cert")
{
    $Env:DEVCOMM_MQTT_REQUIRE_CERTIFICATE="on"
    docker-compose -f ./docker-compose-vernemq.yaml up 
}
ElseIf ($config -eq "nocert")
{
    docker-compose -f ./docker-compose-vernemq.yaml up 
}
ElseIf ($config -eq "password")
{
    $Env:DEVCOMM_MQTT_ALLOW_ANONYMOUS="off"
    $Env:DEVCOMM_MQTT_ADMIN_PASSWORD="pass"
    docker-compose -f ./docker-compose-vernemq.yaml up 
}
Else
{
    Write-Error "Incorrect configuration. Usage:`r`nstart-vernemq <cert, nocert, password>"
}