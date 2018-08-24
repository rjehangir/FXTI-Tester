#!/bin/bash
cd /home/pi
sudo apt-get install git-core
git clone git://git.drogon.net/wiringPi
cd wiringPi
./build
