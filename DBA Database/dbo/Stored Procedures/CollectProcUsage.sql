CREATE PROCEDURE dbo.CollectProcUsage
AS

BEGIN

	DECLARE @UsesTable TABLE
	(
		ObjectName nvarchar(255),
		Executions int,
		LastUse datetime,
		LastCache datetime
	)

	INSERT INTO @UsesTable       
	SELECT p.name, qs.execution_count, qs.last_execution_time, qs.cached_time
	FROM    sys.procedures AS p LEFT OUTER JOIN
			sys.dm_exec_procedure_stats AS qs ON p.object_id = qs.object_id
	WHERE        (p.is_ms_shipped = 0)

	MERGE [dbo].[ProcFnUseLog]      AS [Target]
	USING @UsesTable                    AS [Source]
		ON Target.ObjectName = Source.ObjectName
	WHEN MATCHED AND 
			( Target.LastCache <> Source.LastCache)
		THEN UPDATE SET
			Target.UseCount = Target.UseCount + Source.Executions,
			Target.LastCache = Source.LastCache,
			Target.LastUse = Source.LastUse
	WHEN NOT MATCHED
		THEN INSERT (ObjectName, UseCount, LastUse, LastCache) 
		VALUES      (ObjectName, Executions, LastUse, LastCache);

END;