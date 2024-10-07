#!/bin/bash
qm create 2000 --name "pfSense2" --ostype other --memory 1536 --cpu host --cores 2 --scsihw virtio-scsi-pci --virtio0 local-btrfs:8,discard=on --net0 virtio,bridge=vmbr0
qm importdisk 2000 /var/lib/pve/local-btrfs/template/iso/pfSense-CE-2.7.2-RELEASE-amd64.iso local-btrfs
qm set 2000 --ide2 local-btrfs:iso/pfSense-CE-2.7.2-RELEASE-amd64.iso,media=cdrom
qm set 2000 --boot order=ide2