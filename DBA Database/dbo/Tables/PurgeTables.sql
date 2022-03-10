CREATE TABLE dbo.PurgeTables (
	DatabaseName			VARCHAR(50) NOT NULL,
	TableName				VARCHAR(50) NOT NULL,
	KeyColumn				VARCHAR(50) NOT NULL,
	FrequencyToCheck		VARCHAR(10) NOT NULL,
	LastPurge				DATETIME	NULL,
	Active					BIT			NOT NULL,
	RetentionDays			INT			NOT NULL,
	DeleteChunkSize			INT			NOT NULL,
	OnlyRunStartingFromHour TINYINT		NOT NULL,
	OnlyRunStartingToHour	TINYINT		NOT NULL,
	CONSTRAINT PK_PurgeTables PRIMARY KEY CLUSTERED (DatabaseName ASC, TableName ASC) WITH (FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY];
GO

ALTER TABLE dbo.PurgeTables 
ADD CONSTRAINT DF_PurgeTable_Active DEFAULT (1) FOR Active;
GO

ALTER TABLE dbo.PurgeTables
ADD CONSTRAINT DF_PurgeTables_DeleteChunkSize DEFAULT ((10000)) FOR DeleteChunkSize;
GO

ALTER TABLE dbo.PurgeTables
ADD CONSTRAINT DF_PurgeTables_OnlyRunStartingFromHour DEFAULT ((0)) FOR OnlyRunStartingFromHour;
GO

ALTER TABLE dbo.PurgeTables
ADD CONSTRAINT DF_PurgeTables_OnlyRunStartingToHour DEFAULT ((24)) FOR OnlyRunStartingToHour;
GO



