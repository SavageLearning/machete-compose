#!/bin/bash
set -ex

if [ $EUID -ne 0 ]; then
  echo 'must be root'
  # exit 1
fi


if [[ ! -f env_variables.conf ]]; then
  echo 'must have env_variables.conf to source'
  exit 1
fi
source env_variables.conf

if [ -z ${OPTDIR+x} ]; then
  echo 'OPTDIR must be set'
  exit 1
fi

if [ which docker-compose ];
then
  echo 'attempting to install docker-compose with apt'
  # https://github.com/SavageLearning/machete-cm/issues/10
  apt -y install docker-compose
fi

if [ which docker-compose ]; then
  echo 'cannot find or install docker-compose'
  exit 1
fi

mkdir -p $OPTDIR/logs
mkdir -p $OPTDIR/secrets
mkdir -p $OPTDIR/sqldata
mkdir -p $OPTDIR/sqlbackup/backup
mkdir -p $OPTDIR/sqlbackup/restore

if [[ ! -f $OPTDIR/secrets/appsettings.json ]]; then
  cp ./config/appsettings.json $OPTDIR/secrets
fi
if [[ ! -f $OPTDIR/secrets/server.crt ]]; then
  # make a self-signed cert for testing
  openssl genrsa 2048 > server.key
  chmod 400 server.key
  openssl req -new -x509 -nodes -sha256 -days 365 -key server.key -out server.crt 
  cp ./server.* $OPTDIR/secrets
fi

docker-compose up --no-recreate -d

echo 'Finished executing machete-compose/docker-compose.sh. Output of docker container list:'
docker ps -a
