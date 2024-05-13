# Create VM Template

release=24.04
vmid=9000 # Change VM ID
file=ubuntu-"$release"-server-cloudimg-amd64.img
rm "$file"
wget https://cloud-images.ubuntu.com/releases/"$release"/release/ubuntu-"$release"-server-cloudimg-amd64.img

# Install Packages
virt-customize -a "$file" --install qemu-guest-agent
virt-customize -a "$file" --install linux-modules-extra-6.8.0-31-generic # Needs to be found for every release version
virt-customize -a "$file" --install cifs-utils
virt-customize -a "$file" --install nfs-common

# Extra Packages
virt-customize -a "$file" --run-command 'add-apt-repository ppa:zhangsongcui3371/fastfetch'
virt-customize -a "$file" --install fastfetch

# Mount CIFS Share
# virt-customize -a "$file" --mkdir /media/Ptonomy
# virt-customize -a "$file" --append-line '/etc/fstab://192.168.1.8/Ptonomy /media/Ptonomy cifs credentials=/home/.smbcredentials 0 0'
# virt-customize -a "$file" --run-command 'touch /home/.smbcredentials'
# virt-customize -a "$file" --append-line '/home/.smbcredentials:username=mullrich'
# virt-customize -a "$file" --append-line '/home/.smbcredentials:password=%3^#Beddq@4fbj'

# Mount NFS Share
virt-customize -a "$file" --mkdir /media/Ptonomy
virt-customize -a "$file" --append-line '/etc/fstab:192.168.1.8:/mnt/Ptonomy/Ptonomy /media/Ptonomy nfs defaults 0 0'

# Create VM Template
qm create "$vmid" --name "ubuntu-2404-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk "$vmid" "$file" local-lvm
qm set "$vmid" --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-"$vmid"-disk-0
qm set "$vmid" --boot c -bootdisk scsi0
qm set "$vmid" --ide2 local-lvm:cloudinit
qm set "$vmid" --serial0 socket --vga serial0
qm set "$vmid" --agent enabled=1
# Set if VM Boots on System Start
qm set "$vmid" --onboot 0 # Default = 0
# Resize Template Disk (Do When Cloned Not Here)
# qm resize "$vmid" scsi0 +20G
qm template "$vmid"