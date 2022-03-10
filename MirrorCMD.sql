-- Check to make sure database is in full recovery mode
-- Creates a new backup of data file and log on primary, then secondary restores from that location

:setvar MYDATABASE EncryptionTest
:setvar PRINCIPAL stagedb1 
:setvar MIRROR  stgecosql01 
--:setvar WITNESS dtgewitprd01
:setvar BACKUPPATH D:\mssql\backup\
:setvar RESTOREPATH \\stagedb1\backup\

:setvar TIMEOUT 120

SET NOCOUNT ON;
GO

USE master;
GO

-- Database needs to be in full recovery mode
ALTER DATABASE $(MYDATABASE) SET RECOVERY FULL WITH NO_WAIT;

:connect $(PRINCIPAL)
BACKUP DATABASE $(MYDATABASE)
TO  DISK = '$(BACKUPPATH)$(MYDATABASE).bak'
WITH INIT,
     NAME = N'$(MYDATABASE)-Full Database Backup',
     COMPRESSION,
     STATS = 1;
GO

BACKUP LOG $(MYDATABASE)
TO  DISK = '$(BACKUPPATH)$(MYDATABASE).trn'
WITH NOFORMAT,
     INIT,
     NAME = N'$(MYDATABASE)-Transaction Log  Backup',
     COMPRESSION,
     STATS = 1;
GO

-------------------------------------------------
:connect $(MIRROR)

RESTORE DATABASE $(MYDATABASE)
FROM DISK = '$(RESTOREPATH)$(MYDATABASE).bak'
WITH NORECOVERY,
     NOUNLOAD,
     STATS = 1;
GO

RESTORE LOG $(MYDATABASE)
FROM DISK = '$(RESTOREPATH)$(MYDATABASE).trn'
WITH NORECOVERY,
     STATS = 1;
GO

ALTER DATABASE $(MYDATABASE)
SET PARTNER = N'TCP://$(PRINCIPAL).AD.INNTOPIA.COM:5022';
GO


:connect $(PRINCIPAL)

ALTER DATABASE $(MYDATABASE)
SET PARTNER = N'TCP://$(MIRROR).AD.INNTOPIA.COM:5022';
GO

-- Remove comment if you would like to leave database online on partner. Ex, change owner to sa.
--ALTER DATABASE $(MYDATABASE) SET PARTNER FAILOVER

--if '$(WITNESS)' <> ''
--ALTER DATABASE $(MYDATABASE) SET WITNESS = 'TCP://$(WITNESS).INTERNAL.MYWEBGROCER.COM:5022'
--print '*** Setting the timeout on the principal to $(TIMEOUT) seconds ***'
--ALTER DATABASE $(MYDATABASE) SET PARTNER TIMEOUT $(TIMEOUT)
--GO

