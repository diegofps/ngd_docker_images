#!/bin/sh

safety_checks()
{
    echo "\nStarting safety checks..."

    echo "Safety checks completed!"
}

download_files()
{
    echo "\nDownloading packages..."

    if [ ! -e "/tmp/hadoop-3.3.0-aarch64.tar.gz" ]; then
        wget --directory-prefix /tmp https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0-aarch64.tar.gz &
    fi

    if [ ! -e "/tmp/hadoop-3.3.0.tar.gz" ]; then
        wget --directory-prefix /tmp https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz &
    fi

    if [ ! -e "/tmp/hadoop-3.3.0-aarch64.tar.gz.sha512" ]; then
        wget --directory-prefix /tmp https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0-aarch64.tar.gz.sha512 &
    fi

    if [ ! -e "/tmp/hadoop-3.3.0.tar.gz.sha512" ]; then
        wget --directory-prefix /tmp https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz.sha512 &
    fi

    wait

    echo "Downloads completed!"

    echo "\nChecking signatures..."

    SHA_AMD64=`cat /tmp/hadoop-3.3.0.tar.gz.sha512 | awk '{ print $4 }'`
    SHA_ARM64=`cat /tmp/hadoop-3.3.0-aarch64.tar.gz.sha512 | awk '{ print $4 }'`

    SHA_AMD64_SEEN=`sha512sum /tmp/hadoop-3.3.0.tar.gz  | awk '{ print $1 }'`
    SHA_ARM64_SEEN=`sha512sum /tmp/hadoop-3.3.0-aarch64.tar.gz  | awk '{ print $1 }'`

    good=1

    if [ $SHA_AMD64 != $SHA_AMD64_SEEN ]; then
        echo "Expected $SHA_AMD64 but got $SHA_AMD64_SEEN in x86_64 file"
        good=0
    fi

    if [ "$SHA_ARM64" != "$SHA_ARM64_SEEN" ]; then
        echo "Expected $SHA_ARM64 but got $SHA_ARM64_SEEN in aarch64 file"
        good=0
    fi

    if [ good = "0" ]; then
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

    for node in $NODES ; do

        DEPLOY_FILE=`ssh $node 'ls /tmp/hadoop-3.3.0.tar.gz 2> /dev/null'`

        if [ -z $DEPLOY_FILE ] ; then
            echo "Deploying file to node $node"

        else
            echo "File already in node $node, skipping deploy"
            continue

        fi

        ARCH=`ssh $node uname -m`

        if [ "$ARCH" = "aarch64" ]; then
            scp "/tmp/hadoop-3.3.0-aarch64.tar.gz" $node:'/tmp/hadoop-3.3.0.tar.gz'

        elif [ "$ARCH" = "x86_64" ]; then
            scp "/tmp/hadoop-3.3.0.tar.gz" $node:'/tmp/hadoop-3.3.0.tar.gz'

        else
            echo "Unknown arch $ARCH at node $node, skipping node"
            continue

        fi
    done

    wait

    echo "Deploy files completed"
}

configure_host()
{
    echo "\nConfiguring host..."

    PRIMARY=`hostname -i`
    ./hadoop_configure.sh $PRIMARY $USER

    echo "Host configuration completed!"
}

configure_node()
{
    node=$1
    echo "Configuring node $node..."

    DEPLOY_FILE=`ssh $node 'ls /tmp/hadoop-3.3.0.tar.gz 2> /dev/null'`

    if [ "$DEPLOY_FILE" = "" ] ; then
        echo "Missing deploy file at node $node, skipping"
        return
    fi

    PRIMARY=`hostname -i`
    scp ./hadoop_configure.sh $node:'/tmp/hadoop_configure.sh'
    ssh $node /tmp/hadoop_configure.sh $PRIMARY ngd
}

configure_nodes()
{
    echo "\nConfiguring nodes"
    NODES=`ngd_nodes.sh`

    for node in $NODES ; do
        configure_node $node &
    done

    wait

    echo "Nodes configuration completed!"
}

update_bashrc()
{
    echo "\nUpdating host .bashrc..."    
    bashrc_extend_path "/hadoop/bin"
    bashrc_add_var "HADOOP_HOME" "/hadoop"


    echo "Updating nodes .bashrc..."
    NODES=`ngd_nodes.sh`

    for NODE in $NODES
    do
        bashrc_remote_extend_path "/hadoop/bin" "$NODE"
        bashrc_remote_add_var "HADOOP_HOME" "/hadoop" "$NODE"
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
