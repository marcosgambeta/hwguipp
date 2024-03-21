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
   DATA aPaintCB INIT {}         // Array of items to draw: { cIt, bDraw(hDC,aCoors) }
   DATA lDragWin INIT .F.
   DATA lCaptured INIT .F.
   DATA hCursor
   DATA nOldX, nOldY HIDDEN
   DATA lResizeX, lResizeY, nSize HIDDEN

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, bInit, bSize, bPaint, bcolor, oStyle)
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

METHOD HPanel:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, bInit, bSize, bPaint, bcolor, oStyle)

   LOCAL oParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)

   ::Super:New(oWndParent, nId, nStyle, nX, nY, iif(nWidth == NIL, 0, nWidth), iif(nHeight == NIL, 0, nHeight), oParent:oFont, bInit, bSize, bPaint, NIL, NIL, bcolor)

   IF bcolor != NIL
      ::brush := HBrush():Add(bcolor)
      ::bcolor := bcolor
   ENDIF
   ::oStyle := oStyle
   ::bPaint := bPaint
   ::lResizeX := (::nWidth == 0)
   ::lResizeY := (::nHeight == 0)
   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:Type == WND_MDI
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] := ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nX == 0
            ::oParent:aOffset[1] := ::nWidth
         ELSE
            ::oParent:aOffset[3] := ::nWidth
         ENDIF
      ENDIF
   ENDIF

   hwg_RegPanel()
   ::Activate()

RETURN Self

METHOD HPanel:Activate()

   LOCAL handle := ::oParent:handle

   IF !Empty(handle)
      ::handle := hwg_Createpanel(handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

RETURN NIL

METHOD HPanel:onEvent(msg, wParam, lParam)

   SWITCH msg

   CASE WM_MOUSEMOVE
      IF ::lDragWin .AND. ::lCaptured
         ::Drag(hwg_Loword(lParam), hwg_Hiword(lParam))
      ENDIF
      EXIT

   CASE WM_PAINT
      ::Paint()
      EXIT

   CASE WM_ERASEBKGND
      IF ::brush != NIL
         IF HB_ISOBJECT(::brush)
            hwg_Fillrect(wParam, 0, 0, ::nWidth, ::nHeight, ::brush:handle)
         ENDIF
         RETURN 1
      ENDIF
      EXIT

   CASE WM_SIZE
      IF HB_ISOBJECT(::oEmbedded)
         ::oEmbedded:Resize(hwg_Loword(lParam), hwg_Hiword(lParam))
      ENDIF
      EXIT

   CASE WM_DESTROY
      IF HB_ISOBJECT(::oEmbedded)
         ::oEmbedded:END()
      ENDIF
      ::Super:onEvent(WM_DESTROY)
      RETURN 0

   CASE WM_LBUTTONDOWN
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
      EXIT

   CASE WM_LBUTTONUP
      IF ::lDragWin .AND. ::lCaptured
         hwg_Releasecapture()
         ::lCaptured := .F.
      ENDIF
      EXIT

   CASE WM_HSCROLL
   CASE WM_VSCROLL
   CASE WM_MOUSEWHEEL
      hwg_onTrackScroll(Self, msg, wParam, lParam)

   ENDSWITCH

RETURN ::Super:onEvent(msg, wParam, lParam)

METHOD HPanel:Init()

   IF !::lInit
      IF ::bSize == NIL .AND. Empty(::Anchor)
         ::bSize := {|o, x, y|o:Move(iif(::nX > 0, x - ::nX, 0), ;
            iif(::nY > 0, y - ::nHeight, 0), ;
            iif(::nWidth == 0 .OR. ::lResizeX, x, ::nWidth), ;
            iif(::nHeight == 0 .OR. ::lResizeY, y, ::nHeight)) }
      ENDIF

      ::Super:Init()
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
      Hwg_InitWinCtrl(::handle)
   ENDIF

RETURN NIL

METHOD HPanel:Redefine(oWndParent, nId, nWidth, nHeight, bInit, bSize, bPaint, bcolor)

   LOCAL oParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)

   ::Super:New(oWndParent, nId, 0, 0, 0, iif(nWidth == NIL, 0, nWidth), iif(nHeight != NIL, nHeight, 0), oParent:oFont, bInit, bSize, bPaint, NIL, NIL, bcolor)

   IF bcolor != NIL
      ::brush := HBrush():Add(bcolor)
      ::bcolor := bcolor
   ENDIF

   ::bPaint := bPaint
   ::lResizeX := (::nWidth == 0)
   ::lResizeY := (::nHeight == 0)
   hwg_RegPanel()

RETURN Self

METHOD HPanel:DrawItems(hDC, aCoors)

   LOCAL i
   LOCAL aCB

   IF Empty(aCoors)
      aCoors := hwg_Getclientrect(::handle)
   ENDIF
   IF !Empty(aCB := hwg_getPaintCB(::aPaintCB, PAINT_ITEM))
      FOR i := 1 TO Len(aCB)
         Eval(aCB[i], Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4])
      NEXT
   ENDIF

RETURN NIL

METHOD HPanel:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors
   LOCAL block
   LOCAL oPenLight
   LOCAL oPenGray

   IF hb_IsBlock(::bPaint)
      RETURN Eval(::bPaint, Self)
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)
   aCoors := hwg_Getclientrect(::handle)

   IF hb_IsBlock(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
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

METHOD HPanel:Release()

   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:type == WND_MDI
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] -= ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nX == 0
            ::oParent:aOffset[1] -= ::nWidth
         ELSE
            ::oParent:aOffset[3] -= ::nWidth
         ENDIF
      ENDIF
      hwg_Invalidaterect(::oParent:handle, 0, ::nX, ::nY, ::nWidth, ::nHeight)
   ENDIF
   hwg_Sendmessage(::oParent:handle, WM_SIZE, 0, 0)
   ::oParent:DelControl(Self)

RETURN NIL

METHOD HPanel:Hide()

   LOCAL oItem

   IF ::lHide
      RETURN NIL
   ENDIF

   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:type == WND_MDI
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] -= ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nX == 0
            ::oParent:aOffset[1] -= ::nWidth
         ELSE
            ::oParent:aOffset[3] -= ::nWidth
         ENDIF
      ENDIF
      hwg_Invalidaterect(::oParent:handle, 0, ::nX, ::nY, ::nWidth, ::nHeight)
   ENDIF
   ::nSize := ::nWidth
   FOR EACH oItem IN ::acontrols
      oItem:hide()
   NEXT
   ::super:hide()
   hwg_Sendmessage(::oParent:Handle, WM_SIZE, 0, 0)

RETURN NIL

METHOD HPanel:Show()

   LOCAL oItem

   IF !::lHide
      RETURN NIL
   ENDIF

   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:type == WND_MDI
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] += ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nX == 0
            ::oParent:aOffset[1] += ::nWidth
         ELSE
            ::oParent:aOffset[3] += ::nWidth
         ENDIF
      ENDIF
      hwg_Invalidaterect(::oParent:handle, 1, ::nX, ::nY, ::nWidth, ::nHeight)
   ENDIF
   ::nWidth := ::nsize
   hwg_Sendmessage(::oParent:Handle, WM_SIZE, 0, 0)
   ::super:Show()
   FOR EACH oItem IN ::aControls
      oItem:Show()
   NEXT
   hwg_Movewindow(::Handle, ::nX, ::nY, ::nWidth, ::nHeight)

RETURN NIL

METHOD HPanel:SetPaintCB(nId, block, cId)

   LOCAL i
   LOCAL nLen

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

METHOD HPanel:Drag(xPos, yPos)

   LOCAL oWnd := hwg_getParentForm(Self)

   IF xPos > 32000
      xPos -= 65535
   ENDIF
   IF yPos > 32000
      yPos -= 65535
   ENDIF

   IF Abs(xPos - ::nOldX) > 1 .OR. Abs(yPos - ::nOldY) > 1
      oWnd:Move(oWnd:nX + (xPos - ::nOldX), oWnd:nY + (yPos - ::nOldY))
   ENDIF

RETURN NIL
