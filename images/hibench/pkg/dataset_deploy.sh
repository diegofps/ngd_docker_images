#!/bin/sh

IDD=$1

if [ ! "$#" = "1" ]
then
  echo "SINTAX: $0 <IDD>"
  exit 1
fi

NAME="classification_dataset_${IDD}"

echo "Copying dataset $NAME to bigdata2-primary:app"
sudo kubectl cp ./${NAME}.libsvm bigdata2-primary:/app/classification_dataset.libsvm
sudo kubectl cp ./${NAME}.libsvm bigdata2-primary:/app/regression_dataset.libsvm

echo "Removing any previous dataset from hadoop"
sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /classification_dataset.libsvm
sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /regression_dataset.libsvm

echo "Adding dataset to hadoop in /"
sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/classification_dataset.libsvm /classification_dataset.libsvm
sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/regression_dataset.libsvm /regression_dataset.libsvm

echo "Removing the datasets from the container"
sudo kubectl exec -it bigdata2-primary -- rm /app/classification_dataset.libsvm
sudo kubectl exec -it bigdata2-primary -- rm /app/regression_dataset.libsvm

echo "Displaying hadoop content in /"
sudo kubectl exec -it bigdata2-primary -- hadoop fs -ls -h /

