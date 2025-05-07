//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HSayIcon class
//
// Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HSayIcon INHERIT HSayImage

   METHOD New( oWndParent, nId, nX, nY, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctoolt )

ENDCLASS

METHOD HSayIcon:New( oWndParent, nId, nX, nY, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctoolt )

   ::Super:New( oWndParent, nId, SS_ICON, nX, nY, nWidth, nHeight, bInit, bSize, ctoolt )

   IF lRes == NIL
      lRes := .F.
   ENDIF
   ::oImage := IIf(lRes .OR. HB_ISNUMERIC(Image), ;
      HIcon():AddResource(Image , nWidth, nHeight),  ;
      IIf(HB_ISCHAR(Image),  ;
      HIcon():AddFile(Image , nWidth, nHeight), Image))
   ::Activate()

   RETURN Self
