/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HRadioButton class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HRadioButton INHERIT HControl

   CLASS VAR winclass   INIT "BUTTON"
   DATA  oGroup
   DATA bClick

   METHOD New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
      bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, lTransp )
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor)
   METHOD Value(lValue) SETGET

ENDCLASS

METHOD New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
      bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, lTransp ) CLASS HRadioButton

   ::oParent := iif( oWndParent == Nil, ::oDefaultParent, oWndParent )
   ::id      := iif( nId == Nil, ::NewId(), nId )
   ::title   := cCaption
   ::oGroup  := HRadioGroup():oGroupCurrent
   IF !Empty(lTransp)
      ::extStyle := WS_EX_TRANSPARENT
   ENDIF
   ::style   := Hwg_BitOr(iif(nStyle == Nil, 0, nStyle), BS_AUTORADIOBUTTON + WS_CHILD + WS_VISIBLE + WS_TABSTOP + ;
      iif(::oGroup != Nil .AND. Empty(::oGroup:aButtons), WS_GROUP, 0))
   ::oFont   := oFont
   ::nLeft   := nLeft
   ::nTop    := nTop
   ::nWidth  := nWidth
   ::nHeight := nHeight
   ::bInit   := bInit
   IF ValType(bSize) == "N"
      ::Anchor := bSize
   ELSE
      ::bSize  := bSize
   ENDIF
   ::bPaint  := bPaint
   ::tooltip := ctooltip
   ::tcolor  := tcolor
   IF tColor != Nil .AND. bColor == Nil
      bColor := hwg_Getsyscolor( COLOR_3DFACE )
   ENDIF
   ::bcolor  := bcolor
   IF bColor != Nil
      ::brush := HBrush():Add(bcolor)
   ENDIF

   ::bClick := bClick
   ::Activate()
   ::oParent:AddControl( Self )
   IF bClick != Nil .AND. (::oGroup == Nil .OR. ::oGroup:bSetGet == Nil)
      ::oParent:AddEvent( 0, ::id, {|o,id| onClick(o,id)} )
   ENDIF
   IF ::oGroup != Nil
      AAdd(::oGroup:aButtons, Self)
      ::oParent:AddEvent( BN_CLICKED, ::id, { |o,id|__Valid(o:FindControl(id)) } )
   ENDIF

   RETURN Self

METHOD Activate() CLASS HRadioButton

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

   RETURN Nil

/* Parameter lInit was removed a long time ago */
METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor) CLASS HRadioButton

   ::oParent := iif( oWndParent == Nil, ::oDefaultParent, oWndParent )
   ::id      := nId
   ::oGroup  := HRadioGroup():oGroupCurrent
   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::oFont   := oFont
   ::bInit   := bInit
   IF ValType(bSize) == "N"
      ::Anchor := bSize
   ELSE
      ::bSize  := bSize
   ENDIF
   ::bPaint  := bPaint
   ::tooltip := ctooltip
   ::tcolor  := tcolor
   IF tColor != Nil .AND. bColor == Nil
      bColor := hwg_Getsyscolor( COLOR_3DFACE )
   ENDIF
   ::bcolor  := bcolor
   IF bColor != Nil
      ::brush := HBrush():Add(bcolor)
   ENDIF

   ::bClick := bClick
   ::oParent:AddControl( Self )
   IF bClick != Nil .AND. (::oGroup == Nil .OR. ::oGroup:bSetGet == Nil)
      ::oParent:AddEvent( 0, ::id, {|o,id| onClick(o,id)} )
   ENDIF
   IF ::oGroup != Nil
      AAdd(::oGroup:aButtons, Self)
      ::oParent:AddEvent( BN_CLICKED, ::id, { |o,id|__Valid(o:FindControl(id)) } )
   ENDIF

   RETURN Self

METHOD Value(lValue) CLASS HRadioButton
   IF lValue != Nil
      hwg_Sendmessage(::handle, BM_SETCHECK, Iif(lValue, BST_CHECKED, BST_UNCHECKED), 0)
   ENDIF
   RETURN (hwg_Sendmessage(::handle, BM_GETCHECK, 0, 0) == 1)

STATIC FUNCTION __Valid(oCtrl)

   oCtrl:oGroup:nValue := Ascan(oCtrl:oGroup:aButtons, {|o|o:id == oCtrl:id})
   IF oCtrl:oGroup:bSetGet != Nil
      Eval(oCtrl:oGroup:bSetGet, oCtrl:oGroup:nValue)
   ENDIF
   IF oCtrl:bClick != Nil
      Eval(oCtrl:bClick, oCtrl, oCtrl:oGroup:nValue)
   ENDIF

   RETURN .T.

STATIC FUNCTION onClick( oParent, id )

   LOCAL oCtrl := oParent:FindControl( id )

   IF !Empty(oCtrl)
      Eval(oCtrl:bClick, oCtrl)
   ENDIF

   RETURN .T.
