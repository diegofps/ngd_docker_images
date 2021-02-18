#!/bin/sh


echo "Downloading packages..."
#wget https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz &
#wget https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz.sha512 &
wait


echo "Checking signatures..."
SHA=`cat spark-3.0.1-bin-hadoop3.2.tgz.sha512 | cut -c 32- | tr -d '\n' | sed -E 's/\s+//g' | awk '{ print tolower($0) }'`
SHA_SEEN=`sha512sum ./spark-3.0.1-bin-hadoop3.2.tgz  | awk '{ print $1 }'`

if [ "$SHA" != "$SHA_SEEN" ]; then
    echo "Expected $SHA but got $SHA_SEEN"
    
fi


echo "Done."
