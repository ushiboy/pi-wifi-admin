pi-wifi-admin
=====

pi-wifi-admin is a wifi setting application for Raspberry PI (Raspbian).

This is a prototype version.

## Overview

pi-wifi-admin becomes a Wifi access point when the OS starts up, and allows Wifi clients to edit wpa_supplicant settings using a browser.

## Install

```
$ git clone https://github.com/ushiboy/pi-wifi-admin.git
$ cd pi-wifi-admin
$ sudo ./install.sh
$ sudo systemctl enable pi-wifi-admin.service
```

## Usage

Connect to the access point of "RasPi-AP" SSID with password "raspberry", open "http://192.168.100.1:8080" in the browser and set "wpa_supplicant.conf".

## License

MIT
