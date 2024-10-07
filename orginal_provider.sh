#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False

node=$1
provider=$2
destroy=$3
routers=$4
ansible_limit=$5

sleeping ()
{
    for r in $(seq 1 $2)
    do
	while sleep 5
	do
	    ansible -i /home/aibix/streams/ansible/inventories/inventory1.yaml p$1r${r}v -m ping -u vyos | grep -q pong && break
	    #nc -z -w5 10.20.30.${provider}${r} 22 && break
	done
	echo "router ${r}"
    done
}

# destroy and recreate vms
cd ${HOME}/streams/create-vms/create-vms-vyos/

#destroy
if [ $destroy == 1 ]
   then
       echo "destroying vms"
       for r in $(seq 1 ${routers})
       do
	   sudo qm stop ${node}0${provider}00${r}
	   sudo bash create-vm-vyos.sh -c destroy -n ${node} -p ${provider} -r ${r}
       done
fi

#create
echo "creating vms"
for r in $(seq 1 ${routers})
do
    sudo bash create-vm-vyos.sh -c create -n ${node} -p ${provider} -r ${r}
    sudo qm start ${node}0${provider}00${r}
    ssh-keygen -f "/home/aibix/.ssh/known_hosts" -R "10.20.30.1${r}"
done

#sleeping
echo "waiting for first boot"
sleeping $provider $routers

#update and reboot
cd ${HOME}/streams/ansible
echo "system upgrade"
#ansible-playbook -i inventories/inventory${provider}.yaml vyos_update.yml
ansible-playbook -i inventories/inventory${provider}.yaml vyos_update.yml -e "vyos_version=$(ls -t ${HOME}/streams/ansible/vyos-files/ | head -n 1 | sed -e 's/^vyos-//' | sed -e 's/-amd.*$//')" $ansible_limit

#sleeping
echo "waiting for second boot"
sleep 60
#sleeping $provider $routers

#reboot (hart; wegen kaputtem cloud-init)
echo "hard reboot due to broken cloud-init"
for r in $(seq 1 ${routers})
do
    sudo qm reset ${node}0${provider}00${r}
    sleep 10
done

#sleeping
echo "waiting for third boot"
sleeping $provider $routers

#configuring
echo "configuring network"
ansible-playbook -i inventories/inventory${provider}.yaml setup.yml $ansible_limit

#remove cdrom
echo "removing cdrom"
for r in $(seq 1 ${routers})
do
    sudo qm set ${node}0${provider}00${r} --ide2 media=cdrom,file=none
done

#reboot (muss nicht sein, aber mal checken schadet ja nicht)
echo "third reboot"
ansible-playbook -i inventories/inventory${provider}.yaml vyos_reboot.yml $ansible_limit

echo "all done, enjoy!"
