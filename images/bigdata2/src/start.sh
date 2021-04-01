#!/bin/sh

echo "Start script"


################################################################################
# Start the cluster
################################################################################

STARTED_LOCK="/hadoop/started.lock"


if [ "$MODE" = "primary" ]; then
    echo "Starting as primary node"

    # Configure hibench, if available
    if [ -e "/hibench" -a "$(cat /hibench/conf/spark.conf | grep park.driver.host)" = '' ]
    then
        echo "Setting spark.driver.host in /hibench/conf/spark.conf"
        cat /hibench/conf/spark.conf | sed "s/# Spark home/# Host address\nspark.driver.host       $(hostname -I)\n\n# Spark home/" > ./tmp
        mv ./tmp /hibench/conf/spark.conf
    fi


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


    # Follow hadoop logs
    echo "Following hadoop namenode log"
    tail -f /hadoop/logs/hadoop-root-namenode-*.log

elif [ "$MODE" = "secondary" ]; then
    echo "Starting as secondary node"


    # Init Hadoop
    hdfs --daemon start datanode


    # Init spark
    cat /spark/conf/spark-env.sh | sed "s:# - SPARK_WORKER_CORES, :SPARK_WORKER_CORES=$(nproc) # :" > ./tmp && mv ./tmp /spark/conf/spark-env.sh
    /spark/sbin/start-slave.sh spark://bigdata2-primary:7077


    # Follow hadoop logs
    echo "Following hadoop datanode log"
    tail -f /hadoop/logs/hadoop-root-datanode-*.log

elif [ "$MODE" = "client" ]; then
    echo "Starting as client"
    bash
    exit 0

fi
