#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get -o Acquire::ForceIPv4=true update 2>&1 | tail -1
apt-get -o Acquire::ForceIPv4=true install -y --no-install-recommends gdb 2>&1 | tail -1
apt-get clean; rm -rf /var/lib/apt/lists/*
which gdb && echo GDB_OK
