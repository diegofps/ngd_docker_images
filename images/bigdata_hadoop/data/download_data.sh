#!/bin/sh


echo "Downloading packages..."
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0-aarch64.tar.gz &
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz &

wget https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0-aarch64.tar.gz.sha512 &
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz.sha512 &

wait


echo "Checking signatures..."
SHA_AMD64=`cat ./hadoop-3.3.0.tar.gz.sha512 | awk '{ print $4 }'`
SHA_ARM64=`cat ./hadoop-3.3.0-aarch64.tar.gz.sha512 | awk '{ print $4 }'`

SHA_AMD64_SEEN=`sha512sum ./hadoop-3.3.0.tar.gz  | awk '{ print $1 }'`
SHA_ARM64_SEEN=`sha512sum ./hadoop-3.3.0-aarch64.tar.gz  | awk '{ print $1 }'`

if [ $SHA_AMD64 != $SHA_AMD64_SEEN ]; then
    echo "Expected $SHA_AMD64 but got $SHA_AMD64_SEEN"
fi

if [ "$SHA_ARM64" != "$SHA_ARM64_SEEN" ]; then
    echo "Expected $SHA_ARM64 but got $SHA_ARM64_SEEN"
fi


echo "Done."
