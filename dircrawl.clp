             PGM        PARM(&TOPDIR &OUTPUTFILE &REPLACE &FOLLOWLNK +
                          &DELIM &SKIPQSYS &OFILE &OLIB &SETPKGPATH +
                          &DSPSTDOUT &LOGSTDOUT &PRTSTDOUT +
                          &DLTSTDOUT &IFSSTDOUT &IFSFILE &IFSOPT +
                          &CCSID &PRTSPLF &PRTUSRDTA &PRTTXT +
                          &PRTHOLD &PRTOUTQALL)

             DCL        VAR(&SQL) TYPE(*CHAR) LEN(1024)
             DCL        VAR(&OFILE) TYPE(*CHAR) LEN(10)
             DCL        VAR(&OLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&TOPDIR) TYPE(*CHAR) LEN(255)
             DCL        VAR(&OUTPUTFILE) TYPE(*CHAR) LEN(255)
             DCL        VAR(&REPLACE) TYPE(*CHAR) LEN(10)
             DCL        VAR(&FOLLOWLNK) TYPE(*CHAR) LEN(10)
             DCL        VAR(&DELIM) TYPE(*CHAR) LEN(1)
             DCL        VAR(&SKIPQSYS) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CMDLINE) TYPE(*CHAR) LEN(5000)
             DCL        VAR(&PRTHOLD) TYPE(*CHAR) LEN(4)
             DCL        VAR(&PRTOUTQALL) TYPE(*CHAR) LEN(20)
             DCL        VAR(&PRTOUTQ) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTOUTQLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SETPKGPATH) TYPE(*CHAR) LEN(4)
             DCL        VAR(&INPUTFILE) TYPE(*CHAR) LEN(255)
             DCL        VAR(&USERPW) TYPE(*CHAR) LEN(100)
             DCL        VAR(&OWNERPW) TYPE(*CHAR) LEN(100)
             DCL        VAR(&PARMS) TYPE(*CHAR) LEN(2048)
             DCL        VAR(&PARMLIST)  TYPE(*CHAR) LEN(1024)
             DCL        VAR(&TYPE)      TYPE(*CHAR) LEN(1)
             DCL        VAR(&CURDIR)    TYPE(*CHAR) LEN(128)
             DCL        VAR(&CDLEN)     TYPE(*DEC)  LEN(7 0)
             DCL        VAR(&CPFID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&CMD) TYPE(*CHAR) LEN(9999)
             DCL        VAR(&STDOUTIFS) TYPE(*CHAR) LEN(255)
             DCL        VAR(&STDOUTFILE) TYPE(*CHAR) LEN(255)
             DCL        VAR(&JOB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBNBR) TYPE(*CHAR) LEN(6)
             DCL        VAR(&USER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&DSPSTDOUT) TYPE(*CHAR) LEN(4)
             DCL        VAR(&LOGSTDOUT) TYPE(*CHAR) LEN(4)
             DCL        VAR(&DLTSTDOUT) TYPE(*CHAR) LEN(4)
             DCL        VAR(&PRTSTDOUT) TYPE(*CHAR) LEN(4)
             DCL        VAR(&IFSSTDOUT) TYPE(*CHAR) LEN(4)
             DCL        VAR(&IFSOPT) TYPE(*CHAR) LEN(10)
             DCL        VAR(&IFSFILE) TYPE(*CHAR) LEN(255)
             DCL        VAR(&RTNVAL) TYPE(*CHAR) LEN(6)
             DCL        VAR(&CURJOB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CURUSER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CURNBR) TYPE(*CHAR) LEN(6)
             DCL        VAR(&QDATE) TYPE(*CHAR) LEN(6)
             DCL        VAR(&QTIME) TYPE(*CHAR) LEN(9)
             DCL        VAR(&PRTSPLF) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTUSRDTA) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PRTTXT) TYPE(*CHAR) LEN(30)
             DCL        VAR(&CCSID) TYPE(*CHAR) LEN(10)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERRORS))

/*----------------------------------------------------------------------------*/
/* Create TMP library                                                         */
/*----------------------------------------------------------------------------*/
             CRTLIB     LIB(TMP) TEXT('Temp Objects')
             MONMSG     MSGID(CPF0000)

/*----------------------------------------------------------------------------*/
/* Extract output queue info from incoming parm                               */
/*----------------------------------------------------------------------------*/
             CHGVAR     VAR(&PRTOUTQ) VALUE(%SST(&PRTOUTQALL 1 10))
             CHGVAR     VAR(&PRTOUTQLIB) VALUE(%SST(&PRTOUTQALL 11 10))

/*----------------------------------------------------------------------------*/
/* Run Qshell/Pase command line via QSHPYRUN */
/*----------------------------------------------------------------------------*/
             QSHONI/QSHPYRUN SCRIPTDIR('/rpgopensource') +
                          SCRIPTFILE(pydircrawl.py) ARGS(&TOPDIR +
                          &OUTPUTFILE &REPLACE &FOLLOWLNK &DELIM +
                          &SKIPQSYS) PYVERSION(3.9) +
                          SETPKGPATH(&SETPKGPATH) +
                          DSPSTDOUT(&DSPSTDOUT) +
                          LOGSTDOUT(&LOGSTDOUT) +
                          PRTSTDOUT(&PRTSTDOUT) +
                          DLTSTDOUT(&DLTSTDOUT) +
                          IFSSTDOUT(&IFSSTDOUT) IFSFILE(&IFSFILE) +
                          IFSOPT(&IFSOPT) CCSID(&CCSID) +
                          PRTSPLF(&PRTSPLF) PRTUSRDTA(&PRTUSRDTA) +
                          PRTTXT(&PRTTXT) PRTHOLD(&PRTHOLD) +
                          PRTOUTQ(&PRTOUTQLIB/&PRTOUTQ)

/*----------------------------------------------------------------------------*/
/* Create temp file DIRCRAWL via SQL        */
/*----------------------------------------------------------------------------*/
             /* Delete file if it exists */
             DLTF       FILE(&OLIB/&OFILE)
             MONMSG     MSGID(CPF0000)

             /* Build the SQL to create tha output table */
             CHGVAR     VAR(&SQL) VALUE('CREATE TABLE' |> &OLIB |< +
                          '.' |< &OFILE |> '(IFSFULL VARCHAR(256), +
                          IFSFILE VARCHAR(256), IFSPREFIX +
                          VARCHAR(256),IFSEXT VARCHAR(10),IFSSIZE +
                          DECIMAL(15,2),IFSTYPE +
                          VARCHAR(10),IFSSYMLNK VARCHAR(10))')

             /* Create the table */
             RUNSQL     SQL(&SQL) COMMIT(*NONE)

/*----------------------------------------------------------------------------*/
/* Copy crawl results to DIRCRAWL file      */
/*----------------------------------------------------------------------------*/
             CPYFRMIMPF FROMSTMF(&OUTPUTFILE) TOFILE(&OLIB/&OFILE) +
                          MBROPT(*REPLACE) RCDDLM(*LF) +
                          FLDDLM(&DELIM) RMVCOLNAM(*YES)

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) +
                          MSGDTA('Directory' |> &TOPDIR |> 'was +
                          crawled to file' |> &OLIB |< '/' |< +
                          &OFILE) MSGTYPE(*COMP)

             RETURN

/*----------------------------------------------------------------------------*/
/* HANDLE ERRORS     */
/*----------------------------------------------------------------------------*/
ERRORS:

             SNDPGMMSG  MSGID(CPF9898) MSGF(QCPFMSG) MSGDTA('Error +
                          occurred while crawling directory Please +
                          check the joblog') MSGTYPE(*ESCAPE)

             ENDPGM
