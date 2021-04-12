# README

## Table of Contents

- [README](#readme)
  - [Table of Contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Deploy](#deploy)
  - [Common Tasks](#common-tasks)
  - [Send data to hdfs](#send-data-to-hdfs)
    - [Debugging](#debugging)
  - [Cleaning Up](#cleaning-up)
    - [Undeploy](#undeploy)
    - [Clear Data in all datanodes](#clear-data-in-all-datanodes)

## Getting started

### Deploy

```bash
sudo kubectl create -f 'primary.yaml'
sudo kubectl create -f 'primary_service.yaml'
sudo kubectl create -f 'secondary.yaml'
```

## Common Tasks

## Send data to hdfs

```bash
# Start and connect to a client using the mounted volume in client.yaml
sudo kubectl create -f client.yaml
sudo kubectl exec -it bigdata2-client -- bash

# Send  the parquet files
hadoop fs -put /ipsms/test.snappy.parquet hdfs://bigdata2-primary:9000/test.snappy.parquet
hadoop fs -put /ipsms/train.snappy.parquet hdfs://bigdata2-primary:9000/train.snappy.parquet
hadoop fs -put /ipsms/sample_submission.csv hdfs://bigdata2-primary:9000/sample_submission.csv

# Update replicate parameter for individual files
hdfs dfs -setrep -w 3 /test.snappy.parquet
hdfs dfs -setrep -w 3 /train.snappy.parquet
hdfs dfs -setrep -w 3 /sample_submission.csv
```

### Debugging

```bash
# Open the primary container or a datanode (secondary)
sudo kubectl exec -it bigdata2-primary -- bash

# Open tha log
tail -f /hadoop/logs/hadoop-root-namenode-bigdata2-primary.log
tail -f /hadoop/logs/hadoop-root-namenode-bigdata2-primary.log
```

## Cleaning Up


### Undeploy

```bash
sudo kubectl delete -f 'primary.yaml'
sudo kubectl delete -f 'primary_service.yaml'
sudo kubectl delete -f 'secondary.yaml'

sudo kubectl delete -f 'client.yaml'
```

### Clear Data in all datanodes

```bash
parallel-ssh -h ~/nodes -i -t 0 'sudo rm -rf /media/storage/dfs_datanode'
```
