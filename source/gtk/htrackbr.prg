//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HTrack class - Substitute for WinAPI HTRACKBAR
//
// Copyright 2021 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//
// Copyright 2021 DF7BE
//

#include <hbclass.ch>
#include "hwguipp.ch"
#include "gtk.ch"

#define CLR_WHITE    0xffffff
#define CLR_BLACK    0x000000

CLASS HTrack INHERIT HControl

   CLASS VAR winclass INIT "STATIC"

   DATA lVertical
   DATA oStyleBar
   DATA oStyleSlider
   DATA lAxis INIT .T.
   DATA nFrom
   DATA nTo
   DATA nCurr
   DATA nSize
   DATA oPen1
   DATA oPen2
   DATA tColor2
   DATA lCaptured INIT .F.
   DATA bEndDrag
   DATA bChange

   METHOD New(oWndParent, nId, nX, nY, nWidth, nHeight, bSize, bPaint, color, bcolor, nSize, oStyleBar, oStyleSlider, lAxis)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Set(nSize, oStyleBar, oStyleSlider, lAxis, bPaint)
   METHOD Paint()
   METHOD Drag(xPos, yPos)
   METHOD Move(x1, y1, width, height)
   METHOD Value(xValue) SETGET

ENDCLASS

METHOD HTrack:New(oWndParent, nId, nX, nY, nWidth, nHeight, bSize, bPaint, color, bcolor, nSize, oStyleBar, oStyleSlider, lAxis)

   color := IIf(color == NIL, CLR_BLACK, color)
   bColor := IIf(bColor == NIL, CLR_WHITE, bColor)
   ::Super:New(oWndParent, nId, WS_CHILD + WS_VISIBLE + SS_OWNERDRAW, nX, nY, nWidth, nHeight, , , bSize, bPaint, , color, bcolor)

   ::title := ""
   ::lVertical := (::nHeight > ::nWidth)
   ::nSize := IIf(nSize == NIL, 12, nSize)
   //::nFrom := IIf(::lVertical, Int(::nSize / 2), Int(::nSize / 2))
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
      ::handle := hwg_Createsplitter(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HTrack:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)

   IF msg == WM_MOUSEMOVE
      IF ::lCaptured
         ::Drag(hwg_Loword(lParam), hwg_Hiword(lParam))
      ENDIF

   ELSEIF msg == WM_PAINT
      ::Paint()

   ELSEIF msg == WM_ERASEBKGND
      IF ::brush != NIL
         hwg_Fillrect(wParam, 0, 0, ::nWidth, ::nHeight, ::brush:handle)
         RETURN 1
      ENDIF

   ELSEIF msg == WM_LBUTTONDOWN
      ::lCaptured := .T.
      ::Drag(hwg_Loword(lParam), hwg_Hiword(lParam))

   ELSEIF msg == WM_LBUTTONUP
      ::lCaptured := .F.
      IF hb_IsBlock(::bEndDrag)
         Eval(::bEndDrag, Self)
      ENDIF
      ::Refresh()

   ELSEIF msg == WM_DESTROY
      ::END()
   ENDIF

   RETURN -1

METHOD HTrack:Init()

   IF !::lInit
      ::Super:Init()
      hwg_Setwindowobject(::handle, Self)
   ENDIF

   RETURN NIL

METHOD HTrack:Set(nSize, oStyleBar, oStyleSlider, lAxis, bPaint)

   LOCAL xValue := (::nCurr - ::nFrom) / (::nTo - ::nFrom)

   IF nSize != NIL
      ::nSize := nSize
      ::nFrom := Int(::nSize/2)
      ::nTo := IIf(::lVertical, ::nHeight, ::nWidth) - 1 - Int(::nSize / 2)
      ::nCurr := xValue * (::nTo - ::nFrom) + ::nFrom
   ENDIF
   IF oStyleBar != NIL
      ::oStyleBar := oStyleBar
   ENDIF
   IF oStyleSlider != NIL
      ::oStyleSlider := oStyleSlider
   ENDIF
   IF lAxis != NIL
      ::lAxis := lAxis
   ENDIF
   IF bPaint != NIL
      ::bPaint := bPaint
   ENDIF
   ::Refresh()

   RETURN NIL

METHOD HTrack:Paint()

   LOCAL nHalf
   LOCAL nw
   LOCAL x1
   LOCAL y1
   LOCAL hDC := hwg_Getdc(::handle)

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
         //IF ::nCurr + nHalf < ::nFrom
         IF ::lAxis .AND. ::nCurr - nHalf > ::nFrom
            //hwg_Drawline(hDC, x1, ::nTo, x1, ::nCurr + nHalf)
            hwg_Drawline(hDC, x1, ::nFrom, x1, ::nCurr - nHalf)
         ENDIF
         IF ::oStyleSlider == NIL
            hwg_Rectangle(hDC, x1 - nHalf, ::nCurr + nHalf, x1 + nHalf, ::nCurr - nHalf)
         ELSE
            ::oStyleSlider:Draw(hDC, x1 - nw, ::nCurr - nHalf, x1 + nw, ::nCurr + nHalf)
         ENDIF
         //IF ::nCurr - nHalf > ::nTo
         IF ::lAxis .AND. ::nCurr + nHalf < ::nTo
            IF ::oPen2 != NIL
               hwg_Selectobject(hDC, ::oPen2:handle)
            ENDIF
            //hwg_Drawline(hDC, x1, ::nCurr - nHalf, x1, ::nTo)
            hwg_Drawline(hDC, x1, ::nCurr + nHalf + 1, x1, ::nTo)
         ENDIF
      ELSE
         y1 := Int(::nHeight/2)
         nw := Min(nHalf, x1 - 2)
         IF ::lAxis .AND. ::nCurr - nHalf > ::nFrom
            hwg_Drawline(hDC, ::nFrom, y1, ::nCurr - nHalf, y1)
         ENDIF
         IF ::oStyleSlider == NIL
            hwg_Rectangle(hDC, ::nCurr - nHalf, y1 - nHalf, ::nCurr + nHalf, y1 + nHalf)
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

   hwg_Releasedc(::handle, hDC)

   RETURN NIL

METHOD HTrack:Drag(xPos, yPos)

   LOCAL nCurr := ::nCurr

   IF ::lVertical
      //::nCurr := Min(Max(::nTo, yPos), ::nFrom)
      IF ypos > 60000
         ypos := 0
      ENDIF
      ::nCurr := Min(Max(::nFrom, yPos), ::nTo)
   ELSE
      IF xpos > 60000
         xpos := 0
      ENDIF
      ::nCurr := Min(Max(::nFrom, xPos), ::nTo)
   ENDIF

   ::Refresh()
   IF nCurr != ::nCurr .AND. hb_IsBlock(::bChange)
      Eval(::bChange, Self, ::Value)
   ENDIF

   RETURN NIL

METHOD HTrack:Move(x1, y1, width, height)

   LOCAL xValue := (::nCurr - ::nFrom) / (::nTo - ::nFrom)

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
      ::Refresh()
   ELSE
      xValue := (::nCurr - ::nFrom) / (::nTo - ::nFrom)
   ENDIF

   RETURN xValue
