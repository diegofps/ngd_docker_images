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

uninstall_node()
{
  node=$1
  echo "Removing slave $node"
  ssh $node sudo k3s-agent-uninstall.sh 
}

uninstall_host()
{
  echo "Removing master"
  sudo k3s-uninstall.sh
}

sudo echo "Starting..."

for node in $NODES
do
  uninstall_node $node &
done

uninstall_host &

wait
echo "Done!"

