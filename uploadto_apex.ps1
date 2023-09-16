function query-ESUreport {
param (
 #[Parameter(mandatory=$True)] [string]$Month,
 #[Parameter(mandatory=$True)] [String]$outputfile,
 [Parameter(mandatory=$True)] [String]$dbn
 )

$sqlquery = "DECLARE @FirstDayOfMonth datetime;
				DECLARE @SecondTuesdayOfMonth datetime;
				DECLARE @NDate as char(7);
				DECLARE @N1Date as char(7);
				DECLARE @N2Date as char(7);
				DECLARE @N3Date as char(7);
				DECLARE @N4Date as char(7);
				DECLARE @N5Date as char(7);
				declare @cdate DATETIME
				
				SET @cdate = GETDATE()
				SET  @FirstDayOfMonth = DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE()),0)     
				SET @SecondTuesdayOfMonth = DATEADD(DAY,((10 - DATEPART(dw,@FirstDayOfMonth)) % 7) + 7, @FirstDayOfMonth)

				IF GETDATE() < @SecondTuesdayOfMonth
				BEGIN
					SET @NDate = (SELECT convert(char(7),DATEADD(MONTH,-1,GETDATE()),126))
					SET @N1Date = (SELECT convert(char(7),DATEADD(MONTH,-2,GETDATE()),126))
					SET @N2Date = (SELECT convert(char(7),DATEADD(MONTH,-3,GETDATE()),126))
					SET @N3Date = (SELECT convert(char(7),DATEADD(MONTH,-4,GETDATE()),126))
					SET @N4Date = (SELECT convert(char(7),DATEADD(MONTH,-5,GETDATE()),126))
					SET @N5Date = (SELECT convert(char(7),DATEADD(MONTH,-6,GETDATE()),126))
				END
				ELSE
				BEGIN
					SET @NDate = (SELECT convert(char(7),DATEADD(MONTH,0,GETDATE()),126))
					SET @N1Date = (SELECT convert(char(7),DATEADD(MONTH,-1,GETDATE()),126))
					SET @N2Date = (SELECT convert(char(7),DATEADD(MONTH,-2,GETDATE()),126))
					SET @N3Date = (SELECT convert(char(7),DATEADD(MONTH,-3,GETDATE()),126))         
					SET @N4Date = (SELECT convert(char(7),DATEADD(MONTH,-4,GETDATE()),126))
					SET @N5Date = (SELECT convert(char(7),DATEADD(MONTH,-5,GETDATE()),126))
				END

Declare @Collection varchar(8)
Set @Collection = 'SMS00001' /*Enter the collection ID*/

Select * from (
select *,ROW_NUMBER() OVER (PARTITION BY MachineName ORDER BY State) AS RowNum 
from (
Select
Distinct 
VRS.Name0 + '.' + st.Domain00 as 'MachineName',
Os.Caption0 as 'OperatingSystem',
st.Domain00 as 'Domain',
DATEDIFF(DAY,Operating_System_DATA.LastBootUpTime00,@cdate) as UptimeDays,
CASE WHEN RBSTATE.ClientState > 0 Then 'Yes'
WHEN RBSTATE.ClientState = 0 Then 'No'
ELse 'Unknown' END AS 'RebootRequired',
DSK.Freespace0 AS CDriveFreeGB,
CASE WHEN UI.Title like @NDate + '%' and UCS.Status = 3 THEN @NDate
WHEN UI.Title like @N1Date + '%' and UCS.Status = 3 THEN @N1Date
WHEN UI.Title like @N2Date + '%' and UCS.Status = 3 THEN @N2Date
WHEN UI.Title like @N3Date + '%' and UCS.Status = 3 THEN @N3Date
WHEN UI.Title like @N4Date + '%' and UCS.Status = 3 THEN @N4Date
WHEN UI.Title like @N5Date + '%' and UCS.Status = 3 THEN @N5Date
WHEN RBSTATE.ClientState > 0 Then 'Server Pending Reboot'
ELSE 'Older than ' + @N5date END AS 'Patchlevel',
CASE WHEN UI.Title like @NDate + '%' and UCS.Status = 3 THEN 1
WHEN UI.Title like @N1Date + '%' and UCS.Status = 3 THEN 2
WHEN UI.Title like @N2Date + '%' and UCS.Status = 3 THEN 3
WHEN UI.Title like @N3Date + '%' and UCS.Status = 3 THEN 4
WHEN UI.Title like @N4Date + '%' and UCS.Status = 3 THEN 5
WHEN UI.Title like @N5Date + '%' and UCS.Status = 3 THEN 6
ELSE 7 END AS 'state',
CH.LastActiveTime,
--convert(varchar(32), CH.LastActiveTime, 127) as LastActiveTime,
CASE WHEN UI.Title like @NDate + '%' and UCS.Status = 3 THEN UI.Title
WHEN UI.Title like @N1Date + '%' and UCS.Status = 3 THEN UI.Title
WHEN UI.Title like @N2Date + '%' and UCS.Status = 3 THEN UI.Title
WHEN UI.Title like @N3Date + '%' and UCS.Status = 3 THEN UI.Title
WHEN UI.Title like @N4Date + '%' and UCS.Status = 3 THEN UI.Title
WHEN UI.Title like @N5Date + '%' and UCS.Status = 3 THEN UI.Title
ELSE 'NA' END AS 'KBArticle',
vrs.Client_Version0 as ClientVer,
CH.SiteCode as Sitecode

FROM v_UpdateComplianceStatus UCS
--INNER JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
INNER Join 
			(
Select 'KB' + updi.ArticleID as Article,BulletinID,ArticleID, InfoURL,CI_ID,updi.Title from v_updateinfo updi where (updi.Title like '%Cumulative Update for Windows%' or updi.Title like '%Security Monthly Quality Rollup%' or updi.Title like '%Cumulative Update for Microsoft server operating system%')								
	) UI
		on UCS.CI_ID=UI.CI_ID
INNER JOIN v_CICategories_All CIC ON UI.CI_ID = CIC.CI_ID
INNER JOIN v_CategoryInfo CI ON CIC.CategoryInstanceID = CI.CategoryInstanceID
INNER JOIN v_R_System VRS ON UCS.ResourceID = VRS.ResourceID
INNER JOIN v_GS_OPERATING_SYSTEM Os on UCS.ResourceID = Os.ResourceID
INNER JOIN Computer_System_DATA St on UCS.ResourceID = st.MachineID
INNER Join v_FullCollectionMembership Col on UCS.ResourceID = Col.ResourceID
INNER JOIN Operating_System_DATA ON UCS.ResourceID = Operating_System_DATA.MachineID
Inner Join vSMS_CombinedDeviceResources RBSTATE ON UCS.ResourceID = RBSTATE.MachineID
inner join v_CH_ClientHealth CH on CH.MachineID = VRS.ResourceID
INNER JOIN  (
select ResourceID,DeviceID0,Freespace0/1024 as Freespace0 from v_GS_LOGICAL_DISK where DeviceID0='c:'
) DSK on UCS.ResourceID=DSK.ResourceID
left join (select cmem.ResourceID as ResourceID, count (col.name) Collectioncount  from v_ClientCollectionMembers cmem
left join v_Collection col on cmem.CollectionID = col.CollectionID
where col.Name like 'OS-win%'
group by cmem.ResourceID) colcount on UCS.ResourceID = colcount.ResourceID
where UCS.Status = 3
--order by MachineName,state desc;
) as Subtable
) as finalTable where RowNum = 1;"

#$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$month = get-date -f dd-MMM
#$outputfile = "$ScriptDir\$month-GCS-Patchreport.csv"

Invoke-Sqlcmd -Database $DBn -Query $sqlquery #| export-csv $outputfile -notypeinformation
}

$result = query-ESUreport -dbn cm_kkk

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

Foreach ($item in $result){

$body = "
        {
            `"SERVERNAME`": `"$($item.MachineName)`",
            `"OS`": `"$($item.OperatingSystem)`",
            `"DOMAIN`": `"$($item.domain)`",
            `"UPTIME`": $($item.uptimedays),
            `"REBOOTREQUIRED`": `"$($item.RebootRequired)`",
            `"PATCHLEVEL`": `"$($item.Patchlevel)`",
            `"KBARTICLE`": `"$($item.KBArticle)`"
                }

"

$response = Invoke-RestMethod 'https://apex.oracle.com/pls/apex/acharifamily/patchreport/post' -Method 'POST' -Headers $headers -Body $body -Verbose
$response #| ConvertTo-Json$error

}