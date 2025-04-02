//
// HWGUI - Harbour Win32 GUI library source code:
// HPanel class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include "windows.ch"
#include <hbclass.ch>
#include "guilib.ch"

CLASS HPanelStS INHERIT HPANEL

   DATA aParts
   DATA aText

   METHOD New(oWndParent, nId, nHeight, oFont, bInit, bPaint, bcolor, oStyle, aParts)
   METHOD Write(cText, nPart, lRedraw)
   METHOD SetText(cText) INLINE ::Write(cText, NIL, .T.)
   METHOD PaintText(hDC)
   METHOD Paint()

ENDCLASS

METHOD HPanelStS:New(oWndParent, nId, nHeight, oFont, bInit, bPaint, bcolor, oStyle, aParts)

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

METHOD HPanelStS:Write(cText, nPart, lRedraw)

   ::aText[Iif(nPart==NIL, 1, nPart)] := cText
   IF !HB_ISLOGICAL(lRedraw) .OR. lRedraw
      hwg_Invalidaterect(::handle, 0)
   ENDIF

RETURN NIL

METHOD HPanelStS:PaintText(hDC)

   LOCAL i
   LOCAL x1
   LOCAL x2
   LOCAL nWidth := ::nWidth
   LOCAL oldTColor

   IF ::oFont != NIL
      hwg_Selectobject(hDC, ::oFont:handle)
   ENDIF
   hwg_Settransparentmode(hDC, .T.)
   oldTColor := hwg_Settextcolor(hDC, ::tcolor)
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

METHOD HPanelStS:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL block
   LOCAL aCoors

   IF hb_IsBlock(::bPaint)
      RETURN Eval(::bPaint, Self)
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)

   IF hb_IsBlock(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
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
