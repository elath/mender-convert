Instructions for building a new raspberry pi image.

The mender-convert instructions recommend changing the desired base image on a real rpi and then reading the image back and running through mender-conver.
This does not seem to work, and the resulting files take a VERY long time to process any way. The following works around both these issues at once.

These scripts are set up to prepare an sd image for a raspberry pi 4 configured for use with a hosted mender server.

1. Requirements
    a. The scripts in this repo are tested to work on an up to date install of Ubuntu 24.04 as of 
        15 OCT 2024. So far VMs (ProxMox and WSL2 do NOT work correctly.)
    a. A starting image, tested with 2024-07-04-raspios-bookworm-arm64-lite.img
    b. Prerequisets:
        qemu-utils
        qemu-user-static
        binutils
        xz-utils
        file
        rsyn
        parted
        e2fsprogs
        xfsprogs
        pigz
        dosfstools
        wget
        git
        make
        bmap-tools
        u-boot-tools

2. Instructions:
    a. Update the following variables:
        i. in rpi-prep/rpi-prep.sh
            1. base_img - The input file to be used. This should be the file name of the image in 1.a. eg. "2024-07-04-raspios-bookworm-arm64-lite.img"
            2. image_version to use. This may or may not be the same as the mender artifact version.
            3. tmp_img and tmp_img_size MAY be changed, if required.
        ii. In setup.sh
            1. The input file to be used. This should be the relative path of the image in 1.a. eg. ./2024-07-04-raspios-bookworm-arm64-lite.img
            2. The hosted.mender.com tennant token to be used. eg. "aHvmgUixLJi-uAhNEyFhQzVuHedJsAJqUisSKFZbxVz"
            3. The mender artifact version to use. eg. "1.2"
    b. change directory to rpi-prep
        i.  run rpi-prep.sh
            1. This script normally caches the dist-upgrade command, as this is quite time consuming to run. This can be prevented by deleting the *.part1.img file in rpi-prep.
    c. change directory to parent (mender-convert)
        i. run img-convert.sh
        ii. copy the prepared image to the SD card to be use. eg. sudo dd if=deploy/2024-07-04-raspios-bookworm-arm64-lite_0.5-raspberrypi4_64-mender.img of=/dev/sdb status=progress
            1. If the bs=4M (or equivalent) option is to be used, beware as the dd function will return very quickly, but the copy process will not actually be complete. Run "sync" to be sure.


In case of issues, contact bryce.klippenstein@gmail.com for assistance.

#TODO
1. Collapse these steps into a single script.
2. Ensure apt updates are fully disabled in the final image, as these can break the whole mender setup.
