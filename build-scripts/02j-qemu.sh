#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends qemu-user-static 2>&1 | tail -1
which qemu-x86_64-static && echo QEMU_DONE
