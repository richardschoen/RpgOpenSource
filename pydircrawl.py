#!/QOpenSys/pkgs/bin/python3
#------------------------------------------------
# Script name: pydircrawl.py
#
# Description: 
# This script will crawl a directory structure and 
# output all the file info so it can be processed.
#
# Parameters
# P1=Directory - Root directory path to start from
# P2=Output file - Output file for directory list
# P3=Follow symbolic links
# p3=Replace existing=True-replace, False-Do not replace
#------------------------------------------------

#https://janakiev.com/blog/python-filesystem-analysis/
#http://www.tutorialspoint.com/python/os_walk.htm
#https://stackoverflow.com/questions/13131497/os-walk-to-crawl-through-folder-structure
#https://stackoverflow.com/questions/3771696/python-os-walk-follow-symlinks
# Write file
#https://cmdlinetips.com/2012/09/three-ways-to-write-text-to-a-file-in-python/
#File size
#https://www.journaldev.com/32067/how-to-get-file-size-in-python

import sys
from sys import platform
import os
import re
import time
import traceback

#------------------------------------------------
# Script initialization
#------------------------------------------------

# Initialize or set variables
exitcode=0 #Init exitcode
exitmessage=''
parmsexpected=6;

#Output messages to STDOUT for logging
print("-------------------------------------------------------------------------------")
print("Crawl directory")
print("Start of Main Processing - " + time.strftime("%H:%M:%S"))
print("OS:" + platform)

 
def str2bool(strval):
    #-------------------------------------------------------
    # Function: str2bool
    # Desc: Constructor
    # :strval: String value for true or false
    # :return: Return True if string value is" yes, true, t or 1
    #-------------------------------------------------------
    return strval.lower() in ("yes", "true", "t", "1")

#------------------------------------------------
# Main script logic
#------------------------------------------------
try: # Try to perform main logic

      # Check to see if all required parms were passed
      if len(sys.argv) < parmsexpected + 1:
        raise Exception(str(parmsexpected) + ' required parms - [Top level directory] [Output file] [Replace output file=True/False] [Follow symbolic links=True/False] [Delimiter=|,;] [Skip QSYS.LIB=True/False]. Process cancelled.')
      
      # Set parameter work variables from command line args
      parmscriptname = sys.argv[0] # Script name
      parmdirname = sys.argv[1] # Top level dir to crawl
      parmoutputfile= sys.argv[2] # Delimited output text file
      parmreplaceoutputfile= str2bool(sys.argv[3]) # Replace output file if already found 
      parmfollowlinks= str2bool(sys.argv[4]) #Follow symbolic links
      parmdelimiter= sys.argv[5] # Delimiter for output file
      parmskipqsyslib= str2bool(sys.argv[6]) #Skip /QSYS.LIB files

      print("Top level dir: " + parmdirname)
      print("Output file: " + parmoutputfile)
      print("Replace output file: " + str(parmreplaceoutputfile))
      print("Follow symbolic links: " + str(parmfollowlinks))
      print("Field delimiter: " + str(parmdelimiter))
      print("Skip /QSYS.LIB path: " + str(parmskipqsyslib))

      # Make sure source dir exists
      if os.path.isdir(parmdirname)==False:
         raise Exception('Directory ' + parmdirname + ' not found. Process cancelled.')          

      # Make sure output file does not exist
      if os.path.isfile(parmoutputfile):
         if parmreplaceoutputfile: # If replace, delete existing file
            os.remove(parmoutputfile)
         else: # Bail out if found and replace not selected
            raise Exception('File ' + parmoutputfile + ' exists and replace not selected. Process cancelled.')          

      # Open output file to to append
      outf = open(parmoutputfile, "a")

      # Output field names
      outf.write("fullname" + parmdelimiter + 
                 "filename" + parmdelimiter +
                 "fileprefix" + parmdelimiter +
                 "fileext" + parmdelimiter +
                 "filesize" + parmdelimiter + 
                 "type" + parmdelimiter + 
                 'symlink' + '\n') 

      # Walk thru the directory list and output
      for root, dirs, files in os.walk(parmdirname,topdown=True,followlinks=parmfollowlinks):
          # Do whatever you need to do
          for name in files:

              # If skip paths with /QSYS.LIB enabled, don't 
              # process current file
              if '/QSYS.LIB' in root.upper() and parmskipqsyslib: 
                  continue

              fullname=os.path.join(root,name)
              
              basename=os.path.basename(fullname)
              
              if os.path.islink(fullname):
                 file_size=0
              else:     
                 file_stats=os.stat(fullname)
                 file_size=file_stats.st_size

              split1=os.path.splitext(fullname)

              outf.write(fullname + parmdelimiter + 
                         basename + parmdelimiter + 
                         os.path.basename(split1[0]) + parmdelimiter + 
                         split1[1] + parmdelimiter + 
                          str(file_size) + parmdelimiter + 
                         "file" + parmdelimiter + 
                         str(os.path.islink(fullname)) +  '\n') 
          for name in dirs:

              # If skip paths with /QSYS.LIB enabled, don't 
              # process current file
              if '/QSYS.LIB' in root.upper() and parmskipqsyslib: 
                  continue

              fullname=os.path.join(root,name)
              outf.write(fullname + parmdelimiter + 
                         " " + parmdelimiter + 
                         " " + parmdelimiter + 
                         " " + parmdelimiter + 
                         "0" + parmdelimiter + 
                         "dir" + parmdelimiter + 
                         str(os.path.islink(fullname)) +  '\n') 


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
    print("-------------------------------------------------------------------------------")
    
    # Exit the script now
    sys.exit(exitcode) 

