#!/bin/bash

#############################################
#	alphaqueue4	: 
#	queue the run_NAME.sh files
#	created by submit_job.php
#	v.1.0 by Juan.Castillo@biophys.mpg.de
#	Last update 26.07.22
############################################

LOGDIR="/ptemp/scratch/logs"
LOGRUN="/ptemp/scratch/logs/alphaqueue.log"

SCRIPTS="/var/www/html/alphafold/scripts/"
VAULT="/var/www/html/alphafold/scripts/old/"

DATE="date +%Y-%m-%d-%Hh-%Mm"


### Control vaules
ISIN="1"; ##not found

### launch the existing scripts
echo `$DATE` "	: ### alphaqueue #### launching dockers" 
cp /ptemp/scratch/web-uploads/* /home/alphafold/fastas/
echo `$DATE` "	: checking queue " 
NFILES=` find "$SCRIPTS"  -maxdepth 1 -type f -name "run*" | wc -l`
echo `$DATE` "	: found " $NFILES " jobs" 
for NAME in `find "$SCRIPTS"   -maxdepth 1 -type f -name "run*"`; do
 	LAUNCHED=`echo $NAME | sed -n 's/run/launched/p'`
 	cp $NAME $LAUNCHED
	echo `$DATE` "	: launching: " $NAME " as : " $LAUNCHED 
	LOGNAME=$LOGDIR/`echo $NAME | awk -F'/' '{print $7}'`.log
	echo `$DATE` "	: log: " $LOGNAME 
	chmod 777 $LAUNCHED
	$LAUNCHED >> $LOGNAME 2>&1 & 
	sleep 50;
	mv $NAME $VAULT 
done

echo `$DATE` "	: ### alphaqueue DONE ### "
