#!/bin/bash

#############################################
#	alphaqueue	: 
#	queue the run_NAME.sh files
#	created by submit_job.php
#	v.1.0 by Juan.Castillo@biophys.mpg.de
#	Last update 21.07.22
############################################

LOGDIR="/ptemp/scratch/logs"
LOGRUN="/ptemp/scratch/logs/alphaqueue.log"

SCRIPTS="/var/www/html/alphafold/scripts/"
VAULT="/var/www/html/alphafold/scripts/old/"

DATE="date +%Y-%m-%d-%Hh-%Mm"

### Prepare variables
TABLE='tbl_alphafold'
SQL_EXISTS=$(printf 'SHOW TABLES LIKE "%s"' "$TABLE")
SQL_IS_EMPTY=$(printf 'SELECT 1 FROM %s LIMIT 1' "$TABLE")
### DATABASE Credentials
USERNAME='root';    
PASSWORD='biolbiol';
DATABASE='dockers';
### Control vaules
ISIN="1"; ##not found

### launch the existing scripts
echo `$DATE` "	: ### PHASE 1 #### launching dockers" 
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

echo `$DATE` "	: ### PHASE 1 DONE ### "
echo "	--------------------------------------" 
echo `$DATE` " 	: ### PHASE 2 ##### checking FASTA entries in DB"  

### Check if there is a new active docker by checking if name is in database
if [[ $(mysql -u $USERNAME -p$PASSWORD -e "$SQL_EXISTS" $DATABASE) ]]
then
    ### Check if table has records    
    if [[ $(mysql -u $USERNAME -p$PASSWORD -e "$SQL_IS_EMPTY" $DATABASE) ]]
    then
        #echo "		Table has records ..."
        ### create an array with the current running docker names
        DPSA_N=(`docker ps -a --format="{{.Names}}"`)
		NROWS=${#DPSA_N[@]}
		### loop over the docker array
		for (( i=0; i<$NROWS; i++ ));
		do
			dname=${DPSA_N[$i]};
			ISIN="0"; 	
			### look for running docker in database, if yes, change the tag to 1
			ENTRY=$dname;
			QUERY="USE "$DATABASE"; SELECT dockername FROM "$TABLE;
			COLUMN=$(mysql -u $USERNAME -p$PASSWORD -BNe "$QUERY")
			for field in $COLUMN; do
				if [ $field == $ENTRY ]; then
					ISIN="1";
					 echo `$DATE` "		Running docker " $field " in database, val: " $ISIN; 
				fi
			done
			### running docker is not in database		
			if [ $ISIN == "0" ]; then
				fasta=`docker ps --no-trunc --format "{{ .Command }}"  --filter "name=$dname"  | awk '{ print $2}' | sed 's|--fasta_paths=/mnt/fasta_path_0/||g'`
				#tput setaf 3; 
				echo `$DATE` " FASTA: " $fasta " in database but active docker: " $dname " not, addingg entry" ;	
				#echo "		FASTA: " $fasta " in database but active docker: " $dname " not, addingg entry" ;	
				#tput sgr0;
				### find fastafile in DB, update entry, notify user
				QUERY2="USE "$DATABASE"; SELECT fastafile from "$TABLE;
				COLUMN2=$(mysql -u $USERNAME -p$PASSWORD -BNe "$QUERY2")
				for thing in $COLUMN2; do
					#echo $thing
					if [ "$thing" = "$fasta" ]; then
						#tput setaf 3; echo "		FASTA "$thing " found in DB updating database"; tput sgr0;
						#mysql -u userName --password=yourPassword -D databaseName -e "UPDATE tableName SET columnName = \"${variable}\" WHERE numberColumn = \"${numberVariable}\""
						mysql -u $USERNAME -p$PASSWORD -D $DATABASE -e "UPDATE tbl_alphafold SET dockername = \"${dname}\"  WHERE fastafile = \"${thing}\""   
						mysql -u $USERNAME -p$PASSWORD -D $DATABASE -e "UPDATE tbl_alphafold SET status = 'RUNNING'  WHERE fastafile = \"${thing}\""    
						email=$(mysql -u $USERNAME -p$PASSWORD -D $DATABASE -BNe "SELECT email from tbl_alphafold WHERE dockername = \"${field}\"")
						message="  [RUNNING] Docker $dname for fasta $fasta marked as RUNNING"
						warning="  You should receive a third email once your job is done."
						warning2="	If you don't get a third email, forward this email to:"
						warning3="	Juan.Castillo@biophys.mpg.de"
						#(echo $message; echo ""; echo $warning; echo $warning2; echo $warning3 )| mail -s "alphafold : docker $field is RUNNING"  $email 
						(echo $message; echo ""; echo $warning; echo $warning2; echo $warning3 )| mailx -r alphafold@biophys.mpg.de -s "alphafold : docker $field is RUNNING"  $email 
						#(echo $message; echo ""; echo $warning; echo $warning2; echo $warning3 )| mail -s "alphafold : docker $field is RUNNING" jucastil@biophys.mpg.de ##copy for me  
					fi
				done
			fi
		done
       
    else
        echo "		ERROR: Table is empty ..."
    fi
else
    echo "		ERROR: Table does not exist ..."
fi

echo `$DATE` "	: ### PHASE 2 DONE ###  DB updated with new dockers "
echo "	--------------------------------------" 
echo `$DATE` " 	: ### PHASE 3 ##### Checking active dockers"  
sleep 1m;

donedockers=0
if [[ $(mysql -u $USERNAME -p$PASSWORD -e "$SQL_EXISTS" $DATABASE) ]]
then
    ### Check if table has records    
    if [[ $(mysql -u $USERNAME -p$PASSWORD -e "$SQL_IS_EMPTY" $DATABASE) ]]
    then
        #echo "		Table has records ..."
        ### create an array with the current running docker names
        DPSA_N=(`docker ps -a --format="{{.Names}}"`)
		NROWS=${#DPSA_N[@]}
        ### look for running docker in database
		QUERY="USE "$DATABASE"; SELECT dockername FROM "$TABLE;
		COLUMN=$(mysql -u $USERNAME -p$PASSWORD -BNe "$QUERY")
		for field in $COLUMN; do
			#echo "		Docker " $field " in database"; 
			if [[ ! " ${DPSA_N[*]} " =~ " ${field} " ]]; then
				### check if non-running docker is marked as DONE already
				state=$(mysql -u $USERNAME -p$PASSWORD -D $DATABASE -BNe "SELECT status from tbl_alphafold WHERE dockername = \"${field}\"")
				### tput setaf 3; echo "		Docker " $field " is not running, status: " $state; tput sgr0;
				if [ "$state" = "DONE" ]; then
					donedockers=$((donedockers+1))
				else
					echo "		Docker: " $field " not active, DB status will be changed to DONE, user will be notified"
					state="DONE";
					mysql -u $USERNAME -p$PASSWORD -D $DATABASE -e "UPDATE tbl_alphafold SET status = \"${state}\"  WHERE dockername = \"${field}\""  
					finished=`date +%Y-%m-%d-%H-%M`
					mysql -u $USERNAME -p$PASSWORD -D $DATABASE -e "UPDATE tbl_alphafold SET finished_on = \"${finished}\"  WHERE dockername = \"${field}\""  
					### get registered email, send email
					email=$(mysql -u $USERNAME -p$PASSWORD -D $DATABASE -BNe "SELECT email from tbl_alphafold WHERE dockername = \"${field}\"")
					echo "		Notifying: "$email
					message="  [DONE] Docker $field marked as DONE"
					warning="  IMPORTANT: PLEASE be aware the docker may have crashed or may have been killed"
					#(echo $message; echo ""; echo "Finished: " $finished;  echo $warning )| mail -s "alphafold : docker $field is done, please collect your results"  $email  
					(echo $message; echo ""; echo "Finished: " $finished;  echo $warning )| mailx -r alphafold@biophys.mpg.de -s "alphafold : docker $field is done, please collect your results"  $email  
					#(echo $message; echo ""; echo "Finished: " $finished;  echo $warning )| mailx -r alphafold@biophys.mpg.de -s "alphafold : docker $field is done, please collect your results"  jucastil@biophys.mpg.de ##copy for me     
				fi		
			fi
		done
               
    else
        echo "		ERROR: Table is empty ..."
    fi
else
    echo "		ERROR: Table not exists ..."
fi

echo `$DATE` "	: DONE dockers: " $donedockers

echo `$DATE` "	: ### PHASE 3 DONE ###  docker scan finished "
echo "	--------------------------------------" 
echo `$DATE` " 	: ### PHASE 4 ##### Copying results, updating website"

### output folder: everything happens here
RESPATH='/var/www/html/alphafold/results'
OUTPATH='/home/alphafold/results/'

### tar partial results, copy them to the web area, make them downloadable
find $OUTPATH -maxdepth 1 -type d -exec tar cfP  {}.tar {}  \;  > /dev/null 2>&1
cp -R -u $OUTPATH*.tar $RESPATH
chmod 777 $RESPATH/*.tar


### header of the web + table build after the results
cat $RESPATH/header.part > $RESPATH/raw.html
echo "<th>NAME</th> <th>SIZE</th> <th>Created</th> <th>Download</th>" >> $RESPATH/table.part
ls -lh /home/alphafold/results | grep tar | awk '{print "<tr><td>"$9"</td><td>"$5"</td><td>"$6 " "$7" "$8"</td><td><a href="$9">Direct Download</a></td></tr>" }'  >> $RESPATH/table.part
cat $RESPATH/table.part >> $RESPATH/raw.html
### close the table, add the go to results/back to main buttons
echo "</table> <br><hr><br>" >>  $RESPATH/raw.html
echo "<button type=\"button\" style=\"background-color:Aqua; color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer; \"onClick=\"window.location ='download.html' \">Request donwload link</button>" >> $RESPATH/raw.html
echo "<button type=\"button\" style=\"background-color:lime;  color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer; \"onClick=\"window.location ='../index.html' \">Back to main</button>" >> $RESPATH/raw.html
#sed -i 's|<head>|<head>\n<title>alphafold results</title>|' $RESPATH/raw.html 
sed -i "s|<h2>Last update</h2>|<h2>Last update `date +%Y-%m-%d-%Hh-%Mm`</h2> |"  $RESPATH/raw.html

#~ ### remove unwanted (secret) dockers
#~ #sed -i '/Filebrowser/d'  /var/www/html/parts/monitor/index.html 
#~ ### clean the house
cp $RESPATH/raw.html $RESPATH/results.html
rm -rf $RESPATH/table.part
rm -rf $RESPATH/raw.html

echo `$DATE` "	: ### PHASE 4 DONE ###  "
echo "	--------------------------------------" 

