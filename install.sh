#!/bin/sh

####################################################
#  Sane-button is a daemon like probing the scan
#  button on a scanner supported by sane. Once pressed
#  the pages are scanned from the ADF, OCRed and 
#  converted in a searchable/indexable pdf
#
#  install.sh will deploy the necessary files to 
#  have this service running on the system. Tested
#  on Fedora 28 


###################################################
### 
# Loads the default env
. /etc/profile

##################################################
###
# Loads the variables
. ./sane-button.conf

##################################################
### tif2pdf automate the conversion from tif to
# pdf. The tif files are grouped in a directory 
# under a predefined path given by the PDFDIR var

cd tif2pdf

#################################################
###
# Docker tif2pdf image
docker build -t alpine/tif2pdf .

################################################
###
# Systemd unit socket and service to automate
# tif2pdf
echo "[Unit]
Description=listen pipe

[Socket]
ListenFIFO=${TIF2PDF_SOCKET}
RemoveOnStop=on

[Install]
WantedBy=tif2pdf.service" \
	> /etc/systemd/system/tif2pdf.socket

echo "[Unit]
Description=reads pipe
Requires=tif2pdf.socket

[Service]
StandardInput=socket
StandardOutput=journal
StandardError=journal
ExecStart=/bin/bash -c 'echo start; while read TIMESTAMP; do ${PWD}/tif2pdf.docrun \$TIMESTAMP; done; echo end'" \
	> /etc/systemd/system/tif2pdf.service

systemctl daemon-reload

systemctl enable tif2pdf.socket
systemctl start tif2pdf.socket

######################################################
###
## buttonProb probes the scan button
cd ../buttonProb

######################################################
###
## Docker button_prob image
docker build -t alpine/button_prob .

######################################################
###
## The scan button probing is started automatically
## when the scanner is switched on thanks to udev. 
## USBVENDOR and USBPRODUCT are setted respectively with 
## idVendor and id Product.
echo "ACTION==\"add\", ATTRS{idVendor}==\"${USBVENDOR}\", ATTRS{idProduct}==\"${USBPRODUCT}\", RUN+=\"${PWD}/buttonProb.docrun\"" >/etc/udev/rules.d/buttonProb.rules
udevadm control --reload-rules && udevadm trigger

#####################################################
###
## node-file-manager
cd ../node-file-manager
#docker build -t alpine/node-file-manager .
#docker run --restart always --detach \
#	-v ${PDFDIR}:/data --name pdf-file-manager --publish 8080:8080 \
#	alpine/node-file-manager

#####################################################
###
## Awaiting a very nice nodejs UI, a webdav service 
## is started to get access to and manage pdf files
docker run --restart always -v ${PDFDIR}:/var/lib/dav/data -e ANONYMOUS_METHODS=ALL \
	--name sane-webdav --publish 8080:80 -d bytemark/webdav

