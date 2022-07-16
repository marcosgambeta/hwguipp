/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HControl class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HControl INHERIT HCustomWindow

   DATA   id
   DATA   tooltip
   DATA   lInit      INIT .F.
   DATA   Anchor     INIT 0

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)

   METHOD NewId()
   METHOD Init()

   METHOD Disable()
   METHOD Enable()
   METHOD Enabled( lEnabled ) SETGET
   METHOD Setfocus()    INLINE (hwg_Sendmessage(::oParent:handle, WM_NEXTDLGCTL, ::handle, 1), hwg_Setfocus(::handle))
   METHOD GetText()     INLINE hwg_Getwindowtext( ::handle )
   METHOD SetText( c )  INLINE hwg_Setwindowtext( ::Handle, ::title := c )
   METHOD End()
   METHOD onAnchor( x, y, w, h )

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor) CLASS HControl

   ::oParent := iif( oWndParent == NIL, ::oDefaultParent, oWndParent )
   ::id      := iif( nId == NIL, ::NewId(), nId )
   ::style   := Hwg_BitOr(iif(nStyle == NIL, 0, nStyle), WS_VISIBLE + WS_CHILD)
   ::oFont   := oFont
   ::nLeft   := nLeft
   ::nTop    := nTop
   ::nWidth  := nWidth
   ::nHeight := nHeight
   ::bInit   := bInit
   IF ValType( bSize ) == "N"
      ::Anchor := bSize
   ELSE
      ::bSize   := bSize
   ENDIF
   ::bPaint  := bPaint
   ::tooltip := cTooltip
   ::Setcolor( tcolor, bColor )

   ::oParent:AddControl( Self )

   RETURN Self

METHOD NewId() CLASS HControl
   LOCAL nId := ::oParent:nChildId ++

   RETURN nId

METHOD INIT() CLASS HControl

   IF !::lInit
      IF ::tooltip != Nil
         hwg_Addtooltip( ::handle, ::tooltip )
      ENDIF
      IF ::oFont != Nil
         hwg_Setctrlfont( ::oParent:handle, ::id, ::oFont:handle )
      ELSEIF ::oParent:oFont != Nil
         ::oFont := ::oParent:oFont
         hwg_Setctrlfont( ::oParent:handle, ::id, ::oParent:oFont:handle )
      ENDIF
      IF HB_ISBLOCK( ::bInit )
         Eval(::bInit, Self)
      ENDIF
      ::lInit := .T.
   ENDIF

   RETURN NIL

METHOD Disable() CLASS HControl

   hwg_Enablewindow( ::handle, .F. )

   RETURN NIL

METHOD Enable() CLASS HControl

   hwg_Enablewindow( ::handle, .T. )

   RETURN NIL

METHOD Enabled( lEnabled ) CLASS HControl

   IF lEnabled != Nil
      IF lEnabled
         hwg_Enablewindow( ::handle, .T. )
         RETURN .T.
      ELSE
         hwg_Enablewindow( ::handle, .F. )
         RETURN .F.
      ENDIF
   ENDIF

   RETURN hwg_Iswindowenabled( ::handle )

METHOD End() CLASS HControl

   ::Super:End()

   IF ::tooltip != NIL
      hwg_Deltooltip( ::handle )
      ::tooltip := NIL
   ENDIF

   RETURN NIL

METHOD onAnchor( x, y, w, h ) CLASS HControl
   LOCAL nAnchor, nXincRelative, nYincRelative, nXincAbsolute, nYincAbsolute
   LOCAL x1, y1, w1, h1, x9, y9, w9, h9

   // LOCAL nCxv, nCyh   && not used variables

   // hwg_writelog( "onAnchor "+::classname()+str(x)+"/"+str(y)+"/"+str(w)+"/"+str(h) )
   nAnchor := ::anchor
   x9 := x1 := ::nLeft
   y9 := y1 := ::nTop
   w9 := w1 := ::nWidth
   h9 := h1 := ::nHeight
   // *- calculo relativo
   nXincRelative := iif( x > 0, w / x, 1 )
   nYincRelative := iif( y > 0, h / y, 1 )
   // *- calculo ABSOLUTE
   nXincAbsolute := ( w - x )
   nYincAbsolute := ( h - y )
   IF nAnchor >= ANCHOR_VERTFIX
      // *- vertical fixed center
      nAnchor -= ANCHOR_VERTFIX
      y1 := y9 + Round( ( h - y ) * ( ( y9 + h9 / 2 ) / y ), 2 )
   ENDIF
   IF nAnchor >= ANCHOR_HORFIX
      // *- horizontal fixed center
      nAnchor -= ANCHOR_HORFIX
      x1 := x9 + Round( ( w - x ) * ( ( x9 + w9 / 2 ) / x ), 2 )
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTREL
      // relative - RIGHT RELATIVE
      nAnchor -= ANCHOR_RIGHTREL
      x1 := w - Round( ( x - x9 - w9 ) * nXincRelative, 2 ) - w9
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMREL
      // relative - BOTTOM RELATIVE
      nAnchor -= ANCHOR_BOTTOMREL
      y1 := h - Round( ( y - y9 - h9 ) * nYincRelative, 2 ) - h9
   ENDIF
   IF nAnchor >= ANCHOR_LEFTREL
      // relative - LEFT RELATIVE
      nAnchor -= ANCHOR_LEFTREL
      IF x1 != x9
         w1 := x1 - ( Round( x9 * nXincRelative, 2 ) ) + w9
      ENDIF
      x1 := Round( x9 * nXincRelative, 2 )
   ENDIF
   IF nAnchor >= ANCHOR_TOPREL
      // relative  - TOP RELATIVE
      nAnchor -= ANCHOR_TOPREL
      IF y1 != y9
         h1 := y1 - ( Round( y9 * nYincRelative, 2 ) ) + h9
      ENDIF
      y1 := Round( y9 * nYincRelative, 2 )
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTABS
      // Absolute - RIGHT ABSOLUTE
      nAnchor -= ANCHOR_RIGHTABS
      IF HWG_BITAND( ::Anchor, ANCHOR_LEFTREL ) != 0
         w1 := Int( nxIncAbsolute ) - ( x1 - x9 ) + w9
      ELSE
         IF x1 != x9
            w1 := x1 - ( x9 +  Int( nXincAbsolute ) ) + w9
         ENDIF
         x1 := x9 +  Int( nXincAbsolute )
      ENDIF
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMABS
      // Absolute - BOTTOM ABSOLUTE
      nAnchor -= ANCHOR_BOTTOMABS
      IF HWG_BITAND( ::Anchor, ANCHOR_TOPREL ) != 0
         h1 := Int( nyIncAbsolute ) - ( y1 - y9 ) + h9
      ELSE
         IF y1 != y9
            h1 := y1 - ( y9 +  Int( nYincAbsolute ) ) + h9
         ENDIF
         y1 := y9 +  Int( nYincAbsolute )
      ENDIF
   ENDIF
   IF nAnchor >= ANCHOR_LEFTABS
      // Absolute - LEFT ABSOLUTE
      nAnchor -= ANCHOR_LEFTABS
      IF x1 != x9
         w1 := x1 - x9 + w9
      ENDIF
      x1 := x9
   ENDIF
   IF nAnchor >= ANCHOR_TOPABS
      // Absolute - TOP ABSOLUTE
      IF y1 != y9
         h1 := y1 - y9 + h9
      ENDIF
      y1 := y9
   ENDIF
   // REDRAW AND INVALIDATE SCREEN
   IF ( x1 != X9 .OR. y1 != y9 .OR. w1 != w9 .OR. h1 != h9 )
      ::Move( x1, y1, w1, h1 )
      RETURN .T.
   ENDIF

   RETURN .F.

FUNCTION hwg_SetCtrlName( oCtrl, cName )
   LOCAL nPos

   IF !Empty(cName) .AND. ValType( cName ) == "C" .AND. !( "[" $ cName )
      IF ( nPos :=  RAt( ":", cName ) ) > 0 .OR. ( nPos :=  RAt( ">", cName ) ) > 0
         cName := SubStr( cName, nPos + 1 )
      ENDIF
      oCtrl:objName := Upper( cName )
   ENDIF

   RETURN Nil
