#!/bin/sh

CORES=$(( `nproc` * 2 ))
cat /spark/conf/spark-env.sh | sed "s:# - SPARK_WORKER_CORES, :SPARK_WORKER_CORES=$CORES # :" > ./tmp && mv ./tmp /spark/conf/spark-env.sh
/spark/sbin/start-slave.sh spark://bigdata2-primary:7077

echo "Spark worker started"
