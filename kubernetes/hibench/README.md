# README

## Table of Contents

- [README](#readme)
  - [Table of Contents](#table-of-contents)
  - [Frequent Tasks](#frequent-tasks)
    - [Preparing everything for the first use](#preparing-everything-for-the-first-use)
    - [Deploy / Undeploy the Containers](#deploy--undeploy-the-containers)
    - [Deploy dataset to HDFS](#deploy-dataset-to-hdfs)
    - [Deploy the scala application](#deploy-the-scala-application)
    - [Running the experiments](#running-the-experiments)
    - [Debugging](#debugging)

## Frequent Tasks

### Preparing everything for the first use

```bash
# Run bashrc_extend_path to add ngd_docker_images/bin in your PATH
cd /path/to/ngd_docker_images/bin
./bashrc_extend_path

# Format the drivers (you only need to do this once)
storage_format.sh

# Clear all data folders (do this after every call to undeploy.sh)
storage_clear.sh
```

### Deploy / Undeploy the Containers

To deploy:

```bash
# Deploy as hybrid system (CSD + Host)
./deploy.sh hybrid

# Deploy as host only
./deploy.sh host

# Deploy as CSD only
./deploy.sh csd
```

To undeploy:

```bash
./undeploy.sh

# You need to erase the datanodes if you want to deploy it again
storage_clear.sh
```

### Deploy dataset to HDFS

```bash
# Build the dataset
./dataset_build.sh

# Deploy it (this will copy the generated dataset to bigdata2-primary and then to HDFS)
./dataset_deploy.sh
```

### Deploy the scala application

```bash
# Build the app
./pkg_build.sh

# Deploy it (this will copy the generated application to bigdata2-primary and then to HDFS)
./pkg_deploy.sh
```

### Running the experiments

```bash
# Access bigdata2-primary
sudo kubectl exec -it bigdata2-primary -- bash

# To run SparkPI (replace host with the configuration you are using)
/usr/bin/time -v ./run_sparkpi.sh ./sparkpi_host.csv

# To run all HiBench benchamrks
/usr/bin/time -v ./run_hibench.sh ./hibench_host.csv

# To run all AutoML benchmarks
/usr/bin/time -v ./run_automl.sh ./automl_host.csv all
```

### Debugging

Hadoop master

```bash
# Open the primary container
sudo kubectl exec -it bigdata2-primary -- bash

# Open the namenode log
tail -f /hadoop/logs/hadoop-root-namenode-bigdata2-primary.log
```

Hadoop slaves

```bash
# List all containers with
sudo kubectl get pods -o wide

# Open the worker container you want to debug. Example:
sudo kubectl exec -it bigdata2-secondary-host-sp9fk -- bash

# Open the worker log
tail -f /hadoop/logs/hadoop-root-datanode-bigdata2-secondary-*.log
```

Spark Master

```bash
# Open the primary container
sudo kubectl exec -it bigdata2-primary -- bash

# Open the logs
tail -f /spark/logs/spark--org.apache.spark.deploy.master.Master-1-bigdata2-primary.out
```

Spark slaves

```bash
# List all containers with
sudo kubectl get pods -o wide

# Open the worker container you want to debug. Example:
sudo kubectl exec -it bigdata2-secondary-host-sp9fk -- bash

# Open the worker log
tail -f /spark/logs/spark--org.apache.spark.deploy.worker.Worker-1-bigdata2-secondary-*.out
```
