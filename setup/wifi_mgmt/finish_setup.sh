#!/bin/bash 
cp ./etc_network_interfaces.d_enp1s0 /etc/network/interfaces.d/enp1s0 
cp ./etc_network_interfaces.d_enp2s0 /etc/network/interfaces.d/enp2s0 
cp ./etc_NetworkManager_conf.d_99-unmanaged-devices.conf /etc/NetworkManager/conf.d/99-unmanaged-devices.conf
systemctl enable dolos_service
