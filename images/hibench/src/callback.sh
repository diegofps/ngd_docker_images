#!/bin/sh

OPTION=$1

if [ "$OPTION" = "before" ]; then

    ./update_replication.py

    if [ "$MODE"="primary" ]; then
        if [ -e "/hibench" -a "$(cat /hibench/conf/spark.conf | grep park.driver.host)" = '' ]; then
            echo "Setting spark.driver.host in /hibench/conf/spark.conf"
            cat /hibench/conf/spark.conf | sed "s/# Spark home/# Host address\nspark.driver.host       $(hostname -I)\n\n# Spark home/" > ./tmp
            mv ./tmp /hibench/conf/spark.conf
        fi
    fi

fi