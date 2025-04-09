/*
 * GetWinVers.prg
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * Sample for getting windows version identifiers
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 * Copyright 2020 Wilfried Brunken, DF7BE
 *
*/ 
    * Status:
    *  WinAPI   :  Yes
    *  GTK/Linux:  Yes
    *  GTK/Win  :  Yes

/* Read the function documentation of the called functions for
   return values on non Windows operation systems (GTK)
*/

#include "hwguipp.ch"

Function Main
Local oMainWindow
LOCAL nmin, nmaj, bwin, bwin7, bwin10

   bwin    := hwg_isWindows()
   bwin7   := hwg_isWin7()
   bwin10  := hwg_isWin10()
   nmin    := hwg_GetWinMinorVers()
   nmaj    := hwg_GetWinMajorVers()

   INIT WINDOW oMainWindow MAIN TITLE "Windows Version" AT 0, 0 SIZE 100, 100

   hwg_MsgInfo("Windows    : " + Logical2Str(bwin) + Chr(10) + ;
               "Windows 7  : " + Logical2Str(bwin7) + Chr(10) + ;
               "Windows 10 : " + Logical2Str(bwin10) + Chr(10) + ;
               "Major= " + AllTrim(Str(nmaj)) + Chr(10) + ;
               "Minor= " + AllTrim(Str(nmin)), "Windows Version")

  ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION LOGICAL2STR(bl)
RETURN IIF(bl,"True","False")
