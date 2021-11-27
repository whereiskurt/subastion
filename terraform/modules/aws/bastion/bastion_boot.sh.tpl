#!/bin/bash

echo "DUDE!!! ${name}" > /tmp/dude.file.txt
sudo apt install -y openvpn

mkdir /etc/openvpn/keys/
chmod 700 /etc/openvpn/keys/         

cat > /etc/openvpn/server/server.conf <<EOT
port 1194
proto udp
dev tun
ca /etc/openvpn/keys/ca.cert.pem
cert /etc/openvpn/keys/server.cert.pem
key /etc/openvpn/keys/server.key.pem
dh /etc/openvpn/keys/dh2048.pem
cipher AES-256-CBC
auth SHA512
server ${openvpn_network} ${openvpn_netmask}
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
ifconfig-pool-persist ipp.txt
keepalive 10 120
comp-lzo
persist-key
persist-tun
status openvpn-status.log
log-append  openvpn.log
verb 6
tls-server
tls-auth /etc/openvpn/keys/pfs.key.pem
EOT

chmod 600 /etc/openvpn/server.conf