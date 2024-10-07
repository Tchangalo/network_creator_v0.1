#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False

node=$1
provider=$2
destroy=$3
routers=$4
ansible_limit=$5

C='\033[0;94m'
NC='\033[0m'

sleeping ()
{
    for r in $(seq 1 $2)
    do
	while sleep 5
	do
	    ansible -i ${HOME}/streams/ansible/inventories/inventory${provider}.yaml p$1r${r}v -m ping -u vyos | grep -q pong && break
	done
	echo -e "${C}Router ${r} is running${NC}"
    done
}

# destroy and recreate vms
cd ${HOME}/streams/create-vms/create-vms-vyos/

#destroy
if [ $destroy == 1 ]
   then
       echo -e "${C}Destroying VMs${NC}"
       for r in $(seq 1 ${routers})
       do
	   sudo qm stop ${node}0${provider}00${r}
	   sudo bash create-vm-vyos-turbo.sh -c destroy -n ${node} -p ${provider} -r ${r}
       done
fi

#create and start
echo -e "${C}Starting VMs${NC}"
for r in $(seq 1 ${routers})
do
    sudo bash create-vm-vyos-turbo.sh -c create -n ${node} -p ${provider} -r ${r}
    sudo qm start ${node}0${provider}00${r}
    ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "10.20.30.${provider}${r}"
done

#sleeping
echo -e "${C}Waiting for first boot${NC}"
sleeping $provider $routers

#upgrade
cd ${HOME}/streams/ansible
echo -e "${C}System upgrade${NC}"
ansible-playbook -i inventories/inventory${provider}.yaml vyos_upgrade_turbo.yml -e "vyos_version=$(ls -t ${HOME}/streams/ansible/vyos-files/ | head -n 1 | sed -e 's/^vyos-//' | sed -e 's/-amd.*$//')" $ansible_limit

#sleeping
echo -e "${C}Waiting for second boot${NC}"
sleeping $provider $routers

#configuring
echo -e "${C}Configuring network${NC}"
ansible-playbook -i inventories/inventory${provider}.yaml setup.yml $ansible_limit

#remove cdrom
echo -e "${C}Removing cdrom${NC}"
for r in $(seq 1 ${routers})
do
    sudo qm set ${node}0${provider}00${r} --ide2 media=cdrom,file=none
done

#reboot
echo -e "${C}Final reboot${NC}"
ansible-playbook -i inventories/inventory${provider}.yaml vyos_reboot.yml $ansible_limit

echo -e "${C}All done. Wait a minute until the network is running.${NC}"
