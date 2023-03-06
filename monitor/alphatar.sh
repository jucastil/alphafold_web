#!/bin/bash

###################################################
#	alphatarresults.sh : tar alphafold results
#	v.0.9	Juan.Castillo@biophys.mpg.de
#	Last update: 05.08.2022
##################################################

DATE="date +%Y-%m-%d-%Hh-%Mm"
echo `$DATE` "	: ### alphatarresults #### starting  " 

### tar partial results, copy them to the web area, make them downloadable
find /home/alphafold/results/ -maxdepth 1 -type d -exec tar cfP  {}.tar {}  \;  > /dev/null 2>&1
echo `$DATE` "	: find phase done " 
rsync -av  /home/alphafold/results/*.tar /var/www/html/alphafold/monitor/results/
#cp -R /home/alphafold/results/*.tar /var/www/html/alphafold/monitor/results/
echo `$DATE` "	: copying phase done " 
chmod 777 /var/www/html/alphafold/monitor/results/*.tar
echo `$DATE` "	: onwership phase done " 
echo `$DATE` "	: ### alphatarresults DONE ### "

