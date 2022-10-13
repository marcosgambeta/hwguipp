/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HPen class
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

CLASS HPen INHERIT HObject

   CLASS VAR aPens   INIT { }
   DATA handle
   DATA style, width, color
   DATA nCounter   INIT 1

   METHOD Add(nStyle, nWidth, nColor)
   METHOD Get(nStyle, nWidth, nColor)
   METHOD RELEASE()

ENDCLASS

METHOD Add(nStyle, nWidth, nColor) CLASS HPen
   
   LOCAL i

   nStyle := iif(nStyle == NIL, BS_SOLID, nStyle)
   nWidth := iif(nWidth == NIL, 1, nWidth)
   IF nStyle != BS_SOLID
      nWidth := 1
   ENDIF
   nColor := iif(nColor == NIL, 0, nColor)

   FOR EACH i IN ::aPens
      IF i:style == nStyle .AND. i:width == nWidth .AND. i:color == nColor
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   ::handle := hwg_Createpen(nStyle, nWidth, nColor)
   ::style  := nStyle
   ::width  := nWidth
   ::color  := nColor
   AAdd(::aPens, Self)

   RETURN Self

METHOD Get(nStyle, nWidth, nColor) CLASS HPen
   
   LOCAL i

   nStyle := iif(nStyle == NIL, PS_SOLID, nStyle)
   nWidth := iif(nWidth == NIL, 1, nWidth)
   IF nStyle != BS_SOLID
      nWidth := 1
   ENDIF
   nColor := iif(nColor == NIL, 0, nColor)

   FOR EACH i IN ::aPens
      IF i:style == nStyle .AND. i:width == nWidth .AND. i:color == nColor
         RETURN i
      ENDIF
   NEXT

   RETURN NIL

METHOD RELEASE() CLASS HPen
   
   LOCAL i
   LOCAL nlen := Len(::aPens)

   ::nCounter--
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      FOR EACH i  IN ::aPens
         IF i:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aPens, hb_EnumIndex())
            ASize(::aPens, nlen - 1)
            EXIT
         ENDIF
      NEXT
#else
      FOR i := 1 TO nlen
         IF ::aPens[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aPens, i)
            ASize(::aPens, nlen - 1)
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN NIL
