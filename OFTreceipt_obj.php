<?php
	$text1 = $_POST["input2"];
	$filename = $_POST["filename2"];

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