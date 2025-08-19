# Ethernet Ghosting
_Based on dolosjs_

## Setup
```bash
apt install nodejs npm git net-tools bridge-utils ebtables iptables arptables procps libpcap-dev tmux screen
mkdir /root/tools
cd /root/tools
git clone https://github.com/RickConsole/dolosjs
cd dolosjs
git checkout static-ip #temporary while in development
cd setup/eth_mgmt
chmod +x setup.sh
./setup.sh --ghost-port1 <interface name> --ghost-port2 <interface name> --management-port <interface name>
systemctl restart networking
systemctl restart sshd
reboot
#after reboot
/root/tools/dolosjs/eth_mgmt/finish_setup.sh --ghost-port1 <interface name> --ghost-port2 <interface name> --management-port <interface name>
```


