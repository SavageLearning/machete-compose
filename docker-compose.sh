#!/bin/bash

if [ $EUID -ne 0 ]; then
  echo 'must be root'
  exit 1
fi

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

echo 'Finished executing machete-compose/docker-compose.sh. Output of docker container list:'
docker ps -a
