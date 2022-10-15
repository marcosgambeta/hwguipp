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

CLASS HBrush INHERIT HObject

   CLASS VAR aBrushes   INIT {}
   DATA handle
   DATA COLOR
   DATA nHatch   INIT 99
   DATA nCounter INIT 1

   METHOD Add( nColor )
   METHOD RELEASE()

ENDCLASS

METHOD Add( nColor ) CLASS HBrush
   
   LOCAL i

   For EACH i IN ::aBrushes
      IF i:color == nColor
         i:nCounter ++
         RETURN i
      ENDIF
   NEXT

   ::handle := hwg_Createsolidbrush( nColor )
   ::color  := nColor
   AAdd(::aBrushes, Self)

   RETURN Self

METHOD RELEASE() CLASS HBrush
   
   LOCAL i
   LOCAL nlen := Len( ::aBrushes )

   ::nCounter --
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      For EACH i IN ::aBrushes
         IF i:handle == ::handle
            hwg_Deleteobject( ::handle )
            ADel( ::aBrushes, hb_EnumIndex() )
            ASize( ::aBrushes, nlen - 1 )
            EXIT
         ENDIF
      NEXT
#else
      For i := 1 TO nlen
         IF ::aBrushes[i]:handle == ::handle
            hwg_Deleteobject( ::handle )
            ADel( ::aBrushes, i )
            ASize( ::aBrushes, nlen - 1 )
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN NIL
