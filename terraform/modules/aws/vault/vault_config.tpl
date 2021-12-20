{
    "seal": {
        "awskms": {
            "region": "${region}",
            "kms_key_id": "${kms_key_id}",
            "access_key": "${access_key}",
            "secret_key": "${secret_key}"
        }
    },
    "backend": {
        "file": {
            "path": "secrets"
        }
    },
    "listener": {
        "tcp": {
            "address": "0.0.0.0:${docker_container_port}",
            "tls_disable": 0,
            "tls_cert_file": "vault.cert.pem",
            "tls_key_file": "vault.key.pem"
        }
    },
    "ui": true
}