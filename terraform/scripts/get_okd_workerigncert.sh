#!/bin/bash

workerigncert=$(jq '.ignition.security.tls.certificateAuthorities[].source' $PWD/ignition/worker.ign)

echo -n "{\"workerigncert\":${workerigncert}}"
