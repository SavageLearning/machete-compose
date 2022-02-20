USE master
GO
-- ------------- --
-- GENERATE KEYS --
-- ------------- --
--
-- ALTER SERVICE MASTER KEY FORCE REGENERATE;
--
-- CREATE MASTER KEY
--    ENCRYPTION BY PASSWORD='';
-- GO
--
-- CREATE CERTIFICATE sqlserver_backup_cert
--     WITH SUBJECT = 'sqlserver_backup_cert'
-- GO
--
BACKUP SERVICE MASTER KEY TO FILE = '/var/opt/mssql/certs/servicemasterkey.smk'
    ENCRYPTION BY PASSWORD = '';
-- GO
BACKUP MASTER KEY TO FILE = '/var/opt/mssql/certs/masterkey.key'
    ENCRYPTION BY PASSWORD = '';
-- GO
--
BACKUP CERTIFICATE sqlserver_backup_cert TO FILE = '/var/opt/mssql/certs/sqlserver_backup_cert.cer'
    WITH PRIVATE KEY ( FILE = '/var/opt/mssql/certs/sqlserver_backup_cert.key' ,
    ENCRYPTION BY PASSWORD = '' );
GO
--
