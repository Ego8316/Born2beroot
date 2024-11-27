#!/bin/bash

ARCH=$(uname -srvmo)
PHYS=$(grep 'physical id' /proc/cpuinfo | sort | uniq | wc -l)
VIRT=$(grep 'processor' /proc/cpuinfo | wc -l)

UMEM=$(free -m | awk '/^Mem:/ {printf "%.0f", $3 * 1.048576}')
TMEM=$(free -m | awk '/^Mem:/ {printf "%.0f", $2 * 1.048576}')
PRAM=$(free -k | awk '/^Mem:/ {printf "%.2f%%", $3 / $2 * 100}')

UDSK=$(df -BG --total | awk '/^total/ {print $3}')
TDSK=$(df -BG --total | awk '/^total/ {print $2}')
PDSK=$(df --total | awk '/^total/ {print $5}')

PCPU=$(top -bn1 | awk '/^%Cpu/ {printf "%.1f%%", $2 + $4}')
BOOT=$(who -b | awk '{print $3 " " $4'})
LVMU=$(if [ $(lsblk -o TYPE | grep "lvm" | wc -l) -eq 0 ] ; then echo no; else echo yes; fi)
CTCP=$(ss -Ht | grep ESTAB | wc -l)
USER=$(users | wc -w)
IPVF=$(hostname -I)
MACA=$(ip link show | grep ether | awk '{print $2}')
SUDO=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

echo "		----------------------------------------
		#Architecture		:	$ARCH
		#Physical CPUs		:	$PHYS
		#Virtual CPUs		:	$VIRT
		#Memory Usage		:	$UMEM/${TMEM}MB ($PRAM)
		#Disk Usage		:	${UDSK}B/${TDSK}B ($PDSK)
		#CPU Usage		:	$PCPU
		#Last boot		:	$BOOT
		#LVM active		:	$LVMU
		#TCP Connections	:	$CTCP established
		#User log		:	$USER
		#Network		:	IPv4 $IPV4 ($MACA)
		#Sudo			:	$SUDO commands
		----------------------------------------"