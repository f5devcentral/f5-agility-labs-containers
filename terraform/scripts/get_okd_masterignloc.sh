#!/bin/bash

masterignloc=$(jq '.ignition.config.merge[].source' $PWD/ignition/master.ign)

echo -n "{\"masterignloc\":${masterignloc}}"
