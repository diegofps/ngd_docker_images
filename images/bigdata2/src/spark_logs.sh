#!/bin/sh

while true
do

    FILEPATH=`ls /spark/logs/*.out | grep -E "(worker|master)"`

    if [ "$FILEPATH" = "" ]; then
        echo "Spark log not found"

    else
        echo "Following spark log at $FILEPATH"
        tail -f $FILEPATH
        exit 0
    fi

    sleep 10
done
