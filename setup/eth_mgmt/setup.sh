#!/bin/bash 

# Default interface names
GHOST_PORT1="eth0"
GHOST_PORT2="eth1"
MGMT_PORT="eth2"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ghost-port1)
            GHOST_PORT1="$2"
            shift 2
            ;;
        --ghost-port2)
            GHOST_PORT2="$2"
            shift 2
            ;;
        --management-port)
            MGMT_PORT="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--ghost-port1 INTERFACE] [--ghost-port2 INTERFACE] [--management-port INTERFACE]"
            echo "  --ghost-port1: First interface for 802.1x bypassing (default: eth0)"
            echo "  --ghost-port2: Second interface for 802.1x bypassing (default: eth1)"
            echo "  --management-port: Management interface (default: eth2)"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate interfaces exist
echo "Validating interfaces..."
for iface in "$GHOST_PORT1" "$GHOST_PORT2" "$MGMT_PORT"; do
    if ! ip link show "$iface" &> /dev/null; then
        echo "Error: Interface $iface does not exist on this system"
        echo "Available interfaces:"
        ip link show | grep -E '^[0-9]+:' | cut -d: -f2 | tr -d ' '
        exit 1
    fi
done

# Check for duplicate interfaces
if [[ "$GHOST_PORT1" == "$GHOST_PORT2" ]] || [[ "$GHOST_PORT1" == "$MGMT_PORT" ]] || [[ "$GHOST_PORT2" == "$MGMT_PORT" ]]; then
    echo "Error: All interfaces must be unique"
    echo "Ghost Port 1: $GHOST_PORT1"
    echo "Ghost Port 2: $GHOST_PORT2"
    echo "Management Port: $MGMT_PORT"
    exit 1
fi

echo "Using interfaces:"
echo "  Ghost Port 1 (802.1x bypass): $GHOST_PORT1"
echo "  Ghost Port 2 (802.1x bypass): $GHOST_PORT2"
echo "  Management Port: $MGMT_PORT"

#update repos
apt update
#update os
apt -y upgrade

#install deps that are absolutely required for the project to work
apt --assume-yes install nodejs npm libpcap0.8-dev bridge-utils iptables ebtables arptables network-manager make g++

#install deps for Ethernet as management interface
# Commented out dnsmasq - using static IP only, no DHCP server
# apt --assume-yes install dnsmasq

#install other standard software to make life easier
apt --assume-yes install vim tmux screen zip unzip dnsutils curl

#force the interfaces to be named with predictable conventions. This allows us to easily swap our Ethernet NIC etc. and know we can reference it in dnsmasq and /etc/network/interfaces
ln -s /dev/null /etc/systemd/network/99-default.link

#generate interface configurations from templates
echo "Generating interface configurations..."

# Generate ghost port 1 configuration
sed "s/INTERFACE_NAME/$GHOST_PORT1/g" ./template_ghost_interface.conf > /etc/network/interfaces.d/$GHOST_PORT1

# Generate ghost port 2 configuration  
sed "s/INTERFACE_NAME/$GHOST_PORT2/g" ./template_ghost_interface.conf > /etc/network/interfaces.d/$GHOST_PORT2

# Generate management port configuration
sed "s/INTERFACE_NAME/$MGMT_PORT/g" ./template_mgmt_interface.conf > /etc/network/interfaces.d/$MGMT_PORT

# Generate dnsmasq configuration - COMMENTED OUT (using static IP only)
# sed "s/INTERFACE_NAME/$MGMT_PORT/g" ./template_dnsmasq.conf > /etc/dnsmasq.conf

# Copy main config and update interface placeholders
cp ./config.js ../../
sed -i "s/GHOST_PORT1_PLACEHOLDER/$GHOST_PORT1/g" ../../config.js
sed -i "s/GHOST_PORT2_PLACEHOLDER/$GHOST_PORT2/g" ../../config.js
sed -i "s/MGMT_PORT_PLACEHOLDER/$MGMT_PORT/g" ../../config.js

#ask the tech for their multiplexer pref
promptanswered=0
while [[ $promptanswered == 0 ]]; do
    read -p 'Which multiplexer do you want to use for the dolos service?(tmux/screen) ' servicechoice
    servicechoice=${servicechoice,,} #tolower
    if [[ $servicechoice == "tmux" ]]; then
        sed -i 's/#tmux/tmux/' etc_init.d_dolos_service
        promptanswered=1
    elif [[ $servicechoice == "screen" ]]; then
        sed -i 's/#screen/screen/' etc_init.d_dolos_service
        promptanswered=1
    fi
done
cp ./etc_init.d_dolos_service /etc/init.d/dolos_service
chmod +x /etc/init.d/dolos_service

# Configure SSH to listen only on management interface
echo "Configuring SSH for management interface only..."
cp ./template_sshd_config /etc/ssh/sshd_config

# Remove any existing DHCP configuration from main interfaces file
echo "Cleaning up any existing DHCP configuration..."
if grep -q "iface.*dhcp" /etc/network/interfaces; then
    sed -i '/iface.*dhcp/d' /etc/network/interfaces
fi

#set management interface to start on boot - COMMENTED OUT (no DHCP server)
# systemctl start dnsmasq.service
# systemctl enable dnsmasq.service

#reload the daemons after all those changes
systemctl daemon-reload
# systemctl restart dnsmasq

# Restart SSH service to apply new configuration
systemctl restart ssh

#install Node.js deps
cd ../../
npm install

echo "All set up! Reboot and check that your management network is running and accessible"
echo "Management interface will be available at 192.168.100.1"
echo "Configure your client with a static IP in the 192.168.100.x range (x=2-254)"
echo "SSH access is restricted to the management interface only"
echo "Then you can 'bash finish_setup.sh' to autorun the attack"
