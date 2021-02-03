from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from apscheduler.schedulers.blocking import BlockingScheduler
import os
import glob
import subprocess

def sync_to_folder():
	# Initialize authorization
	g_login = GoogleAuth()
	# Try to load saved credentials
	g_login.LoadCredentialsFile("/home/yoda/Documents/mycreds.txt")
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
	g_login.SaveCredentialsFile("/home/yoda/Documents/mycreds.txt")
	drive = GoogleDrive(g_login)

	# Hellman Folder
	print("\n---Hellman Sync---")
	drive_sync_to_folder("/mnt/chrastil/lab/data/Hellman/GoogleDrive", "1Vp-v7xCYGea3T7kHWnA1xOxqDBDvwMqU", drive)
	
	# SOT Sync
	print("\n---SOT Sync---")
	drive_sync_to_folder("/mnt/chrastil/lab/data/Hellman/GoogleDrive/SOT", "1bqmsA12vkAd-xdkVtv18NdgUcj5bmoWf", drive)
	
	# OFT Sync
	print("\n---OFT Sync---")
	drive_sync_to_folder("/mnt/chrastil/lab/data/Hellman/GoogleDrive/OFT", "136zAoJbvmplv0aDczGppFAFXYUOCFi9D", drive)

def drive_sync_to_folder(target_directory, folder_id, drive):
	mimetypes = {'application/vnd.google-apps.spreadsheet': 'text/csv'}
	query_string = "'%s' in parents and trashed=False and mimeType!='application/vnd.google-apps.folder'" % folder_id

	file_list = drive.ListFile({'q': query_string, 'supportsAllDrives': True, 'includeItemsFromAllDrives': True}).GetList()

	print("Filelist: ")
	for file1 in file_list:
    		print('title: %s, id: %s' % (file1['title'], file1['id']))

	for index, file1 in enumerate(file_list): 
		# Locate file 
		f = drive.CreateFile({'id': file1['id'], 'supportsAllDrives': 'true', 'includeItemsFromAllDrives': True, 'parents': [{'kind': 'drive#fileLink', 'id': folder_id}]})
		filename = file1['title']
		
		# Check MIME Type
		download_mimetype = None
		if file1['mimeType'] in mimetypes:
			download_mimetype = mimetypes[file1['mimeType']]

		# Download file
		f.GetContentFile('%s/%s' % (target_directory, filename), mimetype=download_mimetype) 
		progressBar(index, len(file_list))
		


def progressBar(current, total, barLength = 20):
    percent = float(current) * 100 / total
    arrow   = '-' * int(percent/100 * barLength - 1) + '>'
    spaces  = ' ' * (barLength - len(arrow))

    print('Progress: [%s%s] %d %% %03d/%03d' % (arrow, spaces, percent, current, total), end='\r')

sync_to_folder()
