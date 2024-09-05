function getdisconnectedrdpsessions{

    param(
    $server="localhost"
    )

$users = @{}
$quser = (quser /server:$server|Where-Object{$_ -notlike "*RDP-TCP*" -and $_ -notlike "*USERNAME*"}).trim()|%{

    $data = ($_).split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
$users[$data[0]]=[PSCustomObject]@{
    UserID = $data[0]
    SessionID = $data[1]
    Idlesince = $data[3]
    Sessionstate = $data[2]
    ServerName = $server
}
}
$users.Values
}

getdisconnectedrdpsessions