# machete-compose

### This solution contains:
* A docker-compose file for building the machete environment in test and prod
* A Dockerfile for building Machete base images from `nginx`

### Content Details

### base
the base container for our custom images (note: the machete dockerfile is located at [Machete/blob/master/Dockerfile](https://github.com/SavageLearning/Machete/blob/master/Dockerfile))

### docker-compose.yml
the docker compose solution for machete deployments

### appveyor.yml
the build file, for appveyor. appveyor because that's what v1 uses.  
versions must be manually bumped if you change something (`./container_name/name_version`). floating might cause a beta build
 to be deployed instead of a production build, and we don't want that.

### Local Build

A local build should be able to test the functionality. However, you have to create the following paths:
```
mkdir -p /opt/machete/secrets
mkdir -p /opt/machete/sqldata
mkdir -p /opt/machete/sqlbackup/backup
mkdir -p /opt/machete/sqlbackup/restore
```

The `compose-machete.sh` script will do this for you in a local environment, but don't use it on prodution if there are already
 containers running. If you're unsure about how to use this solution in production, please contact the maintainer and wait
 for assistance.

For Mac, these paths "are not shared from OS X and are not known to Docker." So you will have to configure the shared paths from Docker -> Preferences... -> File Sharing.
See https://docs.docker.com/docker-for-mac/osxfs/#namespaces for more info.
