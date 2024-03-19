/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HStyle class
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

CLASS HStyle INHERIT HObject

   CLASS VAR aStyles INIT {}

   DATA id
   DATA nOrient
   DATA aColors
   DATA oBitmap
   DATA nBorder
   DATA tColor
   DATA oPen
   DATA aCorners

   METHOD New(aColors, nOrient, aCorners, nBorder, tColor, oBitmap)
   METHOD Draw(hDC, nLeft, nTop, nRight, nBottom)
ENDCLASS

METHOD HStyle:New(aColors, nOrient, aCorners, nBorder, tColor, oBitmap)

   LOCAL i
   LOCAL nlen := Len(::aStyles)

   nBorder := Iif(nBorder == NIL, 0, nBorder)
   tColor := Iif(tColor == NIL, 0, tColor)
   nOrient := Iif(nOrient == NIL .OR. nOrient > 9, 1, nOrient)

   FOR i := 1 TO nlen
      IF hwg_aCompare(::aStyles[i]:aColors, aColors) .AND. ;
         hwg_aCompare(::aStyles[i]:aCorners, aCorners) .AND. ;
         Valtype(::aStyles[i]:tColor) == Valtype(tColor) .AND. ;
         ::aStyles[i]:nBorder == nBorder .AND. ;
         ::aStyles[i]:tColor == tColor .AND. ;
         ::aStyles[i]:nOrient == nOrient .AND. ;
         ((::aStyles[i]:oBitmap == NIL .AND. oBitmap == NIL) .OR. ;
         (::aStyles[i]:oBitmap != NIL .AND. oBitmap != NIL .AND. ::aStyles[i]:oBitmap:name == oBitmap:name))
         RETURN ::aStyles[i]
      ENDIF
   NEXT

   ::aColors := aColors
   ::nOrient := nOrient
   ::nBorder := nBorder
   ::tColor := tColor
   ::aCorners := aCorners
   ::oBitmap := oBitmap
   IF nBorder > 0
      ::oPen := HPen():Add(BS_SOLID, nBorder, tColor)
   ENDIF

   AAdd(::aStyles, Self)
   ::id := Len(::aStyles)

   RETURN Self

METHOD HStyle:Draw(hDC, nLeft, nTop, nRight, nBottom)

   LOCAL n1
   LOCAL n2
   
   IF ::oBitmap == NIL
      hwg_drawGradient(hDC, nLeft, nTop, nRight, nBottom, ::nOrient, ::aColors, NIL, ::aCorners)
   ELSE
      hwg_SpreadBitmap(hDC, ::oBitmap:handle, nLeft, nTop, nRight, nBottom)
   ENDIF
   IF !Empty(::oPen)
      n2 := ::nBorder/2
      n1 := Int(n2)
      IF n2 - n1 > 0.1
         n2 := n1 + 1
      ENDIF
      hwg_Selectobject(hDC, ::oPen:handle)
      hwg_Rectangle(hDC, nLeft + n1, nTop + n1, nRight - n2, nBottom - n2)
   ENDIF

   RETURN NIL
