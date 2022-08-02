/*
 *$Id: hcwindow.prg 2985 2021-05-05 16:02:52Z alkresin $
 *
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HCustomWindow class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "error.ch"

   //ANNOUNCE HB_GTSYS
   REQUEST HB_GT_CGI_DEFAULT

CLASS HObject

   DATA cargo
   DATA objName

ENDCLASS
