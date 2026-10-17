#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends xdotool x11-apps 2>&1 | tail -1
which xdotool xwd && echo XTOOLS_DONE
