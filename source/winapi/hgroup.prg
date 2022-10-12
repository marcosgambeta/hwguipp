/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HGroup class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HGroup INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, bColor)
   METHOD Activate()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, bColor) CLASS HGroup

   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), BS_GROUPBOX)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, NIL, tcolor, bColor)

   ::title := cCaption
   ::Activate()

   RETURN Self

METHOD Activate() CLASS HGroup

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

   RETURN NIL
