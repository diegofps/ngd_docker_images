# Deploy

```
sudo kubectl create -f 'primary.yaml'
sudo kubectl create -f 'primary_service.yaml'
sudo kubectl create -f 'secondary.yaml'
```

# Send data to hdfs

```
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

# Undeploy

```
sudo kubectl delete -f 'primary.yaml'
sudo kubectl delete -f 'primary_service.yaml'
sudo kubectl delete -f 'secondary.yaml'

sudo kubectl delete -f 'client.yaml'
```

# Clear Data in all datanodes

```
parallel-ssh -h ~/nodes -i -t 0 'sudo rm -rf /media/storage/dfs_datanode'
```
