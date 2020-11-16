#!/usr/bin/python3

# SOFTtoDrive
# Script that uses Google Drive's API to push OFT & SOT data files to the Spatial Neuroscience UCI Drive

# Load dependencies
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from apscheduler.schedulers.blocking import BlockingScheduler
import os
import glob
import subprocess

# Define function to upload OFT files to lab's UCI google drive
def upload_SOFTfiles():
	# Run Quality check code on the data, write a quality check table to the folder so it can be uploaded to drive
	print("Quality checking the data ...")
	quality_check_SOFT()

	print("FILES UPLOADING TO DRIVE")
	# Initialize authorization
	g_login = GoogleAuth()
	# Try to load saved credentials
	g_login.LoadCredentialsFile("/home/chrastillab/Desktop/mycreds.txt")
	if g_login.credentials is None:
	    # Authenticate if they're not there
	    g_login.LocalWebserverAuth()
	elif g_login.access_token_expired:
	    # Refresh them if expired
	    g_login.Refresh()
	else:
	    # Initialize the saved creds
	    g_login.Authorize()

	# Save the current credentials to a file
	g_login.SaveCredentialsFile("/home/chrastillab/Desktop/mycreds.txt")
	drive = GoogleDrive(g_login)

	# Within OFT file folder, obtain all OFT_filenames
	path = "/var/www/html/OFT/"
	extension = "csv"
	os.chdir(path)
	OFT_filenames = glob.glob('*.{}'.format(extension))

	# Hellman folder ID for OFT
	f_ID = "1AnzDfGLaZc36PRI5TKBkBSDbF6rwZVel"
	query_string = "'%s' in parents and trashed=False" % f_ID


	# Loop through OFT files
	for i in OFT_filenames:
		# If file already exists, overwrite it with the most recent version
		file_list = drive.ListFile({'q': query_string}).GetList()
		try:
			for file1 in file_list:
				if file1['title'] == i:
					print("Overwriting file: " + i)
					file1.Delete()                
		except:
			pass
		# Create file to send to the drive, then upload it
		f = drive.CreateFile({"parents": [{"kind": "drive#fileLink", "id": f_ID}]})
		f.SetContentFile(i)
		f.Upload()
		print("Uploading file: " + i)
		f = None

	print("OFT DATA FILES UPLOADED TO DRIVE")

	# Within SOT file folder, obtain all SOT_filenames
	path = "/var/www/html/SOT/"
	extension = "csv"
	os.chdir(path)
	SOT_filenames = glob.glob('*.{}'.format(extension))

	# Hellman folder ID for SOT
	f_ID = "1Hty3ph-plJ_prH_tTZVxtNvdawE4PA0q"
	query_string = "'%s' in parents and trashed=False" % f_ID

	# Loop through SOT files
	for i in SOT_filenames:
		# If file already exists, overwrite it with the most recent version
		file_list = drive.ListFile({'q':query_string}).GetList()
		try:
			for file1 in file_list:
				if file1['title'] == i:
					print("Overwriting file: " + i)
					file1.Delete()                
		except:
			pass
		# Create file to send to the drive, then upload it
		f = drive.CreateFile({"parents": [{"kind": "drive#fileLink", "id": f_ID}]})
		f.SetContentFile(i)
		f.Upload()
		print("Uploading file: " + i)
		f = None

	print("SOT DATA FILES UPLOADED TO DRIVE")

# Define function that calls R script to quality check data
def quality_check_SOFT():
	subprocess.call("~/Desktop/hellman_QC.R", shell = True)

# Initiate first upload when script is called. Keep terminal window open to have the scheduler run.
upload_SOFTfiles()

# Initiate scheduled upload of OFT files every hour
scheduler = BlockingScheduler()
scheduler.add_job(upload_SOFTfiles, 'interval', hours = 1)
scheduler.start()

quality_check_SOFT()
