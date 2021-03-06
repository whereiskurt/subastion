[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = ./${ica_folder}
certs             = $dir
crl_dir           = $dir
new_certs_dir     = $dir
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir.rand
private_key       = $dir/ica.key.pem
certificate       = $dir/ica.cert.pem
crlnumber         = $dir/crlnumber
crl               = $dir/ica.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30
default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_loose
copy_extension = copy

[ req ]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = v3_ca
prompt = no  

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ policy_loose ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = optional
emailAddress            = optional

[ req_distinguished_name ] 
C = ${ica_cert_country}
ST = ${ica_cert_state}
L = ${ica_cert_location}
O = ${ica_cert_organization}
CN = ${ica_cert_commonname}