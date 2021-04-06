#!/bin/sh

echo "Creating dataset"
ml_dataset_classification_create.py 10000 30 5 0.25 2 ./classification_dataset.csv

echo "Converting dataset to libsvm format"
ml_dataset_csv2libsvm.py ./classification_dataset.csv ./classification_dataset.libsvm

echo "Removing dataset int original format"
rm classification_dataset.csv

echo "Copying the dataset to bigdata2-primary:app"
sudo kubectl cp ./classification_dataset.libsvm bigdata2-primary:/app/classification_dataset.libsvm

echo "Removing any previous dataset from hadoop"
sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /classification_dataset.libsvm

echo "Adding dataset to hadoop in /"
sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/classification_dataset.libsvm /classification_dataset.libsvm

echo "Displaying hadoop content in /"
sudo kubectl exec -it bigdata2-primary -- hadoop fs -ls /

