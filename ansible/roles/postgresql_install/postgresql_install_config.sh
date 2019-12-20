#!/bin/bash
### give it random number to serverid on MariaDB
# To generate a random number in a UNIX or Linux shell, the shell maintains a shell variable named RANDOM. Each time this variable is read, a random number between 0 and 32767 is generated.
SERVERID=$(($RANDOM))

### get total memory ram to configure maintenance_work_mem variable
MEM_TOTAL=$(expr $(($(cat /proc/meminfo | grep MemTotal | awk '{print $2}') / 10)) \* 10 / 1024 / 1024)

### get amount of memory who will be reserved to effective_cache_size variable
MEM_EFCS=$(expr $(($(cat /proc/meminfo | grep MemTotal | awk '{print $2}') / 10)) \* 7 / 1024 / 1024)

### get amount of memory who will be reserved to shared_buffers variable
MEM_SHBM=$(expr $(($(cat /proc/meminfo | grep MemTotal | awk '{print $2}') / 10)) \* 2 / 1024 / 1024)

### get the number of cpu's to estimate how many innodb instances will be enough for it. ###
NR_CPUS=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)

DB_VERSION=`psql --version | egrep -o '[0-9]{1,}\.[0-9]{1,}'`
pgsql_version=`psql --version |awk {'print $3'}| awk -F "." {'print $1$2'}`

if [ $MEM_TOTAL -lt 8 ]
  then
   MEM_MWM="512MB"
   CPS="16"
  elif [ $MEM_TOTAL -gt 8 ] && [ $MEM_TOTAL -lt 24 ]
  then
    MEM_MWM="1024MB"
    CPS="32"
  elif [ $MEM_TOTAL -gt 25 ]
  then
    MEM_MWM="2048MB"
    CPS="64"
fi

if [ $MEM_EFCS -lt 0 ]
  then
   MEM_EFCS="1GB"
  elif [ $MEM_EFCS -gt 1 ]
  then
   MEM_EFCS="${MEM_EFCS}GB"
fi

if [ $MEM_SHBM -lt 0 ]
  then
   MEM_SHBM="1GB"
  elif [ $MEM_SHBM -gt 1 ]
  then
   MEM_SHBM="${MEM_SHBM}GB"
fi

### remove old datadir ###
rm -rf /var/lib/pgsql

### datadir and logdir ####
DATA_DIR="/var/lib/pgsql/datadir"
DATA_LOG="/var/lib/pgsql/logdir"
ARCHIVE_LOG="/var/lib/pgsql/archivelog"

# create directories for mysql datadir and datalog
if [ ! -d ${DATA_DIR} ]
then
    mkdir -p ${DATA_DIR}
    chmod 755 ${DATA_DIR}
    chown -Rf postgres.postgres ${DATA_DIR}
fi

if [ ! -d ${DATA_LOG} ]
then
    mkdir -p ${DATA_LOG}
    chmod 755 ${DATA_LOG}
    chown -Rf postgres.postgres {DATA_LOG}
fi

if [ ! -d ${ARCHIVE_LOG} ]
then
    mkdir -p ${ARCHIVE_LOG}
    chmod 755 ${ARCHIVE_LOG}
    chown -Rf postgres.postgres {ARCHIVE_LOG}
fi

### initdb for deploy a new db fresh and clean ###
/usr/pgsql-$DB_VERSION/bin/postgresql$pgsql_version-setup initdb
systemctl enable postgresql-$DB_VERSION
systemctl start postgresql-$DB_VERSION
sleep 5

echo "

### include server.conf on postgresql.conf
include 'server.conf' " >> /var/lib/pgsql/$DB_VERSION/data/postgresql.conf

echo "
# DB Version: $DB_VERSION
# Server id = $SERVERID
# OS Type: linux
# DB Type: oltp
# Total Memory (RAM): $MEM_TOTAL GB
# CPUs num: $NR_CPUS
# Connections num: 500
# Data Storage: ssd

listen_addresses = '*'
max_connections = 500
shared_buffers = $MEM_SHBM
effective_cache_size = $MEM_EFCS
maintenance_work_mem = $MEM_MWM
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 16777kB
checkpoint_segments = $CPS

### enable archive mode ####
archive_mode = on
archive_command = 'cp %p $ARCHIVE_LOG/%f'
wal_level = 'archive'

### enable log file ###
log_directory = '$DATA_LOG'
log_filename = 'postgresql-%Y%m%d_%H%M%S.log'
log_rotation_age = 7d
log_rotation_size = 10MB
log_truncate_on_rotation = off
log_line_prefix = '%t c%  '

log_connections = on
log_disconnections = on
log_statement = 'ddl'
" > /var/lib/pgsql/$DB_VERSION/data/server.conf

echo "
# pg_hba.conf
host    all             all                0.0.0.0/0                md5
host    replication     replication_user   0.0.0.0/0                md5
" >> /var/lib/pgsql/$DB_VERSION/data/pg_hba.conf

# privs new files
chown -Rf postgres.postgres ${DATA_LOG}
chown -Rf postgres.postgres ${ARCHIVE_LOG}

# restart postgresql
systemctl stop postgresql-$DB_VERSION
sleep 5
systemctl start postgresql-$DB_VERSION
sleep 5

### generate root passwd #####
passwd="$SERVERID-PG"
touch /tmp/$passwd
echo $passwd > /tmp/$passwd
hash=`md5sum  /tmp/$passwd | awk '{print $1}' | sed -e 's/^[[:space:]]*//' | tr -d '/"/'`

### update root password #####
sudo -u postgres psql -c "ALTER USER postgres WITH password '$hash'"

### show users and pwds ####
echo The server_id is $SERVERID!
echo The postgres password is $hash