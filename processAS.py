#!/usr/bin/env python2.7

import sys
seen=set()
a = [i.strip().split(":")[-1].strip() for i in open(sys.argv[1]) ]

o = open(sys.argv[2],"w")
for end in xrange(4,len(a)+1,4):
    	if "IP Address not found" in a[end-4:end]:
        	continue
    	ip,country,city,asnum=a[end-4:end] 
    	if ip in seen:
		continue
	seen.add(ip)
	city = city.split(",")[2:-5]
    	country = country.split(",")[-1]
    	asn = asnum.split(" ")[0]
	ipseg = ip.split(".")
    	print >> o, '%03d%03d%03d%03d|%s|%s|%s|%s|%s'%(int(ipseg[0]),int(ipseg[1]),int(ipseg[2]),int(ipseg[3]),asn," ".join(asnum.split()[1:]), city[0], city[1], country )
