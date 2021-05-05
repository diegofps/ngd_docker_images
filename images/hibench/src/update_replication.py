#!/usr/bin/python3

import os
import re

replication = os.getenv("HADOOP_HDFS_REPLICATION")

if replication:

    with open("/hadoop/etc/hadoop/hdfs-site.xml", "r") as fin:
        data = re.sub("<name>dfs\.replication</name>\n    <value>\d+</value>", '<name>dfs.replication</name>\n    <value>%s</value>' % replication, fin.read())

    with open("/hadoop/etc/hadoop/hdfs-site.xml", "w") as fout:
        fout.write(data)
