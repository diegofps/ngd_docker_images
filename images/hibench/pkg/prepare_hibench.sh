#!/bin/sh

cat /hibench/conf/workloads/ml/lr.conf | sed 's/\(hibench.lr.[a-z]\+.features\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/lr.conf
cat /hibench/conf/workloads/ml/lr.conf | sed 's/\(hibench.lr.tiny.examples\s\+\)[0-9]\+/\1100/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/lr.conf
cat /hibench/conf/workloads/ml/lr.conf | sed 's/\(hibench.lr.small.examples\s\+\)[0-9]\+/\11000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/lr.conf
cat /hibench/conf/workloads/ml/lr.conf | sed 's/\(hibench.lr.large.examples\s\+\)[0-9]\+/\110000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/lr.conf
cat /hibench/conf/workloads/ml/lr.conf | sed 's/\(hibench.lr.huge.examples\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/lr.conf
cat /hibench/conf/workloads/ml/lr.conf | sed 's/\(hibench.lr.gigantic.examples\s\+\)[0-9]\+/\11000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/lr.conf
cat /hibench/conf/workloads/ml/lr.conf | sed 's/\(hibench.lr.bigdata.examples\s\+\)[0-9]\+/\110000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/lr.conf

cat /hibench/conf/workloads/ml/svm.conf | sed 's/\(hibench.svm.[a-z]\+.features\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/svm.conf
cat /hibench/conf/workloads/ml/svm.conf | sed 's/\(hibench.svm.tiny.examples\s\+\)[0-9]\+/\1100/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/svm.conf
cat /hibench/conf/workloads/ml/svm.conf | sed 's/\(hibench.svm.small.examples\s\+\)[0-9]\+/\11000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/svm.conf
cat /hibench/conf/workloads/ml/svm.conf | sed 's/\(hibench.svm.large.examples\s\+\)[0-9]\+/\110000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/svm.conf
cat /hibench/conf/workloads/ml/svm.conf | sed 's/\(hibench.svm.huge.examples\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/svm.conf
cat /hibench/conf/workloads/ml/svm.conf | sed 's/\(hibench.svm.gigantic.examples\s\+\)[0-9]\+/\11000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/svm.conf
cat /hibench/conf/workloads/ml/svm.conf | sed 's/\(hibench.svm.bigdata.examples\s\+\)[0-9]\+/\110000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/svm.conf

cat /hibench/conf/workloads/ml/linear.conf | sed 's/\(hibench.linear.[a-z]\+.features\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/linear.conf
cat /hibench/conf/workloads/ml/linear.conf | sed 's/\(hibench.linear.tiny.examples\s\+\)[0-9]\+/\1100/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/linear.conf
cat /hibench/conf/workloads/ml/linear.conf | sed 's/\(hibench.linear.small.examples\s\+\)[0-9]\+/\11000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/linear.conf
cat /hibench/conf/workloads/ml/linear.conf | sed 's/\(hibench.linear.large.examples\s\+\)[0-9]\+/\110000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/linear.conf
cat /hibench/conf/workloads/ml/linear.conf | sed 's/\(hibench.linear.huge.examples\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/linear.conf
cat /hibench/conf/workloads/ml/linear.conf | sed 's/\(hibench.linear.gigantic.examples\s\+\)[0-9]\+/\11000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/linear.conf
cat /hibench/conf/workloads/ml/linear.conf | sed 's/\(hibench.linear.bigdata.examples\s\+\)[0-9]\+/\110000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/linear.conf

cat /hibench/conf/workloads/ml/rf.conf | sed 's/\(hibench.rf.[a-z]\+.features\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/rf.conf
cat /hibench/conf/workloads/ml/rf.conf | sed 's/\(hibench.rf.tiny.examples\s\+\)[0-9]\+/\1100/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/rf.conf
cat /hibench/conf/workloads/ml/rf.conf | sed 's/\(hibench.rf.small.examples\s\+\)[0-9]\+/\11000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/rf.conf
cat /hibench/conf/workloads/ml/rf.conf | sed 's/\(hibench.rf.large.examples\s\+\)[0-9]\+/\110000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/rf.conf
cat /hibench/conf/workloads/ml/rf.conf | sed 's/\(hibench.rf.huge.examples\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/rf.conf
cat /hibench/conf/workloads/ml/rf.conf | sed 's/\(hibench.rf.gigantic.examples\s\+\)[0-9]\+/\11000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/rf.conf
cat /hibench/conf/workloads/ml/rf.conf | sed 's/\(hibench.rf.bigdata.examples\s\+\)[0-9]\+/\110000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/rf.conf

cat /hibench/conf/workloads/ml/xgboost.conf | sed 's/\(hibench.xgboost.[a-z]\+.features\s\+\)[0-9]\+/\11000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/xgboost.conf
cat /hibench/conf/workloads/ml/xgboost.conf | sed 's/\(hibench.xgboost.tiny.examples\s\+\)[0-9]\+/\1100/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/xgboost.conf
cat /hibench/conf/workloads/ml/xgboost.conf | sed 's/\(hibench.xgboost.small.examples\s\+\)[0-9]\+/\11000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/xgboost.conf
cat /hibench/conf/workloads/ml/xgboost.conf | sed 's/\(hibench.xgboost.large.examples\s\+\)[0-9]\+/\110000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/xgboost.conf
cat /hibench/conf/workloads/ml/xgboost.conf | sed 's/\(hibench.xgboost.huge.examples\s\+\)[0-9]\+/\1100000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/xgboost.conf
cat /hibench/conf/workloads/ml/xgboost.conf | sed 's/\(hibench.xgboost.gigantic.examples\s\+\)[0-9]\+/\11000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/xgboost.conf
cat /hibench/conf/workloads/ml/xgboost.conf | sed 's/\(hibench.xgboost.bigdata.examples\s\+\)[0-9]\+/\110000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/xgboost.conf

cat /hibench/conf/workloads/ml/bayes.conf | sed 's/\(hibench.bayes.bigdata.pages\s\+\)[0-9]\+/\15000000/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/bayes.conf
cat /hibench/conf/workloads/ml/bayes.conf | sed 's/\(hibench.bayes.bigdata.classes\s\+\)[0-9]\+/\1100/' > ./tmp && mv ./tmp /hibench/conf/workloads/ml/bayes.conf


echo "tiny"
cat /hibench/conf/hibench.conf | sed 's/\(hibench.scale.profile\s\+\)[a-z]\+/\1tiny/' > ./tmp && mv ./tmp /hibench/conf/hibench.conf



echo "small"
cat /hibench/conf/hibench.conf | sed 's/\(hibench.scale.profile\s\+\)[a-z]\+/\1small/' > ./tmp && mv ./tmp /hibench/conf/hibench.conf



echo "large"
cat /hibench/conf/hibench.conf | sed 's/\(hibench.scale.profile\s\+\)[a-z]\+/\1large/' > ./tmp && mv ./tmp /hibench/conf/hibench.conf

/hibench/bin/workloads/ml/lr/prepare/prepare.sh
/hibench/bin/workloads/ml/svm/prepare/prepare.sh
/hibench/bin/workloads/ml/linear/prepare/prepare.sh
/hibench/bin/workloads/ml/rf/prepare/prepare.sh

echo "huge"
cat /hibench/conf/hibench.conf | sed 's/\(hibench.scale.profile\s\+\)[a-z]\+/\1huge/' > ./tmp && mv ./tmp /hibench/conf/hibench.conf


/hibench/bin/workloads/ml/xgboost/prepare/prepare.sh
/hibench/bin/workloads/ml/kmeans/prepare/prepare.sh

echo "gigantic"
cat /hibench/conf/hibench.conf | sed 's/\(hibench.scale.profile\s\+\)[a-z]\+/\1gigantic/' > ./tmp && mv ./tmp /hibench/conf/hibench.conf


echo "bigdata"
cat /hibench/conf/hibench.conf | sed 's/\(hibench.scale.profile\s\+\)[a-z]\+/\1bigdata/' > ./tmp && mv ./tmp /hibench/conf/hibench.conf
/hibench/bin/workloads/ml/bayes/prepare/prepare.sh

