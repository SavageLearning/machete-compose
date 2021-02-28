## machete-containers

This solution contains:
* a docker-compose file for building the machete environment in test and prod
* dockerfiles for building machete images

### Content Details

#### base
the base container for our custom images

#### backups
the backups container for Azure fuse

configuration inside container:
```
   $  export AZURE_STORAGE_ACCOUNT=backuptestaccount
   $  export AZURE_STORAGE_ACCESS_KEY="some_long_secret"
   $  echo $AZURE_STORAGE_ACCESS_KEY 
   $  blobfuse /mount/this/ --tmp-path=/mnt/blobfusetmp/ -o allow_root -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --log-level=LOG_DEBUG --file-cache-timeout-in-seconds=120 --container-name=containerbackuptest
```
skipping actual run command but basically for docker-compose you just have to mount the backups volume as /mount/backups...

#### machete dockerfile
the machete dockerfile is located at https://github.com/SavageLearning/Machete/blob/master/Dockerfile

#### docker-compose.yml
the docker compose solution for machete deployments

#### appveyor.yml
the build file, for appveyor. appveyor because that's what v1 use(d). needs to be updated. versions must be manually bumped if you change something (`./container_name/name_version`)



### Local Build

A local build should be able to test the functionality. However, you have to create the following paths:
```
mkdir -p /opt/machete/secrets
mkdir -p /opt/machete/sqldata
mkdir -p /opt/machete/sqlbackup/backup
mkdir -p /opt/machete/sqlbackup/restore
```


The `docker-compose.sh` script will do this for you in a local environment, but please don't use it on prodution. If you're unsure about how to use this solution in production,
please contact the maintainer and wait for assistance.

For Mac, these paths "are not shared from OS X and are not known to Docker." So you will have to configure the shared paths from Docker -> Preferences... -> File Sharing.
See https://docs.docker.com/docker-for-mac/osxfs/#namespaces for more info.
