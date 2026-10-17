#!/bin/bash
# 02a-prepare-rootfs.sh — HOST side: write configs, fake /dev /proc /sys into rootfs
# Run on host BEFORE any chroot usage.
set -e
ROOTFS=/home/z/cs-rootfs
[ -d "$ROOTFS/etc" ] || { echo "rootfs not ready"; exit 1; }

# --- network config ---
rm -f "$ROOTFS/etc/resolv.conf"
cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf"
printf '127.0.0.1\tlocalhost\n127.0.1.1\tcs-build\n' > "$ROOTFS/etc/hosts"
echo cs-build > "$ROOTFS/etc/hostname"

# --- apt sources (focal full) ---
mkdir -p "$ROOTFS/etc/apt"
cat > "$ROOTFS/etc/apt/sources.list" <<'EOF'
deb http://archive.ubuntu.com/ubuntu focal main universe multiverse restricted
deb http://archive.ubuntu.com/ubuntu focal-updates main universe multiverse restricted
deb http://archive.ubuntu.com/ubuntu focal-security main universe multiverse restricted
EOF
mkdir -p "$ROOTFS/etc/apt/apt.conf.d"
cat > "$ROOTFS/etc/apt/apt.conf.d/99cs-build" <<'EOF'
APT::Install-Recommends "false";
APT::Get::AllowUnauthenticated "false";
Acquire::Languages "none";
EOF

# --- fake /dev (regular files; mknod is blocked in this sandbox) ---
mkdir -p "$ROOTFS/dev/pts" "$ROOTFS/dev/shm" "$ROOTFS/run"
for f in null zero random urandom tty full ptmx; do
  [ -e "$ROOTFS/dev/$f" ] || : > "$ROOTFS/dev/$f"
done
ln -sf /dev/null "$ROOTFS/dev/stdout" 2>/dev/null || true

# --- fake /proc (static snapshots) ---
mkdir -p "$ROOTFS/proc/self" "$ROOTFS/proc/sys"
chmod u+w "$ROOTFS/proc" 2>/dev/null || true
rm -f "$ROOTFS/proc/cpuinfo" "$ROOTFS/proc/meminfo" "$ROOTFS/proc/stat" "$ROOTFS/proc/version" "$ROOTFS/proc/filesystems" "$ROOTFS/proc/devices" "$ROOTFS/proc/loadavg" "$ROOTFS/proc/uptime" "$ROOTFS/proc/mounts" "$ROOTFS/proc/cpuinfo.placeholder" 2>/dev/null
grep -E '^(processor|vendor_id|cpu family|model name|model|flags|bogomips|cache)' /proc/cpuinfo > "$ROOTFS/proc/cpuinfo"
cp /proc/meminfo "$ROOTFS/proc/meminfo"
cp /proc/stat "$ROOTFS/proc/stat"
cp /proc/version "$ROOTFS/proc/version"
cp /proc/filesystems "$ROOTFS/proc/filesystems"
cp /proc/devices "$ROOTFS/proc/devices" 2>/dev/null || true
cat /proc/loadavg > "$ROOTFS/proc/loadavg"
cat /proc/uptime > "$ROOTFS/proc/uptime"

# --- fake /sys ---
mkdir -p "$ROOTFS/sys/devices/system/cpu/cpu0" "$ROOTFS/sys/devices/system/cpu/cpu1" "$ROOTFS/sys/devices/system/cpu/cpu1/topology"
rm -f "$ROOTFS/sys/devices/system/cpu/online" "$ROOTFS/sys/devices/system/cpu/present"
echo "0-1" > "$ROOTFS/sys/devices/system/cpu/online"
echo "0-1" > "$ROOTFS/sys/devices/system/cpu/present"

# --- mount table for tools that read /proc/mounts ---
printf 'rootfs / rootfs rw 0 0\nproc /proc proc rw 0 0\ndevtmpfs /dev devtmpfs rw 0 0\n' > "$ROOTFS/proc/mounts"

# --- ldconfig dir + policy to silence service errors ---
mkdir -p "$ROOTFS/usr/local/lib" "$ROOTFS/usr/local/lib/x86_64-linux-gnu"
printf '#!/bin/sh\nexit 101\n' > "$ROOTFS/usr/sbin/policy-rc.d"
chmod +x "$ROOTFS/usr/sbin/policy-rc.d"

echo "rootfs prepared OK"
