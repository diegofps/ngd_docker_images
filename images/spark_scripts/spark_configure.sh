#!/bin/sh

################################################################################
# Extract hadoop
################################################################################

echo "Extracting spark..."
tar -xf /tmp/spark-3.1.1-bin-hadoop3.2.tgz
sudo mv spark-3.1.1-bin-hadoop3.2 /spark


################################################################################
# Configure Build
################################################################################

echo "Configuring spark..."

CORES=`nproc`

cat /spark/conf/log4j.properties.template | sed 's|log4j.rootCategory=INFO, console|log4j.rootCategory=WARN, console|' > /spark/conf/log4j.properties

cat /spark/conf/spark-env.sh.template | \
    sed 's|# - MKL_NUM_THREADS=1        |MKL_NUM_THREADS=1       # |' | \
    sed 's|# - OPENBLAS_NUM_THREADS=1   |OPENBLAS_NUM_THREADS=1  # |' | \
    sed "s|# - SPARK_WORKER_CORES, |SPARK_WORKER_CORES=$CORES # |" > /spark/conf/spark-env.sh

#    | \
#sed 's|# - HADOOP_CONF_DIR, |HADOOP_CONF_DIR=/hadoop/etc/hadoop # |'

cat /spark/conf/spark-defaults.conf.template > /spark/conf/spark-defaults.conf && \
    echo "spark.shuffle.service.enabled false" >> /spark/conf/spark-defaults.conf && \
    echo "spark.dynamicAllocation.enabled false" >> /spark/conf/spark-defaults.conf && \
    echo "spark.dynamicAllocation.shuffleTracking.enabled false" >> /spark/conf/spark-defaults.conf
