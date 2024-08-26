# kvmboot

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

## Configure SWT-PM for the local user

/usr/share/swtpm/swtpm-create-user-config-files

### On Ubuntu
```
sudo aa-complain /usr/bin/swtpm
```

AppArmor profile is broken on Ubuntu 22.04

## Optional: Enable host passthrough to your home directory for SELinux

The following policy enables the virtual machines we launch to touch the home directory on the host.

Compile and install the host SELinux policy:

```bash
checkmodule -M -m -o kvmboot.mod kvmboot.te
semodule_package -o kvmboot.pp -m kvmboot.mod
sudo semodule -i kvmboot.pp
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

## Windows Server 2019

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
./kvmboot --efi --windows --installer win-2k19-Unattended-Virtio.iso Win2k19-Base
```

Then spawn a cloud image to test with:

```bash
./kvmboot --efi --windows lci.Win2k19-Base.root.qcow2 t1
```

## Windows Server 2022

```bash
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-2k22/virtio 2k22
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-2k22/virtio/vioscsi \
    --add-boot-drivers generated/virtio-2k22/virtio/viostor \
    --add-drivers generated/virtio-2k22 \
    --add-drivers downloaded/cloudbase-init \
    --add-drivers win-common/extra \
    --add-drivers win-common/cloudbase \
    --add-drivers win-2k22-server-standard/extra \
    downloaded/SERVER_EVAL_x64FRE_en-us.iso \
    $(libvirt_default_pool)/win-2k22-Unattended-Virtio.iso \
    win-2k22-server-standard/autounattend.xml
```

Then launch to install the base image:

```bash
./kvmboot --efi --windows --installer win-2k22-Unattended-Virtio.iso Win2k22-Base
```

Then spawn a cloud image to test with:

```bash
./kvmboot --efi --windows lci.Win2k22-Base.root.qcow2 t1
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
./kvmboot --efi --windows --installer win-10-unattended-virtio-image.iso win10-base
```

Then spawn a cloud image to test with:

```bash
./kvmboot --efi --windows lci.win10-base.root.qcow2 t1
```

## Windows 10 Updated Image
```bash
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-w10/virtio w10
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-w10/virtio/vioscsi \
    --add-boot-drivers generated/virtio-w10/virtio/viostor \
    --add-drivers generated/virtio-w10 \
    --add-drivers downloaded/cloudbase-init \
    --add-drivers win-common/extra \
    --add-drivers win-common/cloudbase \
    --add-drivers win-10-image-updated/extra \
    downloaded/Win10_20H2_v2_English_x64.iso \
    $(libvirt_default_pool)/win-10-unattended-virtio-image-updated.iso \
    win-10-image-updated/autounattend.xml
```

Then launch to install the base image:

```bash
./kvmboot --efi --windows --installer win-10-unattended-virtio-image-updated.iso win10-base
```

Then spawn a cloud image to test with:

```bash
./kvmboot --efi --windows lci.win10-base.root.qcow2 t1
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

## Windows 11 User Machine

This version skips the cloudbase-init step, and leaves you with an image which
provisions once the user sets up an account.

```bash
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-w11/virtio w11
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-w11/virtio/vioscsi \
    --add-boot-drivers generated/virtio-w11/virtio/viostor \
    --add-drivers generated/virtio-w11 \
    --add-drivers win-common/extra \
    --add-drivers win-11-user/extra \
    downloaded/Win11_23H2_English_x64v2.iso \
    $(libvirt_default_pool)/win-11-unattended-virtio-user.iso \
    win-11-user/autounattend.xml
```

The image that comes up should be able to be SSH'd into Powershell using your default SSH
key. The user will have your name but be administrator.

Then launch to install the base image:

```bash
./kvmboot --efi --windows --installer win-11-unattended-virtio-user.iso win11-base
```

## Windows 7 Image

```bash
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-w7/virtio w7
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-w7/virtio/vioscsi \
    --add-boot-drivers generated/virtio-w7/virtio/viostor \
    --add-drivers generated/virtio-w7 \
    --add-drivers downloaded/cloudbase-init \
    --add-drivers win-common/extra \
    --add-drivers win-common/cloudbase \
    --add-drivers win-7-image/extra \
    downloaded/en_windows_7_professional_with_sp1_vl_build_x64_dvd_u_677791.iso \
    $(libvirt_default_pool)/win-7-unattended-virtio-image-updated.iso \
    win-7-image/autounattend.xml
```

Then launch to install the base image:

```bash
./kvmboot --cpus 1 --efi --windows --installer win-7-unattended-virtio-image-updated.iso win7-base
```

Note: For some reason Windows can't hack a multi-core install.
This image will also fail with a driver signing problem which doesn't have a
clean solution in Linux land. You need to F8 around and disable enforcement
until updates apply.

Then spawn a cloud image to test with:

```bash
./kvmboot --efi --windows lci.win7-base.root.qcow2 t1
```

## Windows 8 Image

Very similar to Windows 7:

```bash
# This is not a typo! The Windows 10 drivers will work, but the Windows 8.1 ones will not
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-w10/virtio w10
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-w10/virtio/vioscsi \
    --add-boot-drivers generated/virtio-w10/virtio/viostor \
    --add-drivers generated/virtio-w10 \
    --add-drivers downloaded/cloudbase-init \
    --add-drivers win-common/extra \
    --add-drivers win-common/cloudbase \
    --add-drivers win-8-image/extra \
    downloaded/en_windows_8_1_x64_dvd_2707217.iso \
    $(libvirt_default_pool)/win-8-unattended-virtio-image-updated.iso \
    win-8-image/autounattend.xml
```

Then launch to install the base image:

```bash
./kvmboot --efi --windows --installer win-8-unattended-virtio-image-updated.iso win8-base
```

# Windows 8 User Image

```
./prepare-virtio-driver-tree downloaded/virtio-win.iso generated/virtio-w10/virtio w10
./prepare-windows-iso \
    --add-boot-drivers generated/virtio-w10/virtio/vioscsi \
    --add-boot-drivers generated/virtio-w10/virtio/viostor \
    --add-drivers generated/virtio-w10 \
    --add-drivers downloaded/cloudbase-init \
    --add-drivers win-common/extra \
    --add-drivers win-common/cloudbase \
    --add-drivers win-8-user/extra \
    downloaded/en_windows_8_1_x64_dvd_2707217.iso \
    $(libvirt_default_pool)/win-8-unattended-virtio-user-updated.iso \
    win-8-user/autounattend.xml
```

Then launch to install the base image:

```bash
./kvmboot --efi --windows --installer win-8-unattended-virtio-image-updated.iso win8-base
```

## Ubuntu 24.04 Image

Run the following to build an autoinstalling Ubuntu 24.04 image. The reason to do this over using the cloud-init
images is to get a ZFS filesystem.



## Injecting an initial SSH key for Administrator
This can be done by inserting a file into C:\ProgramData\ssh\administrators_authorized_keys

# On the handling of optional Windows components

For the user without internet access, and without a WSUS/SCCM server, it is
apparently almost impossible to handle optional Windows components. The only
practical solution is to install ALL of them on a sample Windows image, and use
that as the source for the rest of them:

```powershell
Get-WindowsOptionalFeature -Online | Select-Object FeatureName | ForEach-Object {
Enable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -All }  
```

Then copy the disk image (or just `C:\Windows`) to your offline environment.

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
