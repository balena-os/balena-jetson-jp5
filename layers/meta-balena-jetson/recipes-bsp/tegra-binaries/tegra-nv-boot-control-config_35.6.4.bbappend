# We can't modify the root filesystem at runtime
# but know how the file should look for
# the  Devkits. These values are used for querying only
# and not for setting efivars
do_compile:jetson-xavier() {
        cat > ${B}/nv_boot_control.conf <<EOF
TNSPEC 2888-400-0001-E.0-1-2-jetson-agx-xavier-devkit-
COMPATIBLE_SPEC 2888-400-0001-J.0-1-2-jetson-agx-xavier-devkit-
TEGRA_CHIPID 0x19
TEGRA_OTA_BOOT_DEVICE /dev/mmcblk0boot0
TEGRA_OTA_GPT_DEVICE /dev/mmcblk0boot1
EOF

}

do_compile:jetson-xavier-nx-devkit-emmc() {
        cat > ${B}/nv_boot_control.conf <<EOF
TNSPEC 3668-200-0001-G.0-1-2-jetson-xavier-nx-devkit-emmc-
COMPATIBLE_SPEC 3668-100---1--jetson-xavier-nx-devkit-emmc-
TEGRA_LEGACY_UPDATE true
TEGRA_EMMC_ONLY false
TEGRA_CHIPID 0x19
TEGRA_OTA_BOOT_DEVICE /dev/mtdblock0
TEGRA_OTA_GPT_DEVICE /dev/mtdblock0
EOF

}

do_compile:jetson-xavier-nx-devkit() {
        cat > ${B}/nv_boot_control.conf <<EOF
TNSPEC 3668-200-0000-J.0-1-2-jetson-xavier-nx-devkit-
COMPATIBLE_SPEC 3668-100---1--jetson-xavier-nx-devkit-
TEGRA_LEGACY_UPDATE true
TEGRA_EMMC_ONLY false
TEGRA_CHIPID 0x19
TEGRA_OTA_BOOT_DEVICE /dev/mtdblock0
TEGRA_OTA_GPT_DEVICE /dev/mtdblock0
EOF

}

do_install() {
	install -d ${D}${sysconfdir}
	install -m 0644 ${B}/nv_boot_control.conf ${D}${sysconfdir}/
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
