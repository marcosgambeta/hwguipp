/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HLine class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HLine INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA lVert

   METHOD New( oWndParent, nId, lVert, nLeft, nTop, nLength, bSize )
   METHOD Activate()

ENDCLASS

METHOD New( oWndParent, nId, lVert, nLeft, nTop, nLength, bSize ) CLASS HLine

   ::Super:New( oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, , , , , bSize, { |o, lp|o:Paint( lp ) } )

   ::title := ""
   ::lVert := iif( lVert == NIL, .F. , lVert )
   IF ::lVert
      ::nWidth  := 10
      ::nHeight := iif( nLength == NIL, 20, nLength )
   ELSE
      ::nWidth  := iif( nLength == NIL, 20, nLength )
      ::nHeight := 10
   ENDIF

   ::Activate()

   RETURN Self

METHOD Activate() CLASS HLine

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateSep( ::oParent:handle, ::lVert, ::nLeft, ::nTop, ;
         ::nWidth, ::nHeight )
      ::Init()
   ENDIF

   RETURN NIL
