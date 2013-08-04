#!/bin/bash
#
# Script from http://blog.oldcomputerjunk.net/2012/remastering-youtube-videos-into-avi-for-your-set-top-box
#
mencoder "${1}" -oac mp3lame -lameopts cbr:br=64 \
  -vf scale=512:376,expand=648:384 -ovc xvid \
  -xvidencopts bvhq=1:quant_type=mpeg:bitrate=1300:pass=2:turbo:threads=3 \
  -o `basename "$1"`.avi
