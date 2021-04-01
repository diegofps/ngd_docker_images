#!/bin/sh

################################################################################
# Extract hadoop
################################################################################

echo "Extracting spark..."
tar -xf spark-3.0.1-bin-hadoop3.2.tgz
mv spark-3.0.1-bin-hadoop3.2 /spark


################################################################################
# Configure Build
################################################################################

echo "Configuring spark..."

cat /spark/conf/log4j.properties.template | sed 's|log4j.rootCategory=INFO, console|log4j.rootCategory=WARN, console|' > /spark/conf/log4j.properties

cat /spark/conf/spark-env.sh.template | \
    sed 's|# - MKL_NUM_THREADS=1        |MKL_NUM_THREADS=1       # |' | \
    sed 's|# - OPENBLAS_NUM_THREADS=1   |OPENBLAS_NUM_THREADS=1  # |' > /spark/conf/spark-env.sh

#    | \
#sed 's|# - HADOOP_CONF_DIR, |HADOOP_CONF_DIR=/hadoop/etc/hadoop # |'

cat /spark/conf/spark-defaults.conf.template > /spark/conf/spark-defaults.conf && \
    echo "spark.shuffle.service.enabled true" >> /spark/conf/spark-defaults.conf && \
    echo "spark.dynamicAllocation.enabled true" >> /spark/conf/spark-defaults.conf && \
    echo "spark.dynamicAllocation.shuffleTracking.enabled true" >> /spark/conf/spark-defaults.conf
