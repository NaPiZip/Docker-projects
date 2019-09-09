#!/bin/bash

# Configuring wifi ethernet bridge

sudo systemctl stop hostapd

# Make safety copy if not already done
if [ ! -f /etc/dhcpcd.conf.old ]; then
  sudo mv /etc/dhcpcd.conf /etc/dhcpcd.conf.old
fi
sudo cp dhcpcd.conf /etc/dhcpcd.conf

# Append at the begining
sudo sed -i '1idenyinterfaces wlan0\ndenyinterfaces eth0' /etc/dhcpcd.conf

sudo brctl addbr br0
sudo brctl addif br0 eth0

sudo cp bridge-br0.netdev /etc/systemd/network/bridge-br0.netdev
sudo cp bridge-br0-slave.network /etc/systemd/network/bridge-br0-slave.network
sudo cp bridge-br0.network /etc/systemd/network/bridge-br0.network

sudo systemctl restart systemd-networkd

# Change accespoit settings
sudo cp hostapd_bridge.conf /etc/hostapd/hostapd.conf

echo "brctl addbr br0" >> /etc/dnsmasq.conf
echo "brctl addif br0 eth0" >> /etc/dnsmasq.conf
