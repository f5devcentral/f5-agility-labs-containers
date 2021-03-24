#!/usr/bin/env bash

set -x

sudo make -C docs clean
sudo make -C docs html
