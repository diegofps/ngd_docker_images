#!/bin/bash

NAME=`hostname`
FILE=/project/created.lock

if [ $NAME = "node1" -a -e $FILE  ]; then
	mysqld
else
	touch $FILE
	mysqld --wsrep-new-cluster
fi

