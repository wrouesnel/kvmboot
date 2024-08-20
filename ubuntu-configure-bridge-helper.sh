#!/bin/bash

# Request sudo
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

cat << EOF > /etc/qemu/bridge.conf
allow virbr0
EOF

chown root:root /etc/qemu/bridge.conf
chmod 0644 /etc/qemu/bridge.conf

chmod u+s /usr/lib/qemu/qemu-bridge-helper

# Ubuntu Noble has a bug where it looks for the local CA command here
if [ ! -e "/usr/lib/x86_64-linux-gnu/swtpm/swtpm-localca" ]; then
    if command -v swtpm_localca 1>/dev/null 2>&1; then
        ln -sf "$(command -v swtpm_localca)" "/usr/lib/x86_64-linux-gnu/swtpm/swtpm-localca"
    fi
fi