# AutoML using Spark and Sklearn

This tutorial will help you run a basic AutoML using spark and sklearn. It will create a syntetic dataset, split it in train and test data, convert to numpy raw format and copy it to every node. Then, a pySpark application will evaluate multiple models on it using multiple parameters with the goal of finding the optimal model and its configuration. The benefit of this strategy over spark's ml lib is that each node evaluates a model localy, without much communication. The downside is that sklearn requires the entire dataset to be stored in the ram, making it not suitable for big data, wherease spark's ml lib is.

# Dependencies

1. [A configured k3s cluster](../k3s/k3s_main.md)
1. [A working hadoop + spark setup](./bigdata2_main.md)

# Configure your environment

```bash
# Install dependencies on the host
pip3 install sklearn p_tqdm numpy

# Install dependencies on every spark node
NODES=$(sudo kubectl get pods | grep "^spark-" | awk '{ print $1 }')

for NODE in $NODES
do
    sudo kubectl exec -it $NODE -- apt update
    sudo kubectl exec -it $NODE -- apt install python3-pip -y
    sudo kubectl exec -it $NODE -- pip3 install sklearn
done
```

# Generate a regression dataset and deploy it to every worker

```bash
# Access the AutoML folder
cd images/hibench/automl3

# Create a random dataset with approximately 622MB
ml_dataset_create.py 1000000 30 100  0.25 2 50000 regression ./regression.libsvm

# Convert from libsvm to .npy format. This will generate the files regression.x.npy and regression.y.npy, which are binary numpy data and much faster to load
ml_dataset_libsvm2npy.py ./regression

# Split it into train (0.7) and test data (0.3)
ml_dataset_split.py ./regression 0.7

# Send the files to every node, including spark-primary
k3s_deploy_file.sh "^spark-" ./regression.test.y.npy /app/regression.test.y.npy &
k3s_deploy_file.sh "^spark-" ./regression.test.x.npy /app/regression.test.x.npy &

k3s_deploy_file.sh "^spark-" ./regression.train.y.npy /app/regression.train.y.npy &
k3s_deploy_file.sh "^spark-" ./regression.train.x.npy /app/regression.train.x.npy &

wait

# Remove the temporary local files
rm regression.*
```

# Deploy and run your python application

```bash
# Access the AutoML folder, if are not there
cd images/hibench/automl3

# We recommend you disable swap
sudo swapoff -a

# Deploy it to spark-primary
sudo kubectl cp ./main.py spark-primary:/app/main.py
```

# Run the AutoML application inside spark-primary

```bash
# Access spark-primary
sudo kubectl exec -it spark-primary -- bash

# Run it using spark rdd to distribute the task over all nodes (distributed and parallel mode using spark)
export PYSPARK_PYTHON=python3 # Tell spark you want to use python3
/usr/bin/time -v spark-submit \
    --master "spark://spark-primary:7077" \
    --deploy-mode client \
    --conf spark.yarn.submit.waitAppCompletion=true \
    --conf spark.driver.host=`hostname -I` \
    --conf spark.driver.port=20002 \
    --num-executors 1 \
    --driver-memory 512m \
    --executor-memory 4g \
    --executor-cores 1 \
    "/app/main.py" \
        rdd /app/regression 10 lasso

# Run the same application using all cores in just the current node (parallel mode using multiprocessing)
export OPENBLAS_NUM_THREADS=1 # Configure openblas to disable parallelism, it will come from our multitask implementation
/usr/bin/time ./main.py \
    mp /app/regression 10 lasso `nproc`

# Run the same application using just a single processor (serial mode using just for)
export OPENBLAS_NUM_THREADS=1 # Configure openblas to disable parallelism
/usr/bin/time ./main.py \
    serial /app/regression 10 lasso
```

