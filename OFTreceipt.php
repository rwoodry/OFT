<?php
	if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
	    header('Access-Control-Allow-Origin: *');
	    header('Access-Control-Allow-Methods: POST, GET, DELETE, PUT, PATCH, OPTIONS');
	    //header('Access-Control-Allow-Methods: POST, OPTIONS');
	    header('Access-Control-Allow-Headers: token, Content-Type');
	    header('Access-Control-Max-Age: 1728000');
	    header('Content-Length: 0');
	    header('Content-Type: text/plain');
	    die();
	}
	header('Access-Control-Allow-Origin: *');
	header('Content-Type: application/json');

	$text1 = $_POST["input"];
	$filename = $_POST["filename"];

	if ($text1 != "")
	{
		$file = fopen($filename, "a"); 
		fwrite($file, $text1);
		fclose($file);
	} else
	{
		echo("Messsage delivery failed...");
	}

	$text2 = $_POST["input2"];
	$filename2 = $_POST["filename2"];

	if ($text2 != "")
	{
		$file2 = fopen($filename2, "a"); 
		fwrite($file2, $text2);
		fclose($file2);
	} else
	{
		echo("Messsage delivery failed...");
	}
?>
