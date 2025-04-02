//
// HWGUI - Harbour Win32 GUI library source code:
// HBrush class
//
// Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HBrush INHERIT HObject

   CLASS VAR aBrushes INIT {}
   DATA handle
   DATA COLOR
   DATA nHatch INIT 99
   DATA nCounter INIT 1

   METHOD Add(nColor, nHatch)
   METHOD RELEASE()

ENDCLASS

METHOD HBrush:Add(nColor, nHatch)
   
   LOCAL i

   IF nHatch == NIL
      nHatch := 99
   ENDIF

   FOR EACH i IN ::aBrushes

      IF i:color == nColor .AND. i:nHatch == nHatch
         i:nCounter++
         RETURN i
      ENDIF
   NEXT

   IF nHatch != 99
      ::handle := hwg_Createhatchbrush(nHatch, nColor)
   ELSE
      ::handle := hwg_Createsolidbrush(nColor)
   ENDIF
   ::color := nColor
   AAdd(::aBrushes, Self)

   RETURN Self

METHOD HBrush:RELEASE()
   
   LOCAL i
   LOCAL nlen := Len(::aBrushes)

   ::nCounter--
   IF ::nCounter == 0
      FOR i := 1 TO nlen // TODO: FOR EACH
         IF ::aBrushes[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aBrushes, i)
            ASize(::aBrushes, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN NIL
