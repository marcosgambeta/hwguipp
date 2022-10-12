/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HButton class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA bClick

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, cCaption)
   METHOD Init()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor) CLASS HButton

   // TODO: reorganizar para evitar repetição de código

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

   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), BS_PUSHBUTTON + WS_TABSTOP)

   ::Super:New(oWndParent, nId, nStyle, nX, nY, iif(nWidth == NIL, 90, nWidth), iif(nHeight == NIL, 30, nHeight), oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)
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

METHOD Activate() CLASS HButton

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, cCaption) CLASS HButton

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)
   ::bClick := bClick
   ::title := cCaption

   IF HB_ISBLOCK(bClick)
      ::oParent:AddEvent(0, ::id, {|o, id|onClick(o, id)})
   ENDIF

   RETURN Self

METHOD Init() CLASS HButton

   ::super:init()
   IF ::Title != NIL
      hwg_Setwindowtext(::handle, ::title)
   ENDIF

   RETURN NIL

STATIC FUNCTION onClick(oParent, id)

   LOCAL oCtrl := oParent:FindControl(id)

   IF !Empty(oCtrl) .AND. HB_ISBLOCK(oCtrl:bClick)
      Eval(oCtrl:bClick, oCtrl)
   ENDIF

   RETURN .T.
