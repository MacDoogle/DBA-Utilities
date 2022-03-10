
CREATE PROCEDURE [dbo].[usp_GetIndexUsage]

AS
BEGIN

	-- Can be used to help find tables and or indexes that are rarely or never accessed by looking at index stats since last SQL restart.

WITH IndexCTE (ObjectName, IndexName, IndexType, TotalUserSeeks, 
TotalUserScans, TotalUserLookups, TotalUserUpdates, SumReads, rws, is_unique_constraint, CheckDate)
AS
(
SELECT 
     SCHEMA_NAME([sObj].[schema_id]) + '.' + [sObj].[name] AS [ObjectName],
     ISNULL([sIdx].[name], 'N/A') AS [IndexName],
     CASE
      WHEN [sIdx].[type] = 0 THEN 'Heap'
      WHEN [sIdx].[type] = 1 THEN 'Clustered'
      WHEN [sIdx].[type] = 2 THEN 'Nonclustered'
      WHEN [sIdx].[type] = 3 THEN 'XML'
      WHEN [sIdx].[type] = 4 THEN 'Spatial'
      WHEN [sIdx].[type] = 5 THEN 'Reserved for future use'
      WHEN [sIdx].[type] = 6 THEN 'Nonclustered columnstore index'
     END AS [IndexType]
   , [sdmvIUS].[user_seeks] AS [TotalUserSeeks]
   , [sdmvIUS].[user_scans] AS [TotalUserScans]
   , [sdmvIUS].[user_lookups] AS [TotalUserLookups]
   , [sdmvIUS].[user_updates] AS [TotalUserUpdates]
   , [sdmvIUS].[user_seeks] + [sdmvIUS].[user_scans] + [sdmvIUS].[user_lookups] AS [SumReads]
   , [p].[rows] AS [rws]
   ,sIdx.is_unique_constraint
   ,GETDATE()
FROM
   [sys].[indexes] AS [sIdx]
   INNER JOIN [sys].[objects] AS [sObj]
      ON [sIdx].[object_id] = [sObj].[object_id]
   LEFT JOIN [sys].[dm_db_index_usage_stats] AS [sdmvIUS]
      ON [sIdx].[object_id] = [sdmvIUS].[object_id]
      AND [sIdx].[index_id] = [sdmvIUS].[index_id]
      AND [sdmvIUS].[database_id] = DB_ID()
   LEFT JOIN [sys].[dm_db_index_operational_stats] (DB_ID(),NULL,NULL,NULL) AS [sdmfIOPS]
      ON [sIdx].[object_id] = [sdmfIOPS].[object_id]
	  AND [sIdx].[index_id] = [sdmfIOPS].[index_id]
	LEFT JOIN sys.partitions AS p
	 ON sIdx.object_id = p.object_id
	 AND sIDx.index_id = p.index_id
WHERE
   [sObj].[type] IN ('U','V')         -- Look in Tables & Views
   AND [sObj].[is_ms_shipped] = 0x0   -- Exclude System Generated Objects
   )

MERGE DBA.dbo.IndexUsageStats AS tgt
	USING IndexCTE AS src
ON (tgt.ObjectName = src.ObjectName AND tgt.IndexName = src.IndexName)
WHEN MATCHED
	THEN UPDATE SET
	tgt.TotalUserSeeks += src.TotalUserSeeks,
	tgt.TotalUserScans += src.TotalUserScans,
	tgt.TotalUserLookups += src.TotalUserLookups,
	tgt.TotalUserUpdates += src.TotalUserUpdates,
	tgt.SumReads += src.SumReads,
	tgt.rws += src.rws,
	tgt.CheckDate = src.CheckDate
WHEN NOT MATCHED BY TARGET THEN
	INSERT (ObjectName,
		IndexName,
		IndexType,
		TotalUserSeeks,
		TotalUserScans,
		TotalUserLookups,
		TotalUserUpdates,
		SumReads,
		rws,
		is_unique_constraint,
		CheckDate)
	VALUES (src.ObjectName, src.IndexName, src.IndexType, src.TotalUserSeeks, src.TotalUserScans, src.TotalUserLookups, 
			src.TotalUserUpdates, src.SumReads, src.rws, src.is_unique_constraint, src.CheckDate);


END;

GO

