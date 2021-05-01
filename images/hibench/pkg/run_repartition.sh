#!/bin/sh


if [ ! "$#" = "2" ]
then
  echo "SINTAX: $0 <DS_SIZE> <OUTPUT>"
  exit 1
fi


DS_SIZE=$1
OUTPUT=$2
MODEL=dtr
DIMS="30"
CLUSTERS="100"
NOISE="0.0"
LABELS="2"
JOB_SIZE="100000"
SPARK_PARAMS="--driver-memory 4g --executor-memory 2g"


echo "Building and deploying the pkg"
./pkg_build.sh
./pkg_deploy.sh


if [ ! "$DS_SIZE" = "0" ]; then

  echo "Deploying ml_dataset_create.py to hadoop-primary"
  sudo kubectl cp `which ml_dataset_create.py` hadoop-primary:/app/ml_dataset_create.py


  echo "Creating dataset"
  #sudo kubectl exec -it hadoop-primary -- /app/ml_dataset_create.py \
  #    $DS_SIZE $DIMS $CLUSTERS $NOISE $LABELS $JOB_SIZE \
  #    classification ./classification.libsvm
  
  sudo kubectl exec -it hadoop-primary -- /app/ml_dataset_create.py \
      $DS_SIZE $DIMS $CLUSTERS $NOISE $LABELS $JOB_SIZE \
      regression ./regression.libsvm
  
  
  echo "Deploying dataset to hdfs"
  #sudo kubectl exec -it hadoop-primary -- hadoop fs -rm /classification.libsvm
  #sudo kubectl exec -it hadoop-primary -- hadoop fs -put /app/classification.libsvm /
  
  sudo kubectl exec -it hadoop-primary -- hadoop fs -rm /regression.libsvm
  sudo kubectl exec -it hadoop-primary -- hadoop fs -put /app/regression.libsvm /

fi


echo "Clearing output file"
echo "PARTITIONS;ELLAPSED" > $OUTPUT


echo "Running for different partition sizes"
run()
{
    PARTITIONS=$1
    
    echo "Running por partitionSize=$PARTITIONS"

    VAL=$(sudo kubectl exec -it spark-primary -- /app/run_single.sh "$SPARK_PARAMS" \
        "-dataset=hdfs://hadoop-primary:9000/regression.libsvm \
         -appName=Multidataset -model=lr -numPartitions=${PARTITIONS}" \
         | grep "Ellapsed time" | awk '{ print $3 }')

    echo "Ellapsed time for $PARTITIONS was $VAL"
    echo "$PARTITIONS;$VAL" >> $OUTPUT
}

for i in 0 
do
    run $i
done

echo "Done!"
