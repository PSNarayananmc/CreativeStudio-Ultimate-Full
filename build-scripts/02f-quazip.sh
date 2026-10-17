#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends libquazip5-dev 2>&1 | tail -2; dpkg -L libquazip5-dev 2>/dev/null | grep -E "cmake|\.h$" | head -8; echo QUAZIP_DONE
