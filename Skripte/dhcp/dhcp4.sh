#!/bin/bash
qm create 407999 --name "dhcp4" --ostype l26 --memory 8192 --balloon 8192 --cpu host --cores 4 --scsihw virtio-scsi-single --virtio0 local-btrfs:8,discard=on --net0 virtio,bridge=vmbr0,macaddr="00:24:18:0A:CE:DE"
qm importdisk 407999 /var/lib/pve/local-btrfs/template/iso/ubuntu-24.04.1-live-server-amd64.iso local-btrfs
qm set 407999 --ide2 local-btrfs:iso/ubuntu-24.04.1-live-server-amd64.iso,media=cdrom
qm set 407999 --boot order=ide2
qm set 407999 -net1 model=virtio,bridge=vmbr1001,firewall=0
