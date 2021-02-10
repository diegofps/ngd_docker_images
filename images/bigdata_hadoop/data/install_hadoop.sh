#!/bin/sh

ARCH=`uname -m`

if [ "$ARCH" = "aarch64" ]; then
    echo "Extracting hadoop for aarch64"
    tar -xf hadoop-3.3.0-aarch64.tar.gz

else
    echo "Extracting hadoop for amd64"
    tar -xf hadoop-3.3.0.tar.gz
fi

mv hadoop-3.3.0 /hadoop
