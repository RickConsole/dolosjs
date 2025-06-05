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

echo "Configuring interfaces for finish setup..."
echo "  Ghost Port 1: $GHOST_PORT1"
echo "  Ghost Port 2: $GHOST_PORT2"
echo "  Management Port: $MGMT_PORT"

# Generate ghost port configurations
sed "s/INTERFACE_NAME/$GHOST_PORT1/g" ./template_ghost_interface.conf > /etc/network/interfaces.d/$GHOST_PORT1
sed "s/INTERFACE_NAME/$GHOST_PORT2/g" ./template_ghost_interface.conf > /etc/network/interfaces.d/$GHOST_PORT2

systemctl enable dolos_service
