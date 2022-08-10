#!/bin/bash

###################################################
#	alphares : 
#	- generate html result page 
#	- copy results to the web-upload folder
###-------------------------------------
#	v.0.9	Juan.Castillo@biophys.mpg.de
#	Last update: 05.07.2022
##################################################

DATE=`date +%Y-%m-%d-%Hh-%Mm`
### output folder: everything happens here
RESPATH='/var/www/html/alphafold/results'

### tar partial results, copy them to the web area, make them downloadable
find /home/alphafold/results/ -maxdepth 1 -type d -exec tar cfP  {}.tar {}  \;  > /dev/null 2>&1
cp -R /home/alphafold/results/*.tar /var/www/html/alphafold/results/
chmod 777 /var/www/html/alphafold/results/*.tar

### header of the page
cat $RESPATH/header.part > $RESPATH/raw.html

#~ ### table building (table parameters on header.part)
echo "<th>NAME</th> <th>SIZE</th> <th>Created</th> <th>Download</th>" >> $RESPATH/table.part
ls -lh /home/alphafold/results | grep tar | awk '{print "<tr><td>"$9"</td><td>"$5"</td><td>"$6 " "$7" "$8"</td><td><a href="$9">Direct Download</a></td></tr>" }'  >> $RESPATH/table.part

cat $RESPATH/table.part >> $RESPATH/raw.html
### close the table, add the go to results/back to main buttons
echo "</table> <br><hr><br>" >>  $RESPATH/raw.html
echo "<button type=\"button\" style=\"background-color:Aqua; color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer; \"onClick=\"window.location ='download.html' \">Request donwload link</button>" >> $RESPATH/raw.html
echo "<button type=\"button\" style=\"background-color:lime;  color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer; \"onClick=\"window.location ='../index.html' \">Back to main</button>" >> $RESPATH/raw.html

### formatting the output so that is shown in a nice table
sed -i 's|<head>|<head>\n<title>alphafold results</title>|' $RESPATH/raw.html 
sed -i "s|<h2>Last update</h2>|<h2>Last update ${DATE}</h2> |"  $RESPATH/raw.html

#~ ### remove unwanted (secret) dockers
#~ #sed -i '/Filebrowser/d'  /var/www/html/parts/monitor/index.html 
#~ ### clean the house
cp $RESPATH/raw.html $RESPATH/results.html
rm -rf $RESPATH/table.part
rm -rf $RESPATH/raw.html


