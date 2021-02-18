#!/bin/sh

MASTER=$1

################################################################################
# Extract hadoop
################################################################################

ARCH=`uname -m`

if [ "$ARCH" = "aarch64" ]; then
    echo "Extracting hadoop for aarch64"
    tar -xf hadoop-3.3.0-aarch64.tar.gz

else
    echo "Extracting hadoop for amd64"
    tar -xf hadoop-3.3.0.tar.gz
fi

mv hadoop-3.3.0 /hadoop


echo "Configuring hadoop"

################################################################################
# Configure Build
################################################################################

# Create the data dir
mkdir -p /hadoop_data/dfs_namenode
mkdir -p /hadoop_data/dfs_datanode
mkdir -p /hadoop_data/tmp
chmod -R 750 /hadoop_data

###

# Configure fs.defaultFS
cat /hadoop/etc/hadoop/core-site.xml | sed "s/<configuration>\$/<configuration>\n  <property>\n    <name>fs.defaultFS<\/name>\n    <value>hdfs:\/\/${MASTER}:9000<\/value>\n  <\/property>/" > ./tmp && mv ./tmp /hadoop/etc/hadoop/core-site.xml

# Configure hadoop.tmp.dir
cat /hadoop/etc/hadoop/core-site.xml | sed 's/<\/configuration>$/\n  <property>\n    <name>hadoop.tmp.dir<\/name>\n    <value>file:\/\/\/hadoop_data\/tmp<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/core-site.xml

###


# Allow datanodes not listed in etc/conf/slaves
cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/  <property>\n    <name>dfs.namenode.datanode.registration.ip-hostname-check<\/name>\n    <value>false<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

# Configure dfs.replication
cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/  <property>\n    <name>dfs.replication<\/name>\n    <value>5<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

# Configure dfs.name.dir
cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.name.dir<\/name>\n    <value>file:\/\/\/hadoop_data\/dfs_namenode<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

# Configure dfs.data.dir
cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.data.dir<\/name>\n    <value>file:\/\/\/hadoop_data\/dfs_datanode<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

# Bind address 0.0.0.0
cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.namenode.rpc-bind-host<\/name>\n    <value>0.0.0.0<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.namenode.servicerpc-bind-host<\/name>\n    <value>0.0.0.0<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.namenode.lifeline.rpc-bind-host<\/name>\n    <value>0.0.0.0<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.namenode.http-bind-host<\/name>\n    <value>0.0.0.0<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.namenode.https-bind-host<\/name>\n    <value>0.0.0.0<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml


###

# Configure yarn.nodemanager.aux-services
cat /hadoop/etc/hadoop/mapred-site.xml | sed 's/<\/configuration>/  <property>\n    <name>mapreduce.framework.name<\/name>\n    <value>yarn<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/mapred-site.xml

###

# Configure yarn.nodemanager.aux-services
cat /hadoop/etc/hadoop/yarn-site.xml | sed 's/<\/configuration>/  <property>\n    <name>yarn.nodemanager.aux-services<\/name>\n    <value>mapreduce_shuffle<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/yarn-site.xml

# Configure yarn.web-proxy.address
cat /hadoop/etc/hadoop/yarn-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>yarn.web-proxy.address<\/name>\n    <value>localhost:9046<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/yarn-site.xml
