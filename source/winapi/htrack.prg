//
// HWGUI - Harbour Win32 GUI library source code:
// HTrack class
//
// HTrack class
// Copyright 2021 Alexander S.Kresin <alex@kresin.ru>
//

#include <hbclass.ch>
#include "hwguipp.ch"

#define TBS_AUTOTICKS                1
#define TBS_VERT                     2
#define TBS_TOP                      4
#define TBS_LEFT                     4
#define TBS_BOTH                     8
#define TBS_NOTICKS                 16

#define CLR_WHITE    0xffffff
#define CLR_BLACK    0x000000

CLASS HTrack INHERIT HControl

   CLASS VAR winclass INIT "STATIC"

   DATA lVertical
   DATA oStyleBar, oStyleSlider
   DATA lAxis INIT .T.
   DATA nFrom, nTo, nCurr, nSize
   DATA oPen1, oPen2, tColor2
   DATA lCaptured INIT .F.
   DATA bEndDrag
   DATA bChange

   METHOD New(oWndParent, nId, nX, nY, nWidth, nHeight, bSize, bPaint, color, bcolor, nSize, oStyleBar, oStyleSlider, lAxis)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Paint()
   METHOD Drag(xPos, yPos)
   METHOD Move(x1, y1, width, height)
   METHOD Value(xValue) SETGET

ENDCLASS

METHOD HTrack:New(oWndParent, nId, nX, nY, nWidth, nHeight, bSize, bPaint, color, bcolor, nSize, oStyleBar, oStyleSlider, lAxis)

   color := IIf(color == NIL, CLR_BLACK, color)
   bColor := IIf(bColor == NIL, CLR_WHITE, bColor)
   ::Super:New(oWndParent, nId, WS_CHILD + WS_VISIBLE + SS_OWNERDRAW, nX, nY, nWidth, nHeight, NIL, NIL, bSize, bPaint, NIL, color, bcolor)

   ::title := ""
   ::lVertical := (::nHeight > ::nWidth)
   ::nSize := IIf(nSize == NIL, 12, nSize)
   ::nFrom := Int(::nSize/2)
   ::nTo := IIf(::lVertical, ::nHeight - 1 - Int(::nSize / 2), ::nWidth - 1 - Int(::nSize / 2))
   ::nCurr := ::nFrom
   ::oStyleBar := oStyleBar
   ::oStyleSlider := oStyleSlider
   ::lAxis := (lAxis == NIL .OR. lAxis)
   ::oPen1 := HPen():Add(PS_SOLID, 1, color)

   ::Activate()

   RETURN Self

METHOD HTrack:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HTrack:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)

   SWITCH msg

   CASE WM_MOUSEMOVE
      IF ::lCaptured
         ::Drag(hwg_Loword(lParam), hwg_Hiword(lParam))
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
      ::lCaptured := .T.
      hwg_Setcapture(::handle)
      ::Drag(hwg_Loword(lParam), hwg_Hiword(lParam))
      EXIT

   CASE WM_LBUTTONUP
      ::lCaptured := .F.
      hwg_Releasecapture()
      IF hb_IsBlock(::bEndDrag)
         Eval(::bEndDrag, Self)
      ENDIF
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
      EXIT

   CASE WM_DESTROY
      ::END()
   
   ENDSWITCH

   RETURN -1

METHOD HTrack:Init()

   IF !::lInit
      ::Super:Init()
      hwg_Setwindowobject(::handle, Self)
#ifndef __GTK__
      ::nHolder := 1
      Hwg_InitWinCtrl(::handle)
#endif
   ENDIF

   RETURN NIL

METHOD HTrack:Paint()

   LOCAL nHalf
   LOCAL nw
   LOCAL x1
   LOCAL y1
   LOCAL pps := hwg_Definepaintstru()
   LOCAL hDC := hwg_Beginpaint(::handle, pps)

   IF ::tColor2 != NIL .AND. ::oPen2 == NIL
      ::oPen2 := HPen():Add(PS_SOLID, 1, ::tColor2)
   ENDIF

   IF hb_IsBlock(::bPaint)
      Eval(::bPaint, Self, hDC)
   ELSE

      IF ::oStyleBar == NIL
         hwg_Fillrect(hDC, 0, 0, ::nWidth, ::nHeight, ::brush:handle)
      ELSE
         ::oStyleBar:Draw(hDC, 0, 0, ::nWidth, ::nHeight)
      ENDIF

      nHalf := Int(::nSize/2)
      hwg_Selectobject(hDC, ::oPen1:handle)
      IF ::lVertical
         x1 := Int(::nWidth/2)
         nw := Min(nHalf, x1 - 2)
         IF ::lAxis .AND. ::nCurr - nHalf > ::nFrom
            hwg_Drawline(hDC, x1, ::nFrom, x1, ::nCurr - nHalf)
         ENDIF
         IF ::oStyleSlider == NIL
            hwg_Rectangle(hDC, x1 - nw, ::nCurr + nHalf, x1 + nw, ::nCurr - nHalf)
         ELSE
            ::oStyleSlider:Draw(hDC, x1 - nw, ::nCurr - nHalf, x1 + nw, ::nCurr + nHalf)
         ENDIF
         IF ::lAxis .AND. ::nCurr + nHalf < ::nTo
            IF ::oPen2 != NIL
               hwg_Selectobject(hDC, ::oPen2:handle)
            ENDIF
            hwg_Drawline(hDC, x1, ::nCurr + nHalf + 1, x1, ::nTo)
         ENDIF
      ELSE
         y1 := Int(::nHeight/2)
         nw := Min(nHalf, x1 - 2)
         IF ::lAxis .AND. ::nCurr - nHalf > ::nFrom
            hwg_Drawline(hDC, ::nFrom, y1, ::nCurr - nHalf, y1)
         ENDIF
         IF ::oStyleSlider == NIL
            hwg_Rectangle(hDC, ::nCurr - nHalf, y1 - nw, ::nCurr + nHalf, y1 + nw)
         ELSE
            ::oStyleSlider:Draw(hDC, ::nCurr - nHalf, y1 - nw, ::nCurr + nHalf, y1 + nw)
         ENDIF
         IF ::lAxis .AND. ::nCurr + nHalf < ::nTo
            IF ::oPen2 != NIL
               hwg_Selectobject(hDC, ::oPen2:handle)
            ENDIF
            hwg_Drawline(hDC, ::nCurr + nHalf + 1, y1, ::nTo, y1)
         ENDIF
      ENDIF
   ENDIF
   hwg_Endpaint(::handle, pps)

   RETURN NIL

METHOD HTrack:Drag(xPos, yPos)

   LOCAL nCurr := ::nCurr
   LOCAL nHalf := Int(::nSize/2)
   LOCAL x1
   LOCAL y1


   HB_SYMBOL_UNUSED(nhalf)

   //hwg_writelog(str(xPos) + str(yPos))
   IF ::lVertical
      x1 := Int(::nWidth/2)
      HB_SYMBOL_UNUSED(x1)
      IF yPos > 32000
         yPos -= 65535
      ENDIF
      ::nCurr := Min(Max(::nFrom, yPos), ::nTo)
   ELSE
      y1 := Int(::nHeight/2)
      HB_SYMBOL_UNUSED(y1)
      IF xPos > 32000
         xPos -= 65535
      ENDIF
      ::nCurr := Min(Max(::nFrom, xPos), ::nTo)
   ENDIF
   hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
   IF nCurr != ::nCurr .AND. hb_IsBlock(::bChange)
      Eval(::bChange, Self, ::Value)
   ENDIF

   RETURN NIL

METHOD HTrack:Move(x1, y1, width, height)

   LOCAL xValue := (::nCurr - ::nFrom) / (::nTo - ::nFrom)

   HB_SYMBOL_UNUSED(x1)
   HB_SYMBOL_UNUSED(y1)

   IF ::lVertical .AND. !Empty(height) .AND. height != ::nHeight
      ::nFrom := Int(::nSize/2)
      ::nTo := height-1-Int(::nSize/2)
      ::nCurr := xValue * (::nTo - ::nFrom) + ::nFrom
   ELSEIF !::lVertical .AND. !Empty(width) .AND. width != ::nWidth
      ::nFrom := Int(::nSize/2)
      ::nTo := width-1-Int(::nSize/2)
      ::nCurr := xValue * (::nTo - ::nFrom) + ::nFrom
   ENDIF

   ::Super:Move(x1, y1, width, height)

   RETURN NIL

METHOD HTrack:Value(xValue)

   IF xValue != NIL
      xValue := IIf(xValue < 0, 0, IIf(xValue > 1, 1, xValue))
      ::nCurr := xValue * (::nTo - ::nFrom) + ::nFrom
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
   ELSE
      xValue := (::nCurr - ::nFrom) / (::nTo - ::nFrom)
   ENDIF

   RETURN xValue
