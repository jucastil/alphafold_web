<?php
if(isset($_POST['email'])) {
     
    // REFERENCE: root@sbgamma:/var/www/html/grids/send_form_email.php
    // (grid uploading system)
     
    $email_to = "jucastil@biophys.mpg.de";
    $email_subject = "alphafold submitted";
    
    $fname = $_POST['fname']; // required
    $email_from = $_POST['email']; // required  
    $error_message = "";
    $email_message = "Alphafold details below.\n\n";
    
    // email body
    $email_message .= "..............\n";
    //current time and date
    date_default_timezone_set('Europe/Berlin');
    $email_message .= "Ordered date: ".date("d.m.Y")."\n"; 
    $email_message .= "Time: ".date("H:i")."\n";   
	//from the contact form
	$headers = "From: emorders@biophys.mpg.de" . "\r\n" .
	"Reply-To: emorders@biophys.mpg.de"."\r\n" .

	'X-Mailer: PHP/' . phpversion();
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
<DIV ALIGN="center" class="my_text"><H1><B>Thank you for your input</B></H1></DIV>
<DIV ALIGN="center" class="my_text">SB alphafold submission system<br><br><br></DIV>
<DIV ALIGN="center"><button type="button" style="background-color:yellow;  border-radius:8px; width: 150px; height: 50px; "onClick="window.location ='index.html' ">Back to main</button></DIV>


<?php
}
?>
