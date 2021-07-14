#!/QOpenSys/pkgs/bin/python3
#------------------------------------------------
# Script name: helloworld.py
#
# Description: 
# This is a simple helloworld script that echoes a few messages back to STDOUT output
#
# Parameters
# p1=Message to display (optional)
#------------------------------------------------

import sys

# Get parameters

# Python script name in case you want to use it
parmscriptname = sys.argv[0] 
 
# Default message if not passed as parameter
# Argument 0 is always script name
if len(sys.argv) < 2:
   parmmessage="No message passed"
else:
   parmmessage=sys.argv[1]

# Print simple Hello World messages
print("Script Running:" + parmscriptname)
print("Hello World")
print("Your message is:" + parmmessage)
