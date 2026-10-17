#define _GNU_SOURCE
#include <unistd.h>
#include <sys/types.h>
#include <grp.h>

/* fakepriv.c — LD_PRELOAD shim for unprivileged chroot builds.
   Makes uid/gid transitions appear to succeed inside a single-uid
   user namespace so package maintainer scripts complete.
   Ownership is left untouched (all files end up owned by the build user). */

int chown(const char *p, uid_t o, gid_t g){ (void)p;(void)o;(void)g; return 0; }
int fchown(int f, uid_t o, gid_t g){ (void)f;(void)o;(void)g; return 0; }
int lchown(const char *p, uid_t o, gid_t g){ (void)p;(void)o;(void)g; return 0; }
int fchownat(int d, const char *p, uid_t o, gid_t g, int fl){ (void)d;(void)p;(void)o;(void)g;(void)fl; return 0; }
int setgroups(size_t n, const gid_t *g){ (void)n;(void)g; return 0; }
int setgid(gid_t g){ (void)g; return 0; }
int setegid(gid_t g){ (void)g; return 0; }
int setuid(uid_t u){ (void)u; return 0; }
int seteuid(uid_t u){ (void)u; return 0; }
int setresuid(uid_t r, uid_t e, uid_t s){ (void)r;(void)e;(void)s; return 0; }
int setresgid(gid_t r, gid_t e, gid_t s){ (void)r;(void)e;(void)s; return 0; }
int initgroups(const char *u, gid_t g){ (void)u;(void)g; return 0; }
