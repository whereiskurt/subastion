#!/bin/bash

sudo apt update
sudo apt install -y openvpn easy-rsa

[[ -f /etc/openvpn/keys/ ]] || mkdir /etc/openvpn/keys/
chmod 700 /etc/openvpn/keys/         
openvpn --genkey --secret /etc/openvpn/keys/pfs.key.pem
chmod 600 /etc/openvpn/keys/pfs.key.pem

export EASYRSA_BATCH=1
make-cadir /etc/openvpn/easy_ca/
cd /etc/openvpn/easy_ca/ 
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa build-server-full openvpn-server nopass
./easyrsa build-client-full openvpn-client nopass

cat > /etc/openvpn/server/server.conf <<EOT
port 11194
proto udp
dev tun
ca /etc/openvpn/easy_ca/pki/ca.crt
cert /etc/openvpn/easy_ca/pki/issued/openvpn-server.crt
key /etc/openvpn/easy_ca/pki/private/openvpn-server.key
dh /etc/openvpn/easy_ca/pki/dh.pem
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
chmod 600 /etc/openvpn/server/server.conf 

cat > /etc/openvpn/client/client.conf <<EOT
client
dev tun
proto udp
remote ${openvpn_server_name} ${openvpn_server_port}
ca ca.crt
cert openvpn-client.crt
key openvpn-client.key
tls-version-min 1.2
tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256:TLS-ECDHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256
cipher AES-256-CBC
auth SHA512
resolv-retry infinite
auth-retry none
nobind
persist-key
persist-tun
ns-cert-type server
comp-lzo
verb 6
tls-client
tls-auth pfs.key.pem
EOT
chmod 600 /etc/openvpn/client/client.conf 

mkdir /home/ubuntu/openvpn/
chown ubuntu:ubuntu /home/ubuntu/openvpn/
chmod 700 /home/ubuntu/openvpn/

cp /etc/openvpn/keys/pfs.key.pem \
   /etc/openvpn/easy_ca/pki/ca.crt \
   /etc/openvpn/easy_ca/pki/issued/openvpn-client.crt \
   /etc/openvpn/easy_ca/pki/private/openvpn-client.key \
   /etc/openvpn/client/client.conf \
   /home/ubuntu/openvpn/

chown -R ubuntu:ubuntu /home/ubuntu/openvpn/

tar zcf /home/ubuntu/openvpn-client.tgz /home/ubuntu/openvpn/*

#sudo iptables -t nat -A POSTROUTING -s 10.50.48.0/20 -o eth0 -j MASQUERADE
#sudo echo 1 > /proc/sys/net/ipv4/ip_forward