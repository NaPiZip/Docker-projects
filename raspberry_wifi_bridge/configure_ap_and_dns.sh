#!/bin/bash

# Turn off services
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

cp dhcpcd.conf /etc/dhcpcd.conf
cp dnsmasq.conf /etc/dnsmasq.conf
cp hostapd.conf /etc/hostapd/hostapd.conf

# Make safety copy if not already done
if [ ! -f /etc/default/hostapd.old ]; then
  sudo mv /etc/default/hostapd /etc/default/hostapd.old
fi

# Patch hostapd file y adding path to DAEMON_CONF
awk '/DAEMON_CONF=/ {print "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"";next}1' /etc/default/hostapd.old > /etc/default/hostapd

# Restart the dhcpcd and dnsmasq daemon and set up the new config
sudo service dhcpcd restart
sudo service dnsmasq restart

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
