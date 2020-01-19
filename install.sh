#!/bin/sh

if [ "`whoami`" != "root" ]; then
    echo "Require root privilege"
    exit 1
fi

apt-get update
apt-get install -y hostapd
cp /usr/share/doc/hostapd/examples/hostapd.conf /etc/hostapd/hostapd.conf

sed -i s/ssid=test/ssid=RasPi-AP/g /etc/hostapd/hostapd.conf
sed -i s/#ieee80211n=1/ieee80211n=1/g /etc/hostapd/hostapd.conf
sed -i "s/#ht_capab=\[HT40-\]\[SHORT-GI-20\]\[SHORT-GI-40\]/ht_capab=\[HT40\]\[SHORT-GI-20\]\[DSSS_CCK-40\]/g" /etc/hostapd/hostapd.conf
sed -i s/auth_algs=3/auth_algs=1/g /etc/hostapd/hostapd.conf
sed -i s/#wpa=2/wpa=2/g /etc/hostapd/hostapd.conf
sed -i "s/#wpa_passphrase=secret passphrase/wpa_passphrase=raspberry/g" /etc/hostapd/hostapd.conf
sed -i "s/#wpa_key_mgmt=WPA-PSK WPA-EAP/wpa_key_mgmt=WPA-PSK/g" /etc/hostapd/hostapd.conf
sed -i "s/#rsn_pairwise=CCMP/rsn_pairwise=CCMP/g" /etc/hostapd/hostapd.conf

apt-get install -y isc-dhcp-server

cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 192.168.100.0 netmask 255.255.255.0 {
  range 192.168.100.100 192.168.100.105;
  option routers 192.168.100.1;
  option broadcast-address 192.168.100.255;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF

sed -i 's/INTERFACESv4=""/INTERFACESv4="wlan0"/g' /etc/default/isc-dhcp-server

update-rc.d isc-dhcp-server disable

apt-get install -y python3-venv

mv pi-wifi-admin /usr/local/sbin/
mv pi-wifi-admin.default /etc/default/pi-wifi-admin
mv pi-wifi-admin.service /etc/systemd/system/

mkdir -p /usr/local/lib/pi-wifi-admin
mv app.py requirements.txt /usr/local/lib/pi-wifi-admin
cd /usr/local/lib/pi-wifi-admin
python3 -m venv venv
venv/bin/pip install -U pip
venv/bin/pip install -r requirements.txt
