CREATE TABLE [dbo].[IndexFragmentation] (
    [DateIn]        DATETIME2 (7)  NOT NULL,
    [tblname]       VARCHAR (200)  NOT NULL,
    [idxname]       VARCHAR (200)  NOT NULL,
    [PctFragmented] DECIMAL (5, 2) NOT NULL,
    [PageCnt]       INT            NOT NULL,
    [sizeMB]        BIGINT         NOT NULL,
    [RecordCnt]     BIGINT         NOT NULL,
    [StatsUpdated]  DATETIME2 (7)  NULL
);

