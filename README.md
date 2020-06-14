## machete-containers
dockerfiles for building machete images

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
