FROM ubuntu:18.04

LABEL maintainer="chaimeliyah@gmail.com"

# create and set working directory
RUN apt-get update && apt-get install --no-install-recommends -yq wget ca-certificates libcurl4-gnutls-dev \
 && wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && apt-get update \
 && apt-get install -y blobfuse \
# && apt-get remove -y wget \
 && apt-get clean -y \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /mnt/blobfusetmp/prod \
 && mkdir /mnt/blobfusetmp/test \
 && mkdir -p /mount/prod \
 && mkdir /mount/test

COPY azurefuse.sh /opt
WORKDIR /opt

# start app
CMD "/bin/bash"
