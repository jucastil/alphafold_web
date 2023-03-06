<?php

    //POST data (all together)    
    $firstname = $_POST['fname'];
    $lastname  = $_POST['lname'];
    $filename = $_POST['fasta'];
	$freeform = $_POST['freeform'];
    $email_form = $_POST['email'];
    
    function died($error) {
        // html error page
        echo "<html>";
        echo "<div align=\"center\"><img src=\"logo-new.png\" alt=\"MPIBP logo\"> ";
        echo "<p align=\"center\"> <h1>There were error(s) with your input.</h1>";
        echo "These errors appear below.<br /><br />";
        echo $error."<br /><br />";
        echo "Please go back and fix these errors.<br /><br />";
        echo "<button type=\"button\" style=\"background-color:red; border-radius:8px; width: 100px; height: 50px; \"onClick=\"window.location ='index.html' \">Back to main</button></DIV>"; 
        echo "</html>";
        die();
    }
    //REQUIRED
    $required = array( 'fname', 'lname', 'fasta', 'freeform','email');
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
    //CREATE submission fasta
    function create_fasta($job_name,$filename,$freeform){
		// records the submission sh file
		//$sites = realpath(dirname(__FILE__)).'/';
		//$newfile = $sites."fastas/".$filename.".fasta";
		$newfile = "/ptemp/scratch/web-uploads/".$filename.".fasta";
		//echo $newfile;
		$records = fopen($newfile,"w") or die("Cannot write the fasta!");
		//write the sequence
		$shenanigan .= $freeform;
		fwrite($records, $shenanigan);
		fclose($records);
	}
    
    //echo "Yes, email is set";    //DEBUG
    // $email_to = $_POST['email']; // ONLY TO THE FORM-FILLED 
    $email_to = $email_form . ",jucastil@biophys.mpg.de"; //to jucastil also
    $email_regex = "/([a-zA-Z0-9!#$%&’?^_`~-])+@([a-zA-Z0-9-])+/";
    if(!preg_match($email_regex,$email_to)){
		//echo "Sorry, email seems to be wrongly written";
		died('<b>email seems to be incorrect or wrongly written</b>');      
	}
	$fastapath .= '/ptemp/scratch/web-uploads/' . $filename.".fasta";
	//echo $fastapath; //DEBUG
	if (file_exists($fastapath)) {
		died('<b>FASTA file already exist</b>');      
	} 
	
	#echo $message;
    $email_subject_default = "FASTA ";
    $email_subject = $email_subject_default . $filename ." created";
    $email_message .= "..............\n";
    //current time and date
    date_default_timezone_set('Europe/Berlin');
    $email_message .= " Submitted: ".date("Y-m-d")."\n"; 
    $email_message .= " Time: ".date("H:i")."\n";   
    $email_message .= " ..............\n";
    $email_message .= " First Name: " . $firstname . "\n";
    $email_message .= " Last Name: " . $lastname . "\n";
    $email_message .= " FASTA file: " . $filename . "\n";
    $email_message .= " \n";
    $email_message .= " Please don't forget to come back to main and submit. \n";
    $email_message .= " If you have issues, please write to: \n";
    $email_message .= " Juan.Castillo@biophys.mpg.de \n";
    create_fasta($job_name,$filename,$freeform);
    $headers = "From: alphafold@biophys.mpg.de" . "\r\n" ;
    @mail($email_to, $email_subject, $email_message, $headers); 
    
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
<DIV ALIGN="center" class="my_text"><H1><B>FASTA sucessfully recorded</B></H1></DIV>
<DIV ALIGN="center" class="my_text">SB alphafold submission system<br><br><br></DIV>
<DIV ALIGN="center"><button type="button" style="background-color:yellow;  border-radius:8px; width: 150px; height: 50px; "onClick="window.location ='index.html' ">Back to main</button></DIV>
