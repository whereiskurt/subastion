[ ca ]
default_ca = CA_default

##We sign infrastructure with ICA certs
[ CA_default ]
dir               = ./${openvpn_ica_folder}
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
copy_extension    = copy

[ req ]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_ca
req_extensions      = v3_ca    
prompt = no   

[ v3_ca ]
subjectKeyIdentifier = hash
basicConstraints = CA:true
keyUsage = digitalSignature, cRLSign, keyCertSign

[ client_cert ]
basicConstraints = CA:FALSE
nsCertType = client
nsComment = ${openvpn_clientcert_nscomment}
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
extendedKeyUsage = clientAuth
keyUsage = digitalSignature

[ policy_loose ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = optional
emailAddress            = optional

[ req_distinguished_name ] 
C = ${openvpn_clientcert_country}
ST = ${openvpn_clientcert_state}
L = ${openvpn_clientcert_location}
O = ${openvpn_clientcert_organization}
CN = ${openvpn_clientcert_commonname}
