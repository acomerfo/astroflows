# astroflows
Analyze [net|s]flows by subnet and AS

Author: Curt Dodds dodds@hawaii.edu (scripting)
Author: Adriana Comerford acomerfo@hawaii.edu (scripting)
Author: David Schanzenbach davidls@hawaii.edu (python, AS lookup)
Author: Alan Whinery whinery@hawaii.edu (nfsen, netflows)

1. install and configure NfSen: http://nfsen.sourceforge.net/
1. configure routers to collect netflows or sflows and forward to NfSen
1. let it run for a bit to collect some flows
1. run three scripts in sequence:
   1. collect-1.sh <from-date> <to-date>   # e.g. 2018-1-1 2018-1-31 (dates are inclusive)
   1. map-2.sh <from-date> <to-date>       # e.g. 2018-1-1 2018-1-31 (dates are inclusive) must be same as preceding collect
   1. aggregate-3.sh
1. Three output files are created:
   1. classC-lkup.csv                      # mapping from subnet to AS number and information
   1. from-by-AS-20180101-20180131.csv     # flows by AS
   1. from-by-classC-20180101-20180131.csv # flows by classC subnet

Add enhancements and bugs to _**TODO.md**_
