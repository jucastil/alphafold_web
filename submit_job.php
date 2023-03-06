<?php

    //DATABASE stuff
    $servername = "localhost";
	$username = "root";
	$password = "biolbiol";
    $con = mysqli_connect($servername,$username,$password,'dockers');
 
    //POST data (all together)
    $email_form = $_POST['email'];
    $firstname = $_POST['fname'];
    $lastname  = $_POST['lname'];
    $job_name = $_POST['jname'];
    $filename = $_POST['fasta'];
    $tmp_date = $_POST['template'];
    $run_type = $_POST['runtype'];
    $data_path = $_POST['delivery'];
   
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
    $required = array('email', 'fname', 'lname', 'jname', 'fasta', 'template','runtype','delivery');
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
    //CREATE submission script
    function create_script($job_name,$filename,$tmp_date,$run_type){
		// records the submission sh file
		$sites = realpath(dirname(__FILE__)).'/';
		$newfile = $sites."scripts/run_".$job_name.".sh";
		//random GPU
		$myArray = array(0, 1, 2, 3);
		// Random shuffle
		shuffle($myArray);
		// First element is random now
		$gpudev = $myArray[0];
		//echo $newfile;
		$records = fopen($newfile,"w") or die("Cannot write the script!");
		//fixed run paramenters
		$fasta_path = "--fasta_paths=/home/alphafold/fastas/";
		$data_dir = "--data_dir=/home/alphafold/genetic_database_new/";
		$output_dir = "--output_dir=/home/alphafold/results/";
		$shenanigan = "#!/bin/bash \n \n module load python-3.7.3 \n";
		$shenanigan .= "### user: ".$email_form ."\n";
		$shenanigan .= "sudo python3 /home/alphafold/alphafold/docker/run_docker.py ".$fasta_path.$filename." --max_template_date=".$tmp_date." --gpu_devices=".$gpudev." --model_preset=". $run_type." ".$data_dir." ".$output_dir;
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
	$fastapath .= '/ptemp/scratch/web-uploads/' . $filename;
	//echo $fastapath; //DEBUG
	if (!file_exists($fastapath)) {
		died('<b>FASTA file not found</b>');      
	} 
	
	#echo $message;
    $email_subject_default = "alphafold ";
    $email_subject = $email_subject_default . $filename;
    $email_message .= "..............\n";
    //current time and date
    date_default_timezone_set('Europe/Berlin');
    $email_message .= " Submitted: ".date("Y-m-d")."\n"; 
    $email_message .= " Time: ".date("H:i")."\n";   
    $email_message .= " ..............\n";
    $email_message .= " First Name: " . $firstname . "\n";
    $email_message .= " Last Name: " . $lastname . "\n";
    $email_message .= " Job Name: " . $job_name . "\n";
    $email_message .= " ...... RUN PARAMETERS ....\n";
    $email_message .= " FASTA file: " . $filename . "\n";
    $email_message .= " template: " . $tmp_date . "\n";
    $email_message .= " run type: " . $run_type . "\n";
    $email_message .= " Results delivery: " . $data_path . "\n";
    $email_message .= " \n";
    $email_message .= " Please check the status of your job in the STATUS page. \n";
    $email_message .= " If you have issues forward this email to: \n";
    $email_message .= " Juan.Castillo@biophys.mpg.de \n";
    create_script($job_name,$filename,$tmp_date,$run_type);
    $headers = "From: alphafold@biophys.mpg.de" . "\r\n" ;
    @mail($email_to, $email_subject, $email_message, $headers); 
    
    $start_date .=date("Y-m-d-H-i");
    // database insert SQL code
	$sql = "INSERT INTO `tbl_alphafold` (`firstname`, `lastname`, `jobname`, `fastafile`, `tempdate`,`runtype`,`email`,`start`) VALUES ('$firstname', '$lastname', '$job_name', '$filename', '$tmp_date','$run_type','$email_form','$start_date')";
	$rs = mysqli_query($con, $sql);
	if($rs)
	{
		echo "									Contact Records Inserted";
	}
    

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
<DIV ALIGN="center"><button type="button" style="background-color:yellow;  border-radius:8px; width: 150px; height: 50px; "onClick="window.location ='index.html' ">Back to main</button></DIV>
