FROM mcr.microsoft.com/mssql/server:2017-latest
LABEL maintainer="chaimeliyah@gmail.com"
# https://raw.githubusercontent.com/microsoft/mssql-docker/master/linux/preview/examples/mssql-server-linux-non-root/Dockerfile

# Create non-root user and update permissions
# RUN useradd -M -s /bin/bash -u 10001 -g 0 mssql
# RUN mkdir -p -m 770 /var/opt/mssql && chgrp -R 0 /var/opt/mssql

# Grant sql the permissions to connect to ports <1024 as a non-root user
# RUN setcap 'cap_net_bind_service+ep' /opt/mssql/bin/sqlservr

# Allow dumps from the non-root process
# RUN setcap 'cap_sys_ptrace+ep' /opt/mssql/bin/paldumper
# RUN setcap 'cap_sys_ptrace+ep' /usr/bin/gdb

# Add an ldconfig file because setcap causes the os to remove LD_LIBRARY_PATH
# and other env variables that control dynamic linking
# RUN mkdir -p /etc/ld.so.conf.d && touch /etc/ld.so.conf.d/mssql.conf
# RUN echo -e "# mssql libs\n/opt/mssql/lib" >> /etc/ld.so.conf.d/mssql.conf
# RUN ldconfig

# USER mssql

RUN mkdir -p /var/opt/mssql/scripts
COPY ./scripts /var/opt/mssql/scripts

CMD ["/opt/mssql/bin/sqlservr"]
