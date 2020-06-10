#!/bin/sh

. /etc/profile

PWD=`dirname $0`

. ${PWD}/../sane-button.conf

DOCRUN="${PWD}/tif2pdf.docrun"


if [[ ! -p $PIPE ]]
then
	echo "Creates $PIPE"
	mkfifo -m 666 $PIPE
fi


while true
do
	echo "Reads $PIPE"
	if read TIMESTAMP <"$PIPE"
	then
		echo "Launch ${DOCRUN} ${TIMESTAMP}"
		${DOCRUN} ${TIMESTAMP}

	fi
done

