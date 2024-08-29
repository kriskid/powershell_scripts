function test-conn {
param(
[Parameter(mandatory=$True)] [string]$ipaddress,
[Parameter(mandatory=$True)] [int]$Port
)

BEGIN{
$ErrorActionPreference = "SilentlyContinue"
}

PROCESS{
$connection = New-Object System.Net.Sockets.TcpClient($ipaddress, $port) -ErrorAction SilentlyContinue
if ($connection.Connected) {
     $output = [pscustomobject] @{
     destination = $ipaddress
     port = $port
     connectionSuccess  = $true
     }
} else { 
 $output = [pscustomobject] @{
     destination = $ipaddress
     port = $port
     connectionSuccess  = $False
     }
}

}
END{
$connection.Close()
$output

}
}