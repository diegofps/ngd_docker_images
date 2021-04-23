#!/bin/sh


if [ ! "$#" = "1" ]
then
  echo "SINTAX: $0 <DS_SIZE>"
  exit 1
fi


DS_SIZE=$1
MODEL=dtr
DIMS="30"
CLUSTERS="100"
NOISE="0.0"
LABELS="2"
JOB_SIZE="100000"
SPARK_PARAMS="--driver-memory 4g --executor-memory 4g"
OUTPUT="repartition.csv"


echo "Building and deploying the pkg"
./pkg_build.sh
./pkg_deploy.sh


echo "Deploying ml_dataset_create.py to bigdata2-primary"
sudo kubectl cp `which ml_dataset_create.py` bigdata2-primary:/app/ml_dataset_create.py


echo "Creating dataset"
#sudo kubectl exec -it bigdata2-primary -- /app/ml_dataset_create.py \
#    $DS_SIZE $DIMS $CLUSTERS $NOISE $LABELS $JOB_SIZE \
#    classification ./classification.libsvm

sudo kubectl exec -it bigdata2-primary -- /app/ml_dataset_create.py \
    $DS_SIZE $DIMS $CLUSTERS $NOISE $LABELS $JOB_SIZE \
    regression ./regression.libsvm


echo "Deploying dataset to hdfs"
#sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /classification.libsvm
#sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/classification.libsvm /

sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /regression.libsvm
sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/regression.libsvm /


echo "Clearing output file"
echo "PARTITIONS;ELLAPSED" > $OUTPUT


echo "Running for different partition sizes"
run()
{
    PARTITIONS=$1
    
    echo "Running por partitionSize=$PARTITIONS"

    VAL=$(sudo kubectl exec -it bigdata2-primary -- /app/run_single.sh "$SPARK_PARAMS" \
        "-dataset=hdfs://bigdata2-primary:9000/regression.libsvm \
         -appName=Multidataset -model=lr -numPartitions=${PARTITIONS}" \
         | grep "Ellapsed time" | awk '{ print $3 }')

    echo "Ellapsed time for $PARTITIONS was $VAL"
    echo "$PARTITIONS;$VAL" >> $OUTPUT
}

for i in 1 2 4 8 16 32 64 128 256 512 1024 2048
do
    run $i
done

echo "Done!"
