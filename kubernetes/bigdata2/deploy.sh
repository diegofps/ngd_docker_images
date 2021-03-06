#!/bin/sh

if [ ! "$#" = 1 ]; then
  echo "SINTAX: $0 <MODE=hybrid|host|csd>"
  exit 1
fi

MODE=$1

if [ "$MODE" = "csd" ]; then
  sudo echo "Deploying in csd mode"

  storage_clear.sh

  sudo kubectl create -f hadoop_service.yaml &
  sudo kubectl create -f hadoop_primary.yaml &
  sudo kubectl create -f hadoop_worker_csd.yaml &
  
  sudo kubectl create -f spark_service.yaml &
  sudo kubectl create -f spark_primary.yaml &
  sudo kubectl create -f spark_worker_csd.yaml &

  wait
  k3s_wait.sh start


elif [ "$MODE" = "hybrid" ]; then
  sudo echo "Deploying in hybrid mode"

  storage_clear.sh

  sudo kubectl create -f hadoop_service.yaml &
  sudo kubectl create -f hadoop_primary.yaml &
  sudo kubectl create -f hadoop_worker_csd.yaml &
  sudo kubectl create -f hadoop_worker_host.yaml &
  
  sudo kubectl create -f spark_service.yaml &
  sudo kubectl create -f spark_primary.yaml &
  sudo kubectl create -f spark_worker_csd.yaml &
  sudo kubectl create -f spark_worker_host.yaml &

  wait
  k3s_wait.sh start


elif [ "$MODE" = "host" ]; then
  sudo echo "Deploying in host mode"

  storage_clear.sh

  sudo kubectl create -f hadoop_service.yaml &
  sudo kubectl create -f hadoop_primary.yaml &
  sudo kubectl create -f hadoop_worker_host.yaml &
  
  sudo kubectl create -f spark_service.yaml &
  sudo kubectl create -f spark_primary.yaml &
  sudo kubectl create -f spark_worker_host.yaml &

  wait
  k3s_wait.sh start


else
  echo "Unknown deploy mode ($MODE). Options are: host, hybrid and csd"
  exit 1

fi

echo "Done!"

