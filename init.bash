#!/bin/bash

#
# Initialize the custom data directory layout
#
source /data_dirs.env

mkdir -p /data
for datadir in "${DATA_DIRS[@]}"; do
  ln -s /data/${datadir#/*} ${datadir}
done