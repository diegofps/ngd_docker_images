#!/bin/sh

stop_primary_node()
{
    echo "Stopping hadoop primary node..."

    hdfs --daemon stop namenode
    yarn --daemon stop resourcemanager
    yarn --daemon stop nodemanager
    yarn --daemon stop proxyserver
    mapred --daemon stop historyserver

    echo "Hadoop primary node stopped!"
}

stop_secondary_nodes()
{
    echo "Stopping secondary hadoop nodes..."

    NODES=`ngd_nodes.sh`

    for NODE in $NODES
    do
        #ssh $NODE 'hdfs --daemon start datanode' &
        ssh $NODE bash -c 'JAVA_HOME=`ls /usr/lib/jvm/java-8-openjdk-*` /hadoop/bin/hdfs --daemon stop datanode' &
    done

    wait

    echo "Secondary hadoop nodes stopped!"
}

stop_primary_node
stop_secondary_nodes

echo "Done!"
