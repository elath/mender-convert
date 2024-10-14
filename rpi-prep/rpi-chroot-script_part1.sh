#!/bin/bash

# This script has been moved out of the main rpi-prep.sh script as it needs to be executed from within the chroot.

echo "Update apt packages."
apt update
apt -y dist-upgrade

echo "end of rpi-chroot-script_part1.sh"