#!/bin/bash

workerignloc=$(jq '.ignition.config.merge[].source' $PWD/ignition/worker.ign)

echo -n "{\"workerignloc\":${workerignloc}}"
