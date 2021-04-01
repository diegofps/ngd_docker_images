#!/bin/sh

if [ `whoami` = 'root' ]
then
  echo "You should not run this script as root, aborting"
  exit 0
fi

NODES_FILEPATH=$1
if [ "$NODES_FILEPATH" = "" ]
then
  NODES=`ifconfig | grep tap | sed 's/tap\([0-9]\+\).\+/node\1/'`
else
  NODES=`cat $NODES_FILEPATH`
fi

if [ -e '/etc/systemd/system/k3s.service' ]
then
  echo "It seams like k3s is already installed, use k3s_uninstall.sh to remove it first"
  exit 0
fi

echo "Disabling firewall"
sudo ufw disable

echo "Installing master"
curl -sfL https://get.k3s.io | sh -s - server \
    --cluster-cidr 10.235.32.0/19 \
    --service-cidr 10.235.0.0/19 \
    --resolv-conf /run/systemd/resolve/resolv.conf \
    --tls-san host \
    --bind-address 0.0.0.0 \
    --docker

echo "Installing slaves"
TOKEN=`sudo cat /var/lib/rancher/k3s/server/node-token`
ADDRESS=`hostname -I | awk '{ print $1 }'`

for node in $NODES
do
  ssh $node "curl -sfL https://get.k3s.io | sudo sh -s - agent --docker --server https://${ADDRESS}:6443 --token ${TOKEN}" &
done

wait
echo "Done!"

