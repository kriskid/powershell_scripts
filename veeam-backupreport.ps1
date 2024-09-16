<#
. SYNOPSIS 
Script to generate Veeam backup report. 

. DESCRIPTION 
Author: Krishna Kumar, Email: krishna . kumar@westernalliancebank.com 
This script can be run from the veeam backup servers to genereate the backup report. 
The report output will have the following attributes: 

ServerName 
Status 
JobName 
StartDate 
EndDate 
'obtype 
Backuptype 
Backupserver 

16-Aug-2Ø23 - Version 1.1 - Updated function to report both VM and Agent backup. 
. example 

. \veeam-backupreport.PS1 -dayssince 4 
The days since mentioned will generate the report from number of days, the default value is 1, 

#>

param( 
[parameter()]$dayssince=3 
)

if($dayssince -ge 1){ 
$days = $dayssince * -1 
}else{
$days -1 
}

function getveeamreport{ 
$collection = @{}

$jobs = [veeam.backup.core.cbackupJob]::GETALL()| Where-Object{$_.jobtype -eq "Backup" -or $_.jobtype -eq "EpAgentBackup"} 

$status = foreach ($job in $jobs){
    $sessions = [Veeam.backup.core.cbackupsession]::getByJob($job.id)|Where-Object{$_.Creationtime -ge (get-date).AddDays($days)}
        foreach($session in $sessions){
                $srvsess = Get-VBRTasksession -session $session.id
                    foreach($srv in $srvsess){
                        [PSCustomObject]@{
                            ServerName = $srv.Name
                            Status = $(if($srv.Status -eq "Success"){"Completed"}else{$srv.Status})
                            JobName = $job.Name
                            StartDate = $(Get-Date $Session.CreationTime)
                            EndDate = $session.Endtime
                            JObType = $Session.JobTypeString
                            BackupType = $srv.Jobsess.info.SessionAlgorithm
                        }

                    }

        }
}

}

$restore = Get-VBRrestoresession



# Main
connect-vbrserver -server localhost
getveeamreport

