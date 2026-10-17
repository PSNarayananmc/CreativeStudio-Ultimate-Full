#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update 2>&1 | tail -2
apt-get install -y --no-install-recommends intltool gettext 2>&1 | tail -2
echo TOOLS_DONE
