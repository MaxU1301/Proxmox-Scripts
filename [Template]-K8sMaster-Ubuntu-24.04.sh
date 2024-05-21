# Create VM Template

release=24.04
vmid=9001 # Final Template ID
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

# Install K8s Using kubeadm
virt-customize -a "$file" --run-command 'ufw disable'
virt-customize -a "$file" --run-command 'swapoff -a; sed -i '/swap/d' /etc/fstab'
virt-customize -a "$file" --run-command 'echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf'
virt-customize -a "$file" --run-command 'echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/kubernetes.conf'
virt-customize -a "$file" --run-command 'sysctl --system'

virt-customize -a "$file" --run-command 'apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common'
virt-customize -a "$file" --run-command 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"'
virt-customize -a "$file" --run-command 'apt update'
virt-customize -a "$file" --run-command 'apt install -y docker-ce containerd.io'

virt-customize -a "$file" --run-command 'curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'
virt-customize -a "$file" --run-command 'apt install -y kubeadm kubelet kubectl'
# virt-customize -a "$file" --install kubelet
# virt-customize -a "$file" --install kubectl

# Set up as K8s Master
if [ -e "runme.sh"]; then
    rm runme.sh
fi
touch runme.sh

echo "
ipaddr=\$(ip a s eth0 | grep -E -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
kubeadm init --apiserver-advertise-address=\${ipaddr} --pod-network-cidr=\${ipaddr}/23  --ignore-preflight-errors=all
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
kubeadm token create --print-join-command" >> runme.sh

virt-customize -a "$file" --firstboot runme.sh

rm runme.sh


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