#!/bin/bash
ls /var/lib/dpkg/lock-frontend 2>/dev/null; dpkg --configure -a 2>&1 | tail -3; echo "DPKG_CONFIGURE_DONE"
