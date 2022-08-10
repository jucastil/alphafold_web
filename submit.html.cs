<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {font-family: Arial, Helvetica, sans-serif;}
* {box-sizing: border-box;}

input[type=text], select, textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
  margin-top: 6px;
  margin-bottom: 16px;
  resize: vertical;
}

input[type=submit] {
  background-color: #04AA6D;
  color: white;
  padding: 12px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

input[type=submit]:hover {
  background-color: #45a049;
}

.container {
  border-radius: 5px;
  background-color: #f2f2f2;
  padding: 20px;
}
</style>
</head>
<body>

<h3>Submit job</h3>

<div class="container">
  <form name "new job" action="submit_job.php" method="post">
    <label for="fname">First Name</label>
    <input type="text" id="fname" name="fname" placeholder="Your name..">

    <label for="lname">Last Name</label>
    <input type="text" id="lname" name="lname" placeholder="Your last name..">
    <label for="jname">Job Name / Script name (no spaces allowed!) </label>
    <input type="text" id="jname" name="jname" placeholder="example: username_job">
    
    <label for="fasta">FASTA file name (should have been uploaded previously)</label>
    <input type="text" id="fasta" name="fasta" placeholder="uploaded FASTA file">
    <label for="template">Template date</label>
    <input type="text" id="template" name="template" placeholder="date tag in format YYYY-MM-DD">
    
    <input type="radio" name="runtype" id="multimer" value="multimer"  style="height:35px; width:35px; vertical-align: middle;">
    <label for="multimer">multimer</label>
    <input type="radio" name="runtype"  id="monomer" value="monomer" style="height:35px; width:35px; vertical-align: middle;">
    <label for="monomer">monomer</label>
    <br><br>
    <label for="email">Email to (notifications will arrive here) </label>
    <input type="text" id="email" name="email" placeholder="Your email..">
    <br>
	<strong> >>> WARNING <<< </strong> <br><br>
	After <b>Submit</b> it takes up to 5 minutes for the job to start running <br><br>
    <input type="submit" value="Submit">
    <input type="reset"  style="background-color:yellow; color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer;" value="Reset">
    <button type="button" style="background-color:lime;  color: black;  padding: 12px 20px;  border: none; border-radius: 4px;  cursor: pointer; "onClick="window.location ='index.html' ">Back to main</button>

    
  </form>



</div>
</body>
</html>
