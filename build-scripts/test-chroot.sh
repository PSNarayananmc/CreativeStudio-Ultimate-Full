#!/bin/bash
echo "IN CHROOT: $(uname -m)"; cat /etc/os-release | head -2; echo "null test: $(echo hi > /dev/null && echo WRITE_OK)"; getent hosts archive.ubuntu.com; id
