      //-----------------------------------------------------------------
      //  PROGRAM:    JSON1
      //
      //  PURPOSE:    This is a JSON import program example.
      //              Gets JSON file from HTTPS site and write to CUSTCDT.
      //
      //  DESC:       This program does the following steps:
      //              1.) Clear file RPGOPNSRC/CUSTCDT and open CUSTCDT
      //                  so we can write records to the file.
      //              2.) Gets selected JSON file from HTTPS site to IFS
      //                  via QSHEXEC call to Python script.
      //              3.) JSON file gets loaded via YAJL JSON parsing
      //                  functions.
      //              4.) We iterate the list of customer records and
      //                  write the JSON data to file CUSTCDT in library
      //                  RPGOPNSRC.
      //
      //  DATE:       05/01/2021
      //  AUTHOR:     Richard J. Schoen.
      //  MOD LEVEL:  0000
      //  MOD DATE:   XX/XX/XX
      //-----------------------------------------------------------------
        Ctl-Opt DFTACTGRP(*NO) OPTION(*SRCSTMT)
               BNDDIR('YAJL');

       // Declare files to use
       Dcl-F CUSTCDT                Usage(*INPUT:*OUTPUT)
                                    USROPN;

       // Include yajl function defs copy member
       /include yajl_h

       // Qualified customer data structure
       Dcl-DS list_t                   qualified
                                       template;
          cusnum                  Zoned(6:0);
          lstnam                   Char(8);
          init                     Char(3);
          street                   Char(13);
          city                     Char(6);
          state                    Char(2);
          zipcod                  Zoned(5:0);
          cdtlmt                  Zoned(4:0);
          chgcod                  Zoned(1:0);
          baldue                  Zoned(6:2);
          cdtdue                  Zoned(6:2);
       End-DS;

       // Create result data structure
       Dcl-DS result                   qualified;
          totalcount                Int(10:0) inz(0);
          success                   Ind;
          errmsg                VarChar(500);
          list                         likeds(list_t) dim(999);
       End-DS;

       // Yajl JSON work fields
       Dcl-S docNode                   like(yajl_val);
       Dcl-S list                      like(yajl_val);
       Dcl-S node                      like(yajl_val);
       Dcl-S val                       like(yajl_val);

       // Work fields
       Dcl-S i                      Int(10:0);
       Dcl-S lastElem               Int(10:0);
       Dcl-S dateUSA               Char(10);
       Dcl-S errMsg             VarChar(500) inz('');
       Dcl-S packedNum           Packed(30:9);
       Dcl-S recCount               Int(10:0) inz(0);
       Dcl-S pycmd              VarChar(5000) inz('');
       Dcl-S pasecmd            VarChar(5000) inz('');
       Dcl-S qt                    Char(1) inz('''');
       Dcl-S ifsfile            VarChar(255) inz('');
       Dcl-S pyscript           VarChar(255) inz('');
       Dcl-S rtnpase                Int(10:0) inz(0);
       Dcl-S rtnpython              Int(10:0) inz(0);
       Dcl-S clcommand          VarChar(5000) inz('');
       Dcl-S rtncmd                 Int(10:0) inz(0);

       // Run CL command line via QCMDEXC
       Dcl-PR RunClCmd                 Extpgm('QCMDEXC');
          *N                       Char(3000) Const Options(*Varsize);
          *N                     Packed(15:5) Const;
       End-PR;

       // Run pase command via QSHEXEC command
       Dcl-PR QshExec               Int(10:0);
          *N                    VarChar(5000);
       End-PR;

       // Remove IFS file with pase rm command
       Dcl-PR RmIfsFile             Int(10:0);
          *N                    VarChar(255);
       End-PR;

         // Main program

         // Process steps
         // Read JSON file from web site via Python script to IFS file
         // Open and read JSON file using YAJL and decompose fields
         // Write resulting data fields to CUSTCDT table
          Monitor;

             // Set IFS file
             ifsfile='/rpgopensource/tmp/qcustcdt.json';

             // Set python script name
             pyscript='/rpgopensource/pyreadwebpage.py';

             // Clear file CUSTCDT in RPGOPNSRC
             clcommand = 'CLRPFM FILE(RPGOPNSRC/CUSTCDT)';
             RunClCmd(%trim(clcommand):%len(clcommand));

             // Open CUSTCDT
             open CUSTCDT;

             // Run command to delete IFS file before
             rtnpase=RmIfsFile(ifsfile);

             // Deal with file delete errors if needed
             If rtnpase <> 0;
                //*inlr = *on;
                //return;
             EndIf;

             // Build Python command line
             // Ex: python3 scriptfile "outputifsfile"
             pycmd = 'python3 ' + pyscript + ' ' +
                     '"' + %trim(ifsfile) + '"';

             // Run Python command via QSHEXEC
             rtnpython=QshExec(pycmd);
             // Bail out on pase command errors
             If rtnpython <> 0;
                *inlr = *on;
                Return;
             EndIf;

             // Load JSON file
             docNode = yajl_stmf_load_tree(%trim(ifsfile):
                                            errMsg);

             // If errors, handle the errors.
             If errMsg <> '';
                // handle error
             EndIf;

             // If records loaded, set success flag
             node = YAJL_object_find(docNode: 'records');
             result.success = YAJL_is_true(node);

             result.errmsg = *blanks;
             //de = YAJL_object_find(docNode: 'errmsg');
             //sult.errmsg = YAJL_get_string(node);

             // Read array list into memory
             list = YAJL_object_find(docNode: 'records');

             // Iterate JSON array list elements
             i = 0;
             DoW YAJL_ARRAY_LOOP( list: i: node );

                // Capture last element count
                lastElem = i;

                // Extract each field from current json record
                val = YAJL_object_find(node: 'CUSNUM');
                packedNum = yajl_get_number(val);
                result.list(i).cusnum = packedNum;

                val = YAJL_object_find(node: 'LSTNAM');
                result.list(i).lstnam = yajl_get_string(val);

                val = YAJL_object_find(node: 'INIT');
                result.list(i).init   = yajl_get_string(val);

                val = YAJL_object_find(node: 'STREET');
                result.list(i).street = yajl_get_string(val);

                val = YAJL_object_find(node: 'CITY');
                result.list(i).city   = yajl_get_string(val);

                val = YAJL_object_find(node: 'STATE');
                result.list(i).state  = yajl_get_string(val);

                val = YAJL_object_find(node: 'ZIPCOD');
                packedNum = yajl_get_number(val);
                result.list(i).zipcod = packedNum;

                val = YAJL_object_find(node: 'CDTLMT');
                packedNum = yajl_get_number(val);
                result.list(i).cdtlmt = packedNum;

                val = YAJL_object_find(node: 'CHGCOD');
                packedNum = yajl_get_number(val);
                result.list(i).chgcod = packedNum;

                val = YAJL_object_find(node: 'BALDUE');
                packedNum = yajl_get_number(val);
                result.list(i).baldue = packedNum;

                val = YAJL_object_find(node: 'CDTDUE');
                packedNum = yajl_get_number(val);
                result.list(i).cdtdue = packedNum;

                // Set DS fields for CUSTCDT and write record
                // Note: Technically don't need multi-element DS
                // but if we wanted to return the JSON fields as
                // a strcuture instead of writing to a file we
                // could do so with the multi-record DS.
                cusnum=result.list(i).cusnum;
                lstnam=result.list(i).lstnam;
                init  =result.list(i).init;
                street=result.list(i).street;
                city=result.list(i).city;
                state=result.list(i).state;
                zipcod=result.list(i).zipcod;
                cdtlmt=result.list(i).cdtlmt;
                chgcod=result.list(i).chgcod;
                baldue=result.list(i).baldue;
                cdtdue=result.list(i).cdtdue;
                Write cusrec;

             EndDo;

             // Set list element count
             result.totalcount = lastElem;

             // Release the document
             yajl_tree_free(docNode);

             // Run command to delete IFS file after process
             // Note: Remove after commented out for demo.
             // rtnpase=RmIfsFile(ifsfile);

             // Close CUSTCDT
             close CUSTCDT;

             // Handle any errors
          On-Error;
             *inlr = *on;
             Return;


             // End monitor
          EndMon;

          // Exit
          *inlr = *on;
          Return;

       //------------------------------------------------------
       // Proc: QshExec
       // Desc: Run pase command via QSHONI/QSHEXEC command
       // Parms:
       // P1-cmdln - PASE/QSH command to run
       // Returns:
       // 0=success, -2=errors
       //------------------------------------------------------
       Dcl-Proc QshExec;
       Dcl-PI QshExec               Int(10:0);
          cmdln                 VarChar(5000);
       End-PI;
       Dcl-S qshcmd             VarChar(5000) inz('');

          // Execute QSHEXEC CL command
          Monitor;

             // Build QSHEXEC command call
             qshcmd='QSHONI/QSHEXEC CMDLINE(' + qt + %trim(cmdln) + qt + ')';

             // Run CL command
             RunClCmd(%trim(qshcmd):%Len(qshcmd));

             Return 0;

          On-Error;
             Return -2;
          EndMon;

       End-Proc QshExec;

       //------------------------------------------------------
       // Proc: RmIfsFile
       // Desc: Run pase rm command to delete file
       // Parms:
       // P1-parmifsfile - IFS file name to delete
       // Returns:
       // 0=success, -2=errors
       //------------------------------------------------------
       Dcl-Proc RmIfsFile;
       Dcl-PI RmIfsFile             Int(10:0);
          parmifsfile           VarChar(255);
       End-PI;

       Dcl-S rtnqshexec             Int(10:0) inz(0);
       Dcl-S qshcmd             VarChar(5000) inz('');

          // Execute QSHEXEC CL command
          Monitor;

             // Set pase cmd
             qshcmd = 'rm ' + parmifsfile;

             // Set pase cmd
             rtnqshexec = QshExec(qshcmd);

             Return rtnqshexec;

          On-Error;
             Return -2;
          EndMon;

       End-Proc RmIfsFile; 
