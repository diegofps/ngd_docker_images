#!/bin/bash

mkdir -p /run/mysqld/
chown mysql:mysql /run/mysqld/

if [ $TYPE = "principal" ]; then
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

