//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HButton class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA bClick

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor)
   METHOD Activate()
   METHOD onEvent( msg, wParam, lParam )
   METHOD SetText( value ) INLINE hwg_button_SetText(::handle, ::title := value)
   METHOD GetText() INLINE hwg_button_GetText(::handle)

ENDCLASS

METHOD HButton:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor)

   nStyle := hb_bitor( IIf(nStyle == NIL, 0, nStyle), BS_PUSHBUTTON )
   ::Super:New(oWndParent, nId, nStyle, nX, nY, IIf(nWidth == NIL, 90, nWidth), IIf(nHeight == NIL, 30, nHeight), oFont, bInit, bSize, bPaint, ctoolt, tcolor, bcolor)

   ::title := cCaption
   ::Activate()

   IF ::id == IDOK
      bClick := {||::oParent:lResult := .T., ::oParent:Close()}
   ELSEIF ::id == IDCANCEL
      bClick := {||::oParent:Close()}
   ENDIF
   ::bClick := bClick
   hwg_SetSignal(::handle, "clicked", WM_LBUTTONUP, 0, 0)

   RETURN Self

METHOD HButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      hwg_Setwindowobject(::handle, Self)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HButton:onEvent( msg, wParam, lParam )

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_LBUTTONUP
      IF hb_IsBlock(::bClick)
         Eval(::bClick, Self)
      ENDIF
   ENDIF

   RETURN  NIL
