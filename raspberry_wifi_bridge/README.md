<img src="https://upload.wikimedia.org/wikipedia/de/thumb/c/cb/Raspberry_Pi_Logo.svg/1200px-Raspberry_Pi_Logo.svg.png" alt="Raspberry_Pi_Logo" height="42px" width="42px" align="left"><br>

# Docker Toolbox Notes
<div>
    <a href="https://github.com/NaPiZip/Tipps-and-tricks">
        <img src="https://img.shields.io/badge/Document%20Version-0.0.1-green.svg"/>
    </a>
    <a href="https://www.raspberrypi.org/downloads/raspbian/">
        <img src="https://img.shields.io/badge/RP%20Image-2019--07--10--raspbian--buster--lite-blue"/>
    </a>
</div>


## The System Architecture
The following image shows the system architecture. The Raspberry Pi is used as an access point in order to provide WiFi for the workstations. The traffic between Raspberry Pi and workstations is forwarded via NAT (Network Address Translation) between `etho` and the `wlan0` interface. On the Raspberry Pi is a `hostapd` running which is setting up de WiFi connection, the local `DCHP` then assigns the IP addresses to the workstations within the range of `192.168.4.2 - 192.168.4.20`. Also a local instance of an `DNS` server is running dealing with the resolving the domain names and IP addresses.

<p align="center">
<img src="https://raw.githubusercontent.com/NaPiZip/Docker-projects/master/raspberry_wifi_bridge/images/System_architecture.JPG" alt="Architecture" height="80%" width="80%"/></p>

## Setting up a Raspberry Pi as a Wireless Access Point with bridge functionality
So I first tried a tutorial on the official Raspberry Pi website, but turns out that there is a typo, in setting up the access point (AP), link can be found [here](https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md). Here is a part of the section containing the error:

Add a masquerade for outbound traffic on `eth0`:
```
sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

```
<b>Do not just copy the command since there is a extra blank between `-A` and `POSTROUTING`!!!</b>

### Issues
This section described issues which occurred during deployment.

<b>IP tables rules did not update</b>
After I managed to get the connection between AP and router working I realized that my NAT settings did not get loaded after boot. I added a load of my saved `/etc/iptables.ipv4.nat` in the `/etc/rc.local` file. I debuged the system as follow:
- Checked `dmesg` for errors, which had no succes.
- Controlled the status of `rc.local` by calling:
```
$ service rc.local status
Warning: The unit file, source configuration file or drop-ins of rc-local.service changed on disk. Run 'systemctl daemon-reload' to reload units.
● rc-local.service - /etc/rc.local Compatibility
   Loaded: loaded (/lib/systemd/system/rc-local.service; static; vendor preset: enabled)
  Drop-In: /lib/systemd/system/rc-local.service.d
           └─debian.conf
           /etc/systemd/system/rc-local.service.d
           └─ttyoutput.conf
   Active: inactive (dead)
     Docs: man:systemd-rc-local-generator(8)
```
Strange here was the warning message
- I ran the suggested command:
```
$ sudo systemctl daemon-reload
```
- Checked the status again:
```
$ service rc.local status
● rc-local.service - /etc/rc.local Compatibility
   Loaded: loaded (/lib/systemd/system/rc-local.service; static; vendor preset: enabled)
  Drop-In: /lib/systemd/system/rc-local.service.d
           └─debian.conf
           /etc/systemd/system/rc-local.service.d
           └─ttyoutput.conf
   Active: inactive (dead)
     Docs: man:systemd-rc-local-generator(8)
```
No warnings this time.
- Checked `dmesg` again with the following findings:
```
$ dmesg
...
[   16.272576] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   16.272585] Bluetooth: BNEP filters: protocol multicast
[   16.272602] Bluetooth: BNEP socket layer initialized
[  284.630661] systemd-rc-local-generator[786]: /etc/rc.local is not marked executable, skipping.
```
And turns out that `/etc/rc.local` did not have the right permissions!!!!!!
- Changed the permissions to execute:
```
sudo chmod +x /etc/rc.local
```
Issue fixed.

## Next steps
The next steps consist of migrating the whole configurations into a Docker image.

## Contributing
To get started with contributing to my GitHub repository, please contact me [Slack](https://join.slack.com/t/napi-friends/shared_invite/enQtNDg3OTg5NDc1NzUxLWU1MWNhNmY3ZTVmY2FkMDM1ODg1MWNlMDIyYTk1OTg4OThhYzgyNDc3ZmE5NzM1ZTM2ZDQwZGI0ZjU2M2JlNDU).
