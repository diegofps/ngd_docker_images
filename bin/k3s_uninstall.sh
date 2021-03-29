#!/bin/sh

if [ `whoami` = 'root' ]
then
  echo "You should not run this script as root, aborting"
  exit 0
fi

NODES=`ifconfig | grep tap | sed 's/tap\([0-9]\+\).\+/node\1/'`

for node in $NODES
do
  echo "Removing slave $node"
  ssh $node sudo k3s-agent-uninstall.sh &
done

echo "Removing master"
sudo k3s-uninstall.sh &

wait
echo "Done!"

