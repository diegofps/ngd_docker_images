#!/bin/sh

sudo kubectl delete -f primary.yaml &
sudo kubectl delete -f secondary_host.yaml &
sudo kubectl delete -f secondary_csd.yaml &
sudo kubectl delete -f primary_service.yaml &

wait

k3s_wait.sh end

echo "Done!"

