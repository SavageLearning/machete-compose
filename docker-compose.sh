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

if [[ ! -f /opt/machete/secrets/appsettings.json ]]; then
  cp ./config/appsettings.json /opt/machete/secrets
fi
if [[ ! -f /opt/machete/secrets/server.crt ]]; then
  openssl genrsa 2048 > server.key
  chmod 400 server.key
  openssl req -new -x509 -nodes -sha256 -days 365 -key server.key -out server.crt 
  cp ./server.* /opt/machete/secrets
fi

docker-compose up -d

# https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017&pivots=cs1-bash#sapassword
desired_sql_password=$(cat machete1env.list | grep SQLSERVER_SA_PASSWORD | cut -d\= -f2 | tr -d $'\n')
current_sql_password=$(cat docker-compose.yml | grep SA_PASSWORD\: | cut -d\" -f2 | sed s/\"// )
sqlserver_cert_secret=$(cat machete1env.list | grep SQLSERVER_CERT_SECRET | cut -d\= -f2 | tr -d $'\n')
sudo docker exec -it compose_sqlserver_1 /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U SA -P "${current_sql_password}" \
   -Q "ALTER LOGIN SA WITH PASSWORD='${desired_sql_password}'"
sed -i -e "s/${current_sql_password}/${desired_sql_password}/" docker-compose.yml
sed -i -e "s/bigsecret/${sqlserver_cert_secret}/" docker-compose.yml

docker stop compose_sqlserver_1
docker rm compose_sqlserver_1

docker-compose up -d

echo 'Finished executing machete-compose/docker-compose.sh. Output of docker container list:'
docker ps -a
