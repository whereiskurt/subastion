#!/bin/bash

### echo "DUDE!!! ${name}" > /tmp/dude.file.txt
sudo apt install -y openvpn

mkdir /etc/openvpn/keys/
chmod 700 /etc/openvpn/keys/         

cat > /etc/openvpn/server/server.conf <<EOT
port 11194
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

# find . -name "*.txt" -print0 | while read -d $'\0' file
# do
# done

# scp -i $SUBASTION_GREEN_KEYFILE ./terraform/modules/aws/bastion/openvpn.cert.pem ubuntu@$SUBASTION_GREEN_IP:~/server.cert.pem
# scp -i $SUBASTION_GREEN_KEYFILE ./terraform/modules/aws/bastion/openvpn.key.pem ubuntu@$SUBASTION_GREEN_IP:~/server.key.pem
# scp -i $SUBASTION_GREEN_KEYFILE /etc/ssl/certs/aws_bluegreen.ca.ica.pem ubuntu@$SUBASTION_GREEN_IP:~/ca.cert.pem
# scp -i $SUBASTION_GREEN_KEYFILE ./terraform/modules/openssl/dh.2048.pem ubuntu@$SUBASTION_GREEN_IP:~/dh2048.pem
# scp -i $SUBASTION_GREEN_KEYFILE ./pfs.key.pem ubuntu@$SUBASTION_GREEN_IP:~/pfs.key.pem

#sudo iptables -t nat -A POSTROUTING -s 10.50.48.0/20 -o eth0 -j MASQUERADE
#sudo echo 1 > /proc/sys/net/ipv4/ip_forward