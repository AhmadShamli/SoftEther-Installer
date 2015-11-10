#!/bin/bash

latest="v4.19-9599-beta-2015.10.19"
lateststable="v4.18-9570-rtm-2015.07.26"
#Release Date: 2015-10-19
initfile="vpnserver2"

echo "--------------------------------------------------------------------"
echo "SoftEther VPN Server Install script"
echo "By AhmadShamli"
echo "http://github.com/AhmadShamli"
echo "http://AhmadShamli.com"
echo "credit: DigitalOcean and StackOverflow"
echo "https://www.digitalocean.com/community/tutorials/how-to-setup-a-multi-protocol-vpn-server-using-softether"
echo "--------------------------------------------------------------------"
echo "--------------------------------------------------------------------"
echo
echo "Select Architecture"
echo
echo " 1. Arm EABI (32bit)"
echo " 2. Intel x86 (32bit)"
echo " 3. Intel x64/AMD64 (64bit)"
echo
echo "Please choose architecture: "
read tmp
echo

if test "$tmp" = "3"
then
	arch="64bit_-_Intel_x64_or_AMD64"
	arch2="x64-64bit"
	echo "Selected : 1 " $arch
elif test "$tmp" = "2"
then
	arch="32bit_-_Intel_x86"
	arch2="x86-32bit"
	echo "Selected : 2 " $arch
elif test "$tmp" = "1"
then
	arch="32bit_-_ARM_EABI"
	arch2="arm_eabi-32bit"
	echo "Selected : 3 " $arch
else #default if non selected
	arch="32bit_-_Intel_x86"
	arch2="x86-32bit"
	echo "Selected : 2 " $arch
fi

echo "--------------------------------------------------------------------"
echo
echo "Select OS"
echo
echo " 1. Debian/Ubuntu"
echo " 2. CentOS/Fedora"
echo
echo "Please choose OS: "
read tmp
echo

if test "$tmp" = "2"
then
	os="cent"
	echo "Selected : 2 CentOS/Fedora"
else
	os="deb"
	echo "Selected : 1 Debian/Ubuntu"
fi

echo "--------------------------------------------------------------------"
echo
echo "Select build"
echo
echo " 1. latest(might include beta/rc)"
echo " 2. latest stable"
echo
echo "Please choose build: "
read tmp
echo

if test "$tmp" = "2"
then
	version="$lateststable"
	echo "Latest stable selected: 2 "$lateststable
else
	version="$latest"
	echo "Latest build(stable/beta) selected: 1 "$latest
fi

file="softether-vpnserver-"$version"-linux-"$arch2".tar.gz"
link="http://www.softether-download.com/files/softether/"$version"-tree/Linux/SoftEther_VPN_Server/"$arch"/"$file

if [ ! -s "$file" ]||[ ! -r "$file" ];then
	#remove and redownload empty or unreadable file
	rm -f "$link"
	wget "$link"
elif [ ! -f "file" ];then
	#download if not exist
	wget "$file"
fi

if [ -f "$file" ];then
	tar xzf "$file"
	dir=$(pwd)
	echo "current dir " $dir
	cd vpnserver
	dir=$(pwd)
	echo "changed to dir " $dir
else
	echo "Archive not found. Please rerun this script or check permission."
	break
fi

if [ "$os" -eq "cent" ];then
	yum upgrade
	yum groupinstall "Development Tools" gcc
else
	apt-get update && apt-get upgrade
	apt-get install build-essential -y
fi
	
make
cd ..
mv vpnserver /usr/local
dir=$(pwd)
echo "current dir " $dir
cd /usr/local/vpnserver/
dir=$(pwd)
echo "changed to dir " $dir
chmod 600 *
chmod 700 vpnserver
chmod 700 vpncmd

mkdir /var/lock/subsys

touch /etc/init.d/"$initfile"
#need to cat two time to pass varible($initfile) value inside
cat > /etc/init.d/"$initfile" <<EOF
#!/bin/sh
# chkconfig: 2345 99 01
# description: SoftEther VPN Server
DAEMON=/usr/local/vpnserver/$initfile
LOCK=/var/lock/subsys/$initfile
EOF

cat >> /etc/init.d/"$initfile" <<'EOF'
test -x $DAEMON || exit 0
case "$1" in
start)
$DAEMON start
touch $LOCK
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
esac
exit 0
EOF

chmod 755 /etc/init.d/"$initfile"
if [ "$os" -eq "cent" ];then
	chkconfig --add "$initfile" 
	/etc/init.d/"$initfile" start
else
	update-rc.d "$initfile" defaults
	/etc/init.d/"$initfile" start
fi
	


echo "--------------------------------------------------------------------"
echo "--------------------------------------------------------------------"
echo "Installation done. Hurray."
echo "Now you may want to change VPN server password."
echo "Run in terminal:"
echo "./vpncmd"
echo "Press 1 to select \"Management of VPN Server or VPN Bridge\","
echo "then press Enter without typing anything to connect to the "
echo "localhost server, and again press Enter without inputting "
echo "anything to connect to server by server admin mode."
echo "Then use command below to change admin password:"
echo "ServerPasswordSet"
echo "Done...."

