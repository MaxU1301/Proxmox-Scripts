helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.8 \
    --set nfs.path=/mnt/Ptonomy/k8s-NFS-test \
    --set storageClass.archiveOnDelete=false \
    --set storageClass.defaultClass=true \
    --set storageClass.accessModes=ReadWriteMany
    