;WITH backup_cte AS
(
    SELECT
       database_name AS database_name,
        backup_type =
            CASE type
                WHEN 'D' THEN 'database'
                WHEN 'L' THEN 'log'
                WHEN 'I' THEN 'differential'
                ELSE 'other'
            END,
        backup_finish_date,
        rownum = 
            ROW_NUMBER() OVER
            (
                PARTITION BY database_name, type 
                ORDER BY backup_finish_date DESC
            ),
   media_set_id
    FROM msdb.dbo.backupset
     where database_name not in ('master', 'model', 'msdb')
),
BACKUP2 AS 
(
SELECT distinct
'restore database ['+ b.database_name + '] from ' + STUFF((SELECT ' , disk = ''' + a.physical_device_name +''' with norecovery;'
            from msdb.dbo.backupmediafamily a
            where a.media_set_id = b.media_set_id
            FOR XML PATH('')), 1, 2, '') AS CODE ,
   b.backup_finish_date,b.database_name
 FROM backup_cte b, msdb.dbo.backupmediafamily m
 where b.media_set_id=m.media_set_id  AND B.backup_type = 'log'
 and b.backup_finish_date >= (select max(backup_finish_date) 
        from backup_cte inter
        where inter.backup_type in ('database', 'differential') 
         and inter.rownum=1
         and inter.database_name = b.database_name)
--order by b.backup_finish_date,b.database_name
 ) 
SELECT CODE FROM BACKUP2 b
order by b.database_name, b.backup_finish_date
