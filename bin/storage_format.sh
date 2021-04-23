#!/bin/sh

if [ `whoami` = 'root' ]
then
  echo "You should not run this script as root, aborting"
  exit 0
fi

NODES=`ngd_nodes.sh`

format_host()
{
  echo "Formating host"
  sudo mkdir -p /media/storage
  sudo rm -rf /media/storage/*
  sudo chmod 777 /media/storage
}

format_node()
{
  node=$1
  echo "Formatting $node ..."
  ssh $node sudo mkdir -p /media/storage
  ssh $node sudo chmod 777 /media/storage
  ssh $node '[ -e /dev/ngd-blk2 ] && sudo umount /media/storage'
  ssh $node '[ -e /dev/ngd-blk2 ] && sudo mkfs.ext4 /dev/ngd-blk2'
  ssh $node '[ -e /dev/ngd-blk2 ] && sudo mount /dev/ngd-blk2 /media/storage'
}

sudo echo "Starting..."

format_host &

for node in $NODES
do
  format_node $node &
done

wait
echo "Done!"

