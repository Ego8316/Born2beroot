#!/bin/bash

vg=user--vg
newvg=LVMGroup

sed -i "s/${vg}/${newvg}/g" /etc/fstab
sed -i "s/${vg}/${newvg}/g" /boot/grub/grub.cfg
vgrename user-vg LVMGroup

update-initramfs -c -k all
