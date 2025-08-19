# Ethernet Ghosting
_Based on dolosjs_

## Setup
```bash
apt install nodejs npm git net-tools bridge-utils ebtables iptables arptables procps libpcap-dev tmux screen
mkdir /root/tools
cd /root/tools
git clone https://github.com/RickConsole/dolosjs
cd dolosjs
cd setup/eth_mgmt
chmod +x setup.sh
./setup.sh --ghost-port1 <interface name> --ghost-port2 <interface name> --management-port <interface name>
systemctl restart networking
systemctl restart sshd
reboot
#after reboot
/root/tools/dolosjs/eth_mgmt/finish_setup.sh --ghost-port1 <interface name> --ghost-port2 <interface name> --management-port <interface name>
```

## Usage
Connect the switch to `ghost-port1` and trusted supplicant to `ghost-port2`. The internal service will automatically configure itself. 

When connected to the management port, set an ip in the range `192.168.100.2-192.168.100.254`.
Then you can access the device by
```bash
ssh root@192.168.100.1
```
From here, you can run commands from the box itself or ssh proxy through to access the internal network. 

