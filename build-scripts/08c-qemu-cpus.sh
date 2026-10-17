#!/bin/bash
qemu-x86_64-static -cpu ? 2>&1 | head -30
