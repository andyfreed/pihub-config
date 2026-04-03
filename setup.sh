#!/bin/bash
set -e

# PiHub Setup Script
# Run on a fresh Raspberry Pi OS install to configure:
# - Cellular modem (SIM7600G-H with Hologram SIM)
# - Wi-Fi hotspot (SSID: MOOSE)
# - Ethernet sharing
# - Tailscale
# - NAT routing

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Updating system ==="
sudo apt-get update
sudo apt-get upgrade -y

echo "=== Installing packages ==="
sudo apt-get install -y hostapd dnsmasq

echo "=== Installing Tailscale ==="
curl -fsSL https://tailscale.com/install.sh | sudo sh

echo "=== Copying config files ==="

# Hostapd
sudo cp "$SCRIPT_DIR/configs/hostapd.conf" /etc/hostapd/hostapd.conf
sudo cp "$SCRIPT_DIR/configs/hostapd-default" /etc/default/hostapd

# Dnsmasq
sudo cp "$SCRIPT_DIR/configs/dnsmasq.conf" /etc/dnsmasq.conf

# Cellular connection
sudo cp "$SCRIPT_DIR/configs/cellular.nmconnection" /etc/NetworkManager/system-connections/cellular.nmconnection
sudo chmod 600 /etc/NetworkManager/system-connections/cellular.nmconnection

# NetworkManager - ignore wlan0
sudo mkdir -p /etc/NetworkManager/conf.d
sudo cp "$SCRIPT_DIR/configs/unmanaged-wlan0.conf" /etc/NetworkManager/conf.d/unmanaged-wlan0.conf

# IP forwarding
sudo cp "$SCRIPT_DIR/configs/90-ipforward.conf" /etc/sysctl.d/90-ipforward.conf
sudo sysctl -w net.ipv4.ip_forward=1

# Hotspot startup script
sudo cp "$SCRIPT_DIR/configs/hotspot-setup.sh" /usr/local/bin/hotspot-setup.sh
sudo chmod +x /usr/local/bin/hotspot-setup.sh

# Hotspot systemd service
sudo cp "$SCRIPT_DIR/configs/hotspot.service" /etc/systemd/system/hotspot.service

# dhcpcd - deny wlan0
if ! grep -q "denyinterfaces wlan0" /etc/dhcpcd.conf 2>/dev/null; then
    echo "denyinterfaces wlan0" | sudo tee -a /etc/dhcpcd.conf
fi

# Ethernet sharing
sudo nmcli connection modify "Wired connection 1" ipv4.method shared ipv4.addresses 192.168.5.1/24 ipv4.gateway "" connection.autoconnect yes

echo "=== Enabling services ==="
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl daemon-reload
sudo systemctl enable hotspot.service

echo "=== Reloading NetworkManager ==="
sudo nmcli connection reload

echo "=== Setting up Tailscale ==="
echo "Run 'sudo tailscale up --ssh' and authenticate when ready."

echo ""
echo "=== Setup complete! ==="
echo "Reboot to start everything, or run:"
echo "  sudo nmcli connection up cellular"
echo "  sudo /usr/local/bin/hotspot-setup.sh"
echo ""
echo "Wi-Fi hotspot: MOOSE"
echo "Wi-Fi clients: 192.168.4.x"
echo "Ethernet clients: 192.168.5.x"
