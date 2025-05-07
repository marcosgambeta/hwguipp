//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HCheckButton class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HCheckButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA bSetGet
   DATA lValue

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor, bGFocus)
   METHOD Activate()
   METHOD Disable()
   METHOD Init()
   METHOD onEvent( msg, wParam, lParam )
   METHOD Refresh()
   METHOD SetText( value ) INLINE hwg_button_SetText(::handle, ::title := value)
   METHOD GetText() INLINE hwg_button_GetText(::handle)
   METHOD Value(lValue) SETGET

ENDCLASS

METHOD HCheckButton:New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor, bGFocus)

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), BS_AUTO3STATE + WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctoolt, tcolor, bcolor)

   ::title := cCaption
   ::lValue := IIf(vari == NIL .OR. !hb_IsLogical(vari), .F., vari)
   ::bSetGet := bSetGet

   ::Activate()

   ::bLostFocus := bClick
   ::bGetFocus := bGFocus

   hwg_SetSignal(::handle, "clicked", WM_LBUTTONUP, 0, 0)
   IF bGFocus != NIL
      hwg_SetSignal(::handle, "enter", BN_SETFOCUS, 0, 0)
   ENDIF

   IF Left(::oParent:ClassName(), 6) == "HPANEL" .AND. hb_bitand(::oParent:style, SS_OWNERDRAW) != 0
//      ::oParent:SetPaintCB(PAINT_ITEM, {|o,h|IIf(!::lHide,hwg__DrawCheckBtn(h,::nX,::nY,::nX+::nWidth-1,::nY+::nHeight-1,::lValue,::title),.T.)}, "ch"+Ltrim(Str(::id)))
      ::oParent:SetPaintCB(PAINT_ITEM, {|h|IIf(!::lHide,hwg__DrawCheckBtn(h,::nX,::nY,::nX+::nWidth-1,::nY+::nHeight-1,::lValue,::title),.T.)}, "ch"+Ltrim(Str(::id)))
   ENDIF

   RETURN Self

METHOD HCheckButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      hwg_Setwindowobject(::handle, Self)
      ::Init()
   ENDIF

   RETURN NIL
   
METHOD HCheckButton:Disable()
   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      hwg_Setwindowobject(::handle, Self)
      ::Init()
         hwg_CheckButton(::handle, .F.)
   ENDIF

   RETURN NIL   

METHOD HCheckButton:Init()

   IF !::lInit
      ::Super:Init()
      IF ::lValue
         hwg_CheckButton(::handle, .T.)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HCheckButton:onEvent( msg, wParam, lParam )

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_LBUTTONUP
      __Valid(Self)
   ELSEIF msg == BN_SETFOCUS
      __When( Self )
   ENDIF

   RETURN NIL

METHOD HCheckButton:Refresh()
   
   LOCAL var

   IF hb_IsBlock(::bSetGet)
      var := Eval(::bSetGet, NIL, NIL)
      ::lValue := IIf(var == NIL, .F., var)
   ENDIF

   hwg_CheckButton(::handle, ::lValue)

   RETURN NIL

METHOD HCheckButton:Value(lValue)

   IF lValue != NIL
      IF !hb_IsLogical(lValue)
         lValue := .F.
      ENDIF
      hwg_CheckButton(::handle, lValue)
      IF hb_IsBlock(::bSetGet)
         Eval(::bSetGet, lValue, Self)
      ENDIF
      RETURN (::lValue := lValue)
   ENDIF

   RETURN (::lValue := hwg_IsButtonChecked(::handle))


STATIC FUNCTION __Valid(oCtrl)

   LOCAL res

   oCtrl:lValue := hwg_IsButtonChecked(oCtrl:handle)

   IF hb_IsBlock(oCtrl:bSetGet)
      Eval(oCtrl:bSetGet, oCtrl:lValue, oCtrl)
   ENDIF
   IF hb_IsBlock(oCtrl:bLostFocus) .AND. hb_IsLogical(res := Eval(oCtrl:bLostFocus, oCtrl, oCtrl:lValue)) .AND. !res
      hwg_Setfocus( oCtrl:handle )
   ENDIF

   RETURN .T.

STATIC FUNCTION __When( oCtrl )
   
   LOCAL res

   oCtrl:Refresh()

   IF hb_IsBlock(oCtrl:bGetFocus)
      res := Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet, , oCtrl), oCtrl)
      IF HB_ISLOGICAL(res) .AND. !res
         hwg_GetSkip( oCtrl:oParent, oCtrl:handle, 1 )
      ENDIF
      RETURN res
   ENDIF

   RETURN .T.
