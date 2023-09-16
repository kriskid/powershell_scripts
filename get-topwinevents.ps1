<#
.synopsis

.DESCRIPTION

.PARAMETER

.Inputs

.Outputs

.Example

.Notes
	Author: Krishna KUmar
	email : - Kriskid@gmail.com
	Version: 1.0
	Change Log:
	

.Link
	https://github.com/kriskid/powershell_scripts
#>

Param(
# Parameter help description
[Parameter(Mandatory=$true)]
[ValidateSet("System","Application","setup","Security")]
[String]$LogName,
[Parameter(Mandatory=$true)]
[ValidateSet("Critical","Warning","Informational","Error","LogAlways","Verbose")]
[String]$eventType, 
[Parameter(Mandatory=$false)]
[int16]$Days=7
)

function Test-Administrator  
{  
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}


$date = get-date

if($Days -ge 0){
    $Days = $Days * -1
    }

$Level = switch ($eventType){
    "LogAlways" {0}
    "Critical" {1}
    "Error" {2}
    "Warning" {3}
    "Informational"{4}
    "Verbose"{5}
}


$filterhash = @{
    LogName=$LogName
    Level = $Level
    StartTime = $date.AddDays($Days)
    Endtime = $date
}


$events = Get-WinEvent -FilterHashtable $filterhash
$eventsum = @{}

foreach($event in $events){
    $eventsum[$event.id] = [PSCustomObject]@{
        ID = $event.id
        Count = $eventsum[$event.id].count + 1
        EventType = $event.LevelDisplayName
        TimeCreated = $event.TimeCreated
        Message = $event.Message
    }

}

$eventsum.values |Sort-Object Count -Descending |Select-Object -first 10
