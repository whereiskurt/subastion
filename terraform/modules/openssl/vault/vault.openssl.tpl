[ ca ]
default_ca = CA_default

##We sign infrastructure with ICA certs
[ CA_default ]
dir               = ./../../terraform/modules/openssl/ica
default_md        = sha256
default_days      = 365
preserve          = no
policy            = policy_loose
private_key       = $dir/ica.key.pem
certificate       = $dir/ica.cert.pem
certs             = $dir
crl_dir           = $dir
new_certs_dir     = $dir
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/.rand
copy_extension = copy

[ req ]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_ca
req_extensions = v3_ca    
prompt = no   

[ v3_ca ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = ${vault_cert_nscomment}
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ policy_loose ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = optional
emailAddress            = optional

[ req_distinguished_name ] 
C = ${vault_cert_country}
ST = ${vault_cert_state}
L = ${vault_cert_location}
O = ${vault_cert_organization}

[ alt_names ]
DNS.1 = ${vault_cert_dns_1}
DNS.2 = ${vault_cert_dns_2}
DNS.3 = ${vault_cert_dns_3}
IP.1 = ${vault_cert_ip_1}
IP.2 = ${vault_cert_ip_2}