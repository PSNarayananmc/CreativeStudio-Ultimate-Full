#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends pyqt5-dev pyqt5-dev-tools 2>&1 | tail -1
ls /usr/share/sip/PyQt5/QtCore/QtCoremod.sip && echo SIPDEV_DONE
