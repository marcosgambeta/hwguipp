//
// HWGUI - Harbour Win32 GUI library source code:
// HStatic class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HStatic INHERIT HControl // TODO: HLabel é um nome mais adequado para a classe

   CLASS VAR winclass INIT "STATIC"

   DATA nStyleDraw

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor, lTransp)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor, lTransp)
   METHOD Activate()
   METHOD Init()
   METHOD Paint(lpDis)
   METHOD SetText(c)
   METHOD Refresh()

ENDCLASS

METHOD HStatic:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor, lTransp)

   IF pcount() == 0
      ::Super:New(NIL, NIL, 0, 0, 0, 0, 0, NIL, NIL, NIL, NIL, NIL, NIL, NIL)
      ::Activate()
      RETURN Self
   ENDIF

   // TODO: verificar como tratar a clausula TRANSPARENT na sintaxe alternativa

   IF lTransp != NIL .AND. lTransp
      ::extStyle += WS_EX_TRANSPARENT
      ::nStyleDraw := IIf(Empty(nStyle), 0, nStyle)
      nStyle := SS_OWNERDRAW
      bPaint := {|o, p|o:paint(p)}
   ENDIF

   // Enabling style for tooltips
   IF hb_IsChar(cTooltip)
      IF nStyle == NIL
         nStyle := SS_NOTIFY
      ELSE
         nStyle := hb_bitor(nStyle, SS_NOTIFY)
      ENDIF
   ENDIF

   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)

   ::title := cCaption

   ::Activate()

   RETURN Self

METHOD HStatic:Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor, lTransp)

   HB_SYMBOL_UNUSED(cCaption) // TODO: verificar porque foi marcado como HB_SYMBOL_UNUSED
   HB_SYMBOL_UNUSED(lTransp)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)

   ::title := cCaption
   ::style := ::nX := ::nY := ::nWidth := ::nHeight := 0

   // Enabling style for tooltips
   IF hb_IsChar(cTooltip)
      ::Style := SS_NOTIFY
   ENDIF

   IF lTransp != NIL .AND. lTransp
      ::extStyle += WS_EX_TRANSPARENT
   ENDIF

   RETURN Self

METHOD HStatic:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::extStyle)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HStatic:Init()

   IF !::lInit
      ::Super:init()
      IF ::Title != NIL
         hwg_Setwindowtext(::handle, ::title)
      ENDIF
   ENDIF

   RETURN  NIL

METHOD HStatic:Paint(lpDis)
   
   LOCAL drawInfo := hwg_Getdrawiteminfo(lpDis)
   LOCAL hDC := drawInfo[3]
   LOCAL x1 := drawInfo[4]
   LOCAL y1 := drawInfo[5]
   LOCAL x2 := drawInfo[6]
   LOCAL y2 := drawInfo[7]

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

METHOD HStatic:SetText(c)

   ::Super:SetText(c)
   IF hb_bitand(::extStyle, WS_EX_TRANSPARENT) != 0
      hwg_Invalidaterect(::oParent:handle, 1, ::nX, ::nY, ::nX + ::nWidth, ::nY + ::nHeight)
      hwg_Sendmessage(::oParent:handle, WM_PAINT, 0, 0)
   ENDIF

   RETURN NIL

METHOD HStatic:Refresh()

   IF hb_bitand(::extStyle, WS_EX_TRANSPARENT) != 0
      hwg_Invalidaterect(::oParent:handle, 1, ::nX, ::nY, ::nX + ::nWidth, ::nY + ::nHeight)
      hwg_Sendmessage(::oParent:handle, WM_PAINT, 0, 0)
   ELSE
      ::Super:Refresh()
   ENDIF

   RETURN NIL
