#!/bin/sh


if [ "$1" = "" ]
then
  OUTPUT="./SparkPI_results.csv"
else
  OUTPUT=$1
fi


run_benchmark()
{
    N=$1
    
    SUM=0
    
    for i in `seq $N`
    do
        START=`date +%s`
        /usr/bin/time -v spark-submit --class org.apache.spark.examples.SparkPi \
            --master spark://bigdata2-primary:7077 \
            --deploy-mode client \
            --conf spark.yarn.submit.waitAppCompletion=true \
            --conf spark.driver.host=`hostname -I` \
            --num-executors 1 \
            --driver-memory 1g \
            --executor-memory 1g \
            --executor-cores 1 \
            hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar 1000

        END=`date +%s`
        
        ELLAPSED=$(( $END - $START ))
        SUM=$(( $SUM + $ELLAPSED ))
        
        echo "=== Iteration $i / $N took $ELLAPSED seconds ==="
    done
    
    AVG=$(( $SUM / $N ))
    echo "Average time for SparkPI (N=$N) was $AVG seconds"
    echo "SparkPI,$N,$AVG" >> "$OUTPUT"
}

rm -f $OUTPUT

N=5

run_benchmark $N 
