//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// Pens, brushes, fonts, bitmaps, icons handling
//
// Copyright 2005 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

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

   METHOD New( aColors, nOrient, aCorners, nBorder, tColor, oBitmap )
   METHOD Draw(hDC, nLeft, nTop, nRight, nBottom)

ENDCLASS

METHOD HStyle:New( aColors, nOrient, aCorners, nBorder, tColor, oBitmap )

   LOCAL i
   LOCAL nlen := Len(::aStyles)

   nBorder := Iif(nBorder == NIL, 0, nBorder)
   tColor := Iif(tColor == NIL, -1, tColor)
   nOrient := Iif(nOrient == NIL .OR. nOrient > 9, 1, nOrient)

   FOR i := 1 TO nlen
      IF hwg_aCompare(::aStyles[i]:aColors, aColors) .AND. ;
         hwg_aCompare(::aStyles[i]:aCorners, aCorners) .AND. ;
         Valtype(::aStyles[i]:tColor) == Valtype(tColor) .AND. ;
         ::aStyles[i]:nBorder == nBorder .AND. ;
         ::aStyles[i]:tColor == tColor .AND. ;
         ::aStyles[i]:nOrient == nOrient .AND. ;
         ( (::aStyles[i]:oBitmap == NIL .AND. oBitmap == NIL) .OR. ;
         (::aStyles[i]:oBitmap != NIL .AND. oBitmap != NIL .AND. ::aStyles[i]:oBitmap:name == oBitmap:name) )

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
      ::oPen := HPen():Add( BS_SOLID, nBorder, tColor )
   ENDIF

   AAdd(::aStyles, Self)
   ::id := Len(::aStyles)

   RETURN Self

METHOD HStyle:Draw(hDC, nLeft, nTop, nRight, nBottom)

   IF ::oBitmap == NIL
      hwg_drawGradient(hDC, nLeft, nTop, nRight, nBottom, ::nOrient, ::aColors,, ::aCorners)
   ELSE
      hwg_SpreadBitmap(hDC, ::oBitmap:handle, nLeft, nTop, nRight, nBottom)
   ENDIF

   IF !Empty(::oPen)
      hwg_Selectobject(hDC, ::oPen:handle)
      hwg_Rectangle(hDC, nLeft, nTop, nRight - 1, nBottom - 1)
   ENDIF

   RETURN NIL
