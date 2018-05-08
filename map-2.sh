#!/bin/bash

# Two input arguments are required, from date and to date
# USe format YYYY-MM-DD
FROM=$1
TO=$2
export FROM=${FROM:=2018-1-1}
export TO=${TO:=2018-1-1}

# An ENTITY maps to the NfSen Profile Channels that were configured
ENTITY='SMA Keck NRAO Subaru ATLAS MOPS PS_PS UH88 EAO_JAC IRTF CFHT'

# Create a file that maps classC subnets to AS information
OUTFILE=classC-lkup.csv
rm ip_info $OUTFILE 

# Ignore small flows
# This should be an input parameter or come from the env
MINFLOW="500K"

startdate=$(date -I -d "$FROM") || exit -1
enddate=$(date -I -d "$TO")     || exit -1
enddate=$(date -I -d "$enddate + 1 day")

# For each day in the date range (inclusive)
d="$startdate"
while [ "$d" != "$enddate" ]
do
  yy=$(date +%Y -d $d)
  mm=$(date +%m -d $d)
  dd=$(date +%d -d $d)
  # For each NfSen Channel's subnets
  for entity in $ENTITY
  do
    echo "Processing $entity flows for ${yy}${mm}${dd} ..."
    TIMEWINDOW=${yy}/${mm}/${dd}/nfcapd.${yy}${mm}${dd}0000:${yy}/${mm}/${dd}/nfcapd.${yy}${mm}${dd}2359 
    M_val="/home/nfsen/profiles-data/Astro_Summary/${entity}"
    R_val="$TIMEWINDOW"

    # get the flows
    nfdump -M ${M_val} -R ${R_val} -T -q -a -A dstip4/24 -L $MINFLOW "not dst net  128.171.0.0/16" |\
    grep -v "Byte limit:" | awk '{print $5 }' | while read p; 
    do
      echo "IP: $p" >> ip_info;
      # get AS info for each subnet
      geoiplookup $p >> ip_info ;
    done
  done
  d=$(date -I -d "$d + 1 day")
done

# reformat the geoiplookup results for subsequent use
python processAS.py ip_info $OUTFILE.tmp
sort '--field-separator=|' $OUTFILE.tmp >$OUTFILE
rm -f $OUTFILE.tmp

