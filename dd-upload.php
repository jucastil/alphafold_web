<?php
$source = $_FILES["upfile"]["tmp_name"];
//upload dir so we share it in the network also
$upload_dir =  '/ptemp/scratch/web-uploads';
$destination = $_FILES["upfile"]["name"];
//sample destination for tests
//$destination = '/ptemp/scratch/web-uploads/test.txt';

move_uploaded_file($source, "$upload_dir/$destination");
echo "OK";
?>

