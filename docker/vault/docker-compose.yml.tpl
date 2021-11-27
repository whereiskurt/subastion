version: '2'
services:
  vault:
    image: vault
    container_name: vault
    ports:
      - "${docker_container_port}:${docker_host_port}"
    restart: always
    volumes:
      - ./volumes/logs:/vault/logs
      - ./volumes/file:/vault/file
      - ./volumes/config/vault/config
    cap_add:
      - IPC_LOCK
    entrypoint: vault server -config=/vault/config/vault.json
