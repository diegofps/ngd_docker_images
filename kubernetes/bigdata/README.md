# Starting Hadoop

```bash
sudo kubectl create -f hadoop_master.yaml
sudo kubectl create -f hadoop_master_service.yaml
sudo kubectl create -f hadoop_data.yaml
```

# Stopping Hadoop

```bash
sudo kubectl delete -f hadoop_master.yaml
sudo kubectl delete -f hadoop_master_service.yaml
sudo kubectl delete -f hadoop_data.yaml
```

# Starting Spark

```bash
sudo kubectl create -f spark_master.yaml
sudo kubectl create -f spark_master_service.yaml
sudo kubectl create -f spark_worker.yaml
```

# Stopping Spark

```bash
sudo kubectl delete -f spark_master.yaml
sudo kubectl delete -f spark_master_service.yaml
sudo kubectl delete -f spark_worker.yaml
```
