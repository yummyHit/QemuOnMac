#!/bin/bash
#######################################
# Made by yummyHit
#######################################
# cleaner network
#######################################
# disable ip forwarding
#######################################
if [ `id | awk '{print $1}' | awk -F"[=(]" '{print $2}'` != "0" ]; then
	echo "You must run script with su or sudo command"
	exit 127
fi

qemu_pid=`ps -ef | grep "qemu-system-i386.*ubuntu_kernel.img" | grep -v grep | awk '{print $2}'`

if [ "$qemu_pid" != "" ]; then
	kill -9 $qemu_pid
fi

sudo sysctl -w net.inet.ip.forwarding=0

guest_ip="192.168.123.50"
gateway_ip="192.168.123.1"
subnet_mask="255.255.255.0"

sudo route delete -host $guest_ip $gateway_ip $subnet_mask
