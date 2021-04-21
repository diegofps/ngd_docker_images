#!/bin/sh

if [ ! "$#" = "2" ]; then
  echo "SINTAX: $0 \"<SPARK_PARAMS>\" \"<PKG PARAMS>\""
  exit 1
fi

SPARK_PARAMS="$1"
PKG_PARAMS="$2"

ADDRESS=`hostname -I`

echo "$SPARK_PARAMS"
echo "$PKG_PARAMS"

/usr/bin/time -v spark-submit \
    --class br.com.wespa.ngd.spark.automl2.Tunner2 \
    --master spark://bigdata2-primary:7077 \
    --deploy-mode client \
    --conf spark.yarn.submit.waitAppCompletion=true \
    --conf spark.driver.host=${ADDRESS} \
    --num-executors 1 \
    --executor-cores 1 \
    $SPARK_PARAMS \
    hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar ${PKG_PARAMS}

