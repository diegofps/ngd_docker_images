#!/bin/sh

if [ ! "$#" = "5" ]; then
  echo "SINTAX: $0 <TYPE=all|regression|classification> <EXEC_MEM=4g> <EXEC_CORES=4> <NUM_EXEC=16> <OUTPUT>"
  exit 1
fi

TYPE=$1
EXEC_MEM=$2
EXEC_CORES=$3
NUM_EXEC=$4
OUTPUT=$5
DRIVER_MEM=4g

run_benchmark()
{
    MODEL=$1
    REPETITIONS=$2
    THREADS=$3
    N=$4
    DS=$5
    
    echo
    echo "Starting benchmark for:"
    echo "\tMODEL: $MODEL"
    echo "\tREPETITIONS: $REPETITIONS"
    echo "\tTHREADS: $THREADS"
    echo "\tN: $N"
    echo "\tDS: $DS"

    SUM=0
    
    for i in `seq $N`
    do
        spark-submit --class br.com.wespa.ngd.spark.automl.Tunner2 \
          --master spark://bigdata2-primary:7077 \
          --deploy-mode client \
          --conf spark.yarn.submit.waitAppCompletion=true \
          --conf spark.driver.host=`hostname -I` \
          --driver-memory $DRIVER_MEM \
          --executor-memory $EXEC_MEM \
          --executor-cores $EXEC_CORES \
          --num-executors $NUM_EXEC \
          hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar \
            -m=$MODEL -r=$REPETITIONS -t=$THREADS -ds=$DS \
          | tee ./tmp.stdout
        
        ELLAPSED=$(cat ./tmp.stdout \
          | grep "Ellapsed time" \
          | awk '{ print $3 }')
        
        SUM=` python3 -c "print($SUM + $ELLAPSED)"`
        
        rm ./tmp.stdout
        
        echo "=== Iteration $i / $N took $ELLAPSED seconds ==="
    done
    
    AVG=` python3 -c "print($SUM / $N)"`
    
    echo "Average time for (MODEL=$MODEL, REPETITIONS=$REPETITIONS, THREADS=$THREADS, N=$N) was $AVG seconds"
    echo "$MODEL,$REPETITIONS,$THREADS,$AVG,$N" >> "$OUTPUT"
}

rm -f $OUTPUT

N=1
R=3
T=8


if [ "$TYPE" = "classification" -o "$TYPE" = "all" ]; then
  #DS="hdfs://bigdata2-primary:9000/classification.libsvm"
  DS="/classification.libsvm"

  run_benchmark kmeans 10 $T $N $DS
  run_benchmark lrc 20 $T $N $DS
  run_benchmark dtc 10 $T $N $DS
  run_benchmark rfc 4 $T $N $DS
  run_benchmark gbtc 5 $T $N $DS
  run_benchmark mlpc 5 $T $N $DS
  run_benchmark nbc 30 $T $N $DS
  run_benchmark fmc 5 $T $N $DS
  run_benchmark svc 5 $T $N $DS
fi


if [ "$TYPE" = "regression" -o "$TYPE" = "all" ]; then
  #DS="hdfs://bigdata2-primary:9000/regression.libsvm"
  DS="/regression.libsvm"

  run_benchmark lr 50 $T $N $DS
  run_benchmark dtr 25 $T $N $DS
  run_benchmark rfr 12 $T $N $DS
  #run_benchmark gbtr 10 $T $N $DS
  #run_benchmark fmr 15 $T $N $DS
fi

echo "Content of output file"
cat $OUTPUT
