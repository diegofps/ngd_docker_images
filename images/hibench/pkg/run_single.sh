#!/bin/sh

PARAMS="$1"
ADDRESS=`hostname -I`

/usr/bin/time -v spark-submit \
    --class br.com.wespa.ngd.spark.automl2.Tunner2 \
    --master spark://bigdata2-primary:7077 \
    --deploy-mode client \
    --conf spark.yarn.submit.waitAppCompletion=true \
    --conf spark.driver.host=${ADDRESS} \
    --num-executors 1 \
    --driver-memory 1g \
    --executor-memory 1g \
    --executor-cores 1 \
    hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar ${PARAMS}

