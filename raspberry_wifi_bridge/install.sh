#!/bin/bash

# Install packages
sudo apt-get --fix-borken install
sudo apt-get install dnsmasq hostapd -y

# Turn off services
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

cp dhcpcd.conf /etc/dhcpcd.conf
cp dnsmasq.conf /etc/dnsmasq.conf
cp hostapd.conf /etc/hostapd/hostapd.conf

# Restart the dhcpcd and dnsmasq daemon and set up the new config
sudo service dhcpcd restart
sudo service dnsmasq restart

# Patching hostapd
sudo mv /etc/default/hostapd /etc/default/hostapd.old
awk '/DAEMON_CONF=/ {print "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"";next}1' /etc/default/hostapd.old > /etc/default/hostapd

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
