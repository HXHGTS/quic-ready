#!/bin/sh

DEBIAN_VER=$(cat /etc/os-release |  grep 'VERSION=' | awk -F\" {'print $2'} | awk {'print $1'})

echo "deb http://download.opensuse.org/repositories/home:/wlallemand/Debian_${DEBIAN_VER}/ /" | tee /etc/apt/sources.list.d/home:wlallemand.list

curl -fsSL https://download.opensuse.org/repositories/home:wlallemand/Debian_${DEBIAN_VER}/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/home_wlallemand.gpg > /dev/null

apt update

apt install -y haproxy
