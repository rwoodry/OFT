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
	OFT_folder_ID = "1gThYbi0REw5SFgdv2DB0xR3d1vC89VBF"
	OFT_shared_ID = "136zAoJbvmplv0aDczGppFAFXYUOCFi9D"
	
	# Upload OFT files to regular and shared drives	
	drive_upload_to_folder(OFT_filenames, OFT_folder_ID, drive)
	drive_upload_to_folder(OFT_filenames, OFT_shared_ID, drive)
	print("OFT DATA FILES UPLOADED TO DRIVE")

	# Within SOT file folder, obtain all SOT_filenames
	path = "/var/www/html/SOT/"
	extension = "csv"
	os.chdir(path)
	SOT_filenames = glob.glob('*.{}'.format(extension))
	# Hellman folder ID for SOT
	SOT_folder_ID = "10Kvhc_fjTM2S4TOfGSx0MMWs0Z8ec7CL"
	SOT_shared_ID = "1bqmsA12vkAd-xdkVtv18NdgUcj5bmoWf"
	
	# Upload SOT files to regular and shared drives
	drive_upload_to_folder(SOT_filenames, SOT_folder_ID, drive)
	drive_upload_to_folder(SOT_filenames, SOT_shared_ID, drive)
	print("SOT DATA FILES UPLOADED TO DRIVE")

# Define function that calls R script to quality check data
def quality_check_SOFT():
	subprocess.call("~/Desktop/hellman_QC.R", shell = True)
	print("QC SOFT DONE")

def drive_upload_to_folder(filenames, folder_id, drive):
	query_string = "'%s' in parents and trashed=False" % folder_id
	for i in filenames:
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
		f = drive.CreateFile({"parents": [{"kind": "drive#fileLink", "id": folder_id}]})
		f.SetContentFile(i)

		f.Upload()

		print("Uploading file: " + i)
		f = None

# Initiate first upload when script is called. Keep terminal window open to have the scheduler run.
upload_SOFTfiles()

# Initiate scheduled upload of OFT files every hour
scheduler = BlockingScheduler()
scheduler.add_job(upload_SOFTfiles, 'interval', hours = 5)
scheduler.start()

quality_check_SOFT()
