CREATE TABLE dbo.ProcFnUseLog
   (
    [ObjectName] [nvarchar](255),
    [UseCount] [int] NULL,
    [LastUse] [datetime] NULL,
    [LastCache] [datetime] NULL,
    CONSTRAINT PK_ProcFnUseLog PRIMARY KEY CLUSTERED (ObjectName) WITH (FILLFACTOR = 100)
 )

GO;

ALTER TABLE dbo.ProcFnUseLog ADD  CONSTRAINT [DF_ProcFnUseLog_UseCount]  DEFAULT ((0)) FOR UseCount