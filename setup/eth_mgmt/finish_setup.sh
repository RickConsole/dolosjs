#!/bin/bash 
cp ./etc_network_interfaces.d_enp1s0 /etc/network/interfaces.d/enp1s0 
cp ./etc_network_interfaces.d_enp2s0 /etc/network/interfaces.d/enp2s0 
systemctl enable dolos_service
