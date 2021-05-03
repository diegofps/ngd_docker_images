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


### CORE

# Configure fs.defaultFS
cat /hadoop/etc/hadoop/core-site.xml | sed "s/<configuration>\$/<configuration>\n  <property>\n    <name>fs.defaultFS<\/name>\n    <value>hdfs:\/\/${MASTER}:9000<\/value>\n  <\/property>/" > ./tmp && mv ./tmp /hadoop/etc/hadoop/core-site.xml

# Configure hadoop.tmp.dir
cat /hadoop/etc/hadoop/core-site.xml | sed 's/<\/configuration>$/\n  <property>\n    <name>hadoop.tmp.dir<\/name>\n    <value>file:\/\/\/hadoop_data\/tmp<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/core-site.xml


### HDFS

# Allow datanodes not listed in etc/conf/slaves
cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/  <property>\n    <name>dfs.namenode.datanode.registration.ip-hostname-check<\/name>\n    <value>false<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

# Configure dfs.replication
cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/  <property>\n    <name>dfs.replication<\/name>\n    <value>3<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

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

cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.client.use.datanode.hostname<\/name>\n    <value>false<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml

cat /hadoop/etc/hadoop/hdfs-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>dfs.datanode.use.datanode.hostname<\/name>\n    <value>false<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/hdfs-site.xml


### Mapreduce

cat /hadoop/etc/hadoop/mapred-site.xml | sed 's/<\/configuration>/  <property>\n    <name>mapreduce.framework.name<\/name>\n    <value>yarn<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/mapred-site.xml

cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>yarn.app.mapreduce.am.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|' > ./tmp && mv ./tmp /hadoop/etc/hadoop/mapred-site.xml

cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>mapreduce.map.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|' > ./tmp && mv ./tmp /hadoop/etc/hadoop/mapred-site.xml

cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>mapreduce.reduce.env</name>\n    <value>/hadoop</value>\n  </property>\n</configuration>|' > ./tmp && mv ./tmp /hadoop/etc/hadoop/mapred-site.xml

cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>mapreduce.application.classpath</name>\n    <value>/hadoop/share/hadoop/mapreduce/*,/hadoop/share/hadoop/mapreduce/lib/*,/hadoop/share/hadoop/common/*,/hadoop/share/hadoop/common/lib/*,/hadoop/share/hadoop/yarn/*,/hadoop/share/hadoop/yarn/lib/*,/hadoop/share/hadoop/hdfs/*,/hadoop/share/hadoop/hdfs/lib/*</value>\n  </property>\n</configuration>|' > ./tmp && mv ./tmp /hadoop/etc/hadoop/mapred-site.xml

cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>mapreduce.jobhistory.address</name>\n    <value>hadoop-primary:10020</value>\n  </property>\n</configuration>|' > ./tmp && mv ./tmp /hadoop/etc/hadoop/mapred-site.xml

cat /hadoop/etc/hadoop/mapred-site.xml | sed 's|</configuration>|\n  <property>\n    <name>yarn.app.mapreduce.am.job.client.port-range	</name>\n    <value>50100-50150</value>\n  </property>\n</configuration>|' > ./tmp && mv ./tmp /hadoop/etc/hadoop/mapred-site.xml


### Yarn

cat /hadoop/etc/hadoop/yarn-site.xml | sed 's/<\/configuration>/  <property>\n    <name>yarn.nodemanager.aux-services<\/name>\n    <value>mapreduce_shuffle<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/yarn-site.xml

cat /hadoop/etc/hadoop/yarn-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>yarn.web-proxy.address<\/name>\n    <value>hadoop-primary:9046<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/yarn-site.xml

#cat /hadoop/etc/hadoop/yarn-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>yarn.resourcemanager.address<\/name>\n    <value>hadoop-primary:8032<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/yarn-site.xml

#cat /hadoop/etc/hadoop/yarn-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>yarn.resourcemanager.scheduler.address<\/name>\n    <value>hadoop-primary:8030<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/yarn-site.xml

#cat /hadoop/etc/hadoop/yarn-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>yarn.resourcemanager.resource-tracker.address<\/name>\n    <value>hadoop-primary:8031<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/yarn-site.xml

cat /hadoop/etc/hadoop/yarn-site.xml | sed 's/<\/configuration>/\n  <property>\n    <name>yarn.resourcemanager.hostname<\/name>\n    <value>hadoop-primary<\/value>\n  <\/property>\n<\/configuration>/' > ./tmp && mv ./tmp /hadoop/etc/hadoop/yarn-site.xml


# Remove unnecessary files
rm -rf /hadoop/share/doc
