#!/bin/bash

masterigncert=$(jq '.ignition.security.tls.certificateAuthorities[].source' $PWD/ignition/master.ign)

echo -n "{\"masterigncert\":${masterigncert}}"
