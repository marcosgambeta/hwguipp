/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HCLIENTDC Class
 *
 * Copyright 2005 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
 * www - http://sites.uol.com.br/culikr/
*/

#include "hbclass.ch"
#include "hwgui.ch"

CLASS HCLIENTDC FROM HDC

   METHOD NEW(nWnd)
   METHOD END ()

   HIDDEN:
   DATA m_hWnd

ENDCLASS

METHOD HCLIENTDC:NEW(nWnd)

   ::Super:new()
   ::m_hWnd := nWnd
   ::Attach(hwg_Getdc(::m_hWnd))

   RETURN Self

METHOD HCLIENTDC:END()

   hwg_Releasedc(::m_hWnd, ::m_hDC)
   ::m_hDC       := NIL
   ::m_hAttribDC := NIL

   RETURN NIL
