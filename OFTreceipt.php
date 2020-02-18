<?php
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
?>