#!/bin/bash

ENTITY='SMA Keck NRAO Subaru ATLAS MOPS PS_PS UH88 EAO_JAC IRTF CFHT'
FROM=$1
TO=$2
export FROM=${FROM:=2018-1-1}
export TO=${TO:=2018-1-1}
MINFLOW=500K

for entity in $ENTITY
do
    rm -f flows.$entity*
done

startdate=$(date -I -d "$FROM") || exit -1
enddate=$(date -I -d "$TO")     || exit -1
enddate=$(date -I -d "$enddate + 1 day")

d="$startdate"
while [ "$d" != "$enddate" ]
do
  yy=$(date +%Y -d $d)
  mm=$(date +%m -d $d)
  dd=$(date +%d -d $d)

  if test -z "$FROMDATE"
  then
    FROMDATE=${yy}${mm}${dd}
  fi
  for entity in $ENTITY
  do
    echo "Processing $entity flows for ${yy}${mm}${dd} ..."
    TIMEWINDOW=${yy}/${mm}/${dd}/nfcapd.${yy}${mm}${dd}0000:${yy}/${mm}/${dd}/nfcapd.${yy}${mm}${dd}2359 
    nfdump -M /home/nfsen/profiles-data/Astro_Summary/$entity  -T  -R $TIMEWINDOW -n 100 -s record/bps -A dstip4/24 -L $MINFLOW >/tmp/collect.$entity
    cat /tmp/collect.$entity | head --lines=-4 | tail --lines=+5 | grep -v '128.171.[0-9]*.[0-9]*' | cut --characters=38-72 | sed 's/ \([KMG]\)/\1/g' | awk '{print $1 ", " $3}' >>flows.$entity
  done
  TODATE=${yy}${mm}${dd}
  d=$(date -I -d "$d + 1 day")
done

for entity in $ENTITY
do
  echo "Fixing up TODATE=$TODATE for $entity"
  mv flows.$entity flows.$entity-$FROMDATE-$TODATE
done

