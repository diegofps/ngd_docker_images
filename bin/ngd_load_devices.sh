#!/bin/sh

echo "WARNING: A NEW IMAGE WILL BE WRITTEN ON EVERY DEVICE! YOU HAVE 5 SECONDS TO CANCEL THIS OPERATION (CTRL+C)" 

k3s_wait.sh counter 5

sudo echo "Starting parallel load_insitu..."
NODES=`sudo nvme list | grep 'nvme' | awk '{ print $1 }' | sed 's:/dev/nvme\([0-9]\+\)n1:\1:' | sort -n`

cd /home/ngd/ali/newport

for i in $NODES
do
  sudo ./load_insitu.sh ${i} f q &
done
wait

# Restart the machine
sudo rtcwake -m off -s 1200

