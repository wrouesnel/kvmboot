#!/bin/bash
# Script to handle modifying a Ubuntu ISO into an automated form
# Result is an ISO.
# This is much simpler then the equivalent Windows system, since we just need to dump files into the imag.

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

function containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
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

opt_proxy=
opt_trusted_ca=
opt_root_password=
opt_root_sshkey=
# Collect optional arguments
# opt_proxy=
while [ -n "$1" ] ; do
    arg="$1"
    case $arg in
    # --proxy)
    #   shift
    #   opt_proxy="$1"
    #  ;;
    --help)
      cat << EOF 1>&2
$0 [Fedora ISO] [Output ISO Name] [kickstart.cfg file]

Repack a Fedora NetInst ISO for unattended installation.

    --help              Shows this help.
    --proxy             Proxy server to add to the kickstart file
    --trusted-ca        Trusted CA file to add to the kickstart file

EOF
      ;;
    --proxy)
      shift
      opt_proxy="$1"
      ;;
    --trusted-ca)
      shift
      opt_trusted_ca="$1"
      ;;
    --root-password)
      shift
      opt_root_password="$1"
      ;;

    --root-sshkey)
      shift
      opt_root_sshkey="$1"
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

iso_file="$1"
shift

if [ -z "$iso_file" ]; then
    fatal 1 "Need an output_dir"
fi
iso_file=$(readlink -f ${iso_file})

output_iso="$1"
shift

if [ -z "$output_iso" ]; then
    fatal 1 "Need an output_iso"
fi

kickstart_file="$1"
shift

if [ -z "$kickstart_file" ]; then
    echo "WARN: No autoinstall.yaml file specified!"
fi

log "Setup temporary working directories"
work_dir=$(mktemp -d "${iso_file}.work.XXXXXXX.tmp")
if [ -z "$work_dir" ]; then
    fatal 1 "Error creating temporary directory"
fi
atexit find "${work_dir}" -delete

# Extract the hybrid MBR from the volume
if ! dd "if=${iso_file}" bs=1 count=432 "of=${work_dir}/boot_hybrid.img"; then
  fatal 1 "Could not extract hybrid MBR from ISO"
fi

log "Mount the ISO - use udisks because UDF can't be handled by fuseio"
if ! loop_dev=$(udisksctl loop-setup -f "${iso_file}" | grep -oP 'as .*'); then
    fatal 1 "Could not mount ISO image with udisks"
fi

log "Cut the string to get the /dev/loopX part: ${loop_dev}"
loop_dev="${loop_dev##* }"
loop_dev="${loop_dev%%.*}"

# Loop deletes shouldn't be necessary (and require privileges)
#atexit udisksctl loop-delete -b "${loop_dev}"

log "Ensure a mount happens: ${loop_dev}"
if ! ensure_mount "${loop_dev}"; then
  fatal 1 "Failed to ensure mount for ${loop_dev}"
fi
atexit udisksctl unmount -f -b "${loop_dev}"

# Give the mounts a chance to happen
sleep 1

# These are the alternate partitions we need to copy
#grub_partition=
#efi_partition=""

log "Find the mount path: ${loop_dev}"
if ! mnt_dir="$(udisksctl info -b "${loop_dev}" | tr -s ' ' | cut -d' ' -f2- | grep 'MountPoints' | cut -d' ' -f2)"; then
    log "No mount path, checking for partitions..."    
    mapfile -t partition_objects < <(udisksctl info -b "${loop_dev}" | tr -s ' ' | cut -d' ' -f2- | sed -n -e '/Partitions:/,/*:/p' | head -n-1 | sed 's/Partitions: //')
    mnt_dir=""
    for partition_path in "${partition_objects[@]}"; do
      # You would expect the -p object paths to be what we have here, but they don't work when you look them in udisksctl.
      # The pattern does however keep loop names, which is good enough for us.
      partition_path="/dev/${partition_path##*/}"
      if possible_mnt_dir="$(udisksctl info -b "${partition_path}" | tr -s ' ' | cut -d' ' -f2- | grep 'MountPoints' | cut -d' ' -f2-)"; then
        if [ -z "${possible_mnt_dir}" ]; then
          log "No mounts from: ${partition_path}"
          continue
        else
          log "Found partition mount on ${partition_path}: ${possible_mnt_dir}"
          mnt_dir="${possible_mnt_dir}"
          atexit udisksctl unmount -f -b "${partition_path}"
        fi
      fi
    done
    
    if [ -z "${mnt_dir}" ]; then
      fatal 1 "Could not find the mount path"
    fi
fi

# if [ -z "$efi_partition" ]; then
#   fatal 1 "Could not find EFI partition on the ISO"
# fi

log "Copying EFI partition image"
if ! efi_partition_img=$(mktemp "${iso_file}.XXXXXXX.tmp" ); then
  fatal 1 "Could not make temporary file for EFI partition image"
fi
atexit rm -f "${efi_partition_img}"

# Race condition but \o/
rm -f "${efi_partition_img}"

log "Generating a new EFI partition image"
if ! mkfs.fat -i 37B6BC6E  -C -F 12 -n ESP "${efi_partition_img}" 16384 ; then
  fatal 1 "Failed to create new EFI partition image"
fi

log "Mount the EFI partition image"
if ! efi_loop_dev=$(udisksctl loop-setup -f "${efi_partition_img}" | grep -oP 'as .*'); then
    fatal 1 "Could not mount EFI partition image with udisks"
fi
efi_loop_dev="${efi_loop_dev##* }"
efi_loop_dev="${efi_loop_dev%%.*}"

log "Ensure a mount happens: ${efi_loop_dev}"
if ! ensure_mount "${efi_loop_dev}"; then
  fatal 1 "Failed to ensure mount for ${efi_loop_dev}"
fi
atexit udisksctl unmount -f -b "${efi_loop_dev}"

log "Find the mount directory for the EFI image"
if ! efi_mnt_dir="$(udisksctl info -b "${efi_loop_dev}" | tr -s ' ' | cut -d' ' -f2- | grep 'MountPoints' | cut -d' ' -f2)"; then
  fatal 1 "Could not find the mount directory for the new EFI image"
fi

log "Copy EFI files to the EFI partition (from the main image): ${efi_mnt_dir}"
if ! cp --no-preserve=all -r "${mnt_dir}/EFI" "${efi_mnt_dir}/EFI"; then
    fatal 1 "Failed to copy the ISO included EFI boot config"
fi

log "Copy the mounted ISO contents to the working directory (${mnt_dir} -> ${work_dir})"
if ! cp --no-preserve=all -r "${mnt_dir}/." "${work_dir}/"; then
    fatal 1 "Failed to copy the ISO file for editing"
fi

log "Copy the ks.cfg file to the working directory: ${kickstart_file} -> ${work_dir}"
if [ -n "$kickstart_file" ]; then
  if ! cp --no-preserve=all "$kickstart_file" "${work_dir}/ks.cfg" ; then
      fatal 1 "Error copying ks.cfg file to work directory"
  fi

if [ -n "$opt_root_password" ]; then
  log "Setting root password in kickstart file"
  if ! sed -i "/rootpw.*/d" "${work_dir}/ks.cfg" ; then
    fatal 1 "Failed to edit the kickstart root password"
  fi
  echo "rootpw --plaintext ${opt_root_password}" >> "${work_dir}/ks.cfg"
fi

if [ -n "$opt_root_sshkey" ]; then
  log "Setting root SSH key in kickstart file"
  if ! sed -i "/sshkey --username=root.*/d" "${work_dir}/ks.cfg" ; then
    fatal 1 "Failed to edit the kickstart root password"
  fi
  echo "sshkey --username=root ${opt_root_sshkey}" >> "${work_dir}/ks.cfg"
fi

  cat << EOF >> "${work_dir}/ks.cfg"

%pre --interpreter=/bin/bash
EOF

  if [ -n "${opt_proxy}" ]; then
    cat << EOF >> "${work_dir}/ks.cfg"
if ! grep '\[main\]'] /etc/dnf/dnf.conf ; then
  echo "[main]" >> /etc/dnf/dnf.conf
fi
sed -i "#\[main\]#aproxy = ${opt_proxy}" /etc/dnf/dnf.conf
echo "USING PROXY SERVER: ${opt_proxy}"
echo "## dnf.conf ##"
cat /etc/dnf/dnf.conf
echo ##############

EOF
  if ! sed -i "s#url.*#& --proxy ${opt_proxy} #" "${work_dir}/ks.cfg"; then
    fatal 1 "Error editing the kickstart file"
  fi

  fi

  if [ -n "${opt_trusted_ca}" ]; then
    cat << EOF >> "${work_dir}/ks.cfg"
cat << 'XEOF' > "/etc/pki/ca-trust/source/anchors/$(basename "${opt_trusted_ca}").crt"
$(cat "${opt_trusted_ca}")
XEOF
update-ca-trust
EOF
  fi

  cat << EOF >> "${work_dir}/ks.cfg"
%end
EOF

fi

# We need to ensure the image name is reflected into the grub.cfgs
cd_label="$(echo "${output_iso##*/}" | cut -c -32)"

for grub_cfg in "${work_dir}/boot/grub2/grub.cfg" "${work_dir}/EFI/BOOT/grub.cfg" "${work_dir}/EFI/BOOT/BOOT.conf" ; do
  log "Edit grub.cfg to change volume label"
  if ! sed -i -E "s/LABEL=\S+\ /LABEL=${cd_label}\ /g" "${grub_cfg}" ; then
    fatal 1 "Error while editing grub.cfg"
  fi

  log "Edit grub.cfg to trigger auto installer"
  if ! sed -i 's/set default=.*/set default="0"/' "${grub_cfg}" ; then
    fatal 1 "Error while editing grub.cfg"
  fi

  log "Edit grub.cfg to trigger auto installer"
  if ! sed -i 's/linux.*/& inst.ks=cdrom:\/ks.cfg console=tty0 console=ttyS0,115200n8/g' "${grub_cfg}" ; then
    fatal 1 "Error while editing grub.cfg"
  fi

  log "Edit grub.cfg to reduce boot delay"
  if ! sed -i 's/set timeout=.*/set timeout=3/g' "${grub_cfg}" ; then
    fatal 1 "Error while editing grub.cfg"
  fi

  grub_cfg_tmp=$(mktemp "${iso_file}.grub.cfg.XXXXXXX.tmp") 
  atexit rm -f "${grub_cfg_tmp}"

  cat << EOF > "${grub_cfg_tmp}"
# Serial Output Options
serial --unit=0 --speed=115200
terminal_input serial console
terminal_output serial console

$(cat "${grub_cfg}")
EOF

  # Copy grub cfg out
  if ! cat "${grub_cfg_tmp}" > "${grub_cfg}" ; then
    fatal 1 "grub.cfg editing failed"
  fi

done

log "Rebuild the ISO: ${cd_label}"
if ! xorriso -as mkisofs \
        -V "${cd_label}" \
        -o "${output_iso}" \
        --grub2-mbr "${work_dir}/boot_hybrid.img" \
        --protective-msdos-label \
        -partition_offset 16 \
        --mbr-force-bootable \
        -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "${efi_partition_img}" \
        -appended_part_as_gpt \
        -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
        -c "/boot.catalog" \
        -b "/images/eltorito.img" \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --grub2-boot-info \
        -eltorito-alt-boot \
        -e '--interval:appended_partition_2:::' \
        -no-emul-boot -J \
        -dir-mode 0755 \
        "${work_dir}" ; then
    fatal 1 "Rebuild of ISO failed"
fi

exit 0
