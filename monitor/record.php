<?php

    //POST data (all together)
    $job_name = $_POST['jname'];
    $username= $_POST['username'];
   
    function died($error) {
        // html error page
        echo "<html>";
        echo "<div align=\"center\"><img src=\"logo-new.png\" alt=\"MPIBP logo\"> ";
        echo "<p align=\"center\"> <h1>There were error(s) with your input.</h1>";
        echo "These errors appear below.<br /><br />";
        echo $error."<br /><br />";
        echo "Please go back and fix these errors.<br /><br />";
        echo "<button type=\"button\" style=\"background-color:red; border-radius:8px; width: 100px; height: 50px; \"onClick=\"window.location ='../index.html' \">Back to main</button></DIV>"; 
        echo "</html>";
        die();
    }
    //REQUIRED
    $required = array('jname', 'username');
    $error = false;
	foreach($required as $field) {
		if (empty($_POST[$field])) {
			died('<b>Some submission fields are empty</b><br> Please fill all the fields'); 
		}
	}
    //CLEAN
    function clean_string($string) {
      $bad = array("content-type","bcc:","to:","cc:","href");
      return str_replace($bad,"",$string);
    }
    //CREATE record
    function create_record($job_name,$username){
		// records the submission sh file
		$sites = realpath(dirname(__FILE__)).'/';
		$newfile = $sites."killed/docker_".$job_name;
		//echo $newfile;
		$records = fopen($newfile,"w") or die("Cannot write the script!");
		//fixed run paramenters
		fwrite($records, $username);
		fclose($records);
	}
    
	create_record($job_name,$username);
   
?>


<!-- html sucess here -->
<html>
    <head>
        <title>Alphafold submitted</title>

        <style>
            .my_text
            {
                font-family:    Arial, Helvetica, sans-serif;
                font-size:      20px;
                font-weight:    bold;
            }
        </style>
    </head>

<br>
<br>
<DIV ALIGN="center"><img src="logo-new.png" alt="MPIBP logo"></DIV> 
<DIV ALIGN="center" class="my_text"><H1><B>Thank you for your input</B></H1></DIV>
<DIV ALIGN="center" class="my_text">SB alphafold submission system<br><br><br></DIV>
<DIV ALIGN="center"><button type="button" style="background-color:yellow;  border-radius:8px; width: 150px; height: 50px; "onClick="window.location ='../index.html' ">Back to main</button></DIV>
