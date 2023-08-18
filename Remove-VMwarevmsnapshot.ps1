Param(
[Parameter(Mandatory = $True,HelpMessage = "Enter the VM Name you want to delete the snapshot")]$VMName,
[Parameter(Mandatory = $True, HelpMessage = "Enter the vCenter Server Name where the VM exist")]$VCenterName,
[Parameter(Mandatory = $True, HelpMessage = "Enter the number of days you want the snapshots to be deleted")][int]$Days
)

if($Days -ge 0){
$Days = $Days * -1
}

Function readcredentials{
$cred = Import-Clixml Credfile.xml
}

Function Connectvcenter{
Connect-viserver $VCenterName -credential $cred
}

Function removesnapshot{
Get-snapshot -VM $VMName|Where-Object{$_.created -lt (get-date).adddays($days)}|remove-Snapshot -confirm:$false
}

#main
readcredentials
Connectvcenter
removesnapshot

