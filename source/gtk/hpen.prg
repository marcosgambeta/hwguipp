/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * Pens, brushes, fonts, bitmaps, icons handling
 *
 * Copyright 2005 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

CLASS HPen INHERIT HObject

   CLASS VAR aPens INIT {}

   DATA handle
   DATA style
   DATA width
   DATA color
   DATA nCounter INIT 1

   METHOD Add( nStyle, nWidth, nColor )
   METHOD Get( nStyle, nWidth, nColor )
   METHOD RELEASE()

ENDCLASS

METHOD HPen:Add( nStyle, nWidth, nColor )
   
   LOCAL i

   nStyle := iif(nStyle == NIL, PS_SOLID, nStyle)
   nWidth := iif(nWidth == NIL, 1, nWidth)
   IF nStyle != PS_SOLID
      nWidth := 1
   ENDIF
   nColor := iif(nColor == NIL, 0, nColor)

   For EACH i in ::aPens
      IF i:style == nStyle .AND. ;
            i:width == nWidth .AND. ;
            i:color == nColor

         i:nCounter ++
         RETURN i
      ENDIF
   NEXT

   ::handle := hwg_Createpen( nStyle, nWidth, nColor )
   ::style := nStyle
   ::width := nWidth
   ::color := nColor
   AAdd(::aPens, Self)

   RETURN Self

METHOD HPen:Get( nStyle, nWidth, nColor )
   
   LOCAL i

   nStyle := iif(nStyle == NIL, PS_SOLID, nStyle)
   nWidth := iif(nWidth == NIL, 1, nWidth)
   IF nStyle != PS_SOLID
      nWidth := 1
   ENDIF
   nColor := iif(nColor == NIL, 0, nColor)

   For EACH i in ::aPens
      IF i:style == nStyle .AND. ;
            i:width == nWidth .AND. ;
            i:color == nColor

         RETURN i
      ENDIF
   NEXT

   RETURN NIL

METHOD HPen:RELEASE()
   
   LOCAL i
   LOCAL nlen := Len(::aPens)

   ::nCounter --
   IF ::nCounter == 0
      For i := 1 TO nlen // TODO: FOR EACH
         IF ::aPens[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aPens, i)
            ASize(::aPens, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN NIL
