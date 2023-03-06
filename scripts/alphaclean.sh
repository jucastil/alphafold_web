#!/bin/bash

DATE="date +%Y-%m-%d-%Hh-%Mm"

echo  "	start moving : " `$DATE`
for tar in `find /home/alphafold/results/ -name *.tar  -type f -mtime +20 -print`; do
	mv $tar /ptemp/scratch/old/ ;
done
echo "	end moving : "`$DATE`
