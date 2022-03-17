# RpgOpenSource
Using RPG and CL to Call Open Source Apps via the QSHONI commands: QSHEXEC, QSHPYRUN or QSHBASH 

https://www.github.com/richardschoen/qshoni

# IBM i Library Set up
Create IBM i library and source file from 5250 session
```
CRTLIB LIB(RPGOPNSRC) TEXT('RPG Open Source Code Samples') 

CRTSRCPF FILE(RPGOPNSRC/SOURCE) RCDLEN(120)  

```

# IBM i IFS Set Up
```

MKDIR DIR('/rpgopensource') DTAAUT(*RWX) OBJAUT(*ALL)     

```

# JSONYYAJL1 RPGLE Example (Renamed version of JSON1)
The **JSONYAJL1.RPGLE** sample requires the YAJL library available from Scott Klement's web site. It also requires Python script: **pyreadwebpage.py** to be placed in IFS folder: **/rpgopensource**. Feel free to tweak as desired. 

Scott Klement YAJL Site

http://www.scottklement.com/yajl

Sample JSON File

https://github.com/richardschoen/RpgOpenSource/blob/main/qcustcdt.json

