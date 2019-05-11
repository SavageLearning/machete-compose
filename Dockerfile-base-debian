FROM nginx:1.15.9
LABEL maintainer="chaimeliyah@gmail.com"
EXPOSE 443
ENV DEBIAN_FRONTEND=noninteractive

# install dotnet core 
RUN apt-get update && \
    apt-get install --no-install-recommends -yq wget gnupg apt-transport-https ca-certificates lsof vim iputils-ping && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg && \
    mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ && \
    wget -q https://packages.microsoft.com/config/debian/9/prod.list && \
    mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && \
    chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && \
    apt-get install -yq aspnetcore-runtime-2.2 && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
