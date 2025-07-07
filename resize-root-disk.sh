#!/usr/bin/env bash
set -euo pipefail

# Variables — adjust if your VG/LV names differ
DISK="/dev/sda"
PART_NUM="3"
VG_NAME="ubuntu-vg"
LV_NAME="ubuntu-lv"
LV_PATH="/dev/${VG_NAME}/${LV_NAME}"

echo
echo "🔍 1) Updating package list and installing cloud-guest-utils..."
apt-get update
apt-get install -y cloud-guest-utils

echo
echo "📏 2) Growing partition ${PART_NUM} on ${DISK} to fill the disk..."
growpart "${DISK}" "${PART_NUM}"

echo
echo "🔄 3) Resizing LVM physical volume on ${DISK}${PART_NUM}..."
pvresize "${DISK}${PART_NUM}"

echo
echo "🚀 4) Extending logical volume and filesystem (${LV_PATH})..."
# -l +100%FREE grabs all free extents; -r resizes the FS automatically
lvextend -r -l +100%FREE "${LV_PATH}"

echo
echo "✅ Done! Here’s the new layout and usage:"
lsblk
df -h /

echo
echo "🎉 Your root filesystem is now using the full virtual disk."

