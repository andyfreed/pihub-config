# PiHub Config

Configuration and setup script for a Raspberry Pi 5 portable cellular hotspot.

## What it does

- Connects to the internet via a SIM7600G-H cellular modem (Hologram SIM on Verizon)
- Broadcasts a Wi-Fi hotspot (SSID: MOOSE)
- Shares internet over ethernet too (plug in a device, it gets an IP)
- Runs Tailscale for remote SSH access from anywhere
- NAT routes all traffic from Wi-Fi and ethernet clients through cellular

## Hardware

- Raspberry Pi 5
- SIMCom SIM7600G-H cellular modem (USB)
- Hologram SIM card

## Network layout

| Interface | Subnet | Purpose |
|-----------|--------|---------|
| wwan0 | Carrier-assigned | Cellular internet (primary) |
| wlan0 | 192.168.4.0/24 | Wi-Fi hotspot (MOOSE) |
| eth0 | 192.168.5.0/24 | Wired device sharing |
| tailscale0 | 100.x.x.x | Remote access |

## Restore from scratch

1. Flash a fresh Raspberry Pi OS image using Raspberry Pi Imager
2. Plug the Pi into your router via ethernet
3. SSH into the Pi
4. Run:

```bash
sudo apt-get install -y git
git clone https://github.com/andyfreed/pihub-config.git
cd pihub-config
bash setup.sh
```

5. When prompted, enter the Wi-Fi hotspot password
6. After setup completes, run:

```bash
sudo tailscale up --ssh
```

7. Open the auth link in your browser to add the Pi to your Tailscale network
8. Reboot the Pi

The hotspot, cellular, and all services will start automatically on boot.
