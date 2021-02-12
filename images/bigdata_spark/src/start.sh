#!/bin/sh


if [ "$SPARK_MODE" = "master" ]; then
    echo "Starting in master mode"

    /spark/sbin/start-master.sh -h 0.0.0.0

    sleep 3
    tail -f /spark/logs/spark-*-org.apache.spark.deploy.master.Master-1-*.out


elif [ "#SPARK_MODE" = "worker" ]; then
    echo "Starting in worker mode"

    /spark/sbin/start-slave.sh spark://spark-master:7077

    sleep 3
    tail -f /spark/logs/spark-*-org.apache.spark.deploy.worker.Worker-1-*.out


else
    echo "starting in client mode"
    bash

fi
