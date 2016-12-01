#!/bin/bash

if ["$#" -ne 4]; then
    echo -e "\n[Usage]: ./$0 [UMDS_DATABASE_NAME] [UMDS_DSN_NAME] [UMDS_USERNAME] [UMDS_PASSWORD]"
    echo -e "\t./$0 UMDSDB UMDS_DSN umdsuser VMware1!"
    exit 1
fi

UMDS_DATABASE_NAME=$1
UMDS_DSN_NAME=$2
UMDS_USERNAME=$3
UMDS_PASSWORD=$4

echo "Creating UMDS Installer answer file ..."
cat > /tmp/answer << __EOF__
/usr/local/vmware-umds
yes
no
/var/lib/vmware-umds
yes
${UMDS_DSN_NAME}
${UMDS_USERNAME}
${UMDS_PASSWORD}
yes

__EOF__

echo "Creating /etc/odbc.ini ..."
cat > /etc/odbc.ini << __EOF__
[${UMDS_DSN_NAME}]
;DB_TYPE = PostgreSQL
;SERVER_NAME = localhost
;SERVER_PORT = 5432
;TNS_SERVICE = ${UMDS_DATABASE_NAME}
;USER_ID = umdsuser
Driver = PostgreSQL
DSN = ${UMDS_DSN_NAME}
ServerName = localhost
PortNumber = 5432
Server = localhost
Port = 5432
UserID = ${UMDS_USERNAME}
User = ${UMDS_USERNAME}
Database = ${UMDS_DATABASE_NAME}
__EOF__

echo "Updating /etc/odbcinst.ini ..."
cat > /etc/odbcinst.ini << __EOF__
[PostgreSQL]
Description=PostgreSQL ODBC driver (Unicode version)
Driver=/usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so
Debug=0
CommLog=1
UsageCount=1
__EOF__

echo "Updating pg_hba.conf ..."
echo "local  ${UMDS_DATABASE_NAME}    umdsuser           md5" >> /etc/postgresql/9.5/main/pg_hba.conf

echo "Symlink /var/run/postgresql/.s.PGSQL.5432 /tmp/.s.PGSQL.5432 ..."
ln -s /var/run/postgresql/.s.PGSQL.5432 /tmp/.s.PGSQL.5432

echo "Starting Postgres ..."
service postgresql start

echo "Sleeping for 60 seconds for Postgres DB to be ready ..."
sleep 60

echo "Creating UMDS DB + User ..."
su postgres -c "createdb ${UMDS_DATABASE_NAME}"
su postgres -c "createuser -d -e -r ${UMDS_USERNAME}"
echo "ALTER USER "${UMDS_USERNAME}" WITH PASSWORD '${UMDS_PASSWORD}';" | su postgres -c "psql"

echo "Install VUM UMDS ..."
cat /tmp/answer | /tmp/vmware-umds-distrib/vmware-install.pl EULA_AGREED=yes
