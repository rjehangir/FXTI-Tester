#!/bin/bash
# FXTI Listener Pi Setup (Fathom-X side)
DIRPATH=$(dirname $0)
HOMEDIR=/home/pi
BASHRC=$HOMEDIR/.bashrc

# Remove ip= statement from cmdline.txt
sudo sed -i "s/ip=[0-9\.]*//" /boot/cmdline.txt

# Install wiringpi
echo "Installing wiringpi"
$DIRPATH/install_wiringpi.sh

# Configure dhcp server
$DIRPATH/config-dhcp.sh

