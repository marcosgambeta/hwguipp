/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HSayIcon class
 *
 * Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "hwgui.ch"

CLASS HSayIcon INHERIT HSayImage

   METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctoolt )

ENDCLASS

METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctoolt ) CLASS HSayIcon

   ::Super:New( oWndParent, nId, SS_ICON, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctoolt )

   IF lRes == NIL
      lRes := .F.
   ENDIF
   ::oImage := iif( lRes .OR. ValType( Image ) == "N", ;
      HIcon():AddResource( Image , nWidth, nHeight ),  ;
      iif( ValType( Image ) == "C",  ;
      HIcon():AddFile( Image , nWidth, nHeight ), Image ) )
   ::Activate()

   RETURN Self
