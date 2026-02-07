#!/bin/bash

set -ouex pipefail


tee /usr/lib/systemd/system/startup-script.service <<EOF
[Unit]
Description=Mount encrypted part and run startup script after that
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '/encrypted/mount_encrypted.sh && /encrypted/mountpoint/startup.sh'
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable startup-script.service
