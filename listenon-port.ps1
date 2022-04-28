<#
Author = Krishna Kumar <kriskid@gmail.com>
#>

param (
 [Parameter(mandatory=$True)] [int]$Port
 #[Parameter(mandatory=$True)] [int]$Waitfor
 )

$Listener = [System.Net.Sockets.TcpListener]$Port;
$Listener.Start();
#wait, try connect from another PC etc.
Write-Host "Press enter to stop the Listener" -ForegroundColor Yellow
pause

$Listener.Stop();

