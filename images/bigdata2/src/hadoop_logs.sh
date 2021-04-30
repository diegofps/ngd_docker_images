#!/bin/sh

while true
do

    FILEPATH=`ls /hadoop/logs/*.log | grep -E "(namenode|datanode)"`

    if [ "$FILEPATH" = "" ]; then
        echo "Hadoop log not found"

    else
        echo "Following hadoop log at $FILEPATH"
        tail -f $FILEPATH
        exit 0
    fi

    sleep 10
done
