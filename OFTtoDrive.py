#!/usr/bin/python3

# OFTtoDrive
# Script that uses Google Drive's API to push OFT data files to the Spatial Neuroscience UCI Drive

# Load dependencies
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from apscheduler.schedulers.blocking import BlockingScheduler
import os
import glob

# Define function to upload OFT files to lab's UCI google drive
def upload_OFTfiles():
	# Initialize authorization
	g_login = GoogleAuth()
	# Try to load saved credentials
	g_login.LoadCredentialsFile("mycreds.txt")
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
	g_login.SaveCredentialsFile("mycreds.txt")
	drive = GoogleDrive(g_login)

	# Within OFT file folder, obtain all OFT_filenames
	path = "/var/www/html/OFT/"
	extension = "csv"
	os.chdir(path)
	OFT_filenames = glob.glob('*.{}'.format(extension))

	# Hellman folder ID
	f_ID = "1AAAYH0bWciY2aS4Qtdxr6ZemcPTOziKz"

	# Loop through OFT files
	for i in OFT_filenames:
		f = drive.CreateFile({"parents": [{"kind": "drive#fileLink", "id": f_ID}]})
		f.SetContentFile(os.path.join(path, i))
		f.Upload()
		f = None

# Initiate scheduled upload of OFT files every hour
scheduler = BlockingScheduler()
scheduler.add_job(upload_OFTfiles, 'interval', hours = 1)

