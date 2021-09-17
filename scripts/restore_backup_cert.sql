-- ---------------------------------------------------------------------------- --
-- Restore keys to /var/opt/mssql/certs:/opt/machete/secrets before proceeding! --
-- You will need the GPG decryption key from the ops LastPass.                  --
-- ---------------------------------------------------------------------------- --
--
USE master
GO

-- This password can also be found in the ops LastPass. It is the same throughout.
DECLARE @decryption_key NVARCHAR(MAX)
SET @decryption_key = ''

--
--DROP CERTIFICATE sqlserver_backup_cert
--GO
--
--ALTER SERVICE MASTER KEY FORCE REGENERATE
--GO
--


RESTORE SERVICE MASTER KEY FROM FILE = '/var/opt/mssql/certs/servicemasterkey.smk'
    DECRYPTION BY PASSWORD = @decryption_key
    --
    FORCE
    --
GO
--
-- DROP MASTER KEY
-- GO
--CREATE MASTER KEY ENCRYPTION BY PASSWORD = ''
RESTORE MASTER KEY FROM FILE = '/var/opt/mssql/certs/masterkey.key'
    DECRYPTION BY PASSWORD = @decryption_key
    -- Keep the same unless you are rotating:
    ENCRYPTION BY PASSWORD = @decryption_key
GO
--
OPEN MASTER KEY DECRYPTION BY PASSWORD = @decryption_key;
--
CREATE CERTIFICATE sqlserver_backup_cert FROM FILE = '/var/opt/mssql/certs/sqlserver_backup_cert.crt'
  WITH PRIVATE KEY (
    FILE = '/var/opt/mssql/certs/sqlserver_backup_cert.key',
    DECRYPTION BY PASSWORD = @decryption_key
  )
GO
--
CLOSE MASTER KEY;
