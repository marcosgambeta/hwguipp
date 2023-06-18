*
*  DBFSTRU.PRG
*
*  Copyright (c) 1997-2020 DF7BE
*  Free Software under property of the
*  GNU General Public License
*
*  $Id: dbfstru.prg 3076 2022-05-31 15:54:47Z df7be $
*
*   HWGUI - Harbour Win32 and Linux (GTK) GUI library
*
*   Structure display of DBF files
*   Harbour 3.x.x, Clipper Summer 1987
*
* License:
* GNU General Public License
* with special exceptions of HWGUI.
* See file "license.txt" for details of
* HWGUI project at
*  https://sourceforge.net/projects/hwgui/
*
*
*  Modification documentation
*
*  +------------+-------------------------+----------------------------------+
*  + Date       ! Name and Call           ! Modification                     !
*  +------------+-------------------------+----------------------------------+
*  ! 31.05.2022 ! W.Brunken        DF7BE  ! first creation                   !
*  +------------+-------------------------+----------------------------------+
*
* Compile with:
*  hbmk2 dbfstru.prg

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* ~ Modifications for Clipper S'87 here
* ~ and the instructions in ELSE 
*   (about line 100)  
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* SET PROCEDURE TO dbfstru && Clipper S87
PROCEDURE MAIN   && HARBOUR
PARAMETERS db
PUBLIC CLIPPER
CLIPPER = .F.  && Set to .T. for Clipper

PUBLIC temps,n,nmax,dez,l,zz


PUBLIC HF_NAME,HF_TYP,HF_LEN,HF_DEC



IF PCOUNT() != 1
  ? "Usage : dbfstru NAME.DBF"
  WAIT "End ==> any key"
  QUIT
ENDIF



zz = 0

SET DATE GERMAN  && Format: DD.MM.YYYY, modify to your own needs
USE &db
TEMPS = DTOS(LUPDATE())

 ? "Copyright (c) 1999-2020 DF7BE"
 IF CLIPPER
 ? "Copyright (c) 1985-1993, Computer Associates International, Inc."
 ENDIF
 ? "Under the Property of the GNU General Public Licence"
 ? "with special exceptions of HWGUI."
 ? "See file " , CHR(34) , "license.txt" , CHR(34) , "for details of HWGUI project at"
 ? " https://sourceforge.net/projects/hwgui/"
 ?

* Display header information

? "** structure of database " + db + " ***"

? "Last update " + SUBSTR(TEMPS,3,2) + " " + SUBSTR(TEMPS,5,2) +  " " + ;
   SUBSTR(TEMPS,7,2)
?

? "Data offset " + ALLTRIM(STR(HEADER()))
? "Record size " + ALLTRIM(STR(RECSIZE()))
? "Number of records " + ALLTRIM(STR(LASTREC()))
?

* Display field information

DECLARE F_NAME[FCOUNT()]
DECLARE F_TYP[FCOUNT()]
DECLARE F_LEN[FCOUNT()]
DECLARE F_DEC[FCOUNT()]


IF CLIPPER
 NMAX = AFIELDS(F_NAME,F_TYP,F_LEN,F_DEC)
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
* Clipper S'87:
* Deactivate all instructions in  ELSE  
ELSE
* Harbour
 HF_NAME = ARRAY( FCOUNT() )
 HF_TYP  = ARRAY( FCOUNT() )
 HF_LEN  = ARRAY( FCOUNT() )
 HF_DEC  = ARRAY( FCOUNT() )
NMAX = AFIELDS(HF_NAME,HF_TYP,HF_LEN,HF_DEC)
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ENDIF

? "Number of fields " + ALLTRIM(STR(nmax))
?
? "NAME        TYPE LEN DEC"
?
zz = 11
IF nmax != 0
 FOR n = 1 TO nmax
   IF CLIPPER
    dez = F_DEC[n]
    L = F_LEN[n]
   ELSE
    dez = HF_DEC[n]
    L   = HF_LEN[n]   
   ENDIF
   

   IF dez != 0
     TEMPS = ALLTRIM(STR(dez))
   ELSE
     TEMPS = ""
   ENDIF
*
   IF zz > 22
    zz = 0
    WAIT "Continue ==> any key"
   ENDIF
   IF CLIPPER
     ? PADRIGHT(F_NAME[n],11) + " " + F_TYP[n] + "    " + ;
      PADRIGHT(ALLTRIM(STR(l)),4) + TEMPS
   ELSE
      ? PADRIGHT(HF_NAME[n],11) + " " + HF_TYP[n] + "    " + ;
      PADRIGHT(ALLTRIM(STR(l)),4) + TEMPS
   ENDIF   
   zz = zz + 1
  NEXT
 ENDIF
 WAIT "End ==> any key"
QUIT

RETURN    && END OF MAIN FOR HARBOUR AND CLIPPER

*
*  === End of MAIN ===
*

* Functions PADR() and PADC() are not 
* available in Clipper S'87, so
* they are substituted here

* ================================= *
FUNCTION PADRIGHT    && = PADR
  PARAMETERS padr_stri,padr_laen,fzeichen
* ================================= *
  IF PCOUNT() < 3
    fzeichen = " "
  ENDIF
* Avoid crash of SUBSTR()
  IF ( padr_laen <= 0 )
    RETURN ""
  ENDIF
  IF  padr_stri == ""
    RETURN REPLICATE (fzeichen,padr_laen)
  ENDIF
RETURN SUBSTR(padr_stri,1,padr_laen) + REPLICATE(fzeichen,padr_laen - LEN(SUBSTR(padr_stri,1,padr_laen)))

* ================================= *
FUNCTION PADCENTER    && = PADC
  PARAMETERS padc_stri,padc_laen,fzeichen
* ================================= *
  PRIVATE zahl,zl,zr
  IF PCOUNT() < 3
    fzeichen = " "
  ENDIF
* Avoid crash of SUBSTR()
  if ( padc_laen <= 0 )
    RETURN ""
  endif
  if  padc_stri == ""
    RETURN REPLICATE(fzeichen,padc_laen)
  endif
* Number of filler characteres to add stroed in variable "zahl"
  zahl = padc_laen - LEN(SUBSTR(padc_stri,1,padc_laen))
  zl = INT(zahl / 2)
  zr = zahl - zl
RETURN REPLICATE(fzeichen,zl) + SUBSTR(padc_stri,1,padc_laen) + REPLICATE(fzeichen,zr)
