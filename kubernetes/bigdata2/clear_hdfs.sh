#!/bin/sh

sudo rm -rf /media/storage/dfs_datanode
parallel-ssh -h ~/nodes -i -t 0 sudo rm -rf /media/storage/dfs_datanode
