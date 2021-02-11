# Launch Cloud Image

## Important!

This is a trusted virtualization environment. Which is to say, the script sets up assuming
that everything in your home directory can broadly be accessed and touched. The SELinux policy
changes are also not specific - we will be allowing any KVM process to access some of your home
files including your SSH keys. If you want to do something more specific or more secure, or you
want to play around with untrusted VMs and settings, then you'll need a different configuration.

## Requirements

You need NetworkManager configured to use systemd-resolved.

`/etc/NetworkManager/NetworkManager.conf` resolves systemd-resolved.

## Edit the default bridge to enable DNS

virsh -c qemu:///system net-edit default 

Add the line: `<domain name='default.libvirt' localOnly='yes' />`

virsh -c qemu:///system net-destroy default 
virsh -c qemu:///system net-start default 

## Configure Network Manager

You need to edit `/etc/NetworkManager/NetworkManager.conf` to look something like:

```ini
[main]
#plugins=ifcfg-rh
plugins=keyfile	
dns=systemd-resolved

[keyfile]
unmanaged-devices=interface-name:virbr*
```

This keeps it away from the libvirt bridge interface.

## Configure systemd-resolved 

```bash
mkdir /etc/systemd/resolved.conf.d
cat << EOF > /etc/systemd/resolved.conf.d/libvirt-redirect.conf
[Resolve]
DNS=192.168.122.1
Domains=~default.libvirt
EOF

systemctl restart systemd-resolved
```
## Configure bridge helper

```bash
cat << EOF > /etc/qemu/bridge.conf
allow virbr0
EOF

chown root:root /etc/qemu/bridge.conf
chmod 0644 /etc/qemu/bridge.conf

chmod u+s /usr/lib/qemu/qemu-bridge-helper
```

## Enable host passthrough to your home directory for SELinux

The following policy enables the virtual machines we launch to touch the home directory on the host.

Compile and install the host SELinux policy:


```bash
checkmodule -M -m -o launch-cloud-image.mod launch-cloud-image.te
semodule_package -o launch-cloud-image.pp -m launch-cloud-image.mod
sudo semodule -i launch-cloud-image.pp
```

This policy grants common sense access which allows read-everything but prevents updates to
config files and other non-userdata files.

# Repacking a Windows ISO for installation

```bash
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-2k19 2k19
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-2k19/vioscsi \
    --add-boot-drivers generated/virtio-2k19/viostor \
    --add-drivers generated/virtio-2k19 \
    --add-drivers win-2k19-server-standard/scripts \
    downloaded/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso \
    $(libvirt_default_pool)/win-2k19-Unattended-Virtio.iso \
    win-2k19-server-standard/autounattend.xml
```
