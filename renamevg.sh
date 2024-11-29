#!/bin/bash

vg=hcavet42--vg
newvg=LVMGroup

sed -i "s/${vg}/${newvg}/g" /etc/fstab
sed -i "s/${vg}/${newvg}/g" /boot/grub/grub.cfg
vgrename hcavet42-vg LVMGroup

update-initramfs -c -k all
