qm set 3000 -delete ide2
qm set 3000 -delete unused0
qm set 3000 -boot order=virtio0
qm set 3000 -net0 model=virtio,bridge=vmbr0,firewall=0,enabled=1
qm set 3000 -onboot 1



