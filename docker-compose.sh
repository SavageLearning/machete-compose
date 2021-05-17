#!/bin/bash

if [ $EUID -ne 0 ]; then
  echo 'must be root'
  exit 1
fi

# https://github.com/SavageLearning/machete-cm/issues/10
apt -y install docker-compose

mkdir -p /opt/machete/secrets
mkdir -p /opt/machete/sqldata
mkdir -p /opt/machete/sqlbackup/backup
mkdir -p /opt/machete/sqlbackup/restore

chown $(logname): /opt/machete/secrets
chown $(logname): /opt/machete/sqldata
chown -R $(logname): /opt/machete/sqlbackup

cp config/appsettings.json /opt/machete/secrets

docker-compose up -d

# https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017&pivots=cs1-bash#sapassword
desired_sql_password=$(cat machete1env.list | grep SQLSERVER_SA_PASSWORD | cut -d\= -f2 | tr -d $'\n')
current_sql_password=$(cat docker-compose.yml | grep SA_PASSWORD\: | cut -d\" -f2 | sed s/\"// )
sudo docker exec -it compose_sqlserver_1 /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U SA -P "${current_sql_password}" \
   -Q "ALTER LOGIN SA WITH PASSWORD='${desired_sql_password}'"

echo 'Finished executing machete-compose/docker-compose.sh. Output of docker container list:'
docker ps -a
