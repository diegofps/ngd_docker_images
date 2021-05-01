#!/bin/sh


if [ ! "$#" = "3" ]; then
  echo "SINTAX: $0 <DS_SIZE> <MODEL> <OUTPUT>"
  exit 1
fi


DS_SIZE=$1
MODEL=$2
OUTPUT=$3

DIMS="30"
CLUSTERS="100"
NOISE="0.0"
LABELS="2"
JOB_SIZE="100000"


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
echo "EXEC_MEMORY_SIZE;ELLAPSED" > $OUTPUT


echo "Running for different memory sizes"
run()
{
    MEMORY=$1
    
    echo "Running por executor memory=$MEMORY"

    VAL=$(sudo kubectl exec -it spark-primary -- /app/run_single.sh "--driver-memory 4g --executor-memory $MEMORY" \
        "-dataset=hdfs://hadoop-primary:9000/regression.libsvm \
         -appName=Multidataset -model=$MODEL" \
         | grep "Ellapsed time" | awk '{ print $3 }')

    echo "Ellapsed time for $MEMORY was $VAL"
    echo "$MEMORY;$VAL" >> $OUTPUT
}

for i in 3072m
do
    run $i
done

echo "Done!"
