#!/QOpenSys/pkgs/bin/python3
#------------------------------------------------
# Script name: SendMail365.py
#
# Description: 
# This script will send an email message via Office 365.
# The process reads the encrypted password info from an IFS file.
# Note: If info is stored in an IFS file, access to that file should be limited by security.  
#
# Pip packages needed:
# pip install secure-smtplib
# pip install cryptography
#
# Parameters
# p1=From email
# p2=To email
# p3=Subject
# p4=Message
# p5=Attachment File
# p6=O365 user
# p7=O365 encrypted password (Currently ignored for file based 
#------------------------------------------------
# SMTP email and other python article links that may be useful for learning 
# https://www.pythonforbeginners.com/code-snippets-source-code/using-python-to-send-email/         
# https://docs.python.org/3/library/email.examples.html
# https://techoverflow.net/2021/03/23/how-to-send-email-with-file-attachment-via-smtp-in-python/
# https://stackoverflow.com/questions/26630069/python-smtplib-and-mimetext-adding-an-attachment-to-an-email
# https://www.geeksforgeeks.org/how-to-encrypt-and-decrypt-strings-in-python/
# https://www.geeksforgeeks.org/python-convert-string-to-bytes

#------------------------------------------------
# Imports
#------------------------------------------------
import sys
from sys import platform
import os
import time
import traceback
import ibm_db_dbi as db2 
#import xlrd - Not supported in Python 3.9
import csv
import datetime as dt
from string import Template 
from urllib.parse import unquote
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.base import MIMEBase
from email import encoders
from cryptography.fernet import Fernet

#------------------------------------------------
# Script initialization
#------------------------------------------------

# Initialize or set variables
exitcode=0 # Init exitcode value
exitmessage='' # Init exit message for stdout
parmsexpected=7 # Number of parms we expect to see
keyfile = '/rpgopensource/o365key.txt' #o365 encrypted password key file
pwfile = '/rpgopensource/o365pw.txt' #o365 encrypted password file

#Output messages to STDOUT for logging
print("------------------------------------------")
print("Sending Email Message via Office 365")
print("Start of Main Processing - " + time.strftime("%H:%M:%S"))
print("OS:" + platform)

#------------------------------------------------
# Main script logic
#------------------------------------------------
try: # Try to perform main logic
   
   # Check to see if all required parms were passed
   if len(sys.argv) < parmsexpected + 1:
        raise Exception(str(parmsexpected) + ' required parms - [FromEmail] [ToEmail] [Subject] [Message] [AttachFile] [O365User] [O365PassEncrypted]. Process cancelled.')
   
   # Set SMTP server for Office 365
   smtpserver = smtplib.SMTP('smtp.office365.com', 587)

   # Set parameter work variables from command line args
   parmscriptname = sys.argv[0] 
   parmfrom=sys.argv[1] 
   parmto=sys.argv[2] 
   parmsubject=sys.argv[3] 
   parmmessage=sys.argv[4] 
   parmattachfile=sys.argv[5]
   parmo365user=str.replace(sys.argv[6],'\\','') # Remove any escaped chars like \
   parmo365pass=str.replace(sys.argv[7],'\\','') # Remove any escaped chars like \

   # Display relevent parameters in STDOUT output for logging or debugging     
   print("")     
   print("Parameters:")
   print("Python script name: " + parmscriptname)
   print("From: " + parmfrom)
   print("To: " + parmto)
   print("Subject: " + parmsubject)
   print("AttachFile: " + parmattachfile)   
   print("")     

   # Read encryption key from file and convert to string
   keybytes = open(keyfile,"rb").read() # Read password encryption key from utf-8 file
   keystr = keybytes.decode('utf-8') # Convert to string

   # Read encryption key from file and convert to string
   pwbytes = open(pwfile,"rb").read() # Read encrypted password from utf-8 file
   
   # Instance the Fernet class with the key
   fernet = Fernet(keybytes)
      
   # decrypt the encrypted string with the 
   # Fernet instance of the key,
   # that was used for encrypting the string.
   # encoded byte string is returned by decrypt method,
   # so decode it to string with decode methods
   pwdecrbytes = fernet.decrypt(pwbytes) #decrypt password to bytes 
   pwstring = pwdecrbytes.decode('utf-8') #convert password bytes to string
  
   # Build mime message
   fromaddr = parmfrom
   toaddr = parmto
   msg = MIMEMultipart()
   msg['From'] = fromaddr
   msg['To'] = toaddr
   msg['Subject'] = parmsubject
   
   # Set the message body 
   body = parmmessage
   msg.attach(MIMEText(body, 'plain'))

   # Add single file attachment. Bail if no attachment
   if (parmattachfile.strip() != ""):
      if (os.path.exists(parmattachfile)):
         with open(parmattachfile, 'rb') as attach_file:
              basename = os.path.basename(parmattachfile) # get filename without dir path
              extension = os.path.splitext(basename)[1]   # get file extension
              extension = str.replace(extension,'.','')   # remove . from extension 
              part = MIMEBase('application', extension)   # set up MIMEbase part got attachment
              part.set_payload(open(parmattachfile,"rb").read()) # Read attachment file into mime attachment part
              encoders.encode_base64(part) # encode the mime part
              part.add_header('Content-Disposition', 'attachment; filename=' + basename) # Set attachment file name
              msg.attach(part) # Attach the file attachment mime part to email message
      else:
         #Bail out if file attachment specified and not found
         raise Exception('Attachment File ' + parmattachfile + ' not found. Process cancelled.')          
   
   # Send the secure email now via Office 365 SMTP via TLS
   smtpserver.ehlo()
   smtpserver.starttls()
   smtpserver.login(parmo365user,pwstring)
   text = msg.as_string()
   smtpserver.sendmail(fromaddr, toaddr, text)

   # Set success info
   exitcode=0
   exitmessage="Email sent successfully to " + parmto

#------------------------------------------------
# Handle Exceptions
#------------------------------------------------
except Exception as ex: # Catch and handle exceptions
   exitcode=99 # set return code for stdout
   exitmessage=str(ex) # set exit message for stdout
   print('Traceback Info') # output traceback info for stdout
   traceback.print_exc()        

#------------------------------------------------
# Always perform final processing. Output exit message and exit code
#------------------------------------------------
finally: # Final processing
    # Do any final code and exit now
    # We log as much relevent info to STDOUT as needed
    print('ExitCode:' + str(exitcode))
    print('ExitMessage:' + exitmessage)
    print("End of Main Processing - " + time.strftime("%H:%M:%S"))
    print("------------------------------------------")

    
    # Exit the script now
    sys.exit(exitcode) 
