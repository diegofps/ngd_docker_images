#!/bin/sh

echo "Start script"


################################################################################
# Start the cluster
################################################################################

STARTED_LOCK="/hadoop/started.lock"


if [ "$MODE" = "primary" ]; then
    echo "Starting as primary node"


    # Init Hadoop
    if [ -e "$STARTED_LOCK" ]; then
        echo "Master node already initialized, skipping namenode format"

    else
        echo "Master node already initialized, skipping namenode format"
        # Format the namenode and create a cluster
        hdfs namenode -format alpha
        touch $STARTED_LOCK
    fi

    hdfs --daemon start namenode
    yarn --daemon start resourcemanager
    yarn --daemon start nodemanager
    yarn --daemon start proxyserver
    mapred --daemon start historyserver


    # Init Spark
    /spark/sbin/start-master.sh -h 0.0.0.0


    # Monitor Hadoop log
    echo "Started"
    sleep infinity


elif [ "$MODE" = "secondary" ]; then
    echo "Starting as secondary node"


    # Init Hadoop
    hdfs --daemon start datanode


    # Init spark
    cp /spark/conf/spark-env.sh.template /spark/conf/spark-env.sh
    echo "export SPARK_WORKER_CORES=$(nproc)" >> /spark/conf/spark-env.sh
    /spark/sbin/start-slave.sh spark://bigdata2-primary:7077


    # Monitor Hadoop log
    echo "Started"
    sleep infinity

else

    echo "Starting as client node"
    sleep infinity

fi
