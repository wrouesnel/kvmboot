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

```bash
virsh -c qemu:///system net-edit default 
```

Add the line: `<domain name='default.libvirt' localOnly='yes' />`

A complete confirguraiton will look something like:

```xml
<network xmlns:dnsmasq='http://libvirt.org/schemas/network/dnsmasq/1.0'>
  <name>default</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:a0:27:2f'/>
  <domain name='default.libvirt' localOnly='yes'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
```
The dnsmasq options ensure that changing hostnames are reflected into dnsmasq by libvirt.

```bash
virsh -c qemu:///system net-destroy default 
virsh -c qemu:///system net-start default 
```

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

## Optional: Enable host passthrough to your home directory for SELinux

The following policy enables the virtual machines we launch to touch the home directory on the host.

Compile and install the host SELinux policy:

```bash
checkmodule -M -m -o launch-cloud-image.mod launch-cloud-image.te
semodule_package -o launch-cloud-image.pp -m launch-cloud-image.mod
sudo semodule -i launch-cloud-image.pp
```

This policy grants common sense access which allows read-everything but prevents updates to
config files and other non-userdata files.

# Setup a bashrc function which will find the libvirt default pool

```bash
function libvirt_default_pool() {
    virsh -c qemu:///session pool-dumpxml default | xmlstarlet sel -t -m '//path' -v . -n
}
```

# Repacking a Windows ISO for installation

## Windows Server

```bash
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-2k19/virtio 2k19
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-2k19/virtio/vioscsi \
    --add-boot-drivers generated/virtio-2k19/virtio/viostor \
    --add-drivers generated/virtio-2k19 \
    --add-drivers downloaded/cloudbase-init \
    --add-drivers win-common/extra \
    --add-drivers win-common/cloudbase \
    --add-drivers win-2k19-server-standard/extra \
    downloaded/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso \
    $(libvirt_default_pool)/win-2k19-Unattended-Virtio.iso \
    win-2k19-server-standard/autounattend.xml
```

Then launch to install the base image:

```bash
./launch-cloud-image --efi --windows --installer win-2k19-Unattended-Virtio.iso Win2k19-Base
```

Then spawn a cloud image to test with:

```bash
./launch-cloud-image --efi --windows lci.Win2k19-Base.root.qcow2 t1
```

## Windows 10 Image
```bash
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-w10/virtio w10
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-w10/virtio/vioscsi \
    --add-boot-drivers generated/virtio-w10/virtio/viostor \
    --add-drivers generated/virtio-w10 \
    --add-drivers downloaded/cloudbase-init \
    --add-drivers win-common/extra \
    --add-drivers win-common/cloudbase \
    --add-drivers win-10-image/extra \
    downloaded/Win10_20H2_v2_English_x64.iso \
    $(libvirt_default_pool)/win-10-unattended-virtio-image.iso \
    win-10-image/autounattend.xml
```

Then launch to install the base image:

```bash
./launch-cloud-image --efi --windows --installer win-10-unattended-virtio-image.iso win10-base
```

Then spawn a cloud image to test with:

```bash
./launch-cloud-image --efi --windows lci.win10-base.root.qcow2 t1
```

## Windows 10 User Machine

This version skips the cloudbase-init step, and leaves you with an image which
provisions once the user sets up an account.

```bash
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-w10/virtio w10
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-w10/virtio/vioscsi \
    --add-boot-drivers generated/virtio-w10/virtio/viostor \
    --add-drivers generated/virtio-w10 \
    --add-drivers win-common/extra \
    --add-drivers win-10-user/extra \
    downloaded/Win10_20H2_v2_English_x64.iso \
    $(libvirt_default_pool)/win-10-unattended-virtio-user.iso \
    win-10-user/autounattend.xml
```

The image that comes up should be able to be SSH'd into Powershell using your default SSH
key. The user will have your name but be administrator.

## Injecting an initial SSH key for Administrator
This can be done by inserting a file into C:\ProgramData\ssh\administrators_authorized_keys

# On the handling of optional Windows components

For the user without internet access, and without a WSUS/SCCM server, it is
apparently almost impossible to handle Windows components

# References

## Cloudbase Init Unattended install support params

```
msiexec /i CloudbaseInitSetup_x64.msi /qn /l*v log.txt CLOUDBASEINITCONFFOLDER="C:\" LOGGINGSERIALPORTNAME="COM1" BINFOLDER="C:\bin" LOGFOLDER="C:\log" USERNAME="admin1" INJECTMETADATAPASSWORD="TRUE" USERGROUPS="Administrators" LOGGINGSERIALPORTNAME="COM2" LOCALSCRIPTSFOLDER="C:\localscripts"

There are also MAAS related parameters that you can define. Here is the list: MAASMETADATAURL, MAASOAUTHCONSUMERKEY, MAASOAUTHCONSUMERSECRET, MAASOAUTHTOKENKEY, MAASOAUTHTOKENSECRET.
```

## Sysprep action

Note: for some reason this doesn't launch with Start-Process in Powershell.

```
cd C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf

C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /unattend:Unattend.xml
```
