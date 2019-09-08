#!/bin/bash

# Adding route masquerade

# Make safety copy if not already done
if [ ! -f /etc/sysctl.conf.old ]; then
  sudo mv /etc/sysctl.conf /etc/sysctl.conf.old
fi

awk '/#net.ipv4.ip_forward=1/ {print "net.ipv4.ip_forward=1";next}1' /etc/sysctl.conf.old > /etc/sysctl.conf

sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

if [ ! -f /etc/rc.local.old ]; then
  sudo mv /etc/rc.local /etc/rc.local.old
fi

awk '/exit 0/ {print "iptables-restore < /etc/iptables.ipv4.nat\nexit 0";next}1' /etc/rc.local.old > /etc/rc.local
