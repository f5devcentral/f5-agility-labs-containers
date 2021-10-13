#!/bin/bash

name=$(jq .infraID $PWD/ignition/metadata.json)

echo -n "{\"name\":${name}}"
