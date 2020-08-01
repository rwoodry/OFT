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

	# Hellman folder ID
	f_ID = "1AAAYH0bWciY2aS4Qtdxr6ZemcPTOziKz"

	# Loop through OFT files
	for i in OFT_filenames:
		# If file already exists, overwrite it with the most recent version
		file_list = drive.ListFile({'q':"'1AAAYH0bWciY2aS4Qtdxr6ZemcPTOziKz' in parents and trashed=False"}).GetList()
		try:
			for file1 in file_list:
				if file1['title'] == os.path.join(path, i):
					print("Overwriting file: " + os.path.join(path, i))
					file1.Delete()                
		except:
			pass
		# Create file to send to the drive, then upload it
		f = drive.CreateFile({"parents": [{"kind": "drive#fileLink", "id": f_ID}]})
		f.SetContentFile(os.path.join(path, i))
		f.Upload()
		print("Uploading file: " + os.path.join(path, i))
		f = None

	print("FILES UPLOADED TO DRIVE")

# Initiaite first upload when script is called. Keep terminal window open to have the scheduler run.
upload_OFTfiles()

# Initiate scheduled upload of OFT files every hour
scheduler = BlockingScheduler()
scheduler.add_job(upload_OFTfiles, 'interval', hours = 1)
scheduler.start()


