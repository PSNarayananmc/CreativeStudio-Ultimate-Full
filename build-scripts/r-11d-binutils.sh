#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get -o Acquire::ForceIPv4=true update 2>&1 | tail -1
apt-get -o Acquire::ForceIPv4=true install -y --no-install-recommends binutils 2>&1 | tail -2
which strip && echo BINUTILS_OK
apt-get clean; rm -rf /var/lib/apt/lists/*
