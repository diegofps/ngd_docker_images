#!/bin/sh

TQDM_PATH=$(sudo kubectl exec -it hadoop-primary -- which tqdm)

if [ "$TQDM_PATH" = "" ]; then
  echo "\nInstalling dependencies..."
  sudo kubectl exec -it hadoop-primary -- apt update
  sudo kubectl exec -it hadoop-primary -- apt install python3-pip -yq
  sudo kubectl exec -it hadoop-primary -- pip3 install sklearn p_tqdm==1.3.3
fi

echo "\nRemoving old copies..."
sudo kubectl exec -it hadoop-primary -- hadoop fs -rm /automl-tunner_2.12-1.0.jar
sudo kubectl exec -it hadoop-primary -- rm /app/automl-tunner_2.12-1.0.jar

echo "\nSending new copies..."
sudo kubectl cp $(which ml_dataset_create.py) hadoop-primary:/app
sudo kubectl cp ./target/scala-2.12/automl-tunner_2.12-1.0.jar hadoop-primary:/app
sudo kubectl cp ./run_hibench.sh spark-primary:/app
sudo kubectl cp ./run_sparkpi.sh spark-primary:/app
sudo kubectl cp ./run_automl.sh spark-primary:/app
sudo kubectl cp ./run_single.sh spark-primary:/app

sudo kubectl exec -it hadoop-primary -- hadoop fs -put /app/automl-tunner_2.12-1.0.jar hdfs://hadoop-primary:9000/automl-tunner_2.12-1.0.jar
sudo kubectl exec -it hadoop-primary -- hdfs dfs -setrep 3 hdfs://hadoop-primary:9000/automl-tunner_2.12-1.0.jar

echo "\nDone!"
