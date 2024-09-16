$var1 = @{}
$hostname = $(hostname)
$var1[$hostname] = [pscustomobject]@{
Name = "Hostname"
Value = $hostname
Order = 1
}

$ipaddresses = Get-NetIPAddress|where-object{$_.AddressFamily -eq "IPV4" -and $_.IPaddress -ne "127.0.0.1"}

$addresscount=1
foreach ($ipaddress in $ipaddresses){
$mac = Get-NetAdapter|where-object{$_.ifindex -eq $ipaddress.ifIndex}
$var1["$($ipaddress.ipaddress)$addresscount"] = [pscustomobject]@{
Name = "ipaddress and Mac"
Value = "$($ipaddress.ipaddress) | $($mac.MacAddress)"
Order = 2
}        
$addresscount = $addresscount+1
}

$var1.Values|Sort-Object Order|select Name,Value
