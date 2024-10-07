qm set X000 -delete ide2
qm set X000 -boot order=virtio0
qm set X000 -net0 model=virtio,bridge=vmbr0,firewall=0,enabled=1
qm set X000 -onboot 1



