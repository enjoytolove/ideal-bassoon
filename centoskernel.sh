#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Check Root
[ $(id -u) != "0" ] && { echo "Error! You must be root to run this script"; exit 1; }

# Check OS
if [ -n "$(grep ' 6\.' /etc/redhat-release)" ];then
	OS=CentOS6
elif [ -n "$(grep ' 7\.' /etc/redhat-release)" ];then
	OS=CentOS7
else
	echo "Error! You must run this script on CentOS 6 or 7!"
	kill -9 $$
fi

clear

echo "#===============================================================#"
echo "# Description: Autochange CentOS 6 or 7 Kernel                  #"
echo "# Author: https://www.banwagongzw.com & https://www.vultrcn.com #"
echo "# Version: 1.06 2018-02-15                                      #"
echo "#===============================================================#"
echo ""

# Change Kernel
if [[ ${OS} == CentOS6 ]];then
	echo "OS is CentOS6. Processing..."
	echo ""
	rpm -ivh https://cdn.xiazaio.win/resource/kernel-firmware-2.6.32-504.3.3.el6.noarch.rpm
	rpm -ivh https://cdn.xiazaio.win/resource/kernel-2.6.32-504.3.3.el6.x86_64.rpm --force
	number=$(cat /boot/grub/grub.conf | awk '$1=="title" {print i++ " : " $NF}' | grep '2.6.32-504' | awk '{print $1}')
	sed -i "s/^default=.*/default=$number/g" /boot/grub/grub.conf
	echo ""
	echo "Success! Your server will reboot in 3s..."
	sleep 3
	reboot
else
	echo "OS is CentOS7. Processing..."
	echo ""
	rpm -ivh https://cdn.xiazaio.win/resource/kernel-3.10.0-229.1.2.el7.x86_64.rpm --force
	grub2-set-default `awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg | grep '(3.10.0-229.1.2.el7.x86_64) 7 (Core)' | awk '{print $1}'`
	echo ""
	echo "Success! Your server will reboot in 3s..."
	sleep 3
	reboot
fi
