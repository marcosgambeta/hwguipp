//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HLine class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HLine INHERIT HControl

   CLASS VAR winclass INIT "STATIC"

   DATA lVert

   METHOD New(oWndParent, nId, lVert, nX, nY, nLength, bSize)
   METHOD Activate()

ENDCLASS

METHOD HLine:New(oWndParent, nId, lVert, nX, nY, nLength, bSize)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nX, nY, NIL, NIL, NIL, NIL, bSize, {|o, lp|o:Paint(lp)})

   ::title := ""
   ::lVert := IIf(lVert == NIL, .F. , lVert)
   IF ::lVert
      ::nWidth := 10
      ::nHeight := IIf(nLength == NIL, 20, nLength)
   ELSE
      ::nWidth := IIf(nLength == NIL, 20, nLength)
      ::nHeight := 10
   ENDIF

   ::Activate()

   RETURN Self

METHOD HLine:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateSep(::oParent:handle, ::lVert, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL
