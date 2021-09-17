#!/bin/bash 
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
source env_variables.conf
BACKUPDIR="$OPTDIR/sqlbackup/backup"
BACKUPLOG="$OPTDIR/secrets/sqlbackup.log"
echo "$(TZ=UTC date)" >> $BACKUPLOG
echo "Starting backup:" >> $BACKUPLOG
sudo docker exec compose_sqlserver_1 /opt/mssql-tools/bin/sqlcmd    -S localhost -U SA -P "${SA_PASSWORD}" -Q "
OPEN MASTER KEY DECRYPTION BY PASSWORD = '${SQLSERVER_CERT_SECRET}';
EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@Directory = '/var/opt/mssql/backups/backup',
@BackupType = 'FULL',
@Verify = 'Y',
@Compress = 'Y',
@CheckSum = 'Y',
@Encrypt = 'Y',
@EncryptionAlgorithm = 'AES_256',
@ServerCertificate = 'sqlserver_backup_cert'
CLOSE MASTER KEY;
" >> $BACKUPLOG
backupstatus=$?
if [ $backupstatus -ne 0 ]; then echo "ERROR $backupstatus at 'sqlbackup.sh'" >> $BACKUPLOG; fi
DATESTAMP=$(date -I)
BACKUPFILE="$DATESTAMP.tar"
BACKUPTAR="$BACKUPDIR/$BACKUPFILE"
SQLCONTAINER_ID=$(docker inspect compose_sqlserver_1 | jq '.[]["Id"]')
tar --remove-files -cf $BACKUPTAR $BACKUPDIR/${SQLCONTAINER_ID:1:12}/*
deletestatus=$?
if [ $deletestatus -ne 0 ]; then echo "ERROR $deletestatus at 'sqlbackup.sh' (tarring backups failed)" >> $BACKUPLOG; fi
az storage blob upload --account-name machetebackup -c prod -f $BACKUPTAR -n $BACKUPFILE >>  $BACKUPLOG 2> /dev/null
deletestatus=$?
if [ $deletestatus -ne 0 ]; then echo "ERROR $deletestatus at 'sqlbackup.sh' (azure upload failed)" >> $BACKUPLOG; fi
rm $BACKUPTAR
deletestatus=$?
if [ $deletestatus -ne 0 ]; then echo "ERROR $deletestatus at 'sqlbackup.sh' (removing backup failed)" >> $BACKUPLOG; fi
