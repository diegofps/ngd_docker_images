#!/bin/sh

uninstall_node()
{
    NODE=$1

    echo "Uninstalling Spark in node $NODE"
    
    #ssh $NODE 'sudo service ... stop'

    ssh $NODE 'sudo rm -rf /spark'
}

uninstall_host()
{
    echo "Uninstalling Spark in host..."

    #ssh $NODE 'sudo service ... stop'

    sudo rm -rf /spark

    echo "Host unistalled!"
}

uninstall_nodes()
{
    echo "\nUninstalling nodes..."

    NODES=`ngd_nodes.sh`

    for NODE in $NODES ; do
        uninstall_node $NODE &
    done

    wait

    echo "Nodes uninstalled!"
}

uninstall_host

uninstall_nodes
