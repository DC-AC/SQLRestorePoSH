$Source = read-host -Prompt 'What is source SQL Server for backups?'
$target = read-host -Prompt 'What is target SQL Server for restores?'

$sql = "SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS')"
$svr = Invoke-Sqlcmd -ServerInstance $Source -Query $sql
$svr = $svr.ItemArray[0]
$svr = [String]$svr



if (test-path C:\temp\restore_full.sql) {remove-item C:\temp\restore_full.sql}
if (Test-Path C:\temp\restore_diff.sql) {remove-item C:\temp\restore_diff.sql}
if (Test-Path C:\temp\restore_log.sql) {Remove-Item C:\temp\restore_log.sql}

$1=Invoke-SQLCmd -ServerInstance $source -InputFile 'C:\temp\gen_full_restore.sql'
if($1.count -gt 0)
 {  
$1.ItemArray[0] | out-file C:\temp\restore_full.sql
 }
else { echo "There are no full backups" }


$2=Invoke-SQLCmd -ServerInstance $source -InputFIle 'C:\temp\gen_diff_restore.sql'
if($2.count -gt 0)
 {  
$2.ItemArray[0] | out-file C:\temp\restore_diff.sql
}
else {echo "There are no differential backups"}

$3=Invoke-SQLCmd -ServerInstance $source -InputFIle 'C:\temp\gen_log_restore.sql'
if ($3.count -gt 0)
{
$3.ItemArray[0] | out-file C:\temp\restore_log.sql
}
else { echo "There are no log backups" }



$configFiles = Get-ChildItem  C:\temp\restore*.sql -rec
foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "C:", "\\$svr\c$" } |
    Set-Content $file.PSPath
}


if (test-path C:\temp\restore_full.sql)
{if ((get-item C:\temp\restore_full.sql).length -gt 0kb)
{
Invoke-Sqlcmd -ServerInstance $target -InputFile C:\temp\restore_full.sql
}
}
else {"No full backups to restore"}


if (test-path C:\temp\restore_diff.sql)
{if ((get-item C:\temp\restore_diff.sql).length -gt 0kb)
{
Invoke-Sqlcmd -ServerInstance $target -InputFile C:\temp\restore_diff.sql
}
}
else {"No diff backups to restore"}

if (test-path C:\temp\restore_log.sql)
{if ((get-item C:\temp\restore_log.sql).length -gt 0kb)
{
Invoke-Sqlcmd -ServerInstance $target -InputFile C:\temp\restore_log.sql
}
}
else {"No diff backups to restore"}

