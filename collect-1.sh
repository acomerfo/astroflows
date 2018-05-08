#!/bin/bash

# Two input arguments are required, from date and to date
# USe format YYYY-MM-DD
FROM=$1
TO=$2
export FROM=${FROM:=2018-1-1}
export TO=${TO:=2018-1-1}

# An ENTITY maps to the NfSen Profile Channels that were configured
ENTITY='SMA Keck NRAO Subaru ATLAS MOPS PS_PS UH88 EAO_JAC IRTF CFHT'

# Ignore small flows
# This should be an input parameter or come from the env
MINFLOW=500K

for entity in $ENTITY
do
    rm -f flows.$entity*
done

startdate=$(date -I -d "$FROM") || exit -1
enddate=$(date -I -d "$TO")     || exit -1
# coerce the end date by one more day
enddate=$(date -I -d "$enddate + 1 day")

# For each day in the date range
# We tried but could not reliably query over long date ranges without breakage
# so we just do one day at a time and aggregate the results ourselves
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
  # For each NfSen Connector defined above
  # collect the outbound flows for this day for those source subnets
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

# We discover the end date in the main loop
# this should be replaced by using the enddate parameter
for entity in $ENTITY
do
  echo "Fixing up TODATE=$TODATE for $entity"
  mv flows.$entity flows.$entity-$FROMDATE-$TODATE
done

