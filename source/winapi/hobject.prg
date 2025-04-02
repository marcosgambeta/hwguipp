//
// HWGUI - Harbour Win32 GUI library source code:
// HObject class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"
#include <error.ch>

REQUEST HB_GT_GUI_DEFAULT

CLASS HObject

   DATA cargo
   DATA objName

ENDCLASS

PROCEDURE HB_GT_DEFAULT_NUL()

   RETURN

INIT PROCEDURE HWGINIT

   Hwg_InitProc()
   hwg_ErrSys()

   RETURN

EXIT PROCEDURE Hwg_ExitProcedure

   Hwg_ExitProc()

   RETURN
