#!/bin/bash
#===================================================================#
# Description: Autoinstall serverSpeeder server for CentOS & Debian #
# Author: https://github.com/0oVicero0/serverSpeeder_Install        #
# Mod: https://www.banwagongzw.com & https://www.vultrcn.com        #
# Version: 1.06 2018-02-15                                          #
#===================================================================#

function Welcome()
{
clear
echo "#===================================================================#";
echo "# Description: Autoinstall serverSpeeder server for CentOS & Debian #";
echo "# Author: https://github.com/0oVicero0/serverSpeeder_Install        #";
echo "# Mod: https://www.banwagongzw.com & https://www.vultrcn.com        #";
echo "# Version: 1.06 2018-02-15                                          #";
echo "#===================================================================#";
echo "";
rootness;
mkdir -p /tmp
cd /tmp
}

function rootness()
{
if [[ $EUID -ne 0 ]]; then
   echo "Error! You must run this script as root!" 1>&2
   exit 1
fi
}

function pause()
{
read -n 1 -p "Press Enter to start...or press Ctrl+C to cancel" INP
if [ "$INP" != '' ] ; then
echo -ne '\b \n'
echo "";
fi
}

function Check()
{
echo 'Please wait for a few seconds...'
apt-get >/dev/null 2>&1
[ $? -le '1' ] && apt-get -y -qq install grep unzip ethtool >/dev/null 2>&1
yum >/dev/null 2>&1
[ $? -le '1' ] && yum -y -q install which sed grep awk unzip ethtool >/dev/null 2>&1
[ -f /etc/redhat-release ] && KNA=$(awk '{print $1}' /etc/redhat-release)
[ -f /etc/os-release ] && KNA=$(awk -F'[= "]' '/PRETTY_NAME/{print $3}' /etc/os-release)
[ -f /etc/lsb-release ] && KNA=$(awk -F'[="]+' '/DISTRIB_ID/{print $2}' /etc/lsb-release)
KNB=$(getconf LONG_BIT)
ifconfig >/dev/null 2>&1
[ $? -gt '1' ] && echo -ne "Error! I can not run 'ifconfig' successfully! Please check your system and try again! \n\n" && exit 1;
[ ! -f /proc/net/dev ] && echo -ne "Error! I can not find network device! Please check your system and try again! \n\n" && exit 1;
[ -n "$(grep 'eth0:' /proc/net/dev)" ] && Eth=eth0 || Eth=`cat /proc/net/dev |awk -F: 'function trim(str){sub(/^[ \t]*/,"",str); sub(/[ \t]*$/,"",str); return str } NR>2 {print trim($1)}'  |grep -Ev '^lo|^sit|^stf|^gif|^dummy|^vmnet|^vir|^gre|^ipip|^ppp|^bond|^tun|^tap|^ip6gre|^ip6tnl|^teql|^venet' |awk 'NR==1 {print $0}'`
[ -z "$Eth" ] && echo "Error! I can not find the server pubilc Ethernet! \n\n" && exit 1
URLKernel='https://cdn.xiazaio.win/resource/serverSpeeder.txt'
AcceVer=$(wget --no-check-certificate -qO- "$URLKernel" |grep "$KNA/" |grep "/x$KNB/" |grep "/$KNK/" |awk -F'/' '{print $NF}' |sort -n -k 2 -t '_' |tail -n 1)
MyKernel=$(wget --no-check-certificate -qO- "$URLKernel" |grep "$KNA/" |grep "/x$KNB/" |grep "/$KNK/" |grep "$AcceVer" |tail -n 1)
[ -z "$MyKernel" ] && echo -ne "Error! I can not match the kernel! Please change kernel manually and try again! \n\nYou can view the link to get detaits: "$URLKernel" \n\n" && exit 1
pause;
}

function SelectKernel()
{
KNN=$(echo $MyKernel |awk -F '/' '{ print $2 }') && [ -z "$KNN" ] && Uninstall && echo "Error! I can not match the kernel!" && exit 1
KNV=$(echo $MyKernel |awk -F '/' '{ print $5 }') && [ -z "$KNV" ] && Uninstall && echo "Error! I can not match the kernel!" && exit 1
wget --no-check-certificate -q -O "/tmp/appex/apxfiles/bin/acce-"$KNV"-["$KNA"_"$KNN"_"$KNK"]" "https://raw.githubusercontent.com/uxh/serverSpeeder_kernel/master/$MyKernel"
[ ! -f "/tmp/appex/apxfiles/bin/acce-"$KNV"-["$KNA"_"$KNN"_"$KNK"]" ] && Uninstall && echo "Download Error! I can not found acce-$KNV-[$KNA_$KNN_$KNK]!" && exit 1
}

function Install()
{
Welcome;
Check;
ServerSpeeder;
dl-Lic;
bash /tmp/appex/install.sh
rm -rf /tmp/appex* >/dev/null 2>&1
clear
bash /appex/bin/serverSpeeder.sh status
exit 0
}

function Uninstall()
{
chattr -R -i /appex >/dev/null 2>&1
[ -d /etc/rc.d ] && rm -rf /etc/rc.d/init.d/serverSpeeder >/dev/null 2>&1
[ -d /etc/rc.d ] && rm -rf /etc/rc.d/rc*.d/*serverSpeeder >/dev/null 2>&1
[ -d /etc/rc.d ] && rm -rf /etc/rc.d/init.d/lotServer >/dev/null 2>&1
[ -d /etc/rc.d ] && rm -rf /etc/rc.d/rc*.d/*lotServer >/dev/null 2>&1
[ -d /etc/init.d ] && rm -rf /etc/init.d/serverSpeeder >/dev/null 2>&1
[ -d /etc/init.d ] && rm -rf /etc/rc*.d/*serverSpeeder >/dev/null 2>&1
[ -d /etc/init.d ] && rm -rf /etc/init.d/lotServer >/dev/null 2>&1
[ -d /etc/init.d ] && rm -rf /etc/rc*.d/*lotServer >/dev/null 2>&1
rm -rf /etc/lotServer.conf >/dev/null 2>&1
rm -rf /etc/serverSpeeder.conf >/dev/null 2>&1
[ -f /appex/bin/lotServer.sh ] && bash /appex/bin/lotServer.sh uninstall -f >/dev/null 2>&1
[ -f /appex/bin/serverSpeeder.sh ] && bash /appex/bin/serverSpeeder.sh uninstall -f >/dev/null 2>&1
rm -rf /appex >/dev/null 2>&1
rm -rf /tmp/appex* >/dev/null 2>&1
echo -ne 'serverSpeeder has been removed successfully! \n\n'
exit 0
}

function dl-Lic()
{
chattr -R -i /appex >/dev/null 2>&1
rm -rf /appex >/dev/null 2>&1
mkdir -p /appex/etc
mkdir -p /appex/bin
MAC=$(ifconfig "$Eth" |awk '/HWaddr/{ print $5 }')
[ -z "$MAC" ] && MAC=$(ifconfig "$Eth" |awk '/ether/{ print $2 }')
[ -z "$MAC" ] && Uninstall && echo "Error! I can not found MAC address!" && exit 1
wget --no-check-certificate -q -O "/appex/etc/apx.lic" "http://serverspeeder.azurewebsites.net/lic?mac=$MAC"
[ "$(du -b /appex/etc/apx.lic |awk '{ print $1 }')" -ne '152' ] && Uninstall && echo "Error! I can not generate the Lic for you! Please try again!" && exit 1
echo "Lic generate success!"
[ -n $(which ethtool) ] && rm -rf /appex/bin/ethtool && cp -f $(which ethtool) /appex/bin
}

function ServerSpeeder()
{
[ ! -f /tmp/appex.zip ] && wget --no-check-certificate -q -O "/tmp/appex.zip" "https://cdn.xiazaio.win/resource/appex.zip"
[ ! -f /tmp/appex.zip ] && Uninstall && echo "Error! I can not found appex.zip!" && exit 1
mkdir -p /tmp/appex
unzip -o -d /tmp/appex /tmp/appex.zip
SelectKernel;
APXEXE=$(ls -1 /tmp/appex/apxfiles/bin |grep 'acce-')
sed -i "s/^accif\=.*/accif\=\"$Eth\"/" /tmp/appex/apxfiles/etc/config
sed -i "s/^apxexe\=.*/apxexe\=\"\/appex\/bin\/$APXEXE\"/" /tmp/appex/apxfiles/etc/config
}

[ $# == '1' ] && [ "$1" == 'install' ] && KNK="$(uname -r)" && Install;
[ $# == '1' ] && [ "$1" == 'uninstall' ] && Welcome && pause && Uninstall;
[ $# == '2' ] && [ "$1" == 'install' ] && KNK="$2" && Install;
echo -ne "Usage:\n     bash $0 [install | uninstall | install '{serverSpeeder of Kernel Version}']\n"
