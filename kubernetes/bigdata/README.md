# Starting Hadoop

Make sure all your nodes have the storage mounted at /media/storage

```bash
# WARNING: Only execute this when you need to format all storages
parallel-ssh -h ~/nodes -i -t 0 'sudo mkfs.ext4 /dev/ngd-blk2' 

# These are for mounting
parallel-ssh -h ~/nodes -i -t 0 'sudo mkdir -p /media/storage'
parallel-ssh -h ~/nodes -i -t 0 'sudo mount /dev/ngd-blk2 /media/storage'
parallel-ssh -h ~/nodes -t 0 -i "sudo chmod 777 /media/storage"
```

Then start the kubernetes entities

```bash
sudo kubectl create -f 'hadoop_master.yaml'
sudo kubectl create -f 'hadoop_master_service.yaml'
sudo kubectl create -f 'hadoop_data.yaml'
```

# Stopping Hadoop

```bash
sudo kubectl delete -f 'hadoop_master.yaml'
sudo kubectl delete -f 'hadoop_master_service.yaml'
sudo kubectl delete -f 'hadoop_data.yaml'
```

# Sending data

Create a container and map the volume containing the data to be stored

```bash
docker run -it --name=hadoop-client --entrypoint=/bin/bash -v=`pwd`:/data diegofpsouza/bigdata_hadoop:0.0.1
```

# Starting Spark

```bash
sudo kubectl create -f 'spark_master.yaml'
sudo kubectl create -f 'spark_master_service.yaml'
sudo kubectl create -f 'spark_worker.yaml'
```

# Stopping Spark

```bash
sudo kubectl delete -f 'spark_master.yaml'
sudo kubectl delete -f 'spark_master_service.yaml'
sudo kubectl delete -f 'spark_worker.yaml'
```
