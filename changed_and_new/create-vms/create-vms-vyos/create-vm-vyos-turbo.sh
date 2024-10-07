#!/bin/env bash

set -euo pipefail
while getopts c:n:p:r: flag
do
    case "${flag}" in
	c) command=${OPTARG};;
	n) node=${OPTARG};;
	p) provider=${OPTARG};;
	r) router=${OPTARG};;
    esac
done

echo "vmid:${node}0${provider}00${router} provider:${provider} router:${router}"

if [[ -n "${node+set}" && "${provider+set}" && "${router+set}" ]]
then
    vmid=${node}0${provider}0`printf '%02d' $router`
	mgmtmac=00:24:18:A${provider}:`printf '%02d' $router`:00
    
    case "${command}" in
	create)
	    vmid=${node}0${provider}0`printf '%02d' $router`
	    ## Create VM, import disk and define boot order
	    qm create $vmid --name "p${provider}r${router}v" --ostype l26 --memory 1664 --balloon 1664 --cpu cputype=host --cores 4 --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr1001,,macaddr="${mgmtmac}"
	    qm importdisk $vmid vyos-1.5.0-cloud-init-10G-qemu.qcow2 local-btrfs
	    qm set $vmid --virtio0 local-btrfs:$vmid/vm-$vmid-disk-0.raw
	    qm set $vmid --boot order=virtio0
	    
	    ## add interfaces to the router
	    for net in {1..4}
	    do
		vlanid=$(/home/user/streams/vlans3.sh 8 2 $router $net $provider)
		#qm set $vmid --net${net} virtio,bridge=vmbr${provider},tag=${provider}`printf '%02d' $router`${net},macaddr=00:${node}4:18:F${provider}:`printf '%02d' $router`:`printf '%02d' $net`
		qm set $vmid --net${net} virtio,bridge=vmbr${provider},tag=${vlanid},macaddr=00:${node}4:18:F${provider}:`printf '%02d' $router`:`printf '%02d' $net`
	    done
	    ## Import seed.iso for cloud init
	    qm set $vmid --ide2 media=cdrom,file=local-btrfs:iso/seed.iso
	    
	    echo "                {
                    \"hw-address\": \"${mgmtmac}\",
                    \"ip-address\": \"10.20.30.${provider}${router}\",
                    \"client-classes\": [ \"KnownClients\" ]
                }," >> dhcp.config.txt

	    ;;

	destroy)
	    qm stop $vmid && qm destroy $vmid
	    ;;

	dhcp)
	    echo "                {
                    \"hw-address\": \"${mgmtmac}\",
                    \"ip-address\": \"10.20.30.${provider}${router}\",
                    \"client-classes\": [ \"KnownClients\" ]
                },"
	    ;;

	*)
	    echo "hi there, possible commands are create and destroy"
	    ;;
    esac

else
    echo "something went wrong"

fi



