$Source = read-host -Prompt 'What is source SQL Server for backups?'
$target = read-host -Prompt 'What is target SQL Server for restores?'

$1=Invoke-SQLCmd -ServerInstance $source -InputFIle 'C:\temp\gen_full_restore.sql'
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

$2=Invoke-SQLCmd -ServerInstance $source -InputFIle 'C:\temp\gen_log_restore.sql'
if ($3.count -gt 0)
{
$2.ItemArray[0] | out-file C:\temp\restore_log.sql
}
else { echo "There are no log backups" }


$configFiles = Get-ChildItem  C:\temp\restore*.sql -rec
foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "C:", "\\$source\c$" } |
    Set-Content $file.PSPath
}


Invoke-Sqlcmd -ServerInstance $target -InputFile C:\temp\restore_full.sql


Invoke-Sqlcmd -ServerInstance $target -InputFile C:\temp\restore_diff.sql



