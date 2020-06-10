#!/bin/sh

. /etc/profile

. /etc/sane-button.conf

## If the socket is not available, we won't be able
# to send the scans to tif2pdf
[ ! -p ${TIF2PDF_SOCKET} ] && \
	echo "${TIF2PDF_SOCKET} is not a pipe !" && \
	exit 1

## Look for the scanner USB device
SANE_USB=`
scanimage -f "%d%n" | \
while read ln
do
	echo $ln | grep "${SANE_DRIVER}"
done`

## The command line to check the scanner button 
# and if a page is loaded in the ADF
SCANIMAGE_BIN="scanimage -d ${SANE_USB} -A"
echo "scanimage=${SCANIMAGE_BIN}"

TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
mkdir -vp ${SCANDIR}/${TIMESTAMP}
cd ${SCANDIR}/${TIMESTAMP}

while [ 1 ]
do

   SCANIMAGE_LOG=`${SCANIMAGE_BIN}`
   EXIT=$?
   [ $EXIT -ne 0 ] && break

   echo "$SCANIMAGE_LOG" | \
   while read ln
   do

	if [ "${BTSCAN}" != "yes" ]
	then
		## Get the scanner button status
		BTSCAN=`echo $ln | grep "^--scan" | sed -e 's/^--scan\[=(yes|no)\] \[//' -e 's/\] \[hardware\]$//'`
	else
	        ## The scanner button is pressed

		PAGE_LOADED=`echo $ln | grep "^--page-loaded" | sed -e 's/^--page-loaded\[=(yes|no)\] \[//' -e 's/\] \[hardware\]$//'`
		echo "BTSCAN=$BTSCAN"
		echo "PAGE_LOADED=$PAGE_LOADED"

		if [ "${PAGE_LOADED}" = "yes" ]
		then	
			## The pages are loaded in the ADF

			## The batch start with number of tifs already in the directory to complete the
			## document
			scanimage --source "${SCAN_SOURCE}" -d ${SANE_USB} --batch="scan-%03d.tif" --batch-start=$(ls *.tif|wc -l) \
				--page-width ${PAGE_WIDTH} --page-height ${PAGE_HEIGHT} \
				--format=tiff --mode ${MODE} --resolution ${RESOLUTION} 

		fi
	fi
   done 

   sleep 1s
   BTSCAN="no"

done

## The directory name is sent to tif2pdf
echo "\"${TIMESTAMP}\" >${TIF2PDF_SOCKET}"
echo "${TIMESTAMP}" >${TIF2PDF_SOCKET}

