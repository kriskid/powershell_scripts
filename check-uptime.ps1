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

$boottime=[management.Managementdatetimeconverter]::ToDateTime((get-wmiobject -class win32_operatingsystem).Lastbootuptime)
$date=get-date
$date-$boottime
