# Ethernet Management Setup

This setup script configures a system for 802.1x bypassing with configurable network interfaces.

## Usage

### Default Configuration (eth0, eth1, eth2)
```bash
sudo bash setup.sh
```

### Custom Interface Configuration
```bash
sudo bash setup.sh --ghost-port1 enp1s0 --ghost-port2 enp2s0 --management-port enp3s0
```

## Arguments

- `--ghost-port1 INTERFACE`: First interface for 802.1x bypassing (default: eth0)
- `--ghost-port2 INTERFACE`: Second interface for 802.1x bypassing (default: eth1)  
- `--management-port INTERFACE`: Management interface for operator connectivity (default: eth2)
- `--help`: Show usage information

## Interface Roles

- **Ghost Ports (1 & 2)**: Used for transparent 802.1x bypassing between supplicant and switch
- **Management Port**: Provides operator access with static IP (172.31.255.1) and DHCP server

## Examples

```bash
# Standard setup with eth interfaces
sudo bash setup.sh

# Setup with predictable interface names
sudo bash setup.sh --ghost-port1 enp1s0 --ghost-port2 enp2s0 --management-port enp3s0

# Mixed interface naming
sudo bash setup.sh --ghost-port1 eth0 --ghost-port2 eth1 --management-port wlan0

# Get help
bash setup.sh --help
```

## Finish Setup

After running setup.sh and rebooting, run finish_setup.sh with the same interface arguments:

```bash
sudo bash finish_setup.sh --ghost-port1 enp1s0 --ghost-port2 enp2s0 --management-port enp3s0
```

## Network Configuration

The management interface will be configured with:
- Static IP: 172.31.255.1
- DHCP Range: 172.31.255.10-254
- Lease Time: 12 hours
