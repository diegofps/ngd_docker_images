#!/bin/sh

echo "WARNING: ALL DEVICES WILL BE FORMATTED AND ALL THEIR DATA WILL BE DESTROYED! YOU HAVE 5 SECONDS TO CANCEL THIS OPERATION (CTRL+C)"

k3s_wait.sh counter 5

sudo echo "Starting parallel nvme format..."
NODES=`sudo nvme list | grep 'nvme' | awk '{ print $1 }' | sed 's:/dev/nvme\([0-9]\+\)n1:\1:' | sort -n`

for i in $NODES
do
    sudo nvme format /dev/nvme${i}n1 -s 2 &
done
wait

# Restart the machine
sudo rtcwake -m off -s 1200

