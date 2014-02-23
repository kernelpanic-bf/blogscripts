#!/bin/bash
#
# Needs: apt-get install imagemagick 


PDF_DEST="$HOME/Scanned Files"

LOG="$HOME/brscan/brscan.log"

brscan-skey | while read -r msg ; do 
  
  F="`sed -e 's/^\(.*\) is created\..*$/\1/' <<< $msg`"
  FB="${F%%.pnm}"
  B=`basename "$F"`
  BB=`basename "$FB"`
  D=`dirname "$F"`

  date >> $LOG
  echo "F=$F" >> $LOG


  notify-send -t 5000 "Brother MFC-J415W" "Received: brscan/$B"

  Y="Failed: MISSING INPUT FILE"
  test -f "$F" && Y=`convert "$F" "$FB.jpg" 2>&1`
  notify-send -t 5000 "Brother MFC-J415W" "Conversion to $FB.jpg\n${Y:-OK}"
  echo "$FB.jpg Y=$Y" >> $LOG

  Y="Failed: MISSING INPUT FILE"
  test -f "$F" && Y=`convert -page A4 -density 100 "$F" "$PDF_DEST/$BB.pdf" 2>&1`
  notify-send -t 5000 "Brother MFC-J415W" "Conversion to $BB.pdf\n${Y:-OK}"
  echo "$PDF_DEST/$BB.pdf Y=$Y" >> $LOG
done

notify-send -t 5000 "Brother MFC-J415W" "brscan-skey died for some reason…"

