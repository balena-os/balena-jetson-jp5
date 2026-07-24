include balena-image.inc

do_image:balenaos-img[depends] += " tegra-flash-dry:do_deploy"

# Leave some space, just in case future L4Ts add device specific partitions
# All values are in KiB
DEVICE_SPECIFIC_SPACE:jetson-xavier = "921600"
DEVICE_SPECIFIC_SPACE:jetson-xavier-nx-devkit-emmc = "593920"
DEVICE_SPECIFIC_SPACE:jetson-xavier-nx-devkit = "593920"

BALENA_BOOT_SIZE:jetson-xavier = "121440"
BALENA_BOOT_SIZE:jetson-xavier-nx-devkit-emmc = "121440"
BALENA_BOOT_SIZE:jetson-xavier-nx-devkit = "121440"

IMAGE_ROOTFS_SIZE:jetson-xavier = "733184"
IMAGE_ROOTFS_SIZE:jetson-xavier-nx-devkit-emmc = "733184"
IMAGE_ROOTFS_SIZE:jetson-xavier-nx-devkit = "733184"

BALENA_BOOT_PARTITION_FILES:append = " \
    bootfiles/EFI/BOOT/BOOTAA64.efi:/EFI/BOOT/BOOTAA64.efi \
    extra_uEnv.txt:/extra_uEnv.txt \
"

PART_SPEC_FILE = "partition_specification234.txt"
PART_SPEC_FILE:jetson-xavier-nx-devkit-emmc = "partition_specification194_nxde.txt"
PART_SPEC_FILE:jetson-xavier-nx-devkit = "partition_specification194_nxde.txt"
PART_SPEC_FILE:jetson-xavier = "partition_specification194.txt"

# 20480 in bytes
NVIDIA_PART_OFFSET="40"

check_size() {
    file_path=${1}
    [ -f "${file_path}" ] || bbfatal "Specified path does not exist: ${file_path}"
    file_size=$(ls -l ${file_path} | awk '{print $5}')
    part_size=${2}

    if [ "$file_size" -gt "$part_size" ]; then
        bbfatal "File ${file_path} too big for raw partition!"
    fi;
}

device_specific_configuration() {
    partitions=$(cat "${DEPLOY_DIR_IMAGE}/tegra-binaries/${PART_SPEC_FILE}")
    echo ">>> Partitions list: ${partitions}"
    START=${NVIDIA_PART_OFFSET}
    for n in ${partitions}; do
        part_name=$(echo $n | cut -d ':' -f 1)
        file_name=$(echo $n | cut -d ':' -f 2)
        part_size=$(echo $n | cut -d ':' -f 3)
        file_path=$(find ${DEPLOY_DIR_IMAGE}/bootfiles -name $file_name)
        END=$(expr ${START} \+ ${part_size} \- 1)
        echo ">>> file: ${file_path}, part: ${part_name}, start: ${START} - size: ${part_size} end: ${END}"
        parted -s ${BALENA_RAW_IMG} unit s mkpart $part_name ${START} ${END}
        if [ ! "$file_name" = "none.bin" ]; then
            check_size ${file_path} $(expr ${part_size} \* 512)
            dd if=$file_path of=${BALENA_RAW_IMG} conv=notrunc seek=${START} bs=512
        else
            dd if=/dev/zero of=${BALENA_RAW_IMG} conv=notrunc seek=${START} bs=512 count=${part_size}
      fi
      START=$(expr ${END} \+ 1)
    done
}

device_specific_configuration:jetson-xavier() {
    write_jetson_partitions_xavier
}

device_specific_configuration:jetson-xavier-nx-devkit-emmc() {
    write_jetson_partitions_xavier
}

device_specific_configuration:jetson-xavier-nx-devkit() {
    write_jetson_partitions_xavier
}

write_jetson_partitions_xavier() {
    ESP_BLOCKS=65536
    dd if=/dev/zero of=${DEPLOY_DIR_IMAGE}/tegra-binaries/esp.img seek=${ESP_BLOCKS} count=0 bs=1024
    mkfs.vfat -F 32 -I ${DEPLOY_DIR_IMAGE}/tegra-binaries/esp.img ${ESP_BLOCkS}
    partitions=$(cat ${DEPLOY_DIR_IMAGE}/tegra-binaries/${PART_SPEC_FILE})
    START=${NVIDIA_PART_OFFSET}
    for n in ${partitions}; do
        part_name=$(echo $n | cut -d ':' -f 1)
        file_name=$(echo $n | cut -d ':' -f 2)
        part_size=$(echo $n | cut -d ':' -f 3)
        file_path=$(find ${DEPLOY_DIR_IMAGE}/tegra-binaries -name $part_name)
        END=$(expr ${START} \+ ${part_size} \- 1)
        echo "Will write $part_name from ${START} to ${END} part size: $part_size"
        parted -s ${BALENA_RAW_IMG} unit s mkpart $part_name ${START} ${END}

        # The padding partition exists to allow for the device specific space to
        # be a multiple of 4096. We don't write anything to it for the moment.
      if [ ! "$file_name" = "none.bin" ]; then
        check_size ${file_path} $(expr ${part_size} \* 512)
        dd if=$file_path of=${BALENA_RAW_IMG} conv=notrunc seek=${START} bs=512
      else
        dd if=/dev/zero of=${BALENA_RAW_IMG} conv=notrunc seek=${START} bs=512 count=${part_size}
      fi
      START=$(expr ${END} \+ 1)
    done
}

BALENA_STATE_SIZE:jetson-xavier-nx-devkit-emmc = "20480"
BALENA_STATE_SIZE:jetson-xavier-nx-devkit = "20480"
BALENA_STATE_SIZE:jetson-xavier = "20480"
