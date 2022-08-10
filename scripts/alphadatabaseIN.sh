#!/bin/bash

#############################################
#	alphadatabaseIN	: 
#	update the database after the NEW running dockers
#	v.1.0 by Juan.Castillo@biophys.mpg.de
#	Last update 26.07.22
############################################

LOGDIR="/ptemp/scratch/logs"
LOGRUN="/ptemp/scratch/logs/alphadatabase.log"
DATE="date +%Y-%m-%d-%Hh-%Mm"

### Prepare variables
TABLE='tbl_alphafold'
SQL_EXISTS=$(printf 'SHOW TABLES LIKE "%s"' "$TABLE")
SQL_IS_EMPTY=$(printf 'SELECT 1 FROM %s LIMIT 1' "$TABLE")
DPSA_N=(); # emtpy name array
DPSA_F=(); # emtpy fasta array
N_NAMES="0";
N_FASTAS="0";
### DATABASE Credentials
USERNAME='root';    
PASSWORD='biolbiol';
DATABASE='dockers';

echo `$DATE` " 	: ### alphadatabase ##### checking FASTA entries in DB"  
ISIN="0";

function send_email_docker_running(){

	useremail=$1;
	dockername=$2;
	echo "	sending email to : " $useremail
       
	printf  " ================================\n  `date` \n ================================\n  
  Dear user : \n 
  Your docker *$dockername* is now RUNNING. 
  You can check now the status on:  
  http://alphafold.bpcentral.biophys.mpg.de/alphafold/monitor/status.html
  The data page above is refreshed *each 5 minutes*. 
  Click on a column (for example, FASTA) to order by values.  
  You should get another email when the docker is marked as *DONE*.\n
  If you have questions, or if you need help, please contact Juan.Castillo@biophys.mpg.de. \n
  Thank you for participating! \n " | mail -s  "alphafold $dockername RUNNING " $useremail;

}

function send_email_docker_done(){

	useremail=$1;
	dockername=$2;
	echo "	sending email to : " $useremail
       
	printf  " ================================\n  `date` \n ================================\n  
  Dear user : \n 
  Your docker *$dockername* is now DONE. 
  You can collect the results from:  
  http://alphafold.bpcentral.biophys.mpg.de/alphafold/results/results.html \n
  
  The data page above is refreshed *each 10 minutes*. 
  Click on a column (for example, NAME) to order by values.  \n

  If you have questions, or if you need help, please contact Juan.Castillo@biophys.mpg.de. \n
  Thank you for participating! \n " | mail -s  "alphafold $dockername RUNNING " $useremail;

}


function collect_running_docker_names(){
	DPSA_N=(`docker ps -a --format="{{.Names}}"`);
	N_NAMES=${#DPSA_N[@]};
	echo `$DATE` " 	: found: " $N_NAMES "dockers";  
}

function collect_running_docker_fastas(){

	for (( i=0; i<$N_NAMES; i++ )); do		
		DPSA_F+=$(docker ps --no-trunc --format "{{ .Command }}"  --filter "name=${DPSA_N[$i]}" | awk '{ print $2}' | sed 's|--fasta_paths=/home/alphafold/fasta_path_0/||g');
		#echo $fastafile;			
	done
	N_FASTAS=${#DPSA_F[@]};
	echo `$DATE` " 	: found: " $N_FASTAS "fastas";  

}

function check_database_and_table_health(){
	
	if [[ $(mysql -u $USERNAME -p$PASSWORD -e "$SQL_EXISTS" $DATABASE) ]]
	then
		if [[ $(mysql -u $USERNAME -p$PASSWORD -e "$SQL_IS_EMPTY" $DATABASE) ]]
		then
			echo `$DATE` " 	: Table and database OK";  	
		else
			echo "		ERROR: Table is empty ..."
		fi
	else
		echo "		ERROR: Table does not exist ..."
	fi
	
}

function is_running_docker_in_database(){

	for (( i=0; i<$N_NAMES; i++ )); do
		dname=${DPSA_N[$i]};
		echo $dname;
		IS_IN_DB=$(mysqldump -p$PASSWORD $DATABASE --extended=FALSE | grep $dname | less -S);
		if [[ "$IS_IN_DB" == *"$dname"* ]]; then
			echo "	docker: " $dname " already in database"
		else
			echo " docker not in DB, checking if it's an alphafold docker";
			dimage=`docker ps --no-trunc --format "{{ .Image }}"  --filter "name=$dname"`; 
			echo "	image:" $dimage;
			if [ "$dimage" = "alphafold" ]; then
				echo "	alphafold docker, adding it to database"
				add_running_docker_to_database $dname
				useremail=$(mysql --silent --batch -N -u $USERNAME -p$PASSWORD -D $DATABASE -e "SELECT email FROM tbl_alphafold WHERE dockername= \"$dname\" ");
				send_email_docker_running $useremail $dname;
			else
				echo "	not an alphafold image";
			fi
		fi
	done
		
}

function add_running_docker_to_database(){

	fasta=`docker ps --no-trunc --format "{{ .Command }}"  --filter "name=$dname"  | awk '{ print $2}' | sed 's|--fasta_paths=/mnt/fasta_path_0/||g'`;
	echo "	DEBUG: adding " $dname " to database fasta: " $fasta	
	IS_IN_DB=`mysqldump -p$PASSWORD $DATABASE --extended=FALSE | grep -i "$fasta"`;
	#echo $IS_IN_DB;
	if [[ "$IS_IN_DB" == *"$fasta"* ]]; then
		echo "	fasta in database: adding dockername"
		mysql -u $USERNAME -p$PASSWORD -D $DATABASE -e "UPDATE tbl_alphafold SET dockername = \"${dname}\"  WHERE fastafile = \"${fasta}\"";   
		mysql -u $USERNAME -p$PASSWORD -D $DATABASE -e "UPDATE tbl_alphafold SET status = 'RUNNING'  WHERE fastafile = \"${fasta}\"";    
	else
		echo "	fasta not found"
	fi

}

function is_docker_still_running(){

	QUERY="USE "$DATABASE"; SELECT status FROM "$TABLE;
	COLUMN=$(mysql -u $USERNAME -p$PASSWORD -BNe "$QUERY")
	for state in $COLUMN; do
		#echo $state;
		if [ $state == "RUNNING" ]; then
			#display table, we use the silent mode, no column name (-N)
			#mysql -u $USERNAME -p$PASSWORD -D $DATABASE -e "SELECT dockername FROM tbl_alphafold WHERE status = \"RUNNING\" ";
			mysql --silent --batch -N -u $USERNAME -p$PASSWORD -D $DATABASE -e "SELECT dockername FROM tbl_alphafold WHERE status = \"RUNNING\" " | while IFS= read -r databasedocker
			do
				echo " 	FOUND " $databasedocker " database status RUNNING"
				if [[ " ${DPSA_N[*]} " =~ " ${databasedocker} " ]]; then
					# whatever you want to do when array contains value
					echo "	docker still running";
				else
					echo "	database docker not anymore running, updating database";
					mysql -u $USERNAME -p$PASSWORD -D $DATABASE -e "UPDATE tbl_alphafold SET status = 'DONE'  WHERE dockername = \"${databasedocker}\""    
					useremail=$(mysql --silent --batch -N -u $USERNAME -p$PASSWORD -D $DATABASE -e "SELECT email FROM tbl_alphafold WHERE dockername= \"$dtatabasedocker\" ");
					send_email_docker_done $useremail $databasedocker
				fi
			done;
		fi
	done
	
}



############ main ##################

collect_running_docker_names;
collect_running_docker_fastas;
check_database_and_table_health;
is_running_docker_in_database;
is_docker_still_running;


