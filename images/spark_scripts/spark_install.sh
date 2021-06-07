#!/bin/sh

safety_checks()
{
    echo "\nStarting safety checks..."

    echo "Safety checks completed!"
}

download_files()
{
    echo "\nDownloading packages..."

    if [ ! -e "/tmp/spark-3.1.1-bin-hadoop3.2.tgz" ]; then
        wget --directory-prefix /tmp https://downloads.apache.org/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz &
    fi

    if [ ! -e "/tmp/spark-3.1.1-bin-hadoop3.2.tgz.sha512" ]; then
        wget --directory-prefix /tmp https://downloads.apache.org/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz.sha512 &
    fi

    wait

    echo "Downloads completed!"

    echo "\nChecking signatures..."

    SHA_SPARK=`cat /tmp/spark-3.1.1-bin-hadoop3.2.tgz.sha512 | cut -c 32- | tr -d '\n' | sed -E 's/\s+//g' | awk '{ print tolower($0) }'`
    SHA_SPARK_SEEN=`sha512sum /tmp/spark-3.1.1-bin-hadoop3.2.tgz  | awk '{ print $1 }'`
    
    if [ $SHA_SPARK != $SHA_SPARK_SEEN ]; then
        echo "Expected $SHA_SPARK but got $SHA_SPARK_SEEN in Spark file"
        exit 1
    fi

    echo "Checking signatures completed!"
}

install_java()
{
    echo "\nChecking if a JVM is present..."

    AVAILABLE=`which java`
    if [ -z $AVAILABLE ]; then
        echo "Trying to install java in the host machine"
        sudo apt install openjdk-8-jre-headless openjdk-8-jdk-headless -y
        bashrc_add_var "JAVA_HOME" "/usr/lib/jvm/java-8-openjdk-amd64/"
    fi

    NODES=`ngd_nodes.sh`
    for NODE in $NODES
    do
        AVAILABLE=`ssh $NODE 'which java'`
        if [ -z $AVAILABLE ]; then
            echo "Trying to install java in $NODE"
            ssh $NODE 'sudo apt install openjdk-8-jre-headless -y'
        fi
        bashrc_remote_add_var "JAVA_HOME" "/usr/lib/jvm/java-8-openjdk-arm64/" "$NODE"
    done
    
    echo "JVM check completed!"
}

deploy_files()
{
    echo "\nDeploying file..."
    NODES=`ngd_nodes.sh`

    for NODE in $NODES ; do

        DEPLOY_FILE=`ssh $NODE 'ls /tmp/spark-3.1.1-bin-hadoop3.2.tgz 2> /dev/null'`

        if [ -z $DEPLOY_FILE ] ; then
            echo "Deploying file to node $NODE"
            scp "/tmp/spark-3.1.1-bin-hadoop3.2.tgz" $NODE:'/tmp/spark-3.1.1-bin-hadoop3.2.tgz'

        else
            echo "File already in node $NODE, skipping deploy"

        fi

    done

    echo "Deploy files completed"
}

configure_host()
{
    echo "\nConfiguring spark in host machine..."

    PRIMARY=`hostname -i`
    ./spark_configure.sh $PRIMARY $USER

    echo "Spark host configuration completed!"
}

configure_node()
{
    NODE=$1
    echo "Configuring node $NODE..."

    DEPLOY_FILE=`ssh $NODE 'ls /tmp/spark-3.1.1-bin-hadoop3.2.tgz 2> /dev/null'`

    if [ "$DEPLOY_FILE" = "" ] ; then
        echo "Missing deploy file at node $NODE, skipping"
        return
    fi

    PRIMARY=`hostname -i`
    scp ./spark_configure.sh $NODE:'/tmp/spark_configure.sh'
    ssh $NODE /tmp/spark_configure.sh $PRIMARY ngd
}

configure_nodes()
{
    echo "\nConfiguring nodes"
    NODES=`ngd_nodes.sh`

    for NODE in $NODES ; do
        configure_node $NODE &
    done

    wait

    echo "Nodes configuration completed!"
}

update_bashrc()
{
    echo "\nUpdating host .bashrc..."    
    bashrc_extend_path "/spark/bin"
    bashrc_add_var "SPARK_HOME" "/spark"


    echo "Updating nodes .bashrc..."
    NODES=`ngd_nodes.sh`

    for NODE in $NODES
    do
        bashrc_remote_extend_path "/spark/bin" "$NODE"
        bashrc_remote_add_var "SPARK_HOME" "/spark" "$NODE"
    done

    echo ".bashrc's updated!"
}


safety_checks
download_files
install_java
deploy_files
configure_nodes
configure_host
update_bashrc
