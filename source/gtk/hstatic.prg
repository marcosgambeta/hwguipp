/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HStatic class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HStatic INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"

   METHOD New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
      bSize, bPaint, ctoolt, tcolor, bcolor, lTransp )
   METHOD Activate()
   METHOD Init()
   METHOD SetText( value ) INLINE hwg_static_SetText( ::handle, ::title := value )
   METHOD GetText() INLINE hwg_static_GetText( ::handle )

ENDCLASS

METHOD New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
      bSize, bPaint, ctoolt, tcolor, bcolor, lTransp ) CLASS HStatic

   ::Super:New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
      bSize, bPaint, ctoolt, tcolor, bcolor )

   ::title   := cCaption
   IF lTransp != NIL .AND. lTransp
      ::extStyle += WS_EX_TRANSPARENT
   ENDIF

   ::Activate()

   RETURN Self

METHOD Activate() CLASS HStatic

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic( ::oParent:handle, ::id, ;
         ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::extStyle, ::title )
      IF hb_bitand( ::style, SS_OWNERDRAW ) != 0
         hwg_Setwindowobject( ::handle, Self )
      ENDIF
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init()  CLASS HStatic

   IF !::lInit
      ::Super:Init()
   ENDIF
   RETURN NIL
