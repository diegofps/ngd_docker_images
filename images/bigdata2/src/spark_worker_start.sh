#!/bin/sh

if [ "$SPARK_CORE_MULTIPLIER" = "" ]; then
    CORES=$(( `nproc` ))
else
    CORES=$(( `nproc` * $SPARK_CORE_MULTIPLIER ))
    if [ "$CORES" = "0" ]; then
        CORES=`nproc`
    fi
fi

echo "Configuraing spark with $CORES worker cores"
cat /spark/conf/spark-env.sh | sed "s:# - SPARK_WORKER_CORES, :SPARK_WORKER_CORES=$CORES # :" > ./tmp && mv ./tmp /spark/conf/spark-env.sh
/spark/sbin/start-slave.sh spark://spark-primary:7077

echo "Spark worker started"
