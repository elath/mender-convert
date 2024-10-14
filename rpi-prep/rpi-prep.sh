#!/bin/bash

##The instructions in the readme.md at https://github.com/mendersoftware/mender-convert don't work.
##Instead, we prepare an image straight from RPI foundation with the below script. 
##This prepared image can then be run trhough the mender convert process as usual to reconfigure the partitions and re-package the iso.
##
##This script was prepared and testing on a bare metal install of Ubuntu 24.04.
##
##It appears that the chroot process WILL NOT WORK on a WSL instance.
##
##Prerequisets:
## qemu-utils
## qemu-user-static


image_version=0.4
# Golden image from RPI foundation
base_img="2024-07-04-raspios-bookworm-arm64-lite.img"
# Same as above, but with apt dist-upgrade completed.
# base_img="2024-10-11-raspios-bookworm-arm64-lite_dist-upgrade.img"
prepared_img="${base_img:0:-4}"_"${image_version}".img
prepared_img_part1="${base_img:0:-4}"_"${image_version}"_part1.img
tmp_img="tmp.img"
tmp_img_size=4G

if ! test -f $base_img; then
    echo "Base image not found. Ensure image specified in this script is available."
    exit 1
fi

if ! test -d ./rootfs; then
    echo "Creating rootfs folder"
    mkdir rootfs
fi

if ! test -d ./boot; then
    echo "Creating rootfs folder"
    mkdir boot
fi

if ! test -f ./$tmp_img; then
    echo "Creating tmp.img"
    install -m 660 $base_img $tmp_img
fi

if test ! -f ~/$prepared_img_part1; then

    # Resize the rootfs partition of the temp image to accomodate the
    # updates and installed applications.
    # This is written for an image where the rootfs is partition #2
    qemu-img resize -f raw $tmp_img $tmp_img_size
    growpart $tmp_img 2

    loop_device=$(sudo losetup -f --show -P $tmp_img)
    # echo $loop_device
    sudo e2fsck -f -y ${loop_device}p2
    sudo resize2fs ${loop_device}p2

    # Mount our file systems, and support for local hardware

    sudo mount ${loop_device}p1 ./boot
    sudo mount ${loop_device}p2 ./rootfs

    sudo mount -t proc /proc ./rootfs/proc
    sudo mount --bind /dev ./rootfs/dev
    sudo mount --bind /sys ./rootfs/sys
    sudo mount --bind /run ./rootfs/run

    echo "Install setup script into rootfs."
    sudo install -o root -m 744 rpi-chroot-script_part1.sh rootfs/root/
    sudo install -o root -m 744 rpi-chroot-script_part2.sh rootfs/root/

	#Enter into image
    sudo chroot rootfs bash -c '/root/rpi-chroot-script_part1.sh'

    #Cache part 1
    sudo umount boot
    sudo umount rootfs/proc
    sudo umount rootfs/dev
    sudo umount rootfs/sys
    sudo umount rootfs/run
    sudo umount rootfs

    cp $tmp_img $prepared_img_part1
fi

sudo mount ${loop_device}p1 ./boot
sudo mount ${loop_device}p2 ./rootfs

sudo mount -t proc /proc ./rootfs/proc
sudo mount --bind /dev ./rootfs/dev
sudo mount --bind /sys ./rootfs/sys
sudo mount --bind /run ./rootfs/run

#Enter into image
sudo chroot rootfs bash -c '/root/rpi-chroot-script_part2.sh'

#Exit from image

#Cleanup
sudo sync
sudo sleep 5

sudo umount boot
sudo umount rootfs/proc
sudo umount rootfs/dev
sudo umount rootfs/sys
sudo umount rootfs/run
sudo umount rootfs
sudo losetup -d ${loop_device}*

install -m 440 $tmp_img $prepared_img