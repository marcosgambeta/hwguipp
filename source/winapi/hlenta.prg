//
// HWGUI - Harbour Win32 GUI library source code:
// HLenta class
//
// Copyright 2021 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

#define CLR_WHITE    0xffffff
#define CLR_BLACK    0x000000
#define CLR_GRAY_1   0xcccccc
#define CLR_GRAY_2   0x999999

CLASS HLenta INHERIT HControl

   CLASS VAR winclass INIT "PANEL"

#ifdef __PLATFORM__UNIX
   DATA hBox
#endif
   DATA lVertical
   DATA aItems
   DATA nItemSize
   DATA aItemStyle
   DATA oFont, oPen
   DATA lDrawNext INIT .T.
   DATA lPressed INIT .F.
   DATA lMoved INIT .F.
   DATA nFirst INIT 1
   DATA nSelected INIT 0
   DATA nOver INIT 0
   DATA nShift INIT 0
   DATA nDragKoef INIT 1
   DATA xPos, yPos
   DATA bClick

   METHOD New(oWndParent, nId, nX, nY, nWidth, nHeight, oFont, bSize, bPaint, bClick, color, bcolor, aItems, nItemSize, aItemStyle)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Paint()
   METHOD Drag(xPos, yPos)
   METHOD Value(nValue) SETGET

ENDCLASS

METHOD HLenta:New(oWndParent, nId, nX, nY, nWidth, nHeight, oFont, bSize, bPaint, bClick, color, bcolor, aItems, nItemSize, aItemStyle)

   color := IIf(color == NIL, CLR_BLACK, color)
   bColor := IIf(bColor == NIL, CLR_WHITE, bColor)
   ::Super:New(oWndParent, nId, WS_CHILD + WS_VISIBLE + SS_OWNERDRAW, nX, nY, nWidth, nHeight, oFont, NIL, bSize, bPaint, NIL, color, bcolor)

   ::title := ""
   ::lVertical := (::nHeight > ::nWidth)
   ::bClick := bClick
   ::aItems := aItems
   ::aItemStyle := IIf(Empty(aItemStyle), {HStyle():New({CLR_WHITE, CLR_GRAY_1}, 3), HStyle():New({CLR_GRAY_2}, 3)}, aItemStyle)
   ::nItemSize := nItemSize
   ::oPen := HPen():Add(PS_SOLID, 1, color)

   ::Activate()

   RETURN Self

METHOD HLenta:Activate()
   
   LOCAL handle := ::oParent:handle

   IF !Empty(handle)
#ifdef __PLATFORM__UNIX
      ::handle := hwg_Createpanel(Self, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
#else
      ::handle := hwg_Createpanel(handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
#endif
      ::Init()
   ENDIF

   RETURN NIL

METHOD HLenta:Init()

   IF !::lInit

      ::Super:Init()
      hwg_Setwindowobject(::handle, Self)
#ifndef __PLATFORM__UNIX
      ::nHolder := 1
      Hwg_InitWinCtrl(::handle)
#endif
   ENDIF

   RETURN NIL

METHOD HLenta:onEvent(msg, wParam, lParam)

   LOCAL xPos
   LOCAL yPos
   LOCAL nPos
   LOCAL lRedraw := .F.
   LOCAL y1

   HB_SYMBOL_UNUSED(wParam)

   SWITCH msg

   CASE WM_MOUSEMOVE
      hwg_SetCapture(::handle)
      xPos := hwg_Loword(lParam); yPos := hwg_Hiword(lParam)
      //hwg_writelog(ltrim(str(xpos)) + " " + ltrim(str(ypos)))
      IF xPos < 0 .OR. xPos > ::nWidth .OR. yPos < 0 .OR. yPos > ::nHeight
         ::lPressed := .F.
         ::nOver := 0
         hwg_Releasecapture()
         lRedraw := .T.
      ELSE
         IF ::lPressed
            ::Drag(xPos, yPos)
         ELSE
            y1 := Int(::nShift % ::nItemSize)
            IF y1 > 0
               y1 := ::nItemSize - y1
            ENDIF
            nPos := IIf(::lVertical, yPos - y1, xPos - y1)
            IF nPos > 0
               IF (nPos := Int(nPos / ::nItemSize) + ::nFirst) > Len(::aItems)
                  nPos := 0
               ENDIF
               lRedraw := (::nOver != nPos)
               ::nOver := nPos
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE WM_PAINT
      ::Paint()
      EXIT

   CASE WM_LBUTTONDOWN
      xPos := hwg_Loword(lParam); yPos := hwg_Hiword(lParam)
      ::lPressed := .T.
      ::lMoved := .F.
      ::xPos := xPos
      ::yPos := yPos
      EXIT

   CASE WM_LBUTTONUP
      ::lPressed := .F.
      IF !::lMoved
         IF ::nSelected != ::nOver .AND. ::nOver != 0
            ::nSelected := ::nOver
            lRedraw := .T.
            IF hb_IsBlock(::bClick)
               Eval(::bClick, Self, ::nSelected)
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE WM_DESTROY
      ::End()

   ENDSWITCH

   IF lRedraw
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
   ENDIF

   RETURN -1

METHOD HLenta:Paint()

#ifdef __PLATFORM__UNIX
   LOCAL hDC := hwg_Getdc(::handle)
#else
   LOCAL pps := hwg_Definepaintstru()
   LOCAL hDC := hwg_Beginpaint(::handle, pps)
#endif
   LOCAL i
   LOCAL y1
   LOCAL ob
   LOCAL nCurr
   LOCAL nItemSize := ::nItemSize
   LOCAL oStyle
   LOCAL cText
   LOCAL lVertical := ::lVertical
   LOCAL l1
   LOCAL nW := IIf(::lVertical, ::nWidth, ::nHeight)
   LOCAL nLength := IIf(::lVertical, ::nHeight, ::nWidth)
   LOCAL aItemStyle := ::aItemStyle
   LOCAL lStyleOver := (Len(aItemStyle)>2.AND.aItemStyle[3] != NIL)
   LOCAL lStyleSele := (Len(aItemStyle)>1.AND.aItemStyle[2] != NIL)

   IF hb_IsBlock(::bPaint)
      Eval(::bPaint, Self, hDC)
   ELSE

      IF !Empty(::aItems)
         l1 := (hb_IsArray(::aItems[1]))
         IF ::oFont != NIL
            hwg_Selectobject(hDC, ::oFont:handle)
         ENDIF
         y1 := Int(::nShift % nItemSize)
         IF y1 > 0
            y1 := nItemSize - y1
         ENDIF
         IF y1 > 0
            IF lVertical
               aItemStyle[1]:Draw(hDC, 0, 0, nW, y1)
            ELSE
               aItemStyle[1]:Draw(hDC, 0, 0, y1, nW)
            ENDIF
         ENDIF
         i := 1
         DO WHILE y1 + nItemSize <= nLength .AND. (nCurr := i + ::nFirst - 1) <= Len(::aItems)
            oStyle := IIf(nCurr == ::nSelected .AND. lStyleSele, aItemStyle[2], IIf(nCurr == ::nOver .AND. lStyleOver, aItemStyle[3], aItemStyle[1]))
            cText := IIf(l1, ::aItems[nCurr, 1], ::aItems[nCurr])
            IF lVertical
               oStyle:Draw(hDC, 0, y1, nW, y1 + nItemSize)
               IF !Empty(cText)
                  hwg_SetTextColor(hDC, ::tcolor)
                  hwg_Settransparentmode(hDC, .T.)
                  hwg_Drawtext(hDC, cText, 4, y1 + 4, nW - 4, y1 + nItemSize - 4, DT_LEFT + DT_VCENTER + DT_SINGLELINE)
               ENDIF
            ELSE
               oStyle:Draw(hDC, y1, 0, y1 + nItemSize, nW)
               IF !Empty(cText)
                  hwg_SetTextColor(hDC, ::tcolor)
                  hwg_Settransparentmode(hDC, .T.)
                  hwg_Drawtext(hDC, cText, y1 + 4, 4, y1 + nItemSize - 4, nW - 4, DT_CENTER + DT_VCENTER + DT_SINGLELINE)
               ENDIF
            ENDIF
            hwg_Settransparentmode(hDC, .F.)
            IF l1 .AND. Len(::aItems[nCurr]) > 1 .AND. !Empty(ob := ::aItems[nCurr, 2])
               ob:Draw(hDC, Int((nW - ob:nWidth) / 2), Int((nItemSize - ob:nHeight) / 2), ob:nWidth, ob:nHeight)
            ENDIF
            y1 += nItemSize
            i++
         ENDDO
         IF y1 < nLength
            IF lVertical
               aItemStyle[1]:Draw(hDC, 0, y1, nW, nLength)
            ELSE
               aItemStyle[1]:Draw(hDC, y1, 0, nLength, nW)
            ENDIF
         ENDIF
         IF ::lDrawNext
            hwg_Selectobject(hDC, ::oPen:handle)
            i := Int(nw / 2)
            IF ::nShift > 0
               IF lVertical
                  hwg_Rectangle(hDC, i - 1, 1, i, 2)
                  hwg_Rectangle(hDC, i - 7, 1, i - 6, 2)
                  hwg_Rectangle(hDC, i + 6, 1, i + 7, 2)
               ELSE
                  hwg_Rectangle(hDC, 1, i - 1, 2, i)
                  hwg_Rectangle(hDC, 1, i - 7, 2, i - 6)
                  hwg_Rectangle(hDC, 1, i + 6, 2, i + 7)
               ENDIF
            ENDIF
            IF nCurr < Len(::aItems)
               IF lVertical
                  hwg_Rectangle(hDC, i - 1, nLength - 3, i, nLength - 2)
                  hwg_Rectangle(hDC, i - 7, nLength - 3, i - 6, nLength - 2)
                  hwg_Rectangle(hDC, i + 6, nLength - 3, i + 7, nLength - 2)
               ELSE
                  hwg_Rectangle(hDC, nLength - 1, i - 1, nLength - 3, i)
                  hwg_Rectangle(hDC, nLength - 1, i - 7, nLength - 3, i - 6)
                  hwg_Rectangle(hDC, nLength - 1, i + 6, nLength - 3, i + 7)
               ENDIF
            ENDIF
         ENDIF
      ENDIF

   ENDIF

#ifdef __PLATFORM__UNIX
      hwg_Releasedc(::handle, hDC)
#else
      hwg_Endpaint(::handle, pps)
#endif

   RETURN NIL

METHOD HLenta:Drag(xPos, yPos)

   LOCAL nLength := IIf(::lVertical, ::nHeight, ::nWidth)
   LOCAL nKolItems := Len(::aItems)
   
   //hwg_Writelog("   " + Ltrim(Str(yPos)) + " " + Ltrim(Str(::yPos)) + " " + Ltrim(Str(::nShift)))
   IF nLength < ::nItemSize * nKolItems - 4 .AND. ((::lVertical .AND. Abs(yPos - ::yPos) > 2) .OR. (!::lVertical .AND. Abs(xPos - ::xPos) > 2))
      ::lMoved := .T.
      ::nOver := 0
      ::nShift += Int(IIf(::lVertical, (::yPos - yPos), (::xPos - xPos)) * ::nDragKoef)
      ::xPos := xPos; ::yPos := yPos
      IF ::nShift < 0
         ::nShift := 0
      ELSEIF ::nShift + nLength > Int(nKolItems * ::nItemSize) + 2
         ::nShift := Max(0, Int(nKolItems * ::nItemSize) - nLength + 2)
      ENDIF
      ::nFirst := Int(::nShift/::nItemSize)
      ::nFirst += IIf(::nShift > ::nFirst * ::nItemSize, 2, 1)
      //hwg_Writelog(Ltrim(Str(::nShift)) + " " + Ltrim(Str(::nFirst)))
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
   ENDIF

   RETURN NIL

METHOD HLenta:Value(nValue)

   IF nValue != NIL .AND. nValue >= 0 .AND. !Empty(::aItems) .AND. nValue <= Len(::aItems)
      ::nSelected := nValue
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
   ELSE
      nValue := ::nSelected
   ENDIF

   RETURN nValue
