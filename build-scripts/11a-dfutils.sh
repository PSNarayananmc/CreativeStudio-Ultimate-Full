#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update 2>&1 | tail -1
apt-get install -y --no-install-recommends desktop-file-utils 2>&1 | tail -1
echo DFINSTALLED
