#!/bin/sh

safety_checks()
{
    echo "\nStarting safety checks..."

    echo "Safety checks completed!"
}

download_files()
{
    echo "\nDownloading packages..."

    if [ ! -e "./hadoop-3.3.0-aarch64.tar.gz" ]; then
        wget https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0-aarch64.tar.gz &
    fi

    if [ ! -e "./hadoop-3.3.0.tar.gz" ]; then
        wget https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz &
    fi

    if [ ! -e "./hadoop-3.3.0-aarch64.tar.gz.sha512" ]; then
        wget https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0-aarch64.tar.gz.sha512 &
    fi

    if [ ! -e "./hadoop-3.3.0.tar.gz.sha512" ]; then
        wget https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz.sha512 &
    fi

    wait

    echo "Downloads completed!"

    echo "\nChecking signatures..."

    SHA_AMD64=`cat ./hadoop-3.3.0.tar.gz.sha512 | awk '{ print $4 }'`
    SHA_ARM64=`cat ./hadoop-3.3.0-aarch64.tar.gz.sha512 | awk '{ print $4 }'`

    SHA_AMD64_SEEN=`sha512sum ./hadoop-3.3.0.tar.gz  | awk '{ print $1 }'`
    SHA_ARM64_SEEN=`sha512sum ./hadoop-3.3.0-aarch64.tar.gz  | awk '{ print $1 }'`

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
    
    echo "Java basic check completed!"
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
            scp "./hadoop-3.3.0-aarch64.tar.gz" $node:'/tmp/hadoop-3.3.0.tar.gz'

        elif [ "$ARCH" = "x86_64" ]; then
            scp "./hadoop-3.3.0.tar.gz" $node:'/tmp/hadoop-3.3.0.tar.gz'

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

    # Extract the files
    tar -xf './hadoop-3.3.0.tar.gz'
    sudo mv hadoop-3.3.0 /hadoop

    # Create the data and name directories
    sudo mkdir -p /hadoop_data/dfs_namenode
    sudo mkdir -p /hadoop_data/dfs_datanode
    sudo mkdir -p /hadoop_data/tmp
    sudo chmod -R 777 /hadoop_data



    # Configure the configuration files

    ### CORE

    MASTER=`hostname -i`

    # Configure fs.defaultFS
    cat /hadoop/etc/hadoop/core-site.xml | sed "s|<configuration>|<configuration>\n  <property>\n    <name>fs.defaultFS</name>\n    <value>hdfs://${MASTER}:9000</value>\n  </property>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/core-site.xml


    # Configure hadoop.tmp.dir
    cat /hadoop/etc/hadoop/core-site.xml | sed "s|</configuration>|\n  <property>\n    <name>hadoop.tmp.dir</name>\n    <value>file:///hadoop_data/tmp</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/core-site.xml


    ### HDFS

    # Allow datanodes not listed in etc/conf/slaves
    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|  <property>\n    <name>dfs.namenode.datanode.registration.ip-hostname-check</name>\n    <value>false</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml


    # Configure dfs.replication
    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.replication</name>\n    <value>3</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml


    # Configure dfs.name.dir
    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.name.dir</name>\n    <value>file:\/\/\/hadoop_data\/dfs_namenode</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml


    # Configure dfs.data.dir
    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.data.dir</name>\n    <value>file:\/\/\/hadoop_data\/dfs_datanode</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml


    # Bind address 0.0.0.0
    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.namenode.rpc-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml

    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.namenode.servicerpc-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml

    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.namenode.lifeline.rpc-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml

    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.namenode.http-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml

    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.namenode.https-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml

    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.client.use.datanode.hostname</name>\n    <value>false</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml

    cat /hadoop/etc/hadoop/hdfs-site.xml | sed "s|</configuration>|\n  <property>\n    <name>dfs.datanode.use.datanode.hostname</name>\n    <value>false</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml


    ### Mapreduce

    cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|  <property>\n    <name>mapreduce.framework.name</name>\n    <value>yarn</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml

    cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|\n  <property>\n    <name>yarn.app.mapreduce.am.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml

    cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|\n  <property>\n    <name>mapreduce.map.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml

    cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|\n  <property>\n    <name>mapreduce.reduce.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml

    cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|\n  <property>\n    <name>mapreduce.application.classpath</name>\n    <value>/hadoop/share/hadoop/mapreduce/*,/hadoop/share/hadoop/mapreduce/lib/*,/hadoop/share/hadoop/common/*,/hadoop/share/hadoop/common/lib/*,/hadoop/share/hadoop/yarn/*,/hadoop/share/hadoop/yarn/lib/*,/hadoop/share/hadoop/hdfs/*,/hadoop/share/hadoop/hdfs/lib/*</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml

    cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|\n  <property>\n    <name>mapreduce.jobhistory.address</name>\n    <value>${MASTER}:10020</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml

    cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|\n  <property>\n    <name>yarn.app.mapreduce.am.job.client.port-range	</name>\n    <value>50100-50150</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml


    ### Yarn

    cat /hadoop/etc/hadoop/yarn-site.xml | sed "s|</configuration>|  <property>\n    <name>yarn.nodemanager.aux-services</name>\n    <value>mapreduce_shuffle</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml

    cat /hadoop/etc/hadoop/yarn-site.xml | sed "s|</configuration>|\n  <property>\n    <name>yarn.web-proxy.address</name>\n    <value>${MASTER}:9046</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml

    cat /hadoop/etc/hadoop/yarn-site.xml | sed "s|</configuration>|\n  <property>\n    <name>yarn.resourcemanager.hostname</name>\n    <value>${MASTER}</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml


    # Remove unnecessary files
    rm -rf /hadoop/share/doc

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

    # Extract the files
    ssh $node tar -xf '/tmp/hadoop-3.3.0.tar.gz'
    ssh $node sudo mv hadoop-3.3.0 /hadoop

    # Create the data and name directories
    ssh $node 'sudo mkdir -p /hadoop_data/dfs_namenode ; sudo mkdir -p /hadoop_data/dfs_datanode ; sudo mkdir -p /hadoop_data/tmp ; sudo chown -R ngd:ngd /hadoop_data ; sudo chmod -R 777 /hadoop_data'



    # Configure the configuration files

    ### CORE

    MASTER=`hostname -i`

    # Configure fs.defaultFS
    ssh $node "cat /hadoop/etc/hadoop/core-site.xml | sed 's|<configuration>|<configuration>\n  <property>\n    <name>fs.defaultFS</name>\n    <value>hdfs://${MASTER}:9000</value>\n  </property>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/core-site.xml"


    # Configure hadoop.tmp.dir
    ssh $node "cat /hadoop/etc/hadoop/core-site.xml | sed 's|</configuration>|\n  <property>\n    <name>hadoop.tmp.dir</name>\n    <value>file:///hadoop_data/tmp</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/core-site.xml"


    ### HDFS

    # Allow datanodes not listed in etc/conf/slaves
    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|  <property>\n    <name>dfs.namenode.datanode.registration.ip-hostname-check</name>\n    <value>false</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"


    # Configure dfs.replication
    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.replication</name>\n    <value>3</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"


    # Configure dfs.name.dir
    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.name.dir</name>\n    <value>file:\/\/\/hadoop_data\/dfs_namenode</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"


    # Configure dfs.data.dir
    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.data.dir</name>\n    <value>file:\/\/\/hadoop_data\/dfs_datanode</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"


    # Bind address 0.0.0.0
    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.namenode.rpc-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.namenode.servicerpc-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.namenode.lifeline.rpc-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.namenode.http-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.namenode.https-bind-host</name>\n    <value>0.0.0.0</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.client.use.datanode.hostname</name>\n    <value>false</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's|</configuration>|\n  <property>\n    <name>dfs.datanode.use.datanode.hostname</name>\n    <value>false</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/hdfs-site.xml"


    ### Mapreduce

    ssh $node "cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|  <property>\n    <name>mapreduce.framework.name</name>\n    <value>yarn</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>yarn.app.mapreduce.am.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>mapreduce.map.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>mapreduce.reduce.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>mapreduce.application.classpath</name>\n    <value>/hadoop/share/hadoop/mapreduce/*,/hadoop/share/hadoop/mapreduce/lib/*,/hadoop/share/hadoop/common/*,/hadoop/share/hadoop/common/lib/*,/hadoop/share/hadoop/yarn/*,/hadoop/share/hadoop/yarn/lib/*,/hadoop/share/hadoop/hdfs/*,/hadoop/share/hadoop/hdfs/lib/*</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>mapreduce.jobhistory.address</name>\n    <value>${MASTER}:10020</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>yarn.app.mapreduce.am.job.client.port-range	</name>\n    <value>50100-50150</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml"


    ### Yarn

    ssh $node "cat /hadoop/etc/hadoop/yarn-site.xml | sed 's|</configuration>|  <property>\n    <name>yarn.nodemanager.aux-services</name>\n    <value>mapreduce_shuffle</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/yarn-site.xml | sed 's|</configuration>|\n  <property>\n    <name>yarn.web-proxy.address</name>\n    <value>${MASTER}:9046</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml"

    ssh $node "cat /hadoop/etc/hadoop/yarn-site.xml | sed 's|</configuration>|\n  <property>\n    <name>yarn.resourcemanager.hostname</name>\n    <value>${MASTER}</value>\n  </property>\n</configuration>|' > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml"


    # Remove unnecessary files
    ssh $node 'rm -rf /hadoop/share/doc'

}

configure_nodes()
{
    echo "\nConfiguring nodes"
    NODES=`ngd_nodes.sh`

    for node in $NODES ; do
        configure_node $node #&
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
