#!/bin/bash

#This block of variables should mirror the one in rpi-prep/rpi-prep.sh, where rpi-prep.sh is the "master" version.
##TODO FIX THIS SO IT'S NOT A DUPLICATE
image_version=0.5
base_img="2024-07-04-raspios-bookworm-arm64-lite.img"
prepared_img="${base_img:0:-4}"_"${image_version}".img

artifact_name=0.4

./scripts/bootstrap-rootfs-overlay-hosted-server.sh --output-dir ${PWD}/input/rootfs_overlay_demo --region us --tenant-token "reqUGyFj6T8-INQgPdDr2mI_APY5TUAtsg7ASEpyDl8"
./docker-build
MENDER_ARTIFACT_NAME=$artifact_name ./docker-mender-convert --disk-image $prepared_img --config ./configs/raspberrypi4_bookworm_64bit_config --overlay ./input/rootfs_overlay_demo