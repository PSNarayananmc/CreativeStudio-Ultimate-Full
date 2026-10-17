#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-plug.log
: > $LOG
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 5
EX=/tmp/squashfs-root
probe() { timeout 240 $EX/AppRun --version > /root/probe.txt 2>&1; echo "PROBE_$1=$?"; }
probe C0 >> $LOG
N=0; for f in $EX/usr/lib/kritaplugins/*.so; do [ -f "$f" ] && strip --strip-unneeded "$f" 2>/dev/null && N=$((N+1)); done
echo "stripped_kritaplugins=$N" >> $LOG
probe C1 >> $LOG
N=0; for f in $EX/usr/plugins/*/*.so; do [ -f "$f" ] && strip --strip-unneeded "$f" 2>/dev/null && N=$((N+1)); done
echo "stripped_usrplugins=$N" >> $LOG
probe C2 >> $LOG
N=0; for f in $EX/usr/lib/krita-python-libs/*.so; do [ -f "$f" ] && strip --strip-unneeded "$f" 2>/dev/null && N=$((N+1)); done
echo "stripped_pylibs=$N" >> $LOG
probe C3 >> $LOG
kill $XPID 2>/dev/null
cat $LOG
