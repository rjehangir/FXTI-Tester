#!/bin/bash

#Check if isc-dhcp-server exists, if not install it.
if dpkg-query -W -f='${Status} ${Version}' isc-dhcp-server | grep 4.3; then
	echo "Already installed"
else
	echo "Installing isc-dhcp-server"
	sudo apt-get update --yes
	sudo apt-get install isc-dhcp-server=4.3.* --yes
fi
echo "isc-dhcp-server installed"

S1="iface eth0 inet static"
S2="address 192.168.2.2"
S3="netmask 255.255.255.0"

#Remove existing settings for all other configurations from /network/interfaces
# e.g. sed -i -e '/pattern/,+#d', deletes any line containing the pattern and # number of lines after that.
sudo sed -i -e '/iface eth0 inet manual/,+1d' /etc/network/interfaces
sudo sed -i -e '/eth0 inet static/,+3d' /etc/network/interfaces
sudo sed -i -e '/eth0 inet dhcp/,+1d' /etc/network/interfaces
echo "Previous configuration settings removed from /network/interfaces"

#Append configuration settings for dhcp-server at the end of /network/interfaces
sudo sed -i -e "\$a$S1" \
-e "\$a$S2" \
-e "\$a$S3" \
/etc/network/interfaces
echo "Configuration settings for dhcp-server mode applied in network/interfaces"

#Add configuration settings for dhcp-server to dhcp/dhcpd.conf

#Give a subnet range for ip addresses to be assigned by the server
S4="subnet 192.168.2.0 netmask 255.255.255.0 {"
S5="\\\trange 192.168.2.3 192.168.2.254;"
S6="}"

# e.g. sed commnad removes 6 lines following the line containing the pattern "subnet 192.168.2.0"
sudo sed -i -e '/subnet 192.168.2.0/,+6d' /etc/dhcp/dhcpd.conf

#Append subnet range settings at the end of /dhcp/dhcpd.conf file
sudo sed -i -e "\$a$S4" \
-e "\$a$S5" \
-e "\$a$S6" \
/etc/dhcp/dhcpd.conf
echo "Subnet range settings applied to dhcp/dhcpd.conf"

#Add lease time settings to dhcp/dhcpd.conf 
# e.g. sed /pattern/s/.*/yourtext/ filename replaces the whole line containing the 'pattern' with the text you provide. 
sudo sed -i -e '/default-lease-time/s/.*/default-lease-time 43200;/' /etc/dhcp/dhcpd.conf
sudo sed -i -e '/max-lease-time/s/.*/max-lease-time 43200;/' /etc/dhcp/dhcpd.conf
echo "Lease time and max lease time settings applied to /dhcp/dhcpd.conf"

#Uncomment authoritative globally to make this the primary dhcp server /dhcp/dhcpd.conf
sudo sed -i -e '/authoritative;/s/^#//g' /etc/dhcp/dhcpd.conf
echo "Server set to primary DHCP server"

#Delete option domain name settings as they are not required in /dhcp/dhcpd.conf 
# e.g. sed /pattern/d command deletes any line containing the pattern
sudo sed -i -e '/option domain-name/d' /etc/dhcp/dhcpd.conf

echo "Lease time, domain-name and primary server settings applied to /dhcp/dhcpd.conf"

#Add default configuration settings to default/isc-dhcp-server
S9="DHCPD_CONF=/etc/dhcp/dhcpd.conf"
S10="DHCPD_PID=/var/run/dhcpd.pid"
S11="INTERFACES=\"eth0\""

# Multiple sed statements concatenated into one command to perform action on 3 different lines
# e.g. sed /pattern/s:value replaces the whole line containing the 'pattern' with the variable/value you provide. 
sudo sed -i -e "/DHCPD_CONF=/s:.*:$S9:" \
-e "/DHCPD_PID=/s:.*:$S10:" \
-e "/INTERFACES=/s:.*:$S11:" \
/etc/default/isc-dhcp-server
echo "Configuration settings updated in /default/isc-dhcp-server"

echo "Configuration settings for dhcp-server mode applied to Companion"

#Restart dhcp server 
sudo service isc-dhcp-server restart

#Enable it to run at boot
sudo update-rc.d isc-dhcp-server defaults

echo "DHCP server enabled to run at boot"

