#!/bin/sh

systemctl stop tif2pdf.socket
systemctl disable tif2pdf.socket
rm -vf /etc/systemd/system/tif2pdf.socket \
	/etc/systemd/system/tif2pdf.service \
	/etc/udev/rules.d/buttonProb.rules

systemctl daemon-reload
udevadm control --reload-rules && udevadm trigger

docker stop sane-webdav 
docker rm sane-webdav
docker stop pdf-file-manager
docker rm pdf-file-manager

docker rmi alpine/button_prob alpine/tif2pdf bytemark/webdav alpine/node-file-manager
