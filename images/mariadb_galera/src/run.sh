#!/bin/bash

mkdir /run/mysqld/
chown mysql:mysql /run/mysqld/

if [ $TYPE = "master" ]; then
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

