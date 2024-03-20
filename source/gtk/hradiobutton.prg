/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HRadioButton class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HRadioButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA oGroup
   DATA bClick

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor)
   METHOD Activate()
   METHOD onEvent( msg, wParam, lParam )
   METHOD SetText( value ) INLINE hwg_button_SetText(::handle, ::title := value)
   METHOD GetText() INLINE hwg_button_GetText(::handle)
   METHOD Value( lValue ) SETGET

ENDCLASS

METHOD HRadioButton:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor)

   HB_SYMBOL_UNUSED(bcolor)

   ::oParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id := iif(nId == NIL, ::NewId(), nId)
   ::title := cCaption
   ::oGroup := HRadioGroup():oGroupCurrent
   ::style := hb_bitor(iif(nStyle == NIL, 0, nStyle), BS_AUTORADIOBUTTON + WS_CHILD + WS_VISIBLE + iif(::oGroup != NIL .AND. Empty(::oGroup:aButtons), WS_GROUP, 0))
   ::oFont := oFont
   ::nX := nX
   ::nY := nY
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::bInit := bInit
   IF HB_ISNUMERIC(bSize)
      ::Anchor := bSize
   ELSE
      ::bSize := bSize
   ENDIF
   ::bPaint := bPaint
   ::tooltip := ctoolt
   ::tcolor := tcolor

   ::Activate()
   ::oParent:AddControl( Self )
   ::bClick := bClick
   IF bClick != NIL .AND. (::oGroup == NIL .OR. ::oGroup:bSetGet == NIL)
      hwg_SetSignal(::handle, "released", WM_LBUTTONUP, 0, 0)
   ENDIF
   IF ::oGroup != NIL
      AAdd(::oGroup:aButtons, Self)
      IF ::oGroup:bSetGet != NIL
         hwg_SetSignal(::handle, "released", WM_LBUTTONUP, 0, 0)
      ENDIF
   ENDIF

   IF Left(::oParent:ClassName(), 6) == "HPANEL" .AND. hb_bitand(::oParent:style, SS_OWNERDRAW) != 0
      ::oParent:SetPaintCB(PAINT_ITEM, {|h|Iif(!::lHide,hwg__DrawRadioBtn(h,::nX,::nY,::nX+::nWidth-1,::nY+::nHeight-1,hwg_isButtonChecked(::handle),::title),.T.)}, "rb"+Ltrim(Str(::id)))
*      ::oParent:SetPaintCB(PAINT_ITEM, {|o,h|Iif(!::lHide,hwg__DrawRadioBtn(h,::nX,::nY,::nX+::nWidth-1,::nY+::nHeight-1,hwg_isButtonChecked(::handle),::title),.T.)}, "rb"+Ltrim(Str(::id)))
   ENDIF

   RETURN Self

METHOD HRadioButton:Activate()

   LOCAL groupHandle := ::oGroup:handle

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, @groupHandle, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      ::oGroup:handle := groupHandle
      hwg_Setwindowobject(::handle, Self)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HRadioButton:onEvent( msg, wParam, lParam )

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_LBUTTONUP
      IF ::oGroup:bSetGet == NIL
         Eval(::bClick, Self, ::oGroup:nValue)
      ELSE
         __Valid( Self )
      ENDIF
   ENDIF

   RETURN NIL

METHOD HRadioButton:Value( lValue )
   IF lValue != NIL
      hwg_CheckButton(::handle, .T.)
   ENDIF
   RETURN hwg_isButtonChecked(::handle)

STATIC FUNCTION __Valid( oCtrl )

   oCtrl:oGroup:nValue := Ascan( oCtrl:oGroup:aButtons, { |o|o:id == oCtrl:id } )
   IF hb_IsBlock(oCtrl:oGroup:bSetGet)
      Eval( oCtrl:oGroup:bSetGet, oCtrl:oGroup:nValue )
   ENDIF
   IF hb_IsBlock(oCtrl:bClick)
      Eval( oCtrl:bClick, oCtrl, oCtrl:oGroup:nValue )
   ENDIF

   RETURN .T.
