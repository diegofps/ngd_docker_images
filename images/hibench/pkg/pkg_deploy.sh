#!/bin/sh

TQDM_PATH=$(sudo kubectl exec -it bigdata2-primary -- which tqdm)

if [ "$TQDM_PATH" = "" ]; then
  echo "\nInstalling dependencies..."
  sudo kubectl exec -it bigdata2-primary -- apt update
  sudo kubectl exec -it bigdata2-primary -- apt install python3-pip -yq
  sudo kubectl exec -it bigdata2-primary -- pip3 install sklearn p_tqdm==1.3.3
fi

echo "\nRemoving old copies..."
sudo kubectl exec -it bigdata2-primary -- hadoop fs -rm /automl-tunner_2.12-1.0.jar
sudo kubectl exec -it bigdata2-primary -- rm /app/automl-tunner_2.12-1.0.jar

echo "\nSending new copies..."
sudo kubectl cp ./target/scala-2.12/automl-tunner_2.12-1.0.jar bigdata2-primary:/app
sudo kubectl cp ./run_hibench.sh bigdata2-primary:/app
sudo kubectl cp ./run_sparkpi.sh bigdata2-primary:/app
sudo kubectl cp ./run_automl.sh bigdata2-primary:/app
sudo kubectl cp ./run_single.sh bigdata2-primary:/app
sudo kubectl cp $(which ml_dataset_create.py) bigdata2-primary:/app

sudo kubectl exec -it bigdata2-primary -- hadoop fs -put /app/automl-tunner_2.12-1.0.jar hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar
sudo kubectl exec -it bigdata2-primary -- hdfs dfs -setrep 3 hdfs://bigdata2-primary:9000/automl-tunner_2.12-1.0.jar

echo "\nDone!"
