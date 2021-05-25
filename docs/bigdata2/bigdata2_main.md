# Welcome

This tutorial will explain how to install hadoop and spark on this local cluster.

# Dependencies

1. [Install k3s](../k3s/k3s_main.md)

# Prepare your nodes

HDFS requires a local CSD folder to store its data. By default this folder is /media/storage and is mounted with the second partition on every CSD. The Host must also have this folder, but it is simply a local folder. All commands must be executed inside the Host machine (the one connected to the CSD devices).

```bash
# This will create /media/storage on every CSD and inside the Host
storage_format.sh

# This will erase the content on each of the folder created before. This is useful to do a clean install
storage_clear.sh
```

# Deploy hadoop and spark

```bash
# Access the scripts folder for this task
cd kubernetes/bigdata2

# Choose the deploy mode
./deploy.sh hybrid # If you want to configure the host and all CSDs as hadoop data nodes and spark worker nodes
./deploy.sh csd # If you want to configure all CSDs as hadoop data nodes and spark worker nodes
./deploy.sh host # If you want to configure the host as hadoop data nodes and spark worker nodes
```

The operation above will take some time as each CSD and the host need to download the image from docker hub. Once complete you can do a sanity check and assert they are working by accessing the following URLs.

* [Spark interface](http://localhost:8080/) - Lists every spark task and every worker node
* [HDFS interface](http://localhost:9870/dfshealth.html#tab-datanode) - Lists every data node and their capacities.
* [HDFS explorer](http://localhost:9870/explorer.html#/) - Lists the files stored in HDFS.
* [Hadoop interface](http://localhost:8088/) - Lists hadoop and mapreduce tasks.

# Undeploy hadoop and spark

```bash
# Access the scripts folderr for this task
cd kubernetes/bigdata2

# Undo the operations above
./undeploy.sh
```

# Run some tests

Try to run some basic examples to see if everything is working fine

* [Scala package with SparkPI](./test_scala_with_sparkPI_in_a_package.md)
* [AutoML with Spark and Sklearn](./test_automl_pyspark_with_sklearn.md)

# Common issues

## Worker nodes are not showing in the Spark interface

This is usually caused by the firewall in Ubuntu, you can temporaly disable it with the following command/

```bash
# To stop the firewall
sudo service ufw stop
```

After disabling it, undeploy and deploy again.

## Data nodes are not showing in HDFS interface

This is usualy caused by the data nodes not accessing the folder /media/storage, either because it doesn't exist or because it can't be accessed. Running storage_format.sh and storage_clear.sh in the host usually fixes it.

```bash
# Format, create and set permissions in /media/storage on every node
storage_format.sh

# Erase the content in every /media/storage
storage_clear.sh
```

## Workers are not returning after rebooting the machine

This is a known bug in this setup and one of the reasons it is currently recommended only for experimentation. Reinstalling hadoop and spark fixes this issue.

```bash
# Access the scripts folder
cd kubernetes/bigdata2

# Undeploy them
./undeploy.sh

# Deploy them again
./deploy.sh hybrid
```