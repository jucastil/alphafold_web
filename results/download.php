<?php

    //POST data (all together)
    $email_form = $_POST['email'];
    $firstname = $_POST['fname'];
    $lastname  = $_POST['lname'];
    $folder = $_POST['folder'];
      
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
    $required = array('email', 'fname', 'lname', 'folder');
    $error = false;
	foreach($required as $field) {
		if (empty($_POST[$field])) {
			died('<b>Some submission fields are empty</b><br> Please fill all the fields'); 
		}
	}
    //FOLDER exist
    $folderpath .= '/var/www/html/alphafold-v3/results/' . $folder;
	if (!file_exists($folderpath)) {
		died('<b>Result file doesn not exist</b> <br> Please check again the folder name');  
	} 
    //CLEAN string
    function clean_string($string) {
      $bad = array("content-type","bcc:","to:","cc:","href");
      return str_replace($bad,"",$string);
    }
    
    // (A) EMAIL SETTINGS
    $email_to = $email_form . ",jucastil@biophys.mpg.de"; //to jucastil also
	$email_regex = "/([a-zA-Z0-9!#$%&’?^_`~-])+@([a-zA-Z0-9-])+/";
	if(!preg_match($email_regex,$email_to)){
		//echo "Sorry, email seems to be wrongly written";
		died('<b>email seems to be incorrect or wrongly written</b>');      
	}
    $email_subject_default = "alphafold download request ";
	$email_subject = $email_subject_default . $folder;
	
	//$email_message = "<strong>Test Message</strong>";
	$email_message .= "Request submitted: ".date("d.m.Y")."<br>"; 
	date_default_timezone_set('Europe/Berlin');
	$email_message .= "Time: ".date("H:i")."<br>";   
	$email_message .= "..............<br>";
	$email_message .= "First Name: " . $firstname . "<br>";
	$email_message .= "Last Name: " . $lastname . "<br>";
	$email_message .= "Claimed results : " . $folder . "<br>";
	
	//$mailAttach = "alphares.sh";
	//$mailAttach .= .$folder;
	
	// (B) GENERATE RANDOM BOUNDARY TO SEPARATE MESSAGE & ATTACHMENTS
	// https://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
	$mailBoundary = md5(time());
	$mailHead = implode("\r\n", [
	"MIME-Version: 1.0",
	"Content-Type: multipart/mixed; boundary=\"$mailBoundary\""
	]);

	// (C) DEFINE THE EMAIL MESSAGE
	$mailBody = implode("\r\n", [
	"--$mailBoundary",
	"Content-type: text/html; charset=utf-8",
	"",
	$email_message
	]);

	// (D) MANUALLY ENCODE & ATTACH THE FILE
	$mailBody .= implode("\r\n", [
	"",
	"--$mailBoundary",
	"Content-Type: application/octet-stream; name=\"". basename($mailAttach) . "\"",
	"Content-Transfer-Encoding: base64",
	"Content-Disposition: attachment",
	"",
	chunk_split(base64_encode(file_get_contents($mailAttach))),
	"--$mailBoundary--"
	]);

	// (E) SEND
	echo mail($email_to, $email_subject, $mailBody, $mailHead) ? "OK" : "ERROR" ;
    
  
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
<DIV ALIGN="center"><img src="mpibp_logo_webnotext.gif" alt="MPIBP logo"></DIV> 
<DIV ALIGN="center" class="my_text"><H1><B>Thank you for your input</B></H1></DIV>
<DIV ALIGN="center" class="my_text">SB alphafold submission system<br><br><br></DIV>
<DIV ALIGN="center"><button type="button" style="background-color:yellow;  border-radius:8px; width: 150px; height: 50px; "onClick="window.location ='index.html' ">Back to main</button></DIV>
