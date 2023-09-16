<# 
.SYNOPSIS
Convert any csv to an html file with table.
.DESCRIPTION

.PARAMETER inputfile
Provide a file name in current directory same as the script or full path of the csv file.

.PARAMETER Outputfile
Provide a file name in current directory same as the script or full path of the output file. The default is output-info.csv

.INPUTS
The defaut input file is named serverocids.txt which can be populated with the OCI ID of the compute instance for whcih backup inforation needs to be checked.

.OUTPUTS
The defaut output file is named output-info.csv and will be located in the same path as the script is kept and executed from.

.EXAMPLE

.NOTES
	Author: Krishna Kumar
    Change Log:
    Version 1.0
    2-Mar-2021 : 

.LINK
    
    
#>


Param(
      [Parameter(Mandatory=$false)] [string]$inputfile=".\inputfile.csv",
      [Parameter(Mandatory=$false)] [String]$Outputfile=".\htmlout.html"
  )


#$x = import-csv .\InstallUpdateslog.csv
#$input = import-csv $inputfile


#$outputfile = ".\htmlout.html"


function printtable {
  Param(
    [Parameter(Mandatory=$True)] $inputdata
  )

$table = '<table id="myTable">'

$fields = $inputdata |select -first 1 |%{
foreach ($property in $_.PSObject.Properties) 
{         
$property.Name
}
}
#"count of Fields = $($fields.count)" 

#comment: ----- Header row from csv.
$inputdata |select -first 1|%{
$table += '<tr>'
foreach ($property in $_.PSObject.Properties) 
{         
#$property.Name
if($property.name -ne "color"){
$table += "<th>$($property.Name)</th>"
}
}
$table += '</tr>'
}

#comment: ---- each row into table row
$count=1
$inputdata|%{
$rowcolor = $_.color
if($rowcolor -eq "red"){$table += "<tr class=red> `n`r"}elseif($rowcolor -eq "yellow"){$table += "<tr class=yellow> `n`r"}elseif($rowcolor -eq "green"){$table += "<tr class=green> `n`r"}else{
$table += "<tr> `n`r"
}
:inner
foreach ($property in $_.PSObject.Properties) 
{         
  if($property.name -ne "color"){
$table += "<td>$($property.Value)</td> `n`r"
  }
if ($count%$fields.Count -eq 0){
$count++
break inner
}
$count++
}
$table += "</tr> `n`r"

}
$table += "</table> `n`r"
$table += "<br> `n`r"
$table
}

$htmlstart = @"
<!DOCTYPE html>
<html>
<head>
<style>
* {
  box-sizing: border-box;
}

#myInput {

  
  background-position: 10px 10px;
  background-repeat: no-repeat;
  width: 20%;
  font-size: 16px;
  padding: 12px 20px 12px 40px;
  border: 1px solid #ddd;
  margin-bottom: 12px;
}

#myTable {
  border-collapse: collapse;
  width: 100%;
  border: 1px solid #ddd;
  font-size: 18px;
  padding: 12px;
}

#titletable {
  border-collapse: collapse;
  width: 100%;
  border: 1px solid #ddd;
  font-size: 18px;
  padding: 12px;
  }

#titletable th {
    background-color: #007395;
    color: #ffffff;
      text-align: center;
      padding: 12px;
      border: .1px solid black
 }

#myTable th {
background-color: #007395;
color: #ffffff;
  text-align: left;
  padding: 12px;
  border: 1px solid black
}

#myTable td {
    
  text-align: left;
  padding: 12px;
  border: 1px solid black
}


#myTable tr {
  border-bottom: 1px solid #ddd;
}

#myTable tr.red {
  background-color: #f95728;
  color: #ffffff;
  border-bottom: 1px solid #ddd;
}

#myTable tr.yellow {
  background-color: #ffffcc;
  color: #000000;
  border-bottom: 1px solid #ddd;
}

#myTable tr.green {
  background-color: #00cc66;
  color: #000000;
  border-bottom: 1px solid #ddd;
}

/*#myTable tr.header, #myTable tr:hover {
  background-color: #f1f1f1;
}*/

</style>
</head>
<body>
"@


$htmlend = @"
</body>
</html>
"@

function headertable{
  Param(
    [Parameter(Mandatory=$True)] $headertitle
  )
  $title = @"
  <table id=titletable>
  <tr>
  <th>
  $headertitle
  </th>
  </tr>
  </table>
"@

$title
}

#main


$tickerdata = foreach ($item in  $(import-csv C:\Users\user\Desktop\Near_52W_Lows_26_7_2023.csv)){
  
  $colortheticker = $(if ([int]$item.'Return on Investment' -le 8){"red"}elseif([int]$item.'Return on Investment' -gt 8 -and [int]$item.'Return on Investment' -le 15){"yellow"}elseif([int]$item.'Return on Investment' -gt 15){"green"}else{"None"})
  

[PSCustomObject]@{
  Name = $item.Name
  Ticker = $item.Ticker
  Marketcap = $item.'Market Cap'
 Return_on_investment = [int]$item.'Return on Investment'
 color = $colortheticker
}

}

$demo_project = foreach($item in $(import-csv C:\Users\user\Desktop\demo_projects.csv)){
  $colortheticker = $(if ($item.'STATUS' -eq 'Open'){"red"}elseif($item.STATUS -eq "pending"){"green"}else{"None"})
  

  [PSCustomObject]@{
    Project = $item.Project
    TaskName = $item.TASK_NAME
    STATUS = $item.STATUS
    BUDGET = [int]$item.BUDGET
   color = $colortheticker
  }
}

$htmlstart | out-file $outputfile
headertable -headertitle "ROI Data"|out-file $outputfile -Append
printtable -inputdata $($tickerdata |Sort-Object Return_on_investment) |out-file $outputfile -Append

headertable -headertitle "DEMO PROJECT"|out-file $outputfile -Append
printtable -inputdata $($demo_project |Sort-Object BUDGET) |out-file $outputfile -Append

$htmlend | out-file $outputfile -Append
