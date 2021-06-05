#!/bin/sh

PRIMARY=$1
USERNAME=$2

if [ -z "$PRIMARY" -o -z "$USERNAME" ]; then
    echo "Syntax: $0 <PRIMARY> <USERNAME>"
    exit 1
fi


# Extract the files
tar -xf '/tmp/hadoop-3.3.0.tar.gz'
sudo mv hadoop-3.3.0 /hadoop

# Create the data and name directories
sudo mkdir -p /hadoop_data/dfs_namenode
sudo mkdir -p /hadoop_data/dfs_datanode
sudo mkdir -p /hadoop_data/tmp
sudo chown -R $USERNAME:$USERNAME /hadoop_data
sudo chmod -R 777 /hadoop_data


# Configure the configuration files

### CORE

# Configure fs.defaultFS
cat /hadoop/etc/hadoop/core-site.xml | sed "s|<configuration>|<configuration>\n  <property>\n    <name>fs.defaultFS</name>\n    <value>hdfs://${PRIMARY}:9000</value>\n  </property>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/core-site.xml


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

cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|\n  <property>\n    <name>mapreduce.jobhistory.address</name>\n    <value>${PRIMARY}:10020</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml

cat /hadoop/etc/hadoop/mapred-site.xml | sed "s|</configuration>|\n  <property>\n    <name>yarn.app.mapreduce.am.job.client.port-range	</name>\n    <value>50100-50150</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/mapred-site.xml


### Yarn

cat /hadoop/etc/hadoop/yarn-site.xml | sed "s|</configuration>|  <property>\n    <name>yarn.nodemanager.aux-services</name>\n    <value>mapreduce_shuffle</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml

cat /hadoop/etc/hadoop/yarn-site.xml | sed "s|</configuration>|\n  <property>\n    <name>yarn.web-proxy.address</name>\n    <value>${PRIMARY}:9046</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml

cat /hadoop/etc/hadoop/yarn-site.xml | sed "s|</configuration>|\n  <property>\n    <name>yarn.resourcemanager.hostname</name>\n    <value>${PRIMARY}</value>\n  </property>\n</configuration>|" > ./.tmp && mv ./.tmp /hadoop/etc/hadoop/yarn-site.xml


# Remove unnecessary files
rm -rf /hadoop/share/doc

echo "Done!"
