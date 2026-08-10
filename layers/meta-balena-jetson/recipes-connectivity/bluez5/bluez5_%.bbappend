FILESEXTRAPATHS:append := ":${THISDIR}/files"

# Increase scan duration and make sure caches are flushed
# to overcome autokit sporadic scan reporting no results.
# Scanning appears to work fine outside autokit and this
# could be caused by interferences and caching.
SRC_URI:append:jetson-xavier-nx-devkit = " \
    file://0005-scan_len.patch \
"
