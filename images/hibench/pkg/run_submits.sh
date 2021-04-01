#!/bin/sh
  
MODEL=$1

if [ -z "$MODEL" ]; then
        echo "Syntax: $0 <MODEL>"
        exit 0
fi

mkdir -p ./results

for R in 10 25 50 100 200 400
do
    echo "\n === Running for R=${R} ==="
    /usr/bin/time spark-submit --class br.com.wespa.ngd.spark.parametertunning.Tunner2 \
        --master spark://bigdata2-primary:7077 \
        --deploy-mode client \
        --conf spark.yarn.submit.waitAppCompletion=true \
        --conf spark.driver.port=20002 \
        --conf spark.driver.host=`hostname -I` \
        --num-executors 1 \
        --driver-memory 2g \
        --executor-memory 512m \
        --executor-cores 1 \
        hdfs://bigdata2-primary:9000/automl-hyperparameter-tunner_2.12-1.0.jar \
            -ds=/spark/data/mllib/sample_libsvm_data.txt \
            -m=${MODEL} \
            -r=${R} \
            -t=16 \
        2>&1 > results/${MODEL}_${R}.out
done

