#!/bin/sh


if [ ! "$#" = "3" ]; then
  echo "SINTAX: $0 <SAMPLES> <DIMS> <MODE=hdfs|local>"
  exit 1
fi

SAMPLES=$1
DIMS=$2
MODE=$3
CLUSTERS="100"
NOISE="0.2"
LABELS=2
JOB_SIZE="50000"


if [ "$MODE" = "hdfs" ]
then
  echo "Deploying in hdfs mode"

  echo "Deploying ml_dataset_create.py to bigdata2-primary"
  sudo kubectl cp `which ml_dataset_create.py` bigdata2-primary:/app/ml_dataset_create.py


  echo "Creating classification dataset"
  sudo kubectl exec -it bigdata2-primary -- /app/ml_dataset_create.py \
	  $SAMPLES $DIMS $CLUSTERS $NOISE $LABELS $JOB_SIZE classification /app/classification.libsvm

  echo "Deploying classification dataset to hdfs"
  sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /classification.libsvm
  sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/classification.libsvm /

  echo "Removing classification dataset from local container folder"
  sudo kubectl exec -it bigdata2-primary -- rm /app/classification.libsvm
  

  echo "Creating regression dataset"
  sudo kubectl exec -it bigdata2-primary -- /app/ml_dataset_create.py \
          $SAMPLES $DIMS $CLUSTERS $NOISE $LABELS $JOB_SIZE regression /app/regression.libsvm

  echo "Deploying regression dataset to hdfs"
  sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /regression.libsvm
  sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/regression.libsvm /

  echo "Removing regression dataset from local container folder"
  sudo kubectl exec -it bigdata2-primary -- rm /app/regression.libsvm


  echo "Displaying hdfs content"
  sudo kubectl exec -it bigdata2-primary -- hadoop fs -ls -h /


elif [ "$MODE" = "local" ]
then
  echo "Deploying in local mode."


  echo "Creating classification dataset"
  ml_dataset_create.py $SAMPLES $DIMS $CLUSTERS $NOISE $LABELS $JOB_SIZE classification ./classification.libsvm

  echo "Deploying classification dataset to all worker nodes"
  ./deploy_file.sh bigdata2-secondary ./classification.libsvm /app/classification.libsvm

  echo "Removing classification dataset from local folder"
  rm ./classification.libsvm


  echo "Creating regression dataset"
  ml_dataset_create.py $SAMPLES $DIMS $CLUSTERS $NOISE $LABELS $JOB_SIZE regression ./regression.libsvm

  echo "Deploying regression dataset to all worker nodes"
  ./deploy_file.sh bigdata2-secondary ./regression.libsvm /app/regression.libsvm

  echo "Removing regression dataset from local folder"
  rm ./regression.libsvm


else
  echo "Invalid mode, options: local, hdfs"
  exit 1


fi

