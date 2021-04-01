#!/bin/sh
  
echo "\nRunning bayes"
/hibench/bin/workloads/ml/bayes/spark/run.sh

echo "\nRunning rf"
/hibench/bin/workloads/ml/rf/spark/run.sh

echo "\nRunning xgboost"
/hibench/bin/workloads/ml/xgboost/spark/run.sh

echo "\nRunning linear regression"
/hibench/bin/workloads/ml/linear/spark/run.sh

echo "\nRunning logistic regression"
/hibench/bin/workloads/ml/lr/spark/run.sh

echo "\nRunning SVM"
/hibench/bin/workloads/ml/svm/spark/run.sh

echo "\nRunning kmeans"
/hibench/bin/workloads/ml/kmeans/spark/run.sh

echo "\nDone!"

