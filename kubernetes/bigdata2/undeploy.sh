#!/bin/sh

sudo kubectl delete -f hadoop_primary.yaml &
sudo kubectl delete -f hadoop_worker_csd.yaml &
sudo kubectl delete -f hadoop_worker_host.yaml &
sudo kubectl delete -f hadoop_service.yaml &

sudo kubectl delete -f spark_primary.yaml &
sudo kubectl delete -f spark_worker_csd.yaml &
sudo kubectl delete -f spark_worker_host.yaml &
sudo kubectl delete -f spark_service.yaml &

wait

k3s_wait.sh end

echo "Done!"
