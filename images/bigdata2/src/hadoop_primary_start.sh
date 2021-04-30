#!/bin/sh

STARTED_LOCK="/hadoop/started.lock"

if [ -e "$STARTED_LOCK" ]; then
    echo "Master node already initialized, skipping namenode format"

else
    echo "Master node already initialized, skipping namenode format"
    hdfs namenode -format alpha -clusterid 249bfd46-a641-4ccd-8a02-82667bae653e
    touch $STARTED_LOCK
fi

hdfs --daemon start namenode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
yarn --daemon start proxyserver
mapred --daemon start historyserver

echo "Hadoop primary started"
