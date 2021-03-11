#!/usr/bin/env bash

set -x

sudo rm -rf docs/_build
make -C docs html
