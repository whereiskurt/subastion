[Unit]
Description=subastion vault server

[Service]
WorkingDirectory=${working_dir}
ExecStart=vault server -config=vault.json
Restart="always"

[Install]
WantedBy=multi-user.target
