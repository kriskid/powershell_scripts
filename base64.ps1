function base64{
param (
[Parameter(Mandatory=$False)]
[ValidateSet("UTF8","UNICODE","ASCII","Default","UTF32","UTF7")]
[String]$Encoding = "UTF8",
[Parameter(Mandatory=$True,
ValueFromPipeline = $True)]$Inputstring,
[Parameter(Mandatory=$False)][switch]$Decode
)

BEGIN
{
$output = "NULL"
}

PROCESS
{
if ($Decode)
{
$output = [System.Text.Encoding]::$($Encoding).GetString([System.Convert]::FromBase64String($Inputstring))
}
else{
$output = [Convert]::ToBase64String([Text.Encoding]::$($Encoding).GetBytes($Inputstring))
}
}

END
{
write-output $output
}

}