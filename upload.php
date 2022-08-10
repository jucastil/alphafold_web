<?php
$target_dir = "/ptemp/scratch/web-uploads/";
$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
$uploadOk = 1;
$imageFileType = strtolower(pathinfo($target_file,PATHINFO_EXTENSION));


// Check if file already exists
if (file_exists($target_file)) {
  echo "Sorry, file already exists.";
  $uploadOk = 0;
}

  if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
		// html  upload
        echo "<html>";
        echo "<div align=\"center\"><img src=\"logo-new.png\" alt=\"MPIBP logo\"> ";
        echo "<p align=\"center\"> <h1>File Upload sucessful</h1>";
		echo "The file ". htmlspecialchars( basename( $_FILES["fileToUpload"]["name"])). " has been uploaded.";
        echo "Please go back and fill the submit form<br /><br />";
        echo "<button type=\"button\" style=\"background-color:lime; border-radius:8px; width: 100px; height: 50px; \"onClick=\"window.location ='index.html' \">Back to main</button></DIV>"; 
        echo "</html>"
  } else {
    echo "Sorry, there was an error uploading your file.";
  }

?>
