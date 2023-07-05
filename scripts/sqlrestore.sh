#!/bin/bash 
set -ex
echo "$(TZ=UTC date)"
echo "Starting restore:"

#rm -rf /opt/machete/sqlbackup/restore/*
#BACKUPFILE="$(date -I).tar"
BACKUPFILE="2023-07-02.tar"
#az storage blob download -c prod --account-name machetebackup --name $BACKUPFILE --file $BACKUPFILE
# rclone copy s3:machete-sqlserver-backups/mount/prod/$(date -I).tar.gz /opt/machete/sqlbackup/restore/
#tar -xvf /opt/machete/sqlbackup/restore/$BACKUPFILE -C /opt/machete/sqlbackup/restore --strip-components=6

# should contain a single directory with the olabackupid:
restore_directory="/opt/machete/sqlbackup/restore"
olabackupid=$(cd  ${restore_directory} && ls -d */)
existingbackups=$(find ${restore_directory}/${olabackupid}  | grep bak)
db_names=$(find ${restore_directory}/${olabackupid} -type f -name "*.bak" -exec basename {} \;)
sqlrestore() {
  db=$1
  filename=$2
  sudo docker exec machete_sqlserver_1 /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U SA -P "${SA_PASSWORD}" \
    -Q "
    OPEN MASTER KEY DECRYPTION BY PASSWORD = '${SQLSERVER_CERT_SECRET}';
    RESTORE DATABASE [$db] FROM DISK = N'$filename' WITH FILE = 1, NOUNLOAD, REPLACE, NORECOVERY, STATS = 5
    RESTORE LOG [$db] FROM DISK = N'$filename'
    GO
    CLOSE MASTER KEY;
" >> /var/opt/mssql/certs/sqlrestore.log
  restorestatus=$?
  if [ $restorestatus -ne 0 ]; then echo "ERROR $backupstatus at 'sqlrestore.sh'" >> /var/opt/mssql/certs/sqlrestore.log; fi
}
for database in $db_names
do
  backupfilename="/var/opt/mssql/backups/restore/${olabackupid}${database}"
  shortdbname=$(echo $database | sed -E 's/.{12,12}_([[:alnum:]_]+)_FULL_.*/\1/')
  sqlrestore $shortdbname $backupfilename
done
