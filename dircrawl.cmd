             CMD        PROMPT('Crawl IFS Directories')
             PARM       KWD(TOPDIR) TYPE(*CHAR) LEN(255) RSTD(*NO) +
                          MAX(1) CASE(*MIXED) PROMPT('Top level +
                          directory')
             PARM       KWD(OUTPUTFILE) TYPE(*CHAR) LEN(255) +
                          RSTD(*NO) MAX(1) CASE(*MIXED) +
                          PROMPT('Output IFS file')
             PARM       KWD(REPLACE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT('True') VALUES('False' 'True') MAX(1) +
                          CASE(*MIXED) PROMPT('Replace file')
             PARM       KWD(FOLLOWLNK) TYPE(*CHAR) LEN(10) +
                          RSTD(*YES) DFT('False') VALUES('False' +
                          'True') MAX(1) CASE(*MIXED) +
                          PROMPT('Follow sumbolic links')
             PARM       KWD(DELIM) TYPE(*CHAR) LEN(1) DFT(',') +
                          MAX(1) CASE(*MIXED) PROMPT('Field delimiter')
             PARM       KWD(SKIPQSYS) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT('True') VALUES('False' 'True') MAX(1) +
                          CASE(*MIXED) PROMPT('Skip QSYS.LIB')
             PARM       KWD(OFILE) TYPE(*CHAR) LEN(10) DFT(DIRCRAWL) +
                          MAX(1) CASE(*MIXED) PROMPT('Output +
                          physical file')
             PARM       KWD(OLIB) TYPE(*CHAR) LEN(10) DFT(TMP) +
                          MAX(1) CASE(*MIXED) PROMPT('Output +
                          physical file lib')
             PARM       KWD(SETPKGPATH) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) DFT(*YES) VALUES(*NO *YES) +
                          EXPR(*YES) CASE(*MIXED) PROMPT('Set +
                          QOpenSys yum package path')
             PARM       KWD(DSPSTDOUT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) PROMPT('Display +
                          standard output result')
             PARM       KWD(LOGSTDOUT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) PROMPT('Log +
                          standard output to job log')
             PARM       KWD(PRTSTDOUT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) PROMPT('Print +
                          standard output result')
             PARM       KWD(DLTSTDOUT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*NO *YES) PROMPT('Delete +
                          standard output result')
             PARM       KWD(IFSSTDOUT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) PROMPT('Copy +
                          std output to IFS file')
             PARM       KWD(IFSFILE) TYPE(*CHAR) LEN(255) +
                          PROMPT('IFS file for stdout results')
             PARM       KWD(IFSOPT) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*REPLACE) VALUES(*ADD *REPLACE *NONE) +
                          PROMPT('IFS file option')
             PARM       KWD(CCSID) TYPE(*CHAR) LEN(10) DFT(*SAME) +
                          SPCVAL((*SAME *SAME)) PROMPT('Coded +
                          character set ID for job')
             PARM       KWD(PRTSPLF) TYPE(*CHAR) LEN(10) +
                          DFT(DIRCRAWL) PROMPT('Print stdout +
                          spool file')
             PARM       KWD(PRTUSRDTA) TYPE(*CHAR) LEN(10) DFT(*NONE) SPCVAL((*NONE ' ')) +
                          PROMPT('Print stdout user data')
             PARM       KWD(PRTTXT) TYPE(*CHAR) LEN(30) DFT(*NONE) SPCVAL((*NONE ' ')) CASE(*MIXED) +
                          PROMPT('Print stdout print text')
             PARM       KWD(PRTHOLD) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*NO *YES) SPCVAL((*NONE +
                          ' ')) CASE(*MIXED) PROMPT('Print stdout +
                          hold spool file')
             PARM       KWD(PRTOUTQ) TYPE(QUAL2) MIN(1) +
                          PROMPT('Print stdout to outq')
 QUAL2:      QUAL       TYPE(*NAME) LEN(10) DFT(*SAME) +
                          SPCVAL((*SAME)) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) EXPR(*YES) PROMPT('Library')
