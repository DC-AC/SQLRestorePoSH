
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
),
BACKUP2 AS 
(
SELECT
'restore database '+ b.database_name + ' from ' + STUFF((SELECT ' , disk = ''' + a.physical_device_name +''' with norecovery;'
            from msdb.dbo.backupmediafamily a
            where a.media_set_id = b.media_set_id
            FOR XML PATH('')), 1, 2, '') AS CODE	
 FROM backup_cte b, msdb.dbo.backupmediafamily m
 where rownum = 1 AND b.media_set_id=m.media_set_id  AND B.backup_type = 'log'
 --order by b.backup_finish_date,b.database_name
 ) 
SELECT DISTINCT CODE FROM BACKUP2