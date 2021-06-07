#!/bin/sh

init_cluster()
{
    FORCE=$1
    STARTED_LOCK="/hadoop/started.lock"

    if [ $FORCE = "-f" -o ! -e "$STARTED_LOCK" ]; then
        echo "Master node already initialized, skipping namenode format"
        hdfs namenode -format alpha -clusterid 249bfd46-a641-4ccd-8a02-82667bae653e
        touch $STARTED_LOCK

    else
        echo "Master node already initialized, skipping namenode format"
    fi
}

start_primary_node()
{
    echo "Starting hadoop primary node..."

    hdfs --daemon start namenode
    yarn --daemon start resourcemanager
    yarn --daemon start nodemanager
    yarn --daemon start proxyserver
    mapred --daemon start historyserver

    echo "Hadoop primary node started!"
}

start_secondary_nodes()
{
    echo "Starting secondary hadoop nodes..."

    NODES=`ngd_nodes.sh`

    for NODE in $NODES
    do
        #ssh $NODE 'hdfs --daemon start datanode' &
        ssh $NODE /hadoop/bin/hdfs --daemon start datanode &
    done

    wait

    echo "Secondary hadoop nodes started!"
}

init_cluster $1
start_primary_node
start_secondary_nodes

echo "Done!"
