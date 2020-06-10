#!/bin/sh

. /etc/profile

. /etc/sane-button.conf

### Where the tif files are stored
TIFDIR="${SCANDIR}/${TIMESTAMP}"

mkdir -vp "${PDFDIR}"

echo "Loops ${TIFDIR}/*.tif"
for fscan in ${TIFDIR}/*.tif
do
	echo "Evaluate the level of black on the page BLACK_TRESH_LV ${BLACK_TRESH_LV} for ${fscan}"
        #BLACK_TRESH=`convert $fscan -threshold 50% -format %c histogram:info:- |grep "black$"|sed 's/:.*//'`
	BLACK_TRESH=`convert $fscan -format "%[fx:mean>${BLACK_TRESH_LV}?1:0]" info:`
        [ -z "${BLACK_TRESH}" ] && \
                echo "BLACK_TRESH empty !! Exiting..." && \
                break

	echo "BLACK_TRESH ${BLACK_TRESH} for ${fscan}"
	### if BLACK_TRESH > BLACK_TRESH_LV the page is considered as not blank
	#[ ${BLACK_TRESH} -gt ${BLACK_TRESH_LV} ] && \
#	[ ${BLACK_TRESH} -ne 1 ] && \
		echo "Running OCR on ${fscan}" && \
		tesseract --psm 1 -l fra $fscan $fscan pdf 2>&1 && \
		PAGE_OCRED=1
done

if [ -n "${PAGE_OCRED}" ]
then
	unset PAGE_OCRED

	### if PAGE_OCRED is define, convert didn't fail == at list some files are available to be merged
	cd "${TIFDIR}"

	echo "Assembles and deliver the pages" 
	gs -dNOPAUSE -sDEVICE=pdfwrite -dBATCH -sOUTPUTFILE=output.pdf `ls ${TIFDIR}/*.tif.pdf` && \
		mv -v output.pdf ${PDFDIR}/${TIMESTAMP}.pdf

	[ -n "${DEL_TEMP_FILES}" ] && \
		rm -vrf ${TIFDIR} 
fi

