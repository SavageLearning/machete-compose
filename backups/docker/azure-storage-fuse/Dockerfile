FROM ubuntu:18.04

LABEL maintainer="chaimeliyah@gmail.com"

# create and set working directory
RUN apt-get update && apt-get install --no-install-recommends -yq wget ca-certificates \
 && wget --no-check-certificate https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && apt-get update && apt-get install -y blobfuse fuse \
 && apt-get remove -y wget \
 && apt-get clean -y \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /mnt/blobfusetmp \
 && mkdir -p /mount/backups

# start app
CMD "/bin/bash"
