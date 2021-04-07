#!/bin/sh

if [ "$1" = "" ]
then
  OUTPUT="./hibench_results.csv"
else
  OUTPUT=$1
fi


run_benchmark()
{
    IDD=$1
    NAME=$2
    SIZE=$3
    N=$4

    cat /hibench/conf/hibench.conf | sed "s/\(hibench.scale.profile\s\+\)[a-z]\+/\1$SIZE/" > ./tmp && mv ./tmp /hibench/conf/hibench.conf
    /hibench/bin/workloads/ml/$IDD/prepare/prepare.sh

    SUM=0

    for i in `seq $N`
    do
        START=`date +%s`

        /hibench/bin/workloads/ml/$IDD/spark/run.sh

        END=`date +%s`
        ELLAPSED=$(( $END - $START ))
        SUM=$(( $SUM + $ELLAPSED ))

        echo "=== Iteration $i / $N took $ELLAPSED seconds ==="
    done

    AVG=$(( $SUM / $N ))
    echo "Average time for (IDD=$IDD, NAME=$NAME, SIZE=$SIZE, N=$N) was $AVG seconds"
    echo "$IDD,$NAME,$SIZE,$AVG" >> "$OUTPUT"

    hadoop fs -rm -r -f /HiBench/$NAME
}


rm -f $OUTPUT

N=10
run_benchmark bayes Bayes gigantic $N
run_benchmark kmeans Kmeans large $N
run_benchmark gmm GMM large $N
run_benchmark lr LR small $N
run_benchmark als ALS bigdata $N
run_benchmark gbt GBT gigantic $N
#run_benchmark xgboost XGBoost huge $N
run_benchmark linear Linear small $N
run_benchmark lda LDA small $N
run_benchmark pca PCA large $N
run_benchmark rf RF large $N
run_benchmark svm SVM small $N
run_benchmark svd SVD large $N
