#!/bin/bash
echo x | mksquashfs /bin/empty-test /tmp/t.sqsh -comp zstd -noappend -quiet -no-progress 2>&1 | head -3
echo "ZSTD_EXIT=$?"
unsquashfs -s /tmp/t.sqsh 2>/dev/null | grep -iE "compress|block"
