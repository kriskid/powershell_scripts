param(
[Parameter(mandatory=$True)] [string]$ipaddress,
[Parameter(mandatory=$True)] [int]$Port
)

function test-conn {
param(
[Parameter(mandatory=$True)] [string]$ipaddressx,
[Parameter(mandatory=$True)] [int]$Portx
)

BEGIN{
$ErrorActionPreference = "SilentlyContinue"
}

PROCESS{
$connection = New-Object System.Net.Sockets.TcpClient($ipaddress, $port) -ErrorAction SilentlyContinue
if ($connection.Connected) {
     $output = [pscustomobject] @{
     destination = $ipaddressx
     port = $portx
     connectionSuccess  = $true
     }
} else { 
 $output = [pscustomobject] @{
     destination = $ipaddressx
     port = $portx
     connectionSuccess  = $False
     }
}

}
END{
$connection.Close()
$output

}
}

test-conn -ipaddressx $ipaddress -Portx $Port 