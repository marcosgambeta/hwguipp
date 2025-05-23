//
// HWGUI - Harbour Win32 GUI library source code:
// HSplitter class
//
// Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include <common.ch>
#include "hwguipp.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HSplitter INHERIT HControl

   CLASS VAR winclass INIT "STATIC"

   DATA aLeft
   DATA aRight
   DATA lVertical
   DATA oStyle
   DATA lRepaint INIT .F.
   DATA nFrom, nTo
   DATA hCursor
   DATA lCaptured INIT .F.
   DATA lMoved INIT .F.
   DATA bEndDrag

   METHOD New(oWndParent, nId, nX, nY, nWidth, nHeight, bSize, bDraw, color, bcolor, aLeft, aRight, nFrom, nTo, oStyle)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Paint()
   METHOD Drag(xPos, yPos)
   METHOD DragAll(xPos, yPos)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

// bPaint ==> bDraw
METHOD HSplitter:New(oWndParent, nId, nX, nY, nWidth, nHeight, bSize, bDraw, color, bcolor, aLeft, aRight, nFrom, ;
   nTo, oStyle)

   ::Super:New(oWndParent, nId, WS_CHILD + WS_VISIBLE + SS_OWNERDRAW, nX, nY, nWidth, nHeight, NIL, NIL, bSize, ;
      bDraw, NIL, IIf(color == NIL, 0, color), bcolor)

   ::title := ""
   ::aLeft := IIf(aLeft == NIL, {}, aLeft)
   ::aRight := IIf(aRight == NIL, {}, aRight)
   ::lVertical := (::nHeight > ::nWidth)
   ::nFrom := nFrom
   ::nTo := nTo
   ::oStyle := oStyle

   ::Activate()

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HSplitter:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HSplitter:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)

   SWITCH msg

   CASE WM_MOUSEMOVE
      IF ::hCursor == NIL
         ::hCursor := hwg_Loadcursor(IIf(::lVertical, IDC_SIZEWE, IDC_SIZENS))
      ENDIF
      Hwg_SetCursor(::hCursor)
      IF ::lCaptured
         IF ::lRepaint
            ::DragAll(hwg_Loword(lParam), hwg_Hiword(lParam))
         ELSE
            ::Drag(hwg_Loword(lParam), hwg_Hiword(lParam))
         ENDIF
      ENDIF
      EXIT

   CASE WM_PAINT
      ::Paint()
      EXIT

   CASE WM_ERASEBKGND
      IF ::brush != NIL
         hwg_Fillrect(wParam, 0, 0, ::nWidth, ::nHeight, ::brush:handle)
         RETURN 1
      ENDIF
      EXIT

   CASE WM_LBUTTONDOWN
      Hwg_SetCursor(::hCursor)
      hwg_Setcapture(::handle)
      ::lCaptured := .T.
      EXIT

   CASE WM_LBUTTONUP
      hwg_Releasecapture()
      ::DragAll()
      ::lCaptured := .F.
      IF hb_IsBlock(::bEndDrag)
         Eval(::bEndDrag, Self)
      ENDIF
      EXIT

   CASE WM_DESTROY
      ::END()

   ENDSWITCH

RETURN -1

//-------------------------------------------------------------------------------------------------------------------//

METHOD HSplitter:Init()

   IF !::lInit
      ::Super:Init()
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
      Hwg_InitWinCtrl(::handle)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HSplitter:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors
   LOCAL x1
   LOCAL y1
   LOCAL x2
   LOCAL y2

   IF hb_IsBlock(::bPaint)
      Eval(::bPaint, Self)
   ELSE
      pps := hwg_Definepaintstru()
      hDC := hwg_Beginpaint(::handle, pps)
      aCoors := hwg_Getclientrect(::handle)
      IF ::oStyle == NIL
         x1 := aCoors[1] + IIf(::lVertical, 1, 5)
         y1 := aCoors[2] + IIf(::lVertical, 5, 1)
         x2 := aCoors[3] - IIf(::lVertical, 0, 5)
         y2 := aCoors[4] - IIf(::lVertical, 5, 0)
         hwg_Drawedge(hDC, x1, y1, x2, y2, EDGE_ETCHED, IIf(::lVertical, BF_LEFT, BF_TOP))
      ELSE
         ::oStyle:Draw(hDC, 0, 0, aCoors[3], aCoors[4])
      ENDIF
      hwg_Endpaint(::handle, pps)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HSplitter:Drag(xPos, yPos)

   LOCAL nFrom
   LOCAL nTo

   nFrom := IIf(::nFrom == NIL, 1, ::nFrom)
   nTo := IIf(::nTo == NIL, IIf(::lVertical, ::oParent:nWidth - 1, ::oParent:nHeight - 1), ::nTo)
   IF ::lVertical
      IF xPos > 32000
         xPos -= 65535
      ENDIF
      IF (xPos := (::nX + xPos)) >= nFrom .AND. xPos <= nTo
         ::nX := xPos
      ENDIF
   ELSE
      IF yPos > 32000
         yPos -= 65535
      ENDIF
      IF (yPos := (::nY + yPos)) >= nFrom .AND. yPos <= nTo
         ::nY := yPos
      ENDIF
   ENDIF
   hwg_MoveWindow(::handle, ::nX, ::nY, ::nWidth, ::nHeight)
   ::lMoved := .T.

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HSplitter:DragAll(xPos, yPos)

   LOCAL i
   LOCAL oCtrl
   LOCAL nDiff
   LOCAL wold
   LOCAL hold
   LOCAL nX
   LOCAL nY
   LOCAL nWidth
   LOCAL nHeight

   IF xPos != NIL .OR. yPos != NIL
      ::Drag(xPos, yPos)
   ENDIF
   FOR i := 1 TO Len(::aRight)
      oCtrl := ::aRight[i]
      nX := oCtrl:nX
      nY := oCtrl:nY
      nWidth := wold := oCtrl:nWidth
      nHeight := hold := oCtrl:nHeight
      IF ::lVertical
         nDiff := ::nX + ::nWidth - oCtrl:nX
         nX += nDiff
         nWidth -= nDiff
      ELSE
         nDiff := ::nY + ::nHeight - oCtrl:nY
         nY += nDiff
         nHeight -= nDiff
      ENDIF
      oCtrl:Move(nX, nY, nWidth, nHeight)
      hwg_onAnchor(oCtrl, wold, hold, oCtrl:nWidth, oCtrl:nHeight)
   NEXT
   FOR i := 1 TO Len(::aLeft)
      oCtrl := ::aLeft[i]
      nX := oCtrl:nX
      nY := oCtrl:nY
      nWidth := wold := oCtrl:nWidth
      nHeight := hold := oCtrl:nHeight
      IF ::lVertical
         nDiff := ::nX - (oCtrl:nX + oCtrl:nWidth)
         nWidth += nDiff
      ELSE
         nDiff := ::nY - (oCtrl:nY + oCtrl:nHeight)
         nHeight += nDiff
      ENDIF
      oCtrl:Move(nX, nY, nWidth, nHeight)
      hwg_onAnchor(oCtrl, wold, hold, oCtrl:nWidth, oCtrl:nHeight)
   NEXT
   ::lMoved := .F.

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//
