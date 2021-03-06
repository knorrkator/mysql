#!/bin/bash

set -e

# Kills a Docker instance if it's running and removes its image.
# Determines the Docker instance by it's name or id
kill_and_rm() {
  local name_or_id=$1
  docker kill ${name_or_id} > /dev/null 2>&1 || /bin/true
  docker rm ${name_or_id} > /dev/null 2>&1 || /bin/true
}

echo Prepare Environment
kill_and_rm mysql55initial
kill_and_rm mysql55master
kill_and_rm mysql55slave
kill_and_rm mysql55.1


echo "=> Building mysql 5.5 image"
docker build -t mysql-5.5 5.5/

echo "=> Testing if mysql is running on 5.5"
docker run -d -p 13306:3306 -e MYSQL_USER="user" -e MYSQL_PASS="test" --name mysql55initial mysql-5.5; sleep 10
mysqladmin -uuser -ptest -h127.0.0.1 -P13306 ping | grep -c "mysqld is alive"

echo "=> Testing replication on mysql 5.5"
docker run -d -e MYSQL_USER=user -e MYSQL_PASS=test -e REPLICATION_MASTER=true -e REPLICATION_USER=repl -e REPLICATION_PASS=repl -p 13307:3306 --name mysql55master mysql-5.5; sleep 10
docker run -d -e MYSQL_USER=user -e MYSQL_PASS=test -e REPLICATION_SLAVE=true -p 13308:3306 --link mysql55master:mysql --name mysql55slave mysql-5.5; sleep 10
docker logs mysql55master | grep "repl:repl"
mysql -uuser -ptest -h127.0.0.1 -P13307 -e "show master status\G;" | grep "mysql-bin.*"
mysql -uuser -ptest -h127.0.0.1 -P13308 -e "show slave status\G;" | grep "Slave_IO_Running.*Yes"
mysql -uuser -ptest -h127.0.0.1 -P13308 -e "show slave status\G;" | grep "Slave_SQL_Running.*Yes"

echo "=> Testing volume on mysql 5.5"
mkdir -p vol55
docker run --name mysql55.1 -d -p 13309:3306 -e MYSQL_USER="user" -e MYSQL_PASS="test" -v $(pwd)/vol55:/var/lib/mysql mysql-5.5; sleep 10
mysqladmin -uuser -ptest -h127.0.0.1 -P13309 ping | grep -c "mysqld is alive"
docker stop mysql55.1
docker run  -d -p 13310:3306 -v $(pwd)/vol55:/var/lib/mysql mysql-5.5; sleep 10
mysqladmin -uuser -ptest -h127.0.0.1 -P13310 ping | grep -c "mysqld is alive"

echo "=>Done"
