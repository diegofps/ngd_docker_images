#!/bin/sh

if [ "$1" = "" ]
then
  OUTPUT="./automl_results.csv"
else
  OUTPUT=$1
fi

if [ "$2" = "" ]
then
  GROUP="all"
else
  GROUP=$2
fi

run_benchmark()
{
    MODEL=$1
    REPETITIONS=$2
    THREADS=$3
    N=$4
    DS=$5
    MEM=$6
    
    SUM=0
    
    if [ "$MEM" = "" ]
    then
        MEM="1g"
    fi


    for i in `seq $N`
    do
        START=`date +%s`
        /usr/bin/time -v spark-submit --class br.com.wespa.ngd.spark.automl.Tunner2 \
            --master spark://bigdata2-primary:7077 \
            --deploy-mode client \
            --conf spark.yarn.submit.waitAppCompletion=true \
            --conf spark.driver.host=`hostname -I` \
            --driver-memory $MEM \
            --executor-memory $MEM \
            --executor-cores 1 \
            --num-executors 1 \
            hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar \
                 -m=$MODEL -r=$REPETITIONS -t=$THREADS -ds=$DS
        END=`date +%s`
        
        ELLAPSED=$(( $END - $START ))
        SUM=$(( $SUM + $ELLAPSED ))
        
        echo "=== Iteration $i / $N took $ELLAPSED seconds ==="
    done
    
    AVG=$(( $SUM / $N ))
    echo "Average time for (MODEL=$MODEL, REPETITIONS=$REPETITIONS, THREADS=$THREADS, N=$N) was $AVG seconds"
    echo "$MODEL,$REPETITIONS,$THREADS,$AVG,$N" >> "$OUTPUT"
}

rm -f $OUTPUT

N=4
R=5
T=8


if [ "$GROUP" = "clustering" -o "$GROUP" = "all" ]; then
  DS="hdfs://bigdata2-primary:9000/classification_dataset.libsvm"
  run_benchmark kmeans 10 $T $N $DS
fi


if [ "$GROUP" = "classification" -o "$GROUP" = "all" ]; then
  DS="hdfs://bigdata2-primary:9000/classification_dataset.libsvm"
  run_benchmark lrc 20 $T $N $DS
  run_benchmark dtc 10 $T $N $DS
  run_benchmark rfc 4 $T $N $DS
  run_benchmark gbtc 5 $T $N $DS
  run_benchmark mlpc 5 $T $N $DS 1g
  run_benchmark nbc 30 $T $N $DS
  run_benchmark fmc 5 $T $N $DS 1g
  run_benchmark svc 5 $T $N $DS
fi


if [ "$GROUP" = "regression" -o "$GROUP" = "all" ]; then
  DS="hdfs://bigdata2-primary:9000/regression_dataset.libsvm"
  run_benchmark nbc 30 $T $N $DS
  run_benchmark fmc 5 $T $N $DS 1g
  run_benchmark svc 5 $T $N $DS
fi

