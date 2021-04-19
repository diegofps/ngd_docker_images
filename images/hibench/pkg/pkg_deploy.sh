#!/bin/sh

echo "\nRemoving old copies..."
sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /automl-tunner_2.12-1.0.jar
sudo kubectl exec -it bigdata2-primary -- rm /app/automl-tunner_2.12-1.0.jar

echo "\nSending new copies..."
sudo kubectl cp ./target/scala-2.12/automl-tunner_2.12-1.0.jar bigdata2-primary:/app
sudo kubectl cp ./run_hibench.sh bigdata2-primary:/app
sudo kubectl cp ./run_sparkpi.sh bigdata2-primary:/app
sudo kubectl cp ./run_automl.sh bigdata2-primary:/app
sudo kubectl cp ./run_single.sh bigdata2-primary:/app

sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/automl-tunner_2.12-1.0.jar hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar
sudo kubectl exec -it bigdata2-primary -- hdfs dfs -setrep 3 hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar

echo "\nDone!"
