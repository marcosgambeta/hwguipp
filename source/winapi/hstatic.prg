/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HStatic class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HStatic INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"

   DATA   nStyleDraw

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor, lTransp)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor, lTransp)
   METHOD Activate()
   METHOD Init()
   METHOD Paint(lpDis)
   METHOD SetText(c)
   METHOD Refresh()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor, lTransp) CLASS HStatic

   IF lTransp != NIL .AND. lTransp
      ::extStyle += WS_EX_TRANSPARENT
      ::nStyleDraw := iif(Empty(nStyle), 0, nStyle)
      nStyle := SS_OWNERDRAW
      bPaint := { |o, p| o:paint(p) }
   ENDIF

   // Enabling style for tooltips
   IF ValType(cTooltip) == "C"
      IF nStyle == NIL
         nStyle := SS_NOTIFY
      ELSE
         nStyle := Hwg_BitOr(nStyle, SS_NOTIFY)
      ENDIF
   ENDIF

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)

   ::title := cCaption

   ::Activate()

   RETURN Self

METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor, lTransp) CLASS HStatic

   HB_SYMBOL_UNUSED(cCaption) // TODO: verificar
   HB_SYMBOL_UNUSED(lTransp)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)

   ::title := cCaption
   ::style := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0

   // Enabling style for tooltips
   IF ValType(cTooltip) == "C"
      ::Style := SS_NOTIFY
   ENDIF

   IF lTransp != NIL .AND. lTransp
      ::extStyle += WS_EX_TRANSPARENT
   ENDIF

   RETURN Self

METHOD Activate() CLASS HStatic

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::extStyle)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HStatic

   IF !::lInit
      ::Super:init()
      IF ::Title != NIL
         hwg_Setwindowtext(::handle, ::title)
      ENDIF
   ENDIF

   RETURN  NIL

METHOD Paint(lpDis) CLASS HStatic
   LOCAL drawInfo := hwg_Getdrawiteminfo(lpDis)
   LOCAL hDC := drawInfo[3], x1 := drawInfo[4], y1 := drawInfo[5], x2 := drawInfo[6], y2 := drawInfo[7]

   IF ::oFont != NIL
      hwg_Selectobject(hDC, ::oFont:handle)
   ENDIF
   IF ::tcolor != NIL
      hwg_Settextcolor(hDC, ::tcolor)
   ENDIF

   hwg_Settransparentmode(hDC, .T.)
   hwg_Drawtext(hDC, ::title, x1, y1, x2, y2, ::nStyleDraw)
   hwg_Settransparentmode(hDC, .F.)

   RETURN NIL

METHOD SetText(c) CLASS HStatic

   ::Super:SetText(c)
   IF hwg_bitand(::extStyle, WS_EX_TRANSPARENT) != 0
      hwg_Invalidaterect(::oParent:handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight)
      hwg_Sendmessage(::oParent:handle, WM_PAINT, 0, 0)
   ENDIF

   RETURN NIL

METHOD Refresh() CLASS HStatic

   IF hwg_bitand(::extStyle, WS_EX_TRANSPARENT) != 0
      hwg_Invalidaterect(::oParent:handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight)
      hwg_Sendmessage(::oParent:handle, WM_PAINT, 0, 0)
   ELSE
      ::Super:Refresh()
   ENDIF

   RETURN NIL
