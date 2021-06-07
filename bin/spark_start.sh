#!/bin/sh

start_primary_node()
{
    echo "Starting spark primary node..."

    /spark/sbin/start-master.sh -h 0.0.0.0

    echo "Spark primary node started!"
}

start_secondary_nodes()
{
    echo "Starting secondary spark nodes..."

    NODES=`ngd_nodes.sh`
    PRIMARY=`hostname -i`

    for NODE in $NODES
    do
        ssh $NODE /spark/sbin/start-worker.sh spark://$PRIMARY:7077
    done

    wait

    echo "Secondary spark nodes started!"
}

start_primary_node
start_secondary_nodes

echo "Done!"
