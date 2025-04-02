//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HStatus class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include "windows.ch"
#include <hbclass.ch>
#include "guilib.ch"

CLASS HStatus INHERIT HControl

   CLASS VAR winclass INIT "msctls_statusbar32"

   DATA aParts

   METHOD New( oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint )
   METHOD Activate()
   METHOD Init()
   METHOD SetText( t ) INLINE  hwg_WriteStatus(::oParent, NIL, t)

ENDCLASS

METHOD HStatus:New( oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint )

   nStyle := hb_bitor( iif(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + WS_OVERLAPPED + WS_CLIPSIBLINGS )
   ::Super:New( oWndParent, nId, nStyle, 0, 0, 0, 0, oFont, bInit, bSize, bPaint )

   ::aParts := aParts
   ::Activate()

   RETURN Self

METHOD HStatus:Activate()

   // Variables not used
   // LOCAL aCoors

   IF !Empty(::oParent:handle)

      ::handle := hwg_Createstatuswindow(::oParent:handle, ::id)

      ::Init()
   ENDIF

   RETURN NIL

METHOD HStatus:Init()

   IF !::lInit
      ::Super:Init()
   ENDIF

   RETURN  NIL
