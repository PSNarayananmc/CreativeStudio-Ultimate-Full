#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends qtbase5-private-dev 2>&1 | tail -1; echo PRIVDEV_DONE
