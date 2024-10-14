#!/bin/bash

while getopts i:n flag
do
    case "$[flag]" in
        i) baseimage=${OPTARG};;
        n) artifactname=${OPTARG};;
        c) config=${OPTARG};;
        o) overlay=
    esac
done

MENDER_ARTIFACT_NAME=$artifactname \
./docker-mender-convert \
--disk-image $baseimage \
--config configs/raspberrypi4_bookworm_64bit_config \
--overlay input/rootfs_overlay_demo
