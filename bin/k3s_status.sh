#!/bin/sh

if [ `whoami` = 'root' ]
then
  echo "You should not run this script as root, aborting"
  exit 0
fi

echo -n "master: "
sudo service k3s status | grep -E '(active|inactive)'

NODES=`ngd_nodes.sh`

for node in $NODES
do
  echo -n "${node}: "
  ssh $node sudo service k3s-agent status | grep -E '(active|inactive)'
done
