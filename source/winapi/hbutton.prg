//
// HWGUI - Harbour Win32 GUI library source code:
// HButton class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA bClick

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, cCaption)
   METHOD Init()

ENDCLASS

METHOD HButton:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor)

   // TODO: reorganizar para evitar repeti��o de c�digo

   IF pcount() == 0
      ::Super:New(NIL, NIL, BS_PUSHBUTTON + WS_TABSTOP, 0, 0, 90, 30, NIL, NIL, NIL, NIL, NIL, NIL, NIL)
      ::Activate()
      IF ::id != IDOK .AND. ::id != IDCANCEL
         IF ::oParent:className == "HSTATUS"
            ::oParent:oParent:AddEvent(0, ::id, {|o, id|onClick(o, id)})
         ELSE
            ::oParent:AddEvent(0, ::id, {|o, id|onClick(o, id)})
         ENDIF
      ENDIF
      RETURN Self
   ENDIF

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), BS_PUSHBUTTON + WS_TABSTOP)

   ::Super:New(oWndParent, nId, nStyle, nX, nY, IIf(nWidth == NIL, 90, nWidth), IIf(nHeight == NIL, 30, nHeight), oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)
   ::bClick := bClick
   ::title := cCaption
   ::Activate()

   IF ::id != IDOK .AND. ::id != IDCANCEL
      IF ::oParent:className == "HSTATUS"
         ::oParent:oParent:AddEvent(0, ::id, {|o, id|onClick(o, id)})
      ELSE
         ::oParent:AddEvent(0, ::id, {|o, id|onClick(o, id)})
      ENDIF
   ENDIF

   RETURN Self

METHOD HButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HButton:Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, cCaption)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)
   ::bClick := bClick
   ::title := cCaption

   IF hb_IsBlock(bClick)
      ::oParent:AddEvent(0, ::id, {|o, id|onClick(o, id)})
   ENDIF

   RETURN Self

METHOD HButton:Init()

   ::super:init()
   IF ::Title != NIL
      hwg_Setwindowtext(::handle, ::title)
   ENDIF

   RETURN NIL

STATIC FUNCTION onClick(oParent, id)

   LOCAL oCtrl := oParent:FindControl(id)

   IF !Empty(oCtrl) .AND. hb_IsBlock(oCtrl:bClick)
      Eval(oCtrl:bClick, oCtrl)
   ENDIF

   RETURN .T.
