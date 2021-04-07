#!/bin/sh

echo "Creating datasets"
ml_dataset_classification_create.py 5000 30 2 0.25 2 ./classification_dataset.csv
ml_dataset_regression_create.py 10 0.1 5000 ./regression_dataset.csv

echo "Converting datasets to libsvm format"
ml_dataset_csv2libsvm.py ./classification_dataset.csv ./classification_dataset.libsvm
ml_dataset_csv2libsvm.py ./regression_dataset.csv ./regression_dataset.libsvm

echo "Removing dataset int original format"
rm classification_dataset.csv
rm regression_dataset.csv

