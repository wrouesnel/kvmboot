#!/bin/bash
# Upload a file to a libvirt store

# log functions
function log() {
  echo "$*" 1>&2
}

function fatal() {
  local exit_code="$1"
  shift
  echo "FATAL: $*" 1>&2
  exit "$exit_code"
}

# atexit handler
ATEXIT=()

function atexit() {
  ATEXIT+=( "$*" )
}

function _atexit_handler() {
  local EXPR
  for EXPR in "${ATEXIT[@]}"; do
    #log "atexit: $EXPR"
    eval "$EXPR"
  done
}

trap _atexit_handler EXIT

if [ -z "${VIRSH_DEFAULT_CONNECT_URI}" ]; then
  if [ $EUID -eq 0 ]; then
    log "Running as root: using system daemon"
    default_connect="qemu:///system"
  else
    log "Running as user: using session daemon"
    default_connect="qemu:///session"
  fi
fi

virsh="$(command -v virsh) -q --connect=${VIRSH_DEFAULT_CONNECT_URI:-$default_connect}"

# Default libvirt pool
_default_pool="default"

# Collect optional arguments
opt_pool="${_default_pool}"
while [ -n "$1" ] ; do
    arg="$1"
    case $arg in
    --pool)
        shift
        opt_pool="$1"
        ;;
    --help)
      cat << EOF 1>&2
$0 <src file> [dst name]

    --pool  Destination pool to upload to (default:${_default_pool})
EOF
        exit 0
        ;;
    --)
        break
        ;;
    -*)
        break
        ;;
    *)
        break
        ;;
    esac
    shift
done

src_name="$1"

if [ ! -e "$src_name" ]; then
    fatal 1 "$src_name does not exist!"
fi

if [ ! -f "$src_name" ]; then
    fatal 1 "$src_name is not a file!"
fi

shift

if [ -n "$1" ]; then
    dst_name="$1"
else
    dst_name="$(basename "$src_name")"
fi

src_size=$(stat --format "%s" "$src_name")


if ! $virsh vol-create-as --pool "$opt_pool" --name "$dst_name" --format raw --capacity "$src_size" 1>&2 ; then
    fatal 1 "Could not create new volume in $opt_pool pool"
fi

# Upload to volume
if ! $virsh vol-upload --pool "$opt_pool" --offset 0 --length "$src_size" "$dst_name" "$src_name" 1>&2 ; then
    $virsh vol-delete --pool "$opt_pool" "$dst_name" || log "Failed to delete $dst_name. Please delete manually."
    fatal 1 "Could not upload to volume"
fi

exit 0