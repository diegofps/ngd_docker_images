#!/bin/sh


SIZE=$1
DIMS=$2
IDD=$3

if [ "$SIZE" = "" ]; then
  SIZE=1
fi

if [ "$DIMS" = "" ]; then
  DIMS=20
fi

if [ "$IDD" = "" ]; then
  IDD="generic"
fi

SAMPLES_CLASSIFICATION=$(( SIZE * 2500 ))
SAMPLES_REGRESSION=$(( SIZE * 10000 ))

NAME_CLASSIFICATION="classification_dataset_${IDD}"
NAME_REGRESSION="regression_dataset_${IDD}"


echo "Creating datasets"
ml_dataset_classification_create.py $SAMPLES_CLASSIFICATION $DIMS 2 0.25 2 "./${NAME_CLASSIFICATION}.csv"
ml_dataset_regression_create.py $DIMS 0.1 $SAMPLES_REGRESSION "./${NAME_REGRESSION}.csv"

echo "Converting datasets to libsvm format"
ml_dataset_csv2libsvm.py "./${NAME_CLASSIFICATION}.csv" "./${NAME_CLASSIFICATION}.libsvm"
ml_dataset_csv2libsvm.py "./${NAME_REGRESSION}.csv" "./${NAME_REGRESSION}.libsvm"

echo "Removing dataset in original format"
rm "${NAME_CLASSIFICATION}.csv"
rm "${NAME_REGRESSION}.csv"



