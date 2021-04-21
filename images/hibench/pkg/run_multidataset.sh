#!/bin/sh


#if [ ! `whoami` = 'root' ]
#then
#  echo "You should run this script as root, aborting"
#  exit 0
#fi


OUTPUT=$1

if [ "$OUTPUT" = "" ]
then
  OUTPUT="./multidataset.csv"
fi


sudo echo "Starting multidataset experiment..."

ADDRESS=`sudo kubectl exec -it bigdata2-primary -- hostname -I`
SPARK_PARAMS="--driver-memory 4g --executor-memory 4g"

run_benchmark_set()
{
  SIZE=$1

  ./dataset_build.sh $SIZE 30 $SIZE
  ./dataset_deploy.sh $SIZE

  rm -rf classification_dataset_${SIZE}.libsvm
  rm -rf regression_dataset_${SIZE}.libsvm

  echo -n "$SIZE" >> $OUTPUT

  echo "Running lr..."
  VAL=$(sudo kubectl exec -it bigdata2-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
      -dataset=hdfs://bigdata2-primary:9000/regression_dataset.libsvm \
      -appName=Multidataset -model=lr" | grep "Ellapsed time" | awk '{ print $3 }')
  echo -n ";$VAL" >> $OUTPUT

  echo "Starting dtr..."
  VAL=$(sudo kubectl exec -it bigdata2-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
      -dataset=hdfs://bigdata2-primary:9000/regression_dataset.libsvm \
      -appName=Multidataset -model=dtr" | grep "Ellapsed time" | awk '{ print $3 }')
  echo -n ";$VAL" >> $OUTPUT

  echo "Starting rfr"
  VAL=$(sudo kubectl exec -it bigdata2-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
      -dataset=hdfs://bigdata2-primary:9000/regression_dataset.libsvm \
      -appName=Multidataset -model=rfr" | grep "Ellapsed time" | awk '{ print $3 }')
  echo -n ";$VAL" >> $OUTPUT

  #echo "Starting gbtr..."
  #VAL=$(sudo kubectl exec -it bigdata2-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
  #    -dataset=hdfs://bigdata2-primary:9000/regression_dataset.libsvm \
  #    -appName=Multidataset -model=gbtr" | grep "Ellapsed time" | awk '{ print $3 }')
  #echo -n ";$VAL" >> $OUTPUT

  echo "Starting fmr..."
  VAL=$(sudo kubectl exec -it bigdata2-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
      -dataset=hdfs://bigdata2-primary:9000/regression_dataset.libsvm \
      -appName=Multidataset -model=fmr" | grep "Ellapsed time" | awk '{ print $3 }')
  echo -n ";$VAL" >> $OUTPUT

  echo "" >> $OUTPUT

  echo "Finished analysis for SIZE=$SIZE"
}

echo "Building and deploying the pkg"
./pkg_build.sh
./pkg_deploy.sh


echo "Cleaning the output file"
echo "SIZE;lr;dtr;rfr;fmr" > $OUTPUT


echo "Starting multidataset regression analysis"
for i in 1 10 100 1000 10000 
do
  echo " --- Starting benchmark for size=$i --- "
  run_benchmark_set $i
  echo " --- Ended benchmark for size=$i --- "
done

echo "Results"
cat $OUTPUT

echo "Done!"

