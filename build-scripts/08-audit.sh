#!/bin/bash
bash /root/audit-cpu-glibc.sh
cat /root/audit-results.txt | head -40
