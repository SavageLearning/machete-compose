#!/bin/bash
sqlserver_password=${1}
sqlserver_certificate_secret=${2}
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
echo "$(TZ=UTC date)" >> /opt/machete/sqlbackup.log
echo "Starting backup:" >> /opt/machete/sqlbackup.log
deletestatus=$?
sqlserver=$(docker container list | grep sqlserver | awk '{print $1}')
if [ $deletestatus -ne 0 ]; then echo "ERROR $deletestatus at 'sqlbackup.sh' (deleting backups failed)" >> /opt/machete/sqlbackup.log; fi
sudo docker exec ${sqlserver} /opt/mssql-tools/bin/sqlcmd 
   -S localhost -U SA -P "${sqlserver_password}" 
   -Q "
OPEN MASTER KEY DECRYPTION BY PASSWORD = '${sqlserver_certificate_secret}';
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
" >> /opt/machete/sqlbackup.log
backupstatus=$?
if [ $backupstatus -ne 0 ]; then echo "ERROR $backupstatus at 'sqlbackup.sh'" >> /opt/machete/sqlbackup.log; fi
echo "Creating the archive..."
docker exec -u 0 azurefuse sh -c "tar --remove-files -czvf /mount/backups/$(date -I).tar.gz /backups/*"
