#!/bin/bash

field="my_dockername"

message="[DONE] Docker $field done"

#printf '%s \n %s \n \n' "$message"," please collect your results"

(echo $message; echo "" ; echo " Please collect your results") | mail -s "Docker $field is done, please collect your results" jucastil@biophys.mpg.de ##copy for me 
