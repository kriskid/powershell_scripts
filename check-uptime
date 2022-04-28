$boottime=[management.Managementdatetimeconverter]::ToDateTime((get-wmiobject -class win32_operatingsystem).Lastbootuptime)
$date=get-date
$date-$boottime
