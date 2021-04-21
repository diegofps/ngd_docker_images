#!/bin/sh

MODE=$1

if [ "$MODE" = "csd" ]; then
  sudo echo "Deploying in csd mode"

  storage_clear.sh

  sudo kubectl create -f primary.yaml &
  sudo kubectl create -f secondary_csd.yaml &
  sudo kubectl create -f primary_service.yaml &

  wait
  k3s_wait.sh start

elif [ "$MODE" = "hybrid" ]; then
  sudo echo "Deploying in hybrid mode"

  storage_clear.sh

  sudo kubectl create -f primary.yaml &
  sudo kubectl create -f secondary_csd.yaml &
  sudo kubectl create -f secondary_host.yaml &
  sudo kubectl create -f primary_service.yaml &

  wait
  k3s_wait.sh start

elif [ "$MODE" = "host" ]; then
  sudo echo "Deploying in host mode"

  storage_clear.sh

  sudo kubectl create -f primary.yaml &
  sudo kubectl create -f secondary_host.yaml &
  sudo kubectl create -f primary_service.yaml &

  wait
  k3s_wait.sh start

else
  echo "Unknown deploy mode ($MODE). Options are: host, hybrid and csd"
  exit 1

fi

echo "Done!"

