FROM ubuntu:16.04

MAINTAINER wlam@vmware.com

ARG UMDS_INSTALLER_SCRIPT=install_umds.sh
ARG UMDS_INSTALLER_PACKAGE=VMware-UMDS-6.5.0-4540462.tar.gz

ARG UMDS_DATABASE_NAME=local
ENV UMDS_DATABASE_NAME $UMDS_DATABASE_NAME

ARG UMDS_DSN_NAME=local
ENV UMDS_DSN_NAME $UMDS_DSN_NAME

ARG UMDS_USERNAME=local
ENV UMDS_USERNAME $UMDS_USERNAME

ARG UMDS_PASSWORD=local
ENV UMDS_PASSWORD $UMDS_PASSWORD

RUN apt-get update

RUN apt-get -y install vim perl tar sed psmisc unixodbc postgresql postgresql-contrib odbc-postgresql python-minimal

ADD $UMDS_INSTALLER_SCRIPT /tmp/

ADD $UMDS_INSTALLER_PACKAGE /tmp/

RUN sh /tmp/$UMDS_INSTALLER_SCRIPT $UMDS_DATABASE_NAME $UMDS_DSN_NAME $UMDS_USERNAME $UMDS_PASSWORD

CMD export PATH=$PATH:/usr/local/vmware-umds/bin && service postgresql start && /bin/bash
