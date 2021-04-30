#!/bin/sh

echo "Start script"

if [ -e "./callback.sh" ]; then ./callback.sh before ; fi

if [ "$MODE" = "primary" ]; then
    echo "Starting as primary node"
    ./hadoop_primary_start.sh
    ./spark_primary_start.sh
    ./hadoop_logs.sh

elif [ "$MODE" = "secondary" ]; then
    echo "Starting as secondary node"
    ./hadoop_worker_start.sh
    ./spark_worker_start.sh
    ./hadoop_logs.sh


elif [ "$MODE" = "hadoop_primary" ]; then
    echo "Starting as hadoop primary node"
    ./hadoop_primary_start.sh
    ./hadoop_logs.sh

elif [ "$MODE" = "hadoop_worker" ]; then
    echo "Starting as hadoop primary node"
    ./hadoop_worker_start.sh
    ./hadoop_logs.sh


elif [ "$MODE" = "spark_primary" ]; then
    echo "Starting as spark primary node"
    ./spark_primary_start.sh
    ./spark_logs.sh

elif [ "$MODE" = "spark_worker" ]; then
    echo "Starting as hadoop primary node"
    ./spark_worker_start.sh
    ./spark_logs.sh


elif [ "$MODE" = "client" ]; then
    echo "Starting as client"
    sleep infinity
    exit 0

fi

if [ -e "./callback.sh" ]; then ./callback.sh after ; fi
