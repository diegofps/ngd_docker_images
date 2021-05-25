# Welcome

This tutorial will help you compile a scala application, deploy it to to HDFS and run it inside Spark.

# Dependencies

1. [A configured k3s cluster](../k3s/main.md)
1. [A working hadoop + spark setup](./bigdata2_main.md)

# Configure your environment

```bash
# Install scala-sbt (https://www.scala-sbt.org/download.html)
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list

curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add

sudo apt-get update
sudo apt-get install sbt
```

# Compile the demo sbt package and deploy it to HDFS

```bash
# The folder images/hibench/pkg contains a scala package source with multiple examples
cd images/hibench/pkg

# Build it
./pkg_build.sh

# Deploy it to HDFS. Once inside HDFS, this package will be available to every pod
./pkg_deploy.sh
```

If you go to [HDFS explorer](http://localhost:9870/explorer.html#/), you will see the file "automl-tunner_2.12-1.0.jar" in it.

# Run the Spark application

```bash
# First open a pod with access to spark and hadoop
sudo kubectl exec -it spark-primary -- bash

# You can also see the content inside hadoop from here
hadoop fs -ls /

# Now tell spark to run our package
/usr/bin/time -v spark-submit --class org.apache.spark.examples.SparkPi \
    --master spark://spark-primary:7077 \
    --deploy-mode client \
    --conf spark.yarn.submit.waitAppCompletion=true \
    --conf spark.driver.host=`hostname -I` \
    --num-executors 1 \
    --driver-memory 1g \
    --executor-memory 1g \
    --executor-cores 1 \
    hdfs://hadoop-primary:9000/automl-tunner_2.12-1.0.jar \
        1000
```

Some details:

* **spark-submit** : the spark command used to start spark programs in Spark. It accepts both scala .jar and python .py files.
* **/usr/bin/time -v** : This is not necessary but prints detailed execution time. I think they are extremely useful.
* **--class org.apache.spark.examples.SparkPi** : The class with the main function to run. Our package has multiple classes, each for a different example.
* **--master spark://spark-primary:7077** : The spark master url
* **--deploy-mode client** : An spark application is divided into driver and workers. The mode "client" tells spark to run the driver on my local machine
* **--conf spark.yarn.submit.waitAppCompletion=true** : Wait for the app to finish and lock this terminal
* **--conf spark.driver.host=`hostname -I`** : By default, spark uses this machine's hostname when the worker nodes try to contact back the driver. This name is usually not available as docker dns does not resolve container names. This forces the workers to use its IP instead.
* **--num-executors 1** : Number of spark executors
* **--driver-memory 1g** : Restrict driver memory up to this size
* **--executor-memory 1g** : Restrict each executor memory up to this size
* **--executor-cores 1** : Each executor has up to one core
* **hdfs://hadoop-primary:9000/automl-tunner_2.12-1.0.jar** : The package we want to run
* **1000** : A list of parameters for our application, in this case it is just one

The correct output will contain a line with the estimation of PI, like

```bash
...
Pi is roughly 3.1415902341588566
...
```
