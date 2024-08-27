#!/bin/bash
# Script for writing a Windows ISO to a USB

set -o pipefail

# atexit handler
ATEXIT=()

function atexit() {
  ATEXIT+=( "$*" )
}

function _atexit_handler() {
  local EXPR
  for (( idx=${#ATEXIT[@]}-1 ; idx>=0 ; idx-- )); do
    EXPR="${ATEXIT[idx]}"
    echo "atexit: $EXPR" 1>&2
    eval "$EXPR"
  done
}

trap _atexit_handler EXIT

function log() {
  echo "$*" 1>&2
}

function fatal() {
  local exit_code="$1"
  shift
  echo "FATAL: $*" 1>&2
  exit "$exit_code"
}

# Check if the given loop device is mounted by udevctl
# Usage: is_mounted <loop_dev>
function is_mounted() {
  local loop_dev="$1"
  declare -a mountpoints
  mapfile -t mountpoints < <(udisksctl info -b "${loop_dev}" | tr -s ' ' | cut -d' ' -f2- | sed -n -e '/Mountpoints:/,/*:/p' | head -n-1 | sed 's/Mountpoints: //')
  if [ ${#mountpoints[mountpoints]} = 0 ]; then
    return 1
  fi
  return 0
}

# Ensure a loop device is mounted
# Usage: is_mounted <loop_dev>
function ensure_mount() {
  local loop_dev="$1"
  log "Ensuring udisks mount for: $loop_dev"
  if ! is_mounted "${loop_dev}"; then
    udisksctl mount -b "${loop_dev}" 1>/dev/null 2>&1
  fi
  return 0
}

# Build a list of USB mass storage devices

declare -a usb_devices 

for device in /dev/disk/by-id/*; do 
    if udevadm info --query=property --path="block/$(basename "$(readlink -f "$device")")" 2>/dev/null | grep -q ^ID_BUS=usb; then
        usb_devices+=( "${device}" )
    fi
done

while [ -n "$1" ] ; do
    arg="$1"
    case $arg in
    --list)
      for device in "${usb_devices[@]}"; do
        echo "$device"
      done
      exit 0
      ;;
    --help)
      cat << EOF 1>&2
$0 [Windows ISO] [Target USB Drive]

Write a Windows ISO to a USB drive

    --list              List available USB devices and exit
    --help              Shows this help.

EOF
      ;;
    --*)
      fatal 1 "Unrecognized option: $1"
      ;;
    *)
      break
      ;;
    esac
    shift
done

source_iso="$1"
if [ -z "$source_iso" ]; then
    fatal 1 "Need an ISO file"
fi
source_iso="$(readlink -f "${source_iso}")"

shift

dest_device="$1"
if [ -z "$dest_device" ]; then
    fatal 1 "Need an destination device"
fi

if [ -z "${usb_devices[$dest_device]}" ]; then
    fatal 1 "Not a USB device"
fi

orig_dest_device="${dest_device}"
dest_device="$(readlink -f "${dest_device}")"

log "About to write to: ${orig_dest_device} (${dest_device})"

sleep 3

# Kill the 4M front and back on the disk
if ! sudo dd if=/dev/zero "of=${dest_device}" bs=1M count=4; then
    fatal 1 "Error while cleaning up partition info on target device: ${dest_device}"
fi

if ! sudo dd if=/dev/zero "of=${dest_device}" bs=512 count=2048 seek=$(($(sudo blockdev --getsz "${dest_device}") - 2048 )); then
    fatal 1 "Error while cleaning up partition info on target device: ${dest_device}"
fi

if ! sudo sgdisk -Z -n 0:0:0 -t 0:ef00 "${dest_device}"; then
    fatal 1 "Failed to partition ${dest_device}"
fi

# Searching for mountpoints
windows_partition=
mapfile -t partition_objects < <(udisksctl info -b "${dest_device}" | tr -s ' ' | cut -d' ' -f2- | sed -n -e '/Partitions:/,/*:/p' | head -n-1 | sed 's/Partitions: //')
for partition_path in "${partition_objects[@]}"; do
    # You would expect the -p object paths to be what we have here, but they don't work when you look them in udisksctl.
    # The pattern does however keep loop names, which is good enough for us.
    partition_path="/dev/${partition_path##*/}"

    log "Creating filesystem on partition ${partition_path}"

    if ! sudo mkfs.vfat -n "WINSETUP" "${partition_path}"; then
        fatal 1 "Failed to create Windows partition on USB key"
    fi

    windows_partition="${partition_path}"
    break
done

if [ -z "${windows_partition}" ]; then
    fatal 1 "Could not find any partitions on the USB key"
fi

sleep 3

log "Ensure a mount happens: ${windows_partition}"
if ! ensure_mount "${windows_partition}"; then
  fatal 1 "Failed to ensure mount for ${windows_partition}"
fi
atexit udisksctl unmount -f -b "${windows_partition}"

log "Find the mount path: ${windows_partition}"
if mnt_dir="$(udisksctl info -b "${windows_partition}" | tr -s ' ' | cut -d' ' -f2- | grep 'MountPoints' | cut -d' ' -f2-)"; then
    log "Found partition mount on ${windows_partition}: ${mnt_dir}"
    atexit udisksctl unmount -f -b "${partition_path}"
fi

if [ -z "${mnt_dir}" ]; then
    fatal 1 "No mounts from: ${windows_partition}"
fi

log "Mount the ISO - use udisks because UDF can't be handled by fuseio"
if ! loop_dev=$(udisksctl loop-setup -f "${source_iso}" | grep -oP 'as .*'); then
    fatal 1 "Could not mount ISO image with udisks"
fi

log "Cut the string to get the /dev/loopX part"
loop_dev="${loop_dev##* }"
loop_dev="${loop_dev%%.*}"

# Happens automatically if you delay and wait for the mount (see sleep below)
#atexit udisksctl loop-delete -b "${loop_dev}"

log "Ensure a mount happens: ${loop_dev}"
sleep 1
if ! ensure_mount "${loop_dev}"; then
  fatal 1 "Failed to ensure mount for ${loop_dev}"
fi
atexit udisksctl unmount -f -b "${loop_dev}"

log "Find the mount path"
if ! iso_mnt_dir="$(udisksctl info -b "${loop_dev}" | tr -s ' ' | cut -d' ' -f2- | grep 'MountPoints' | cut -d' ' -f2)"; then
    fatal 1 "Could not find the mount path"
fi
log "Mount Path Found: ${iso_mnt_dir}"

log "Copying installation files"
if ! rsync --fsync -av -W --progress "${iso_mnt_dir}/" "${mnt_dir}/"; then
    fatal 1 "Failed to copy ISO files to USB key"
fi
