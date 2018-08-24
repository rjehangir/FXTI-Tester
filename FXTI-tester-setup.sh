#!/bin/bash
# FXTI Tester Pi Setup (USB side)
DIRPATH=$(dirname $0)
HOMEDIR=/home/pi
BASHRC=$HOMEDIR/.bashrc

# Enable auto-login
systemctl set-default multi-user.target
ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service

# Remove ip= statement from cmdline.txt
sudo sed -i "s/ip=[0-9\.]*//" /boot/cmdline.txt

# Install wiringpi
echo "Installing wiringpi"
$DIRPATH/install_wiringpi.sh

# Copy fxtitest.sh to the home directory
echo "Copying fxtitest.sh to $HOMEDIR"
cp $DIRPATH/fxtitest.sh $HOMEDIR


# Get fxtitest.sh to run on start
echo "Configuring fxtitest.sh to run on start with ...?"

