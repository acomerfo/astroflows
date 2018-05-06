#!/bin/bash

BASE=${BASE:-by}
ENTITY='SMA Keck NRAO Subaru ATLAS MOPS PS_PS UH88 EAO_JAC IRTF CFHT'
#ENTITY='EAO_JAC'
SUFFIX="$1-$2"
export FROM="$1"
export TO="$2"
OUTFILE=from-${BASE}-classC-$SUFFIX.csv
OUTFILE2=from-${BASE}-AS-$SUFFIX.csv

rm -f $OUTFILE $OUTFILE.tmp

echo $SUFFIX
for entity in $ENTITY
do
  echo "Processing $entity flows for ${SUFFIX} ..."
  cat flows.${entity}-${SUFFIX} | sed 's/\.[0-9]*|/\.0/' | awk 'BEGIN{IGNORECASE = 1}
       function printpower(n,b,p) {printf "%u ", n*b^p; }
       /[0-9]$/{print $2, $1};
       /K(iB)?$/{print $1, printpower($2,  2, 10)};
       /M(iB)?$/{print $1, printpower($2,  2, 20)};
       /G(iB)?$/{print $1, printpower($2,  2, 30)};
       /T(iB)?$/{print $1, printpower($2,  2, 40)};
       /KB$/{    print $1, printpower($2, 10,  3)};
       /MB$/{    print $1, printpower($2, 10,  6)};
       /GB$/{    print $1, printpower($2, 10,  9)};
       /TB$/{    print $1, printpower($2, 10, 12)}'| awk '{split($2,ipseg,"."); printf("%03d%03d%03d%03d|%d\n", ipseg[1], ipseg[2], ipseg[3], ipseg[4], $1);}' | awk '-F|' '{sum[$1] += $2;} END {for(subnet in sum) printf("%s|%s\n", subnet, sum[subnet]);}' | sort '--field-separator=|' >flow
  join -t '|' -a 1 flow classC-lkup.csv | sed "s/^/${FROM}|${TO}|${entity}|/g" >>$OUTFILE.tmp
done

awk '-F|' '{ip=$4; printf("%s|%s|%s|%d.%d.%d.%d|%s|%s|%s|%s|%s|%s\n", $1, $2, $3, ip/1e9, ip%1e9/1e6, ip%1e6/1e3, ip%1e3, $5, $6, $7, $8, $9, $10);}' $OUTFILE.tmp | sort '--field-separator=|' -Vr --key=3,3d --key=5,5 >$OUTFILE

awk '-F|' '{key=$3"-"$6; sum[key] += $5; hdr[key]=$1"|"$2"|"$3; tlr[key]=$6"|"$7"|"$8"|"$9"|"$10;} END {for(asn in sum) printf("%s|%s|%s\n", hdr[asn], sum[asn], tlr[asn]);}' $OUTFILE | sort '--field-separator=|' -Vr --key=3,3d --key=4,4 >$OUTFILE2 
rm -f flow $OUTFILE.tmp
