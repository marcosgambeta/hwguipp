/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HPanel class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HPanel INHERIT HControl

   DATA winclass Init "PANEL"
   DATA oEmbedded
   DATA bScroll
   DATA oStyle
   DATA aPaintCB    INIT {}         // Array of items to draw: { cIt, bDraw(hDC,aCoors) }
   DATA lDragWin    INIT .F.
   DATA lCaptured   INIT .F.
   DATA hCursor
   DATA nOldX, nOldY HIDDEN
   DATA lResizeX, lResizeY, nSize HIDDEN

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, bInit, bSize, bPaint, bcolor, oStyle)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Redefine(oWndParent, nId, nWidth, nHeight, bInit, bSize, bPaint, bcolor)
   METHOD DrawItems(hDC, aCoors)
   METHOD Paint()
   METHOD BackColor(bcolor) INLINE ::Setcolor(NIL, bcolor, .T.)
   METHOD Hide()
   METHOD Show()
   METHOD SetPaintCB(nId, block, cId)
   METHOD Drag(xPos, yPos)
   METHOD Release()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, bInit, bSize, bPaint, bcolor, oStyle) CLASS HPanel
   LOCAL oParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, iif(nWidth == NIL, 0, nWidth), ;
      iif(nHeight == NIL, 0, nHeight), oParent:oFont, bInit, bSize, bPaint, NIL, NIL, bcolor)

   IF bcolor != NIL
      ::brush  := HBrush():Add(bcolor)
      ::bcolor := bcolor
   ENDIF
   ::oStyle := oStyle
   ::bPaint   := bPaint
   ::lResizeX := (::nWidth == 0)
   ::lResizeY := (::nHeight == 0)
   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:Type == WND_MDI
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] := ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nLeft == 0
            ::oParent:aOffset[1] := ::nWidth
         ELSE
            ::oParent:aOffset[3] := ::nWidth
         ENDIF
      ENDIF
   ENDIF

   hwg_RegPanel()
   ::Activate()

   RETURN Self

METHOD Activate() CLASS HPanel
   LOCAL handle := ::oParent:handle

   IF !Empty(handle)
      ::handle := hwg_Createpanel(handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD onEvent(msg, wParam, lParam) CLASS HPanel

   IF msg == WM_MOUSEMOVE
      IF ::lDragWin .AND. ::lCaptured
         ::Drag(hwg_Loword(lParam), hwg_Hiword(lParam))
      ENDIF
   ELSEIF msg == WM_PAINT
      ::Paint()
   ELSEIF msg == WM_ERASEBKGND
      IF ::brush != NIL
         IF ValType(::brush) != "N"
            hwg_Fillrect(wParam, 0, 0, ::nWidth, ::nHeight, ::brush:handle)
         ENDIF
         RETURN 1
      ENDIF
   ELSEIF msg == WM_SIZE
      IF ::oEmbedded != NIL
         ::oEmbedded:Resize(hwg_Loword(lParam), hwg_Hiword(lParam))
      ENDIF
   ELSEIF msg == WM_DESTROY
      IF ::oEmbedded != NIL
         ::oEmbedded:END()
      ENDIF
      ::Super:onEvent(WM_DESTROY)
      RETURN 0
   ELSEIF msg == WM_LBUTTONDOWN
      IF ::lDragWin
         IF ::hCursor == NIL
            ::hCursor := hwg_Loadcursor(IDC_HAND)
         ENDIF
         Hwg_SetCursor(::hCursor)
         hwg_Setcapture(::handle)
         ::lCaptured := .T.
         ::nOldX := hwg_Loword(lParam)
         ::nOldY := hwg_Hiword(lParam)
      ENDIF
   ELSEIF msg == WM_LBUTTONUP
      IF ::lDragWin .AND. ::lCaptured
         hwg_Releasecapture()
         ::lCaptured := .F.
      ENDIF
   ELSEIF msg == WM_HSCROLL .OR. msg == WM_VSCROLL .OR. msg == WM_MOUSEWHEEL
      hwg_onTrackScroll(Self, msg, wParam, lParam)
   ENDIF

   RETURN ::Super:onEvent(msg, wParam, lParam)

METHOD Init() CLASS HPanel

   IF !::lInit
      IF ::bSize == NIL .AND. Empty(::Anchor)
         ::bSize := { | o, x, y | o:Move(iif(::nLeft > 0, x - ::nLeft, 0), ;
            iif(::nTop > 0, y - ::nHeight, 0), ;
            iif(::nWidth == 0 .OR. ::lResizeX, x, ::nWidth), ;
            iif(::nHeight == 0 .OR. ::lResizeY, y, ::nHeight)) }
      ENDIF

      ::Super:Init()
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
      Hwg_InitWinCtrl(::handle)
   ENDIF

   RETURN NIL

METHOD Redefine(oWndParent, nId, nWidth, nHeight, bInit, bSize, bPaint, bcolor) CLASS HPanel
   LOCAL oParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)

   ::Super:New(oWndParent, nId, 0, 0, 0, iif(nWidth == NIL, 0, nWidth), iif(nHeight != NIL, nHeight, 0), oParent:oFont, bInit, ;
      bSize, bPaint, NIL, NIL, bcolor)

   IF bcolor != NIL
      ::brush  := HBrush():Add(bcolor)
      ::bcolor := bcolor
   ENDIF

   ::bPaint   := bPaint
   ::lResizeX := (::nWidth == 0)
   ::lResizeY := (::nHeight == 0)
   hwg_RegPanel()

   RETURN Self

METHOD DrawItems(hDC, aCoors) CLASS HPanel

   LOCAL i, aCB

   IF Empty(aCoors)
      aCoors := hwg_Getclientrect(::handle)
   ENDIF
   IF !Empty(aCB := hwg_getPaintCB(::aPaintCB, PAINT_ITEM))
      FOR i := 1 TO Len(aCB)
         Eval(aCB[i], Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4])
      NEXT
   ENDIF

   RETURN NIL

METHOD Paint() CLASS HPanel
   LOCAL pps, hDC, aCoors, block, oPenLight, oPenGray

   IF ::bPaint != NIL
      RETURN Eval(::bPaint, Self)
   ENDIF

   pps    := hwg_Definepaintstru()
   hDC    := hwg_Beginpaint(::handle, pps)
   aCoors := hwg_Getclientrect(::handle)

   IF !Empty(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
      Eval(block, Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4])
   ELSEIF ::oStyle == NIL
      oPenLight := HPen():Add(BS_SOLID, 1, hwg_Getsyscolor(COLOR_3DHILIGHT))
      hwg_Selectobject(hDC, oPenLight:handle)
      hwg_Drawline(hDC, 5, 1, aCoors[3] - 5, 1)
      oPenGray := HPen():Add(BS_SOLID, 1, hwg_Getsyscolor(COLOR_3DSHADOW))
      hwg_Selectobject(hDC, oPenGray:handle)
      hwg_Drawline(hDC, 5, 0, aCoors[3] - 5, 0)
   ELSE
      ::oStyle:Draw(hDC, 0, 0, aCoors[3], aCoors[4])
   ENDIF
   ::DrawItems(hDC, aCoors)

   IF !Empty(oPenGray)
      oPenGray:Release()
      oPenLight:Release()
   ENDIF
   hwg_Endpaint(::handle, pps)

   RETURN NIL

METHOD Release() CLASS HPanel

   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:type == WND_MDI
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] -= ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nLeft == 0
            ::oParent:aOffset[1] -= ::nWidth
         ELSE
            ::oParent:aOffset[3] -= ::nWidth
         ENDIF
      ENDIF
      hwg_Invalidaterect(::oParent:handle, 0, ::nLeft, ::nTop, ::nWidth, ::nHeight)
   ENDIF
   hwg_Sendmessage(::oParent:handle, WM_SIZE, 0, 0)
   ::oParent:DelControl(Self)

   RETURN NIL

METHOD Hide() CLASS HPanel
   LOCAL i

   IF ::lHide
      RETURN NIL
   ENDIF
   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:type == WND_MDI
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] -= ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nLeft == 0
            ::oParent:aOffset[1] -= ::nWidth
         ELSE
            ::oParent:aOffset[3] -= ::nWidth
         ENDIF
      ENDIF
      hwg_Invalidaterect(::oParent:handle, 0, ::nLeft, ::nTop, ::nWidth, ::nHeight)
   ENDIF
   ::nSize := ::nWidth
   FOR i := 1 TO Len(::acontrols)
      ::acontrols[i]:hide()
   NEXT
   ::super:hide()
   hwg_Sendmessage(::oParent:Handle, WM_SIZE, 0, 0)

   RETURN NIL

METHOD Show() CLASS HPanel
   LOCAL i

   IF !::lHide
      RETURN NIL
   ENDIF
   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:type == WND_MDI
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] += ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nLeft == 0
            ::oParent:aOffset[1] += ::nWidth
         ELSE
            ::oParent:aOffset[3] += ::nWidth
         ENDIF
      ENDIF
      hwg_Invalidaterect(::oParent:handle, 1, ::nLeft, ::nTop, ::nWidth, ::nHeight)
   ENDIF
   ::nWidth := ::nsize
   hwg_Sendmessage(::oParent:Handle, WM_SIZE, 0, 0)
   ::super:Show()
   FOR i := 1 TO Len(::aControls)
      ::aControls[i]:Show()
   NEXT
   hwg_Movewindow(::Handle, ::nLeft, ::nTop, ::nWidth, ::nHeight)

   RETURN NIL

METHOD SetPaintCB(nId, block, cId) CLASS HPanel

   LOCAL i, nLen

   IF Empty(cId)
      cId := "_"
   ENDIF
   IF Empty(::aPaintCB)
      ::aPaintCB := {}
   ENDIF

   nLen := Len(::aPaintCB)
   FOR i := 1 TO nLen
      IF ::aPaintCB[i, 1] == nId .AND. ::aPaintCB[i, 2] == cId
         EXIT
      ENDIF
   NEXT
   IF Empty(block)
      IF i <= nLen
         ADel(::aPaintCB, i)
         ::aPaintCB := ASize(::aPaintCB, nLen - 1)
      ENDIF
   ELSE
      IF i > nLen
         Aadd(::aPaintCB, {nId, cId, block})
      ELSE
         ::aPaintCB[i, 3] := block
      ENDIF
   ENDIF

   RETURN NIL

METHOD Drag(xPos, yPos) CLASS HPanel

   LOCAL oWnd := hwg_getParentForm(Self)
   IF xPos > 32000
      xPos -= 65535
   ENDIF
   IF yPos > 32000
      yPos -= 65535
   ENDIF

   IF Abs(xPos-::nOldX) > 1 .OR. Abs(yPos-::nOldY) > 1
      oWnd:Move(oWnd:nLeft + (xPos - ::nOldX), oWnd:nTop + (yPos - ::nOldY))
   ENDIF

   RETURN NIL

CLASS HPanelStS INHERIT HPANEL

   DATA aParts
   DATA aText

   METHOD New(oWndParent, nId, nHeight, oFont, bInit, bPaint, bcolor, oStyle, aParts)
   METHOD Write(cText, nPart, lRedraw)
   METHOD SetText(cText)    INLINE ::Write(cText, NIL, .T.)
   METHOD PaintText(hDC)
   METHOD Paint()

ENDCLASS

METHOD New(oWndParent, nId, nHeight, oFont, bInit, bPaint, bcolor, oStyle, aParts) CLASS HPanelStS

   oWndParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)
   IF bColor == NIL
      bColor := 0xeeeeee
   ENDIF

/*
   ::Super:New(oWndParent, nId, SS_OWNERDRAW, 0, oWndParent:nHeight - nHeight, ;
      oWndParent:nWidth, nHeight, bInit, {|o, w, h|o:Move(0, h - o:nHeight)}, bPaint, bcolor)
    Block reverted to old value with HB_SYMBOL_UNUSED(w)
*/
  
   ::Super:New(oWndParent, nId, SS_OWNERDRAW, 0, oWndParent:nHeight - nHeight, ;
      oWndParent:nWidth, nHeight, bInit, {|o, w, h|HB_SYMBOL_UNUSED(w), o:Move(0, h - o:nHeight)}, bPaint, bcolor)
   ::Anchor := ANCHOR_LEFTABS+ANCHOR_RIGHTABS

   ::oFont := Iif(oFont == NIL, ::oParent:oFont, oFont)
   ::oStyle := oStyle
   IF !Empty(aParts)
      ::aParts := aParts
   ELSE
      ::aParts := {0}
   ENDIF
   ::aText := Array(Len(::aParts))
   AFill(::aText, "")

   RETURN Self

METHOD Write(cText, nPart, lRedraw) CLASS HPanelStS

   ::aText[Iif(nPart==NIL, 1, nPart)] := cText
   IF Valtype(lRedraw) != "L" .OR. lRedraw
      hwg_Invalidaterect(::handle, 0)
   ENDIF

   RETURN NIL

METHOD PaintText(hDC) CLASS HPanelStS

   LOCAL i, x1, x2, nWidth := ::nWidth, oldTColor

   IF ::oFont != NIL
      hwg_Selectobject(hDC, ::oFont:handle)
   ENDIF
   hwg_Settransparentmode(hDC, .T.)
   oldTColor  := hwg_Settextcolor(hDC, ::tcolor)
   FOR i := 1 TO Len(::aParts)
      x1 := Iif(i == 1, 4, x2 + 4)
      IF ::aParts[i] == 0
         x2 := x1 + Int(nWidth / (Len(::aParts) - i + 1))
      ELSE
         x2 := x1 + ::aParts[i]
      ENDIF
      nWidth -= ( x2-x1+1 )
      IF !Empty(::aText[i])
         hwg_Drawtext(hDC, ::aText[i], x1, 6, x2, ::nHeight - 2, DT_LEFT + DT_VCENTER)
      ENDIF
   NEXT
   hwg_Settextcolor(hDC, oldTColor)
   hwg_Settransparentmode(hDC, .F.)

   RETURN NIL

METHOD Paint() CLASS HPanelStS
   LOCAL pps, hDC, block, aCoors

   IF ::bPaint != NIL
      RETURN Eval(::bPaint, Self)
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)

   IF !Empty(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
      aCoors := hwg_Getclientrect(::handle)
      Eval(block, Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4])
   ELSEIF Empty(::oStyle)
      ::oStyle := HStyle():New({::bColor}, 1, NIL, 0.4, 0)
   ENDIF
   ::oStyle:Draw(hDC, 0, 0, ::nWidth, ::nHeight)

   ::PaintText(hDC)
   ::DrawItems(hDC)

   hwg_Endpaint(::handle, pps)

   RETURN NIL

CLASS HPanelHea INHERIT HPANEL

   DATA  xt, yt
   DATA  lMaximized   INIT .F.

   METHOD New(oWndParent, nId, nHeight, oFont, bInit, bPaint, tcolor, bcolor, oStyle, cText, xt, yt, lBtnClose, lBtnMax, lBtnMin)
   METHOD SetText(c, lrefresh)  // INLINE (::title := c)
   METHOD SetSysbtnColor(tColor, bColor)
   METHOD PaintText(hDC)
   METHOD Paint()

ENDCLASS

METHOD New(oWndParent, nId, nHeight, oFont, bInit, bPaint, tcolor, bcolor, oStyle, ;
           cText, xt, yt, lBtnClose, lBtnMax, lBtnMin) CLASS HPanelHea
 
   LOCAL nBtnSize, btnClose, btnMax, btnMin, x1

   oWndParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)
   IF bColor == NIL
      bColor := 0xeeeeee
   ENDIF

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, 0, 0, oWndParent:nWidth, nHeight, bInit, ANCHOR_TOPABS + ANCHOR_LEFTABS + ANCHOR_RIGHTABS, bPaint, bcolor, oStyle)

   ::title := cText
   ::xt := xt
   ::yt := yt
   ::oFont := Iif(oFont == NIL, ::oParent:oFont, oFont)
   ::oStyle := oStyle
   ::tColor := Iif(tColor == NIL, 0, tColor)
   ::lDragWin := .T.

   IF !Empty(lBtnClose) .OR. !Empty(lBtnMax) .OR. !Empty(lBtnMin)
      nBtnSize := Min(24, ::nHeight)
      x1 := ::nWidth-nBtnSize-4

      IF !Empty(lBtnClose)
         @ x1, Int((::nHeight-nBtnSize)/2) OWNERBUTTON btnClose OF Self ;
            SIZE nBtnSize, nBtnSize ON PAINT {|o|fPaintBtn(o)} ;
            ON SIZE ANCHOR_RIGHTABS ON CLICK {||::oParent:Close()}
         x1 -= nBtnSize
      ENDIF
      IF !Empty(lBtnMax)
         @ x1, Int((::nHeight-nBtnSize)/2) OWNERBUTTON btnMax OF Self ;
            SIZE nBtnSize, nBtnSize ON PAINT {|o|fPaintBtn(o)} ;
            ON SIZE ANCHOR_RIGHTABS ;
            ON CLICK {||Iif(::lMaximized,::oParent:Restore(),::oParent:Maximize()),::lMaximized:=!::lMaximized}
         x1 -= nBtnSize
      ENDIF
      IF !Empty(lBtnMin)
         @ x1, Int((::nHeight-nBtnSize)/2) OWNERBUTTON btnMin OF Self ;
            SIZE nBtnSize, nBtnSize ON PAINT {|o|fPaintBtn(o)} ;
            ON SIZE ANCHOR_RIGHTABS ;
            ON CLICK {||::oParent:Minimize()}
      ENDIF
      ::SetSysbtnColor(0, 0xededed)
   ENDIF

   RETURN Self
   
METHOD SetText(c, lrefresh) CLASS HPanelHea
// DF7BE: Set lrefresh to .T. for refreshing the header text
// (compatibility to INLINE definition)

LOCAL pps, hDC

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

METHOD SetSysbtnColor(tColor, bColor)

   LOCAL oBtn, oPen1, oPen2

   oPen1 := HPen():Add(BS_SOLID, 2, tColor)
   oPen2 := HPen():Add(BS_SOLID, 1, tColor)

   IF !Empty(oBtn := ::FindControl("btnclose"))
      oBtn:SetColor(tColor, bColor)
      oBtn:oPen1 := oPen1; oBtn:oPen2 := oPen2
   ENDIF
   IF !Empty(oBtn := ::FindControl("btnmax"))
      oBtn:SetColor(tColor, bColor)
      oBtn:oPen1 := oPen1; oBtn:oPen2 := oPen2
   ENDIF
   IF !Empty(oBtn := ::FindControl("btnmin"))
      oBtn:SetColor(tColor, bColor)
      oBtn:oPen1 := oPen1; oBtn:oPen2 := oPen2
   ENDIF
   RETURN NIL

METHOD PaintText(hDC) CLASS HPanelHea

   LOCAL x1, y1, oldTColor

   IF ::title != NIL

      IF ::oFont != NIL
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      hwg_Settransparentmode(hDC, .T.)
      oldTColor := hwg_Settextcolor(hDC, ::tcolor)
      x1 := Iif(::xt == NIL, 4, ::xt)
      y1 := Iif(::yt == NIL, 4, ::yt)
      hwg_Drawtext(hDC, ::title, x1, y1, ::nWidth - 4, ::nHeight - 4, DT_LEFT + DT_VCENTER)
      hwg_Settextcolor(hDC, oldTColor)
      hwg_Settransparentmode(hDC, .F.)
   ENDIF

   RETURN NIL

METHOD Paint() CLASS HPanelHea
   LOCAL pps, hDC, block, aCoors, i

   IF ::bPaint != NIL
      RETURN Eval(::bPaint, Self)
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)

   IF !Empty(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
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

   LOCAL pps, hDC, aCoors

   IF oBtn:state == OBTN_NORMAL
      oBtn:state := OBTN_STATE1
      hwg_Invalidaterect(oBtn:oParent:handle, 0, oBtn:nLeft, oBtn:nTop, oBtn:nLeft+oBtn:nWidth - 1, oBtn:nTop + oBtn:nHeight - 1)
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
