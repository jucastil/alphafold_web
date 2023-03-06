#!/bin/bash
#####################################################
#
#	alphanotify
#	-checks dockers running vs scripts launched
#	-sends you an email once the docker is done
#	v1.0 : JuanCastillo 2023_02_16
################################################### 

### initial values
status="done"
DOCKERNAME="pepito"
RUNNING="true"

function print_doing_nothing(){
	### message repeated
	echo 
	echo "	Doing nothing: Bye...";
	echo
}



function is_docker_running(){
	### runs in the background, checks if docker is done
	echo
	echo "	Activating monitoring... run log on: " $DOCKERNAME"_status.log"
	read -p "	Email address ? " EMAIL
	echo "	You will get an email when the docker is done"
	while $RUNNING; do
		sleep 60
		containers=$(docker ps | awk '{if(NR>1) print $NF}')  		# get all running docker container names
		#for container in $containers
		#do
		if [[ "$containers" =~ "$DOCKERNAME" ]]; then
			RUNNING="true"
			status=`docker ps -f name=$DOCKERNAME --format '{{.Status}}'`
			echo "	docker $LASTDOCKER status: " $status >> $DOCKERNAME"_status.log"
		else
			RUNNING="false"
			message="[DONE] Docker $DOCKERNAME done, last status : $status"
			echo $message | mail -s "Docker $DOCKERNAME is done" $EMAIL
			#sed -i "${LINENUMBER}s/NOT/${status}/" $DOCKERUSERLOG
		fi
		#done	
	done &
}

############### main #######################







if [[ $# -eq 0 ]] ; then
	tput setaf 2;
 	echo; echo "	Starting monitor"; echo
	tput sgr0;
	read -p "	Continue (y/n)?" CONT
	if [ "$CONT" = "y" ]; then
		DOCKERNAME=`docker ps -a --latest --format "{{.Names}}"`
		echo "	last docker running : " $DOCKERNAME   
		tput setaf 2;
		read -p "	Was it your docker (y/n)?" CONT2
		tput sgr0;
		if [ "$CONT2" = "y" ]; then
			is_docker_running
		else
			tput setaf 2;
			read -p "	Name docker manually (y/n)?" CONT3
			tput sgr0;
			if [ "$CONT3" = "y" ]; then
				read -p "	Please introduce the name of the docker to monitor: " LASTDOCKER
				is_docker_running
			else
				print_doing_nothing
			fi
		fi	
	else
		print_doing_nothing
	fi
fi


