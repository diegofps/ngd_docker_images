#!/bin/sh

if [ ! "$#" = "1" ]
then
  echo "SINTAX: $0 <MODEL>"
  exit 1
fi

MODEL=$1

SPARK_PARAMS="--driver-memory 4g --executor-memory 4g"

run()
{
    PARTITION_SIZE=$1
    
    echo "Running por partitionSize=$PARTITION_SIZE"

    VAL=$(sudo kubectl exec -it bigdata2-primary -- /app/run_single.sh "$SPARK_PARAMS"\
        "-dataset=hdfs://bigdata2-primary:9000/regression_dataset.libsvm \
         -appName=Multidataset -model=lr -partitionSize=${PARTITION_SIZE}" \
         | grep "Ellapsed time" | awk '{ print $3 }')

    echo "Ellapsed time for $PARTITION_SIZE was $VAL"
}

for i in 1 2 4 8 16 32 64 128 256 512 1024 2048
do
    run $i
done

echo "Done!"

