/*
   EXTMODUL.CH
   External Modul/Function for designer
   added by richard Roesnadi 17/04/07 03:40am

   in Designer.prg
   #include extmodul.ch

*/

/* extended rdd func modules */

REQUEST __RUN, UPPER
EXTERNAL DBCREATE, DBUSEAREA, DBCREATEINDEX, DBSEEK, DBCLOSEAREA, DBSELECTAREA, DBUNLOCK, DBUNLOCKALL
EXTERNAL BOF, EOF, DBF, DBAPPEND, DBCLOSEALL, DBCLOSEAREA, DBCOMMIT,DBCOMMITALL, DBCREATE
EXTERNAL DBDELETE, DBFILTER, DBSETFILTER, DBGOBOTTOM, DBGOTO, DBGOTOP, DBRLOCK, DBRECALL, DBDROP, DBEXISTS
EXTERNAL DBRLOCKLIST, DBRUNLOCK,  LOCK, RECNO,  DBSETFILTER, DBFILEGET, DBFILEPUT
EXTERNAL DBSKIP, DBSTRUCT, DBTABLEEXT, DELETED, DBINFO, DBORDERINFO, DBRECORDINFO
EXTERNAL FCOUNT, FIELDDEC, FIELDGET, FIELDNAME, FIELDLEN, FIELDPOS, FIELDPUT
EXTERNAL FIELDTYPE, FLOCK, FOUND, HEADER, LASTREC, LUPDATE, NETERR, AFIELDS
EXTERNAL RECCOUNT, RECSIZE, SELECT, ALIAS, RLOCK
EXTERNAL __DBZAP, USED, RDDSETDEFAULT, __DBPACK, __DBAPP, __DBCOPY
EXTERNAL DBFCDX, DBFFPT //ADS

REQUEST  ORDKEYNO, ORDKEYCOUNT, ORDSCOPE, ORDCOUNT, ORDSETFOCUS, DBEVAL
EXTERNAL ORDBAGEXT, ORDBAGNAME, ORDCONDSET, ORDCREATE, ORDDESTROY, ORDFOR
EXTERNAL ORDKEY, ORDKEYCOUNT, ORDKEYNO, ORDKEYGOTO, ORDFINDREC, ORDSKIPRAW
EXTERNAL ORDSKIPUNIQUE, ORDKEYVAL, ORDKEYADD, ORDKEYDEL, ORDDESCEND, ORDISUNIQUE
EXTERNAL ORDCUSTOM, ORDWILDSEEK, ORDLISTADD, ORDLISTCLEAR, ORDLISTREBUILD, ORDNAME
EXTERNAL ORDNUMBER
EXTERNAL RDDSYS, RDDINFO, RDDLIST, RDDSETDEFAULT, RDDREGISTER, RDDNAME

EXTERNAL TRANSFORM

/* MISC.C */
EXTERNAL hwg_Getdesktopwidth, hwg_Getdesktopheight, hwg_Iscapslockactive, hwg_Isnumlockactive, hwg_Isscrolllockactive
EXTERNAL hwg_Copystringtoclipboard, hwg_Getstockobject, hwg_Winexec, hwg_Getkeynametext, hwg_Activatekeyboardlayout
EXTERNAL hwg_Pts2pix, hwg_Getwindowsdir, hwg_Getsystemdir, hwg_Gettempdir, hwg_Shellabout
EXTERNAL HWG_GETCOMPUTERNAME, HWG_GETUSERNAME

/* window.c */
EXTERNAL HWG_SETWINDOWSTYLE, HWG_SETWINDOWEXSTYLE, HWG_GETWINDOWSTYLE, HWG_GETWINDOWEXSTYLE

/* message.c */
EXTERNAL hwg_Msgstop, hwg_Msgokcancel, hwg_Msgyesno, hwg_Msgnoyes, hwg_Msgyesnocancel, hwg_Msgexclamation, hwg_Msgretrycancel, hwg_Msgbeep

/* shellapi.c */
EXTERNAL hwg_Shellmodifyicon, hwg_Selectfolder, hwg_Shellexecute, hwg_Shellnotifyicon

/* print */
EXTERNAL HPRINTER, HWINPRN, PRINTDOS, HWG_SETPRINTERMODE, HWG_CLOSEPRINTER
EXTERNAL HWG_OPENPRINTER, HWG_OPENDEFAULTPRINTER, HWG_GETPRINTERS, HWG_GETDEFAULTPRINTER

//#define _LETODB_
#ifdef _LETODB_

/* leto DB
   DBF/CDX Engines for Client/Server solution from the founder of hwGUI
   see: http://www.sourceforge.net/projects/letodb

   don't forget to unmark (blddesig.bat)
   rem echo %HRB_DIR%\lib\rddleto.lib + >> b32.bc

*/

EXTERNAL LETO, RDINI
EXTERNAL HB_IPRECV, HB_IPRECVREADY, HB_IPSEND, HB_IPSENDALL, HB_IPSERVER, HB_IPACCEPT
EXTERNAL HB_IPCONNECT, HB_IPDATAREADY, HB_IPERRORCODE, HB_IPERRORDESC, HB_IPCLOSE
EXTERNAL HB_IPINIT, HB_IPCLEANUP, HB_IP_RFD_SET, HB_IP_RFD_ZERO, HB_IP_RFD_CLR
EXTERNAL HB_IP_RFD_SELECT, HB_IP_RFD_ISSET

#endif



//#define _USE_RDDADS_
#ifdef _USE_RDDADS_

/*
  for using rddads you need files :

       ACE32.DLL    (Advantage Windows client functionality)
       ACE32.LIB    (BUILD USE IMPLIB.EXE, ex: "IMPLIB ACE32 ACE32.DLL" )
       ADSLOC32.DLL (FOR LOCAL)
       AXCWS32.dll  (REMOTE COMMUNICATION LIB)

       EXTEND.CHR   (FOR non-USA OEM character)
       ANSI.CHR     (non-English ANSI LANGUAGE SUPPORT)
       ADSLOCAL.CFG (Local Server configuration file)

  BLDDESIG.BAT
   undo remark
   rem echo %HRB_DIR%\lib\rddads.lib + >> b32.bc
   rem echo %HRB_DIR%\lib\ace32.lib + >> b32.bc

*/

EXTERNAL ADS
EXTERNAL ADSGETRELKEYPOS, ADSSETRELKEYPOS
EXTERNAL ADSCUSTOMIZEAOF
EXTERNAL ADSTESTRECLOCKS
EXTERNAL ADSSetFileType, ADSSetServerType
EXTERNAL ADSSETDATEFORMAT, ADSSETEPOCH

EXTERNAL ADSAPPLICATIONEXIT
EXTERNAL ADSISSERVERLOADED
EXTERNAL ADSGETCONNECTIONTYPE
EXTERNAL ADSUNLOCKRECORD
EXTERNAL ADSGETTABLECONTYPE
EXTERNAL ADSGETSERVERTIME
EXTERNAL ADSISTABLELOCKED
EXTERNAL ADSISRECORDLOCKED
EXTERNAL ADSLOCKING
EXTERNAL ADSRIGHTSCHECK
EXTERNAL ADSSETCHARTYPE
EXTERNAL ADSGETTABLECHARTYPE
EXTERNAL ADSSETDEFAULT
EXTERNAL ADSSETSEARCHPATH
EXTERNAL ADSSETDELETED
EXTERNAL ADSSETEXACT
EXTERNAL ADSBLOB2FILE, ADSFILE2BLOB

EXTERNAL ADSKEYNO, ADSKEYCOUNT
EXTERNAL ADSADDCUSTOMKEY
EXTERNAL ADSDELETECUSTOMKEY


EXTERNAL ADSCLEARAOF, ADSEVALAOF, ADSGETAOFOPTLEVEL, ADSISRECORDINAOF
EXTERNAL ADSREFRESHAOF, ADSSETAOF

EXTERNAL ADSGETFILTER
EXTERNAL ADSGETTABLEALIAS
EXTERNAL ADSISRECORDVALID

EXTERNAL ADSENABLEENCRYPTION, ADSDISABLEENCRYPTION, ADSISENCRYPTIONENABLED
EXTERNAL ADSENCRYPTTABLE, ADSDECRYPTTABLE, ADSISTABLEENCRYPTED
EXTERNAL ADSENCRYPTRECORD, ADSDECRYPTRECORD, ADSISRECORDENCRYPTED
EXTERNAL ADSCONNECT, ADSDISCONNECT

EXTERNAL ADSCREATESQLSTATEMENT, ADSEXECUTESQLDIRECT
EXTERNAL ADSPREPARESQL, ADSEXECUTESQL

EXTERNAL ADSCLOSEALLTABLES, ADSWRITEALLRECORDS, ADSREFRESHRECORD
EXTERNAL ADSCOPYTABLE, ADSCONVERTTABLE
EXTERNAL ADSREGCALLBACK, ADSCLRCALLBACK

EXTERNAL ADSISINDEXED, ADSREINDEX
EXTERNAL ADSISEXPRVALID, ADSGETNUMINDEXES

EXTERNAL ADSCONNECTION, ADSGETHANDLETYPE
EXTERNAL ADSGETLASTERROR, ADSGETNUMOPENTABLES, ADSSHOWERROR
EXTERNAL ADSBEGINTRANSACTION, ADSCOMMITTRANSACTION
EXTERNAL ADSFAILEDTRANSACTIONRECOVERY, ADSINTRANSACTION, ADSROLLBACK


EXTERNAL ADSVERSION
EXTERNAL ADSCACHERECORDS, ADSCACHEOPENTABLES, ADSCACHEOPENCURSORS
EXTERNAL ADSGETNUMACTIVELINKS
EXTERNAL ADSDDADDTABLE, ADSDDADDUSERTOGROUP
EXTERNAL ADSCONNECT60, ADSDDCREATE, ADSDDCREATEUSER
EXTERNAL ADSDDGETDATABASEPROPERTY, ADSDDSETDATABASEPROPERTY, ADSDDGETUSERPROPERTY


EXTERNAL ADSTESTLOGIN
EXTERNAL ADSRESTRUCTURETABLE
EXTERNAL ADSCOPYTABLECONTENTS
EXTERNAL ADSDIRECTORY
EXTERNAL ADSCHECKEXISTENCE
EXTERNAL ADSDELETEFILE
EXTERNAL ADSSTMTSETTABLEPASSWORD
//EXTERNAL ADSCLOSECACHEDTABLES

EXTERNAL ADSMGCONNECT, ADSMGDISCONNECT, ADSMGGETINSTALLINFO
EXTERNAL ADSMGGETACTIVITYINFO, ADSMGGETCOMMSTATS, ADSMGRESETCOMMSTATS
EXTERNAL ADSMGGETUSERNAMES, ADSMGGETLOCKOWNER, ADSMGGETSERVERTYPE
//ADSMGGETOPENTABLES
EXTERNAL ADSMGKILLUSER, ADSMGGETHANDLE

#endif

//#define _RICHLIB_
#ifdef _RICHLIB_
EXTERNAL SAYDOLLAR, SAYRUPIAH
REQUEST RICHPERIODE, RICHSCOPE, RICHOPEN, SAVESESSION, RESTSESSION, GETBATASTGL, V_ONE
REQUEST RECURDEL, DSTAMPUSER, RECLOCK, RICHOPEN
REQUEST GETA_OFPAN, pINf, RMATCH
REQUEST saveArray, RestArray, SureN, SureC, SureD
#endif
