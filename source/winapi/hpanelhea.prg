//
// HWGUI - Harbour Win32 GUI library source code:
// HPanel class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HPanelHea INHERIT HPANEL

   DATA xt
   DATA yt
   DATA lMaximized INIT .F.

   METHOD New(oWndParent, nId, nHeight, oFont, bInit, bPaint, tcolor, bcolor, oStyle, cText, xt, yt, lBtnClose, lBtnMax, lBtnMin)
   METHOD SetText(c, lrefresh)  // INLINE (::title := c)
   METHOD SetSysbtnColor(tColor, bColor)
   METHOD PaintText(hDC)
   METHOD Paint()

ENDCLASS

METHOD HPanelHea:New(oWndParent, nId, nHeight, oFont, bInit, bPaint, tcolor, bcolor, oStyle, cText, xt, yt, lBtnClose, lBtnMax, lBtnMin)

   LOCAL nBtnSize
   LOCAL btnClose
   LOCAL btnMax
   LOCAL btnMin
   LOCAL x1

   oWndParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   IF bColor == NIL
      bColor := 0xeeeeee
   ENDIF

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, 0, 0, oWndParent:nWidth, nHeight, bInit, ANCHOR_TOPABS + ANCHOR_LEFTABS + ANCHOR_RIGHTABS, bPaint, bcolor, oStyle)

   ::title := cText
   ::xt := xt
   ::yt := yt
   ::oFont := IIf(oFont == NIL, ::oParent:oFont, oFont)
   ::oStyle := oStyle
   ::tColor := IIf(tColor == NIL, 0, tColor)
   ::lDragWin := .T.

   IF !Empty(lBtnClose) .OR. !Empty(lBtnMax) .OR. !Empty(lBtnMin)
      nBtnSize := Min(24, ::nHeight)
      x1 := ::nWidth-nBtnSize-4

      IF !Empty(lBtnClose)
         @ x1, Int((::nHeight-nBtnSize)/2) OWNERBUTTON btnClose OF Self SIZE nBtnSize, nBtnSize ;
            ON PAINT {|o|fPaintBtn(o)} ;
            ON SIZE ANCHOR_RIGHTABS ;
            ON CLICK {||::oParent:Close()}
         x1 -= nBtnSize
      ENDIF
      IF !Empty(lBtnMax)
         @ x1, Int((::nHeight-nBtnSize)/2) OWNERBUTTON btnMax OF Self SIZE nBtnSize, nBtnSize ;
            ON PAINT {|o|fPaintBtn(o)} ;
            ON SIZE ANCHOR_RIGHTABS ;
            ON CLICK {||IIf(::lMaximized,::oParent:Restore(),::oParent:Maximize()),::lMaximized:=!::lMaximized}
         x1 -= nBtnSize
      ENDIF
      IF !Empty(lBtnMin)
         @ x1, Int((::nHeight-nBtnSize)/2) OWNERBUTTON btnMin OF Self SIZE nBtnSize, nBtnSize ;
            ON PAINT {|o|fPaintBtn(o)} ;
            ON SIZE ANCHOR_RIGHTABS ;
            ON CLICK {||::oParent:Minimize()}
      ENDIF
      ::SetSysbtnColor(0, 0xededed)
   ENDIF

RETURN Self

METHOD HPanelHea:SetText(c, lrefresh)
// DF7BE: Set lrefresh to .T. for refreshing the header text
// (compatibility to INLINE definition)

   LOCAL pps
   LOCAL hDC

 IF lrefresh == NIL
   lrefresh := .F.
 ENDIF

 ::title := c

 IF lrefresh
  pps := hwg_Definepaintstru()
  hDC := hwg_Beginpaint(::handle, pps)

  ::PaintText(hDC)

  hwg_Endpaint(::handle, pps)

   // hwg_Sendmessage(::oParent:handle, WM_SIZE, 0, 0)  // Does not refresh
   hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)

 ENDIF

RETURN NIL

METHOD HPanelHea:SetSysbtnColor(tColor, bColor)

   LOCAL oBtn
   LOCAL oPen1
   LOCAL oPen2

   oPen1 := HPen():Add(BS_SOLID, 2, tColor)
   oPen2 := HPen():Add(BS_SOLID, 1, tColor)

   IF !Empty(oBtn := ::FindControl("btnclose"))
      oBtn:SetColor(tColor, bColor)
      oBtn:oPen1 := oPen1
      oBtn:oPen2 := oPen2
   ENDIF
   IF !Empty(oBtn := ::FindControl("btnmax"))
      oBtn:SetColor(tColor, bColor)
      oBtn:oPen1 := oPen1
      oBtn:oPen2 := oPen2
   ENDIF
   IF !Empty(oBtn := ::FindControl("btnmin"))
      oBtn:SetColor(tColor, bColor)
      oBtn:oPen1 := oPen1
      oBtn:oPen2 := oPen2
   ENDIF

RETURN NIL

METHOD HPanelHea:PaintText(hDC)

   LOCAL x1
   LOCAL y1
   LOCAL oldTColor

   IF HB_ISCHAR(::title)
      IF HB_ISOBJECT(::oFont)
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      hwg_Settransparentmode(hDC, .T.)
      oldTColor := hwg_Settextcolor(hDC, ::tcolor)
      x1 := IIf(::xt == NIL, 4, ::xt)
      y1 := IIf(::yt == NIL, 4, ::yt)
      hwg_Drawtext(hDC, ::title, x1, y1, ::nWidth - 4, ::nHeight - 4, DT_LEFT + DT_VCENTER)
      hwg_Settextcolor(hDC, oldTColor)
      hwg_Settransparentmode(hDC, .F.)
   ENDIF

RETURN NIL

METHOD HPanelHea:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL block
   LOCAL aCoors
   LOCAL i

   IF hb_IsBlock(::bPaint)
      RETURN Eval(::bPaint, Self)
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)

   IF hb_IsBlock(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
      aCoors := hwg_Getclientrect(::handle)
      Eval(block, Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4])
   ELSEIF Empty(::oStyle)
      ::oStyle := HStyle():New({::bColor}, 1)
   ENDIF
   ::oStyle:Draw(hDC, 0, 0, ::nWidth, ::nHeight)

   ::PaintText(hDC)
   ::DrawItems(hDC)

   hwg_Endpaint(::handle, pps)
   FOR i := 1 TO Len(::aControls)
      hwg_Invalidaterect(::aControls[i]:handle, 0)
   NEXT

RETURN NIL

#define OBTN_STATE1  5

STATIC FUNCTION fPaintBtn(oBtn)

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors

   IF oBtn:state == OBTN_NORMAL
      oBtn:state := OBTN_STATE1
      hwg_Invalidaterect(oBtn:oParent:handle, 0, oBtn:nX, oBtn:nY, oBtn:nX+oBtn:nWidth - 1, oBtn:nY + oBtn:nHeight - 1)
      RETURN NIL
   ELSEIF oBtn:state == OBTN_STATE1
      oBtn:state := OBTN_NORMAL
   ENDIF
   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(oBtn:handle, pps)
   aCoors := hwg_Getclientrect(oBtn:handle)

   IF oBtn:state == OBTN_MOUSOVER
      hwg_Fillrect(hDC, 0, 0, aCoors[3] - 1, aCoors[4] - 1, oBtn:brush:handle)
   ELSEIF oBtn:state == OBTN_PRESSED
      hwg_Fillrect(hDC, 0, 0, aCoors[3] - 1, aCoors[4] - 1, oBtn:brush:handle)
      hwg_Selectobject(hDC, oBtn:oPen2:handle)
      hwg_Rectangle(hDC, 0, 0, aCoors[3] - 1, aCoors[4] - 1)
   ENDIF

   hwg_Selectobject(hDC, oBtn:oPen1:handle)
   IF oBtn:objname == "BTNCLOSE"
      hwg_Drawline(hDC, 6, 6, aCoors[3] - 6, aCoors[4] - 6)
      hwg_Drawline(hDC, aCoors[3] - 6, 6, 6, aCoors[4] - 6)
   ELSEIF oBtn:objname == "BTNMAX"
      hwg_Drawline(hDC, 6, 6, aCoors[3] - 6, 6)
      hwg_Drawline(hDC, 6, aCoors[4] - 6, aCoors[3] - 6, aCoors[4] - 6)
      hwg_Selectobject(hDC, oBtn:oPen2:handle)
      hwg_Drawline(hDC, 6, 6, 6, aCoors[4] - 6)
      hwg_Drawline(hDC, aCoors[3] - 6, 6, aCoors[3] - 6, aCoors[4] - 6)
   ELSEIF oBtn:objname == "BTNMIN"
      hwg_Drawline(hDC, 6, aCoors[4] - 6, aCoors[3] - 12, aCoors[4] - 6)
   ENDIF

   hwg_Endpaint(oBtn:handle, pps)

RETURN NIL
