/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HPAINTDC Class
 *
 * Copyright 2005 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
 * www - http://sites.uol.com.br/culikr/
*/

#include "hbclass.ch"
#include "hwgui.ch"

CLASS HPAINTDC FROM HDC

   DATA m_ps

   METHOD NEW(nWnd)
   METHOD END ()

   HIDDEN:
   DATA m_hWnd

ENDCLASS

METHOD HPAINTDC:NEW(nWnd)

   ::Super:new()
   ::m_ps := hwg_Definepaintstru()
   ::m_hWnd := nWnd
   ::Attach(hwg_Beginpaint(::m_hWnd, ::m_ps))

   RETURN Self

METHOD HPAINTDC:END()

   hwg_Endpaint(::m_hWnd, ::m_ps)
   ::m_hDC := NIL
   ::m_hAttribDC := NIL

   RETURN NIL
