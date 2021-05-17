#!/bin/bash
sqlserver_password=${1}
sqlserver_certificate_secret=${2}
sqlserver=$(docker container list | grep sqlserver | awk '{print $1}')

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
exec &>> /opt/machete/sqlrestore.log
echo "$(TZ=UTC date)"
echo "Starting restore:"

# clear the old backups and download new ones
# rm -rf /opt/machete/sqlbackup/restore/*
# rclone copy s3:machete-sqlserver-backups/mount/prod/$(date -I).tar.gz /opt/machete/sqlbackup/restore/
# tar -xzvf /opt/machete/sqlbackup/restore/$(date -I).tar.gz -C /var/lib/docker/volumes/sql-database-backups/_data/

# should contain a single directory with the olabackupid:
export olabackupid=$(ls -d /opt/machete/sqlbackup/restore/)
# originally we were shooting for one day before the current day, but this process should actually take place after backups are finished, so we can grab the current day
# existingbackups=$(ls -LRh /var/lib/docker/volumes/sql-database-backups/_data/backups | grep bak | grep $(expr $(date +'%Y%m%d') - 1))
existingbackups=$(ls -LRh /var/lib/docker/volumes/compose_sql-database-backups/_data/backups | grep bak | grep $(expr $(date +'%Y%m%d')))
listofdatabases=$(jq -r '.Tenants.tenants' /var/lib/docker/volumes/compose_app-secrets/_data/appsettings.json | grep -v [{}] | sed s/[\ \"\,]//g | sed s/default/machete/g | awk -F':' '{print $2"_db"}')
sqlrestore() {
  db=$1
  filename=$2
  sudo docker exec ${sqlserver} /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U SA -P "${sqlserver_password}" \
    -Q "
    OPEN MASTER KEY DECRYPTION BY PASSWORD = '${sqlserver_certificate_secret}';
    RESTORE DATABASE [$db] FROM DISK = N'/var/opt/mssql/backups/backups/$olabackupid/$db/FULL/$filename' WITH FILE = 1, NOUNLOAD, REPLACE, NORECOVERY, STATS = 5
    RESTORE LOG [$db] FROM DISK = N'/var/opt/mssql/backups/backups/$olabackupid/$db/FULL/$filename'
    GO
    CLOSE MASTER KEY;
" >> /opt/machete/sqlrestore.log
  restorestatus=$?
  if [ $restorestatus -ne 0 ]; then echo "ERROR $backupstatus at 'sqlrestore.sh'" >> /opt/machete/sqlrestore.log; fi
}
for database in $listofdatabases
do
  backupfilename=$(printf '%s\n' "${existingbackups[@]}" | grep $database)
  sqlrestore $database $backupfilename
done
