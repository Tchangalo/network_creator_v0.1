#!/bin/bash
qm create X07999 --name "dhcpX" --ostype l26 --memory 8192 --balloon 8192 --cpu host --cores 4 --scsihw virtio-scsi-single --virtio0 local-btrfs:8,discard=on --net0 virtio,bridge=vmbr0,macaddr="00:24:18:0A:CX:DE"
qm importdisk X07999 /var/lib/pve/local-btrfs/template/iso/ubuntu-24.04.1-live-server-amd64.iso local-btrfs
qm set X07999 --ide2 local-btrfs:iso/ubuntu-24.04.1-live-server-amd64.iso,media=cdrom
qm set X07999 --boot order=ide2
qm set X07999 -net1 model=virtio,bridge=vmbrX001,firewall=0
