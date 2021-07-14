#!/QOpenSys/pkgs/bin/python3
#------------------------------------------------
# Script name: pyreadwebpage.py
#
# Description: 
# This script reads a JSON file from a web site (similar to a REST server) 
#
# Parameters
# P1=Temp Output File - Temporary IFS output file 
#------------------------------------------------

import sys
from sys import platform
import os
import re
import time
import traceback
import requests as req

#------------------------------------------------
# Script initialization
#------------------------------------------------

# Initialize or set variables
exitcode=0 #Init exitcode
exitmessage=''
parmsexpected=1;

#------------------------------------------------
# Main script logic
#------------------------------------------------
try: # Try to perform main logic

      # Check to see if all required parms were passed
      if len(sys.argv) < parmsexpected + 1:
        raise Exception(str(parmsexpected) + ' required parms - [Output file]. Process cancelled.')
      
      # Set parameter work variables from command line args
      parmscriptname = sys.argv[0] # Script name
      parmoutputfile= sys.argv[1] # Delimited output text file

      # Open output file to to append
      outf = open(parmoutputfile, "a")

      # Make HTTP request 
      resp = req.get("https://raw.githubusercontent.com/richardschoen/RpgOpenSource/main/qcustcdt.json")

      # Output data to IFS file
      outf.write(resp.text) 

      # Close file now
      outf.close()

      # Set success info
      exitcode=0
      exitmessage='Completed successfully'

#------------------------------------------------
# Handle Exceptions
#------------------------------------------------
except Exception as ex: # Catch and handle exceptions
   exitcode=99 # set return code for stdout
   exitmessage=str(ex) # set exit message for stdout
   print('Traceback Info') # output traceback info for stdout
   traceback.print_exc()        

#------------------------------------------------
# Always perform final processing
#------------------------------------------------
finally: # Final processing
    # Do any final code and exit now
    # We log as much relevent info to STDOUT as needed
    print('ExitCode:' + str(exitcode))
    print('ExitMessage:' + exitmessage)
    print("End of Main Processing - " + time.strftime("%H:%M:%S"))
    
    # Exit the script now
    sys.exit(exitcode) 

