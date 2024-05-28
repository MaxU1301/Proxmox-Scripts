# Create VM Template

release=24.04
vmid=9000 # Final Template ID
file=ubuntu-"$release"-server-cloudimg-amd64.img

# Get Ubuntu Cloud Image
if [ -f "$file" ]; then rm $file; fi
wget https://cloud-images.ubuntu.com/releases/"$release"/release/ubuntu-"$release"-server-cloudimg-amd64.img

# Get SetupQuartz.sh script
if [ -f SetupQuartz.sh ]; then rm SetupQuartz.sh; fi
wget https://github.com/MaxU1301/Proxmox-Scripts/raw/main/SubScripts/SetupQuartz.sh

# Install Packages
virt-customize -a "$file" --install qemu-guest-agent
virt-customize -a "$file" --install cifs-utils
virt-customize -a "$file" --install nfs-common
virt-customize -a "$file" --install linux-modules-extra-6.8.0-31-generic # Needs to be found for every release version

# Extra Packages
virt-customize -a "$file" --run-command 'add-apt-repository ppa:zhangsongcui3371/fastfetch'
virt-customize -a "$file" --install fastfetch,gh

# Setting First Boot Commands
#virt-customize -a "$file" --firstboot-install 

# First Boot Commands Remove Machine ID
virt-customize -a "$file" --firstboot-command 'echo -n >/etc/machine-id'
virt-customize -a "$file" --firstboot-command 'rm /var/lib/dbus/machine-id'
virt-customize -a "$file" --firstboot-command 'ln -s /etc/machine-id /var/lib/dbus/machine-id'
virt-customize -a "$file" --firstboot-command 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'

# Create Script To Set as K8s Master
chmod +x SetupQuartz.sh
virt-customize -a "$file" --upload 'SetupQuartz.sh:/home/SetupQuartz.sh'

# Mount CIFS Share
# virt-customize -a "$file" --mkdir /media/Ptonomy
# virt-customize -a "$file" --append-line '/etc/fstab://192.168.1.8/Ptonomy /media/Ptonomy cifs credentials=/home/.smbcredentials 0 0'
# virt-customize -a "$file" --run-command 'touch /home/.smbcredentials'
# virt-customize -a "$file" --append-line '/home/.smbcredentials:username=mullrich'
# virt-customize -a "$file" --append-line '/home/.smbcredentials:password=%3^#Beddq@4fbj'

# Mount NFS Share
# virt-customize -a "$file" --mkdir /media/Ptonomy
# virt-customize -a "$file" --append-line '/etc/fstab:192.168.1.8:/mnt/Ptonomy/Ptonomy /media/Ptonomy nfs defaults 0 0'

# Allow SSH Password Login (Unsafe)
# virt-customize -a "$file" --run-command 'echo "PasswordAuthentication yes" | tee /etc/ssh/sshd_config.d/60-cloudimg-settings.conf'

# Create VM Template
qm create "$vmid" --name "ubuntu-2404-template" --memory 4096 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk "$vmid" "$file" local-lvm
qm set "$vmid" --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-"$vmid"-disk-0
qm set "$vmid" --boot c -bootdisk scsi0
qm set "$vmid" --ide2 local-lvm:cloudinit
qm set "$vmid" --serial0 socket --vga serial0
qm set "$vmid" --agent enabled=1

# Set if VM Boots on System Start
qm set "$vmid" --onboot 0 # Default = 0

# Resize Template Disk to 10 GiB total
qm resize "$vmid" scsi0 +6.5G

qm template "$vmid"