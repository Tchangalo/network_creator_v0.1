#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False

node=$1
provider=$2
destroy=$3
router=$4

C='\033[0;94m'
NC='\033[0m'

sleeping ()
{
	while sleep 5
	do
	    ansible -i ${HOME}/streams/ansible/inventories/inventory${provider}.yaml p$1r${router}v -m ping -u vyos | grep -q pong && break
	done
	echo -e "${C}Router ${router} is running${NC}"
}

#destroy and recreate vms
cd ${HOME}/streams/create-vms/create-vms-vyos/

#destroy
if [ $destroy == 1 ]
   then
       echo -e "${C}Destroying VM${NC}"
	   sudo qm stop ${node}0${provider}00${router}
	   sudo bash create-vm-vyos.sh -c destroy -n ${node} -p ${provider} -r ${router}
       #sleep 1
fi

#create
echo -e "${C}Creating VM${NC}"
sudo bash create-vm-vyos.sh -c create -n ${node} -p ${provider} -r ${router}
#sleep 1

#start
echo -e "${C}Starting VM${NC}"
sudo qm start ${node}0${provider}00${router}

#ssh-keygen
echo -e "${C}ssh-keygen${NC}"
ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "10.20.30.${provider}${router}"

#sleeping
echo -e "${C}Waiting for first boot${NC}"
sleeping $provider $router

#upgrade and reboot
cd ${HOME}/streams/ansible
echo -e "${C}System upgrade and reboot${NC}"
ansible-playbook -i inventories/inventory${provider}.yaml vyos_upgrade_turbo.yml -e "vyos_version=$(ls -t ${HOME}/streams/ansible/vyos-files/ | head -n 1 | sed -e 's/^vyos-//' | sed -e 's/-amd.*$//')" -l "p${provider}r${router}v"

#sleeping
echo -e "${C}Waiting for second boot${NC}"
sleeping $provider $router

#configuring
echo -e "${C}Configuring network${NC}"
ansible-playbook -i inventories/inventory${provider}.yaml setup.yml "-l p${provider}r${router}v"

#remove cdrom
echo -e "${C}Removing cdrom${NC}"
sudo qm set ${node}0${provider}00${router} --ide2 media=cdrom,file=none

#reboot
echo -e "${C}Final reboot${NC}"
ansible-playbook -i inventories/inventory${provider}.yaml vyos_reboot.yml -l "p${provider}r${router}v"

echo -e "${C}All done. Wait a minute until the router is running.${NC}"
