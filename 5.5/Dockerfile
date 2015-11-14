FROM gliderlabs/alpine
MAINTAINER Knorrkator <knorrkator@posteo.de>

# Fork of tutum/mysql (https://github.com/tutumcloud/mysql/tree/master/5.5) to
# use Alpine Linux as baseimage instead of Ubuntu. Alpines fingerprint is much
# smaller than Ubuntus.


# Let's get it on

# Add MySQL configuration
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD mysqld_charset.cnf /etc/mysql/conf.d/mysqld_charset.cnf

# Install Mysql/Maria DB
RUN apk --update add mysql mysql-client && \
    rm -f /etc/mysql/my.cnf && \
    mysql_install_db > /dev/null 2>&1 && \
    touch /var/lib/mysql/.EMPTY_DB

# Install additional tools
RUN apk --update add pwgen

# Add MySQL scripts
ADD import_sql.sh /import_sql.sh
ADD run.sh /run.sh

ENV MYSQL_USER=admin \
    MYSQL_PASS=**Random** \
    ON_CREATE_DB=**False** \
    REPLICATION_MASTER=**False** \
    REPLICATION_SLAVE=**False** \
    REPLICATION_USER=replica \
    REPLICATION_PASS=replica \
    ON_CREATE_DB=**False**

# Add VOLUMEs to allow backup of config and databases
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

EXPOSE 3306
CMD ["/bin/sh", "/run.sh"]
