#!/bin/sh


if [ ! "$#" = 2 ]; then
  echo "SINTAX: $0 <MODE=hdfs|local> <OUTPUT>"
  exit 1
fi

MODE=$1
OUTPUT=$2

sudo echo "Starting multidataset experiment..."

ADDRESS=`sudo kubectl exec -it spark-primary -- hostname -I`
SPARK_PARAMS="--driver-memory 4g --executor-memory 2g"

if [ "$MODE" = "hdfs" ]; then
  DATASET="hdfs://hadoop-primary:9000/regression.libsvm"

elif [ "$MODE" = "local" ]; then
  DATASET="/app/regression.libsvm"

else
  echo "Invalid mode, options are: hdfs, local"
  exit 1

fi

run_benchmark_set()
{
  SAMPLES=$1

  ./dataset_create.sh $SAMPLES 30 $MODE regression

  if [ "$MODE" = "hdfs" ]; then
    DS_SIZE=`sudo kubectl exec -it hadoop-primary -- hadoop fs -ls -h / | grep regression.libsvm | awk '{ print $5 $6 }'`
  elif [ "$MODE" = "local" ]; then
    DS_SIZE=`sudo kubectl exec -it hadoop-primary -- ls -lh /app | grep regression.libsvm | awk '{ print $5 }'`
  else
    DS_ZIE="0"
  fi

  echo -n "$MODE;$SAMPLES;$DS_SIZE" >> $OUTPUT

  echo "Running lr..."
  VAL=$(sudo kubectl exec -it spark-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
      -dataset=$DATASET -appName=Multidataset -model=lr" | grep "Ellapsed time" | awk '{ print $3 }')
  echo -n ";$VAL" >> $OUTPUT

  echo "Starting dtr..."
  VAL=$(sudo kubectl exec -it spark-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
      -dataset=$DATASET -appName=Multidataset -model=dtr" | grep "Ellapsed time" | awk '{ print $3 }')
  echo -n ";$VAL" >> $OUTPUT

  echo "Starting rfr"
  VAL=$(sudo kubectl exec -it spark-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
      -dataset=$DATASET -appName=Multidataset -model=rfr" | grep "Ellapsed time" | awk '{ print $3 }')
  echo -n ";$VAL" >> $OUTPUT

  #echo "Starting gbtr..."
  #VAL=$(sudo kubectl exec -it spark-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
  #    -dataset=$DATASET -appName=Multidataset -model=gbtr" | grep "Ellapsed time" | awk '{ print $3 }')
  #echo -n ";$VAL" >> $OUTPUT

  echo "Starting fmr..."
  VAL=$(sudo kubectl exec -it spark-primary -- /app/run_single.sh "$SPARK_PARAMS" "\
      -dataset=$DATASET -appName=Multidataset -model=fmr" | grep "Ellapsed time" | awk '{ print $3 }')
  echo -n ";$VAL" >> $OUTPUT

  echo "" >> $OUTPUT

  echo "Finished analysis for SIZE=$SAMPLES"
}

echo "Building and deploying the pkg"
./pkg_build.sh
./pkg_deploy.sh


echo "Cleaning the output file"
echo "MODE;SAMPLES;DS_SIZE;lr;dtr;rfr;fmr" > $OUTPUT


echo "Starting multidataset regression analysis"
for i in 100 1000 10000 100000 1000000 10000000
do
  echo " --- Starting benchmark for size=$i --- "
  run_benchmark_set $i
  echo " --- Ended benchmark for size=$i --- "
done

echo "Showing Results"
cat $OUTPUT

echo "Done!"

