#!/bin/bash
sqlserver=$(docker container list | grep sqlserver | awk '{print $1}')

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
exec &>> /var/opt/mssql/certs/sqlrestore.log
echo "$(TZ=UTC date)"
echo "Starting restore:"

# clear the old backups and download new ones - save, belongs to Esteban (emergency May 2021)
# rm -rf /opt/machete/sqlbackup/restore/*
# rclone copy s3:machete-sqlserver-backups/mount/prod/$(date -I).tar.gz /opt/machete/sqlbackup/restore/
# tar -xzvf /opt/machete/sqlbackup/restore/$(date -I).tar.gz -C /var/lib/docker/volumes/sql-database-backups/_data/

# should contain a single directory with the olabackupid:
restore_directory="/var/opt/mssql/backups/restore"
olabackupid=$(ls ${restore_directory})
existingbackups=$(find ${restore_directory}/${olabackupid} | grep bak)
db_names=$(find ${restore_directory}/${olabackupid} | grep bak | cut -d\/ -f10 | cut -d_ -f2,3)

sqlrestore() {
  db=$1
  filename=$2
  /opt/mssql-tools/bin/sqlcmd \
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
  backupfilename=$(printf '%s\n' "${existingbackups[@]}" | grep $database)
  sqlrestore $database $backupfilename
done
