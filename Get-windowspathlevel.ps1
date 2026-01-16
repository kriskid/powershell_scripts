$updatesession = New-Object -comobject Microsoft.update.Session
$updateSearcher = $updatesession.createUpdateSearcher()

$updates = $updateSearcher.QueryHistory(0,$updateSearcher.GetTotalHistoryCount())

$hotfixes = Get-HotFix

$hotfixinstallstate = foreach($hotfix in $hotfixes){
    $updatename = ($updates|Where-Object{$_.title -like "*$($hotfix.HotfixID)*"}).title
[PSCustomObject]@{
    Name = $updatename
    Hostname = $hotfix.__server
    InstalledON = $hotfix.InstalledON
    InstalledBy = $hotfix.InstalledBy
    PatchLevel = if($updatename -ne $null){$updatename.substring(0,7)}

}

}

$hotfixinstallstate|Where-Object{$_.Name -like "*Cumulative Update for Windows*"}