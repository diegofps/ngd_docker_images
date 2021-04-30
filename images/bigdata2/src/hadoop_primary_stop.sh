#!/bin/sh

hdfs --daemon stop namenode
yarn --daemon stop resourcemanager
yarn --daemon stop nodemanager
yarn --daemon stop proxyserver
mapred --daemon stop historyserver

echo "Hadoop primary stoped"
