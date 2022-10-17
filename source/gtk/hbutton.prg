/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HButton class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA bClick

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor)
   METHOD Activate()
   METHOD onEvent( msg, wParam, lParam )
   METHOD SetText( value ) INLINE hwg_button_SetText(::handle, ::title := value)
   METHOD GetText() INLINE hwg_button_GetText(::handle)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor) CLASS HButton

   nStyle := hb_bitor( iif( nStyle == NIL,0,nStyle ), BS_PUSHBUTTON )
   ::Super:New(oWndParent, nId, nStyle, nX, nY, iif(nWidth == NIL, 90, nWidth), iif(nHeight == NIL, 30, nHeight), oFont, bInit, bSize, bPaint, ctoolt, tcolor, bcolor)

   ::title := cCaption
   ::Activate()

   IF ::id == IDOK
      bClick := {||::oParent:lResult := .T., ::oParent:Close()}
   ELSEIF ::id == IDCANCEL
      bClick := { ||::oParent:Close() }
   ENDIF
   ::bClick := bClick
   hwg_SetSignal(::handle, "clicked", WM_LBUTTONUP, 0, 0)

   RETURN Self

METHOD Activate() CLASS HButton

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      hwg_Setwindowobject(::handle, Self)
      ::Init()
   ENDIF

   RETURN NIL

METHOD onEvent( msg, wParam, lParam )  CLASS HButton

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_LBUTTONUP
      IF ::bClick != NIL
         Eval(::bClick, Self)
      ENDIF
   ENDIF

   RETURN  NIL
