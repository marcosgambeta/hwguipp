/*
 *$Id: hcontrol.prg 2968 2021-04-09 06:13:17Z alkresin $
 *
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HStatus class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HStatus INHERIT HControl

   CLASS VAR winclass   INIT "msctls_statusbar32"
   DATA aParts
   METHOD New( oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint )
   METHOD Activate()
   METHOD Init()
   METHOD SetText( t ) INLINE  hwg_WriteStatus( ::oParent,, t )

ENDCLASS

METHOD New( oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint ) CLASS HStatus

   nStyle := hb_bitor( iif( nStyle == NIL,0,nStyle ), WS_CHILD + WS_VISIBLE + WS_OVERLAPPED + WS_CLIPSIBLINGS )
   ::Super:New( oWndParent, nId, nStyle, 0, 0, 0, 0, oFont, bInit, bSize, bPaint )

   ::aParts  := aParts
   ::Activate()

   RETURN Self

METHOD Activate() CLASS HStatus
   * Variables not used
   * LOCAL aCoors

   IF !Empty(::oParent:handle)

      ::handle := hwg_Createstatuswindow( ::oParent:handle, ::id )

      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HStatus

   IF !::lInit
      ::Super:Init()
   ENDIF

   RETURN  NIL
