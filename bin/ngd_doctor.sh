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

check_ecdsa()
{
  NODE=$1
  echo "Fixing possible ECDSA issues for node $NODE..."
  
  ssh $NODE -o BatchMode=yes -o StrictHostKeyChecking=no echo > /dev/null
}

for node in $NODES ; do 
  check_ecdsa $node &
done
wait

echo "Done!"

