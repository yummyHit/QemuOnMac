#!/bin/bash
#######################################
# Made by yummyHit
#######################################
# for ubuntu low versions
#######################################
# for parallels can't execute versions
#######################################
# for use network in virt env
#######################################
if [ `id | awk '{print $1}' | awk -F"[=(]" '{print $2}'` != "0" ]; then
	echo "You must run script with su or sudo command"
	exit 127
fi

echo
printf "Guest IP: "
read guest_ip
echo
printf "Gateway IP: "
read gateway_ip
echo
printf "Subnet Mask: "
read subnet_mask
echo

c_class_rt=`echo "$gateway_ip" | awk -F"." '{print $NF}'`
c_class_subnet=`echo "$subnet_mask" | awk -F"." '{print $NF}'`
c_class_host=$(($c_class_rt & $c_class_subnet))
host_net="`echo $gateway_ip | awk -F"." '{print $1"."$2"."$3}'`.$c_class_host"

stop_script=$(cat $(pwd)/stop.sh | sed -e 's/guest_ip=.*/guest_ip="'$guest_ip'"/g' -e 's/gateway_ip=.*/gateway_ip="'$gateway_ip'"/g' -e 's/subnet_mask=.*/subnet_mask="'$subnet_mask'"/g')
echo "$stop_script" > $(pwd)/stop.sh

# install with ubuntu-6.10-desktop-i386.iso
#qemu-system-i386 -hda ubuntu_kernel.img -cdrom ~/Downloads/ubuntu-6.10-desktop-i386.iso -m 2048 -boot d

# below.. qemu-bridge-helper not found
#qemu-system-i386 -hda ubuntu_kernel.img -cpu host -smp 2 -m 2G \
#	-drive file=ubuntu_kernel.img,cache=none,if=virtio,format=raw \
#	-device virtio-net-pci,mac=E2:F2:6A:01:9D:C9,netdev=br0 \
#	-netdev bridge,br=br-lan,id=br0 -boot d

# Error.. Parameter 'type' expects a net backend type (maybe it is not compiled into this binary)
printf -v macaddr "52:54:%02x:%02x:%02x:%02x" $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff ))
#qemu-system-i386 -net nic,macaddr="$macaddr" -net vde ubuntu_kernel.img -m 2G -boot d

# tuntap error with mac os such as not found directory tun0/tap0
#sudo ifconfig bridge1 create
#sudo ifconfig bridge1 $c_class_host.1/24
#sudo ifconfig bridge1 addm tap0
#sudo pfctl -F all
#sudo pfctl -f $(pwd)/pfctl_nat_config -e

# startx, but it can't use network
sudo sysctl -w net.inet.ip.forwarding=1
sudo route add -host $guest_ip $gateway_ip $subnet_mask
qemu-system-i386 -hda ubuntu_kernel.img -m 2048 -device e1000,netdev=qemudev,mac=$macaddr -netdev user,id=qemudev,net=$host_net/24,dhcpstart=$guest_ip -boot d &
