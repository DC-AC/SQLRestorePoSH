$Source = read-host -Prompt 'What is source SQL Server for backups?'
$target = read-host -Prompt 'What is target SQL Server for restores?'

$1=Invoke-SQLCmd -ServerInstance $source -InputFIle 'C:\temp\gen_full_restore.sql'
$1.ItemArray[0] | out-file C:\temp\restore_full.sql

$2=Invoke-SQLCmd -ServerInstance $source -InputFIle 'C:\temp\gen_diff_restore.sql'
$2.ItemArray[0] | out-file C:\temp\restore_diff.sql


$2=Invoke-SQLCmd -ServerInstance $source -InputFIle 'C:\temp\gen_log_restore.sql'
$2.ItemArray[0] | out-file C:\temp\restore_log.sql


$configFiles = Get-ChildItem  C:\temp\restore*.sql -rec
foreach ($file in $configFiles)
{
    (Get-Content $file.PSPath) |
    Foreach-Object { $_ -replace "C:", "\\$source\c$" } |
    Set-Content $file.PSPath
}


Invoke-Sqlcmd -ServerInstance $target -InputFile C:\temp\restore_full.sql


Invoke-Sqlcmd -ServerInstance $target -InputFile C:\temp\restore_diff.sql

