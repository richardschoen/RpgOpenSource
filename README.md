# RpgOpenSource
Using RPG and CL to Call Open Source Apps via the QSHONI commands: QSHEXEC, QSHPYRUN or QSHBASH 

https://www.github.com/richardschoen/qshoni

# IBM i Set up
Create IBM i library and source file from 5250 session
```
CRTLIB LIB(RPGOPNSRC) TEXT('RPG Open Source Code Samples') 

CRTSRCPF FILE(RPGOPNSRC/SOURCE) RCDLEN(120)  
```

# JSON1 RPGLE Example
The JSON1.RPGLE sample requires the YAJL library available from Scott Klement's web site 

http://www.scottklement.com/yajl

Sample JSON File

https://github.com/richardschoen/RpgOpenSource/blob/main/qcustcdt.json

