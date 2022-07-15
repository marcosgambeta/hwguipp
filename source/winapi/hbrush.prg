/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HBrush class
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

CLASS HBrush INHERIT HObject

   CLASS VAR aBrushes   INIT { }
   DATA handle
   DATA COLOR
   DATA nHatch   INIT 99
   DATA nCounter INIT 1

   METHOD Add( nColor, nHatch )
   METHOD RELEASE()

ENDCLASS

METHOD Add( nColor, nHatch ) CLASS HBrush
   LOCAL i

   IF nHatch == Nil
      nHatch := 99
   ENDIF

   FOR EACH i IN ::aBrushes

      IF i:color == nColor .AND. i:nHatch == nHatch
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT

   IF nHatch != 99
      ::handle := hwg_Createhatchbrush( nHatch, nColor )
   ELSE
      ::handle := hwg_Createsolidbrush( nColor )
   ENDIF
   ::color  := nColor
   AAdd( ::aBrushes, Self )

   RETURN Self

METHOD RELEASE() CLASS HBrush
   LOCAL i, nlen := Len( ::aBrushes )

   ::nCounter --
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      FOR EACH i IN ::aBrushes
         IF i:handle == ::handle
            hwg_Deleteobject( ::handle )
            ADel( ::aBrushes, hb_enumindex() )
            ASize( ::aBrushes, nlen - 1 )
            EXIT
         ENDIF
      NEXT
#else
      FOR i := 1 TO nlen
         IF ::aBrushes[i]:handle == ::handle
            hwg_Deleteobject( ::handle )
            ADel( ::aBrushes, i )
            ASize( ::aBrushes, nlen - 1 )
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN Nil
