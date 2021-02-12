#!/bin/sh

echo "Starting script"

################################################################################
# Start the cluster
################################################################################

STARTED_LOCK="/hadoop/started.lock"

if [ "$HADOOP_MODE" = "master" ]; then
    echo "Starting as master node"

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

    sleep 3
    tail -f /hadoop/logs/hadoop-root-namenode-*.log

else
    echo "Starting as data node"
    hdfs --daemon start datanode

    sleep 3
    tail -f /hadoop/logs/hadoop-root-datanode-*.log
fi
