#!/bin/bash
# to replace sqlbackup.sh after everything works as intented
exec &>> /var/opt/mssql/certs/sqlbackup.log
echo "$(TZ=UTC date)"
echo "Starting backup:"

/opt/mssql-tools/bin/sqlcmd 
  -S localhost -U SA -P "${SA_PASSWORD}" 
  -Q "
OPEN MASTER KEY DECRYPTION BY PASSWORD = '${SQLSERVER_CERT_SECRET}';
EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = '/var/opt/mssql/backups',
@BackupType = 'FULL',
@Verify = 'Y',
@Compress = 'Y',
@CheckSum = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@ServerCertificate = 'sqlserver_backup_cert'
CLOSE MASTER KEY;
" >> /var/opt/mssql/certs/sqlrestore.log
backupstatus=$?
if [ $backupstatus -ne 0 ]; then echo
    "ERROR $backupstatus at 'rclone_backup.sh'" >> /var/opt/mssql/certs/sqlbackup.log; fi

echo "Creating the archive..."
tar --remove-files -czvf /var/opt/mssql/backups/backup/$(date -I).tar.gz /var/opt/mssql/backups/backup/*
# test without copying anything
rclone --config=rclone.conf copy /var/opt/mssql/backups/backup/$(date -I).tar.gz s3:machete-sqlserver-backups/mount/prod --dry-run
rclonedryrunstatus=$?
if [ $rclonedryrunstatus -ne 0 ]; then echo "ERROR $rclonedryrunstatus at rclone_backup.sh" >> /var/opt/mssql/backups/backup.log; fi
if [ $rclonedryrunstatus -eq 0 ]; then
  #actually copy the backups
  rclone copy /var/opt/mssql/backups/backup/$(date -I).tar.gz s3:machete-sqlserver-backups/mount/prod
  #remove the backup from container volume
  rm -rf /var/opt/mssql/backups/backup/$(date -I).tar.gz
fi
