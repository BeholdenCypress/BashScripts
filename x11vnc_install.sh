#!/bin/bash

#Check to see if the script is being run as root
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script is required to be run as root"
    exit
fi

# Update repositories and install x11vnc and net-tools
apt update
apt install x11vnc net-tools -y

# Store the VNC Password in /etc/x11vnc.pwd. This can be stored anywhere, this is just a convinent place since x11vnc will be run as a service
x11vnc -storepasswd /etc/x11vnc.pwd

# Create x11vnc service file
cat >> /lib/systemd/system/x11vnc.service <<EOL
[Unit]
Description=x11vnc service
After=display-manager.service network.target syslog.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pwd -rfbport 5900 -shared
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Reload daemon, enable and start the newly created x11vnc service
systemctl daemon-reload
systemctl enable x11vnc.service
systemctl start x11vnc.service


echo "If you want to make sure the new x11vnc service is running, after the script completes run the command 'systemctl status x11vnc.service'"