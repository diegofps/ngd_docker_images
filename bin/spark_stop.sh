#!/bin/sh

stop_primary_node()
{
    echo "Stopping spark primary node..."

    /spark/sbin/stop-master.sh

    echo "Spark primary node stopped!"
}

stop_secondary_nodes()
{
    echo "Stopping secondary spark nodes..."

    NODES=`ngd_nodes.sh`

    for NODE in $NODES
    do
        ssh $NODE /spark/sbin/stop-worker.sh &
    done

    wait

    echo "Secondary spark nodes stopped!"
}

stop_primary_node
stop_secondary_nodes

echo "Done!"
