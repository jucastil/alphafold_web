#!/bin/bash

###################################################
#	alphamon3 : generate html output from docker
#	v.1.0	Juan.Castillo@biophys.mpg.de
#	Last update: 11.07.2022
##################################################

DATE=`date +%Y-%m-%d-%Hh-%Mm`
### output folder: everything happens here
MONPATH='/var/www/html/alphafold/monitor'

cat $MONPATH/header.part > $MONPATH/raw.html

### table building

#export FORMAT="table {{.Names}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}"

DRUNNING=`docker ps -q | wc -l`  # number of running dockers

## info arrays : some are not properly stored :-)
DPSA_N=(`docker ps -a --format="{{.Names}}"`)
DPSA_I=(`docker ps -a --format="{{.Image}}"`)
DPSA_C=(`docker ps -a --format="{{.CreatedAt}}"`)
## test: stats once docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 

## test: print array lenghts
NROWS=${#DPSA_N[@]}
#echo "	found : " $NROWS " dockers"

echo "<th>NAME</th> <th>IMAGE</th> <th>CREATED</th> <th>STATUS</th> <th>FASTA</th>  <th>CPU%</th> <th>MEM USAGE / LIMIT </th>" >> $MONPATH/table.part

for (( i=0; i<$NROWS; i++ ));
do
   echo "<tr><td>${DPSA_N[$i]}" "</td><td>" "${DPSA_I[$i]}" "</td><td>""${DPSA_C[$i]}" "</td><td>" \
    `docker ps -a --format="{{.Status}}" --filter "name=${DPSA_N[$i]}"` "</td><td>" \
    `docker ps --no-trunc --format "{{ .Command }}"  --filter "name=${DPSA_N[$i]}"  | awk '{ print $2}' | sed 's|--fasta_paths=/mnt/fasta_path_0/||g'` "</td><td>" \
    `docker stats --no-stream --format "{{.CPUPerc}}" ${DPSA_N[$i]}` "</td><td>" \
    `docker stats --no-stream --format "{{.MemUsage}}" ${DPSA_N[$i]}` "</td></tr>" >> $MONPATH/table.part
done

cat $MONPATH/table.part >> $MONPATH/raw.html
### close the table, add the go to results/back to main buttons
echo "</table> <br><hr><br>" >>  $MONPATH/raw.html
echo "<button type=\"button\" style=\"background-color:Coral; color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer; \"onClick=\"window.location ='../results/results.html' \">Go to results</button>" >> $MONPATH/raw.html
echo "<button type=\"button\" style=\"background-color:Aqua; color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer; \"onClick=\"window.location ='submit.html' \">Mark as done</button>" >> $MONPATH/raw.html

echo "<button type=\"button\" style=\"background-color:lime;  color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer; \"onClick=\"window.location ='../index.html' \">Back to main</button>" >> $MONPATH/raw.html


### formatting the output so that is shown in a nice table
sed -i 's|<head>|<head>\n<title>alphafold monitor</title>|' $MONPATH/raw.html 
sed -i "s|<h2>Last update</h2>|<h2>Last update ${DATE}</h2> |"  $MONPATH/raw.html

### remove unwanted (secret) dockers
sed -i '/dokuwiki/d'  $MONPATH/raw.html
sed -i '/mysql-xwiki/d'  $MONPATH/raw.html
sed -i '/xwiki/d'  $MONPATH/raw.html
sed -i '/trilium/d' $MONPATH/raw.html 
### clean the house
cp $MONPATH/raw.html $MONPATH/status.html
rm -rf $MONPATH/table.part
rm -rf $MONPATH/raw.html

