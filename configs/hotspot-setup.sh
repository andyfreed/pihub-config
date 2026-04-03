#!/bin/bash

# Wait for cellular to come up
sleep 10

# Set up wlan0
ip link set wlan0 down
ip addr flush dev wlan0
ip addr add 192.168.4.1/24 dev wlan0
ip link set wlan0 up

# NAT: masquerade traffic from hotspot and ethernet out to internet
iptables -t nat -A POSTROUTING -s 192.168.4.0/24 ! -d 192.168.4.0/24 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.5.0/24 ! -d 192.168.5.0/24 -j MASQUERADE
iptables -A FORWARD -i wlan0 -o wwan0 -j ACCEPT
iptables -A FORWARD -i wwan0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o wwan0 -j ACCEPT
iptables -A FORWARD -i wwan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o tailscale0 -j ACCEPT
iptables -A FORWARD -i tailscale0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o tailscale0 -j ACCEPT
iptables -A FORWARD -i tailscale0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Start hostapd and dnsmasq
systemctl restart dnsmasq
systemctl restart hostapd
