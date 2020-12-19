#!/bin/bash

CONFIG_DST=/etc/mysql/mariadb.conf.d/60-galera.cnf
CONFIG_SRC=/project/galera.cnf

cat $CONFIG_SRC | envsubst > $CONFIG_DST

if [ $NODE_TYPE = "principal" ]; then
	FILE=/project/created.lock

	if [ -e $FILE  ]; then
		mysqld
	else
		touch $FILE
	        mysqld --wsrep-new-cluster
	fi

else
	mysqld
fi

