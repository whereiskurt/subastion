#!/bin/bash

sudo apt update
sudo apt install -y openvpn easy-rsa

mkdir /etc/openvpn/keys/
chmod 700 /etc/openvpn/keys/         

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

make-cadir /etc/openvpn/easy_ca/
cd /etc/openvpn/easy_ca/ 
./easyrsa init-pki
EASYRSA_BATCH=1 ./easyrsa build-ca nopass
EASYRSA_BATCH=1 ./easyrsa gen-dh
EASYRSA_BATCH=1 ./easyrsa build-server-full openvpn-server nopass
EASYRSA_BATCH=1 ./easyrsa build-client-full openvpn-client nopass

openvpn --genkey --secret /etc/openvpn/keys/pfs.key.pem
cp /etc/openvpn/keys/pfs.key.pem /home/ubuntu
chown ubuntu:ubuntu /home/ubuntu/pfs.key.pem

cp /etc/openvpn/easy_ca/pki/issued/openvpn-client.crt /etc/openvpn/easy_ca/pki/private/openvpn-client.key /home/ubuntu
chown ubuntu:ubuntu /home/ubuntu/openvpn-client*


# scp -i $SUBASTION_GREEN_KEYFILE ./terraform/modules/aws/bastion/openvpn.green.cert.pem ubuntu@$SUBASTION_GREEN_IP:~/server.cert.pem
# scp -i $SUBASTION_GREEN_KEYFILE ./terraform/modules/aws/bastion/openvpn.green.key.pem ubuntu@$SUBASTION_GREEN_IP:~/server.key.pem
# scp -i $SUBASTION_GREEN_KEYFILE /etc/ssl/certs/aws_bluegreen.ca.ica.pem ubuntu@$SUBASTION_GREEN_IP:~/ca.cert.pem
# scp -i $SUBASTION_GREEN_KEYFILE ./terraform/modules/openssl/dh.2048.pem ubuntu@$SUBASTION_GREEN_IP:~/dh2048.pem
# scp -i $SUBASTION_GREEN_KEYFILE ./pfs.key.pem ubuntu@$SUBASTION_GREEN_IP:~/pfs.key.pem

#sudo iptables -t nat -A POSTROUTING -s 10.50.48.0/20 -o eth0 -j MASQUERADE
#sudo echo 1 > /proc/sys/net/ipv4/ip_forward