#!/bin/sh

if [ `whoami` = 'root' ]
then
  echo "You should not run this script as root, aborting"
  exit 0
fi

NODES=`ifconfig | grep tap | sed 's/tap\([0-9]\+\).\+/node\1/'`

clear_host()
{
  echo "Clearing data in host ..."
  sudo rm -rf /media/storage/*
}

clear_node()
{
  node=$1
  echo "Clearing data in $node ..."
  ssh $node sudo rm -rf /media/storage/*
}

clear_host &

for node in $NODES
do
  clear_node $node &
done

wait
echo "Done!"

