#!/bin/sh

if [ -e "/home/$USER/.ngd/nodes" ]; then
  cat "/home/$USER/.ngd/nodes"

elif [ ! $(which ifconfig) = "" ]; then
  DEVS=`ifconfig | grep tap | sed 's/tap\([0-9]\+\).\+/node\1/'`

  for D in $DEVS
  do
    echo $D
  done

fi
