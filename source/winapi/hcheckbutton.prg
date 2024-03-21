/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HCheckButton class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HCheckButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"
   DATA bSetGet
   DATA lValue
   DATA bClick

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, ;
      bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus, lTransp, bLFocus)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, vari, bSetGet, oFont, bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus)
   METHOD Init()
   METHOD Refresh()
   METHOD Disable()
   METHOD Enable()
   METHOD Value(lValue) SETGET

ENDCLASS

METHOD HCheckButton:New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, ;
      bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus, lTransp, bLFocus)

   IF pcount() == 0
      ::Super:New(NIL, NIL, BS_AUTO3STATE + WS_TABSTOP, 0, 0, 0, 0, NIL, NIL, NIL, NIL, NIL, NIL, NIL)
      ::lValue := .F.
      ::Activate()
      ::oParent:AddEvent(BN_CLICKED, ::id, {|o, id|__Valid(o:FindControl(id))})
      RETURN Self
   ENDIF

   IF !Empty(lTransp)
      ::extStyle := WS_EX_TRANSPARENT
   ENDIF
   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), BS_AUTO3STATE + WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   ::title := cCaption
   ::lValue := iif(vari == NIL .OR. ValType(vari) != "L", .F., vari)
   ::bSetGet := bSetGet

   ::Activate()

   ::bClick := bClick
   ::bLostFocus := bLFocus
   ::bGetFocus := bGFocus

   ::oParent:AddEvent(BN_CLICKED, ::id, {|o, id|__Valid(o:FindControl(id))})
   IF bGFocus != NIL
      ::oParent:AddEvent(BN_SETFOCUS, ::id, {|o, id|__When(o:FindControl(id))})
   ENDIF
   IF bLFocus != NIL
      ::oParent:AddEvent(BN_KILLFOCUS, ::id, ::bLostFocus)
   ENDIF

   RETURN Self

METHOD HCheckButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HCheckButton:Redefine(oWndParent, nId, vari, bSetGet, oFont, bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   ::lValue := iif(vari == NIL .OR. ValType(vari) != "L", .F., vari)
   ::bSetGet := bSetGet

   ::bClick := bClick
   ::bGetFocus := bGFocus
   ::oParent:AddEvent(BN_CLICKED, ::id, {|o, id|__Valid(o:FindControl(id))})
   IF bGFocus != NIL
      ::oParent:AddEvent(BN_SETFOCUS, ::id, {|o, id|__When(o:FindControl(id))})
   ENDIF

   RETURN Self

METHOD HCheckButton:Init()

   IF !::lInit
      ::Super:Init()
      IF ::lValue
         hwg_Sendmessage(::handle, BM_SETCHECK, 1, 0)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HCheckButton:Refresh()

   LOCAL var

   IF hb_IsBlock(::bSetGet)
      var := Eval(::bSetGet, NIL, NIL)
      ::lValue := iif(var == NIL, .F., var)
   ENDIF

   hwg_Sendmessage(::handle, BM_SETCHECK, iif(::lValue, 1, 0), 0)

   RETURN NIL

METHOD HCheckButton:Disable()

   ::Super:Disable()
   hwg_Sendmessage(::handle, BM_SETCHECK, BST_INDETERMINATE, 0)

   RETURN NIL

METHOD HCheckButton:Enable()

   ::Super:Enable()
   hwg_Sendmessage(::handle, BM_SETCHECK, iif(::lValue, 1, 0), 0)

   RETURN NIL

METHOD HCheckButton:Value(lValue)

   IF lValue != NIL
      IF ValType(lValue) != "L"
         lValue := .F.
      ENDIF
      hwg_Sendmessage(::handle, BM_SETCHECK, iif(lValue, 1, 0), 0)
      IF hb_IsBlock(::bSetGet)
         Eval(::bSetGet, lValue, Self)
      ENDIF
      RETURN (::lValue := lValue)
   ENDIF

   RETURN (::lValue := (hwg_Sendmessage(::handle, BM_GETCHECK, 0, 0) == 1))

STATIC FUNCTION __Valid(oCtrl)

   LOCAL l := hwg_Sendmessage(oCtrl:handle, BM_GETCHECK, 0, 0)

   IF l == BST_INDETERMINATE
      hwg_Checkdlgbutton(oCtrl:oParent:handle, oCtrl:id, .F.)
      hwg_Sendmessage(oCtrl:handle, BM_SETCHECK, 0, 0)
      oCtrl:lValue := .F.
   ELSE
      oCtrl:lValue := (l == 1)
   ENDIF

   IF hb_IsBlock(oCtrl:bSetGet)
      Eval(oCtrl:bSetGet, oCtrl:lValue, oCtrl)
   ENDIF
   IF hb_IsBlock(oCtrl:bClick) .AND. !Eval(oCtrl:bClick, oCtrl, oCtrl:lValue)
      hwg_Setfocus(oCtrl:handle)
   ENDIF

   RETURN .T.

STATIC FUNCTION __When(oCtrl)

   LOCAL res

   oCtrl:Refresh()

   IF hb_IsBlock(oCtrl:bGetFocus)
      res := Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet, NIL, oCtrl), oCtrl)
      IF !res
         hwg_GetSkip(oCtrl:oParent, oCtrl:handle, 1)
      ENDIF
      RETURN res
   ENDIF

   RETURN .T.
