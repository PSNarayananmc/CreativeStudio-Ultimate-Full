#!/usr/bin/env python3
"""perf-monitor.py — host-side RSS/timing monitor for chroot krita processes.
Usage: perf-monitor.py <output.csv> <duration_s>
Samples /proc every 0.3s for processes whose exe/cwd references cs-rootfs and name matches krita.
Writes: timestamp,pid,name,rss_kb,vsz_kb per line. Prints summary at end.
"""
import os, sys, time, glob

out_path = sys.argv[1]
duration = float(sys.argv[2])
t_end = time.time() + duration

def krita_procs():
    found = []
    for stat in glob.glob("/proc/[0-9]*/comm"):
        try:
            name = open(stat).read().strip()
            pid = int(stat.split("/")[2])
            if name in ("krita", "kritarunner") :
                exe = os.path.realpath("/proc/%d/exe" % pid)
                if "cs-rootfs" in exe:
                    status = open("/proc/%d/status" % pid).read()
                    rss = vsz = 0
                    for line in status.splitlines():
                        if line.startswith("VmRSS:"):
                            rss = int(line.split()[1])
                        elif line.startswith("VmSize:"):
                            vsz = int(line.split()[1])
                    found.append((pid, name, rss, vsz))
        except (IOError, OSError, ValueError):
            continue
    return found

with open(out_path, "w") as f:
    f.write("ts,pid,name,rss_kb,vsz_kb\n")
    peak = {}
    n = 0
    while time.time() < t_end:
        for pid, name, rss, vsz in krita_procs():
            f.write("%.1f,%d,%s,%d,%d\n" % (time.time(), pid, name, rss, vsz))
            cur = peak.get(pid, (0, 0, name))
            if rss > cur[0]:
                peak[pid] = (rss, vsz, name)
        f.flush()
        time.sleep(0.3)
        n += 1

total_peak = 0
print("=== MONITOR SUMMARY ===")
for pid, (rss, vsz, name) in sorted(peak.items()):
    print("PEAK pid=%d name=%s rss=%d kB vsz=%d kB" % (pid, name, rss, vsz))
    total_peak += rss
print("TOTAL_PEAK_RSS_KB=%d (%.1f MB)" % (total_peak, total_peak / 1024.0))
print("SAMPLES=%d" % n)
