/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HControl class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

REQUEST HWG_ENDWINDOW

#define  CONTROL_FIRST_ID   34000

Function hwg_SetCtrlName( oCtrl, cName )
   
   LOCAL nPos

   IF !Empty(cName) .AND. HB_ISCHAR(cName) .AND. !("[" $ cName)
      IF ( nPos :=  RAt(":", cName) ) > 0 .OR. ( nPos :=  RAt(">", cName) ) > 0
         cName := SubStr(cName, nPos + 1)
      ENDIF
      oCtrl:objName := Upper(cName)
      IF __ObjHasMsg( oCtrl, "ODEFAULTPARENT" )
         hwg_SetWidgetName( oCtrl:handle, oCtrl:objName )
      ENDIF
   ENDIF

   RETURN NIL

   //- HControl

CLASS HControl INHERIT HCustomWindow

   DATA id
   DATA tooltip
   DATA lInit INIT .F.
   DATA Anchor INIT 0

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctoolt, tcolor, bcolor)
   METHOD Init()
   METHOD NewId()

   METHOD Disable()
   METHOD Enable()
   METHOD Enabled( lEnabled )

   METHOD Setfocus() INLINE hwg_SetFocus(::handle)
   METHOD Move( x1, y1, width, height, lMoveParent )
   METHOD onAnchor( x, y, w, h )
   METHOD End()

ENDCLASS

METHOD HControl:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctoolt, tcolor, bcolor)

   ::oParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id := iif(nId == NIL, ::NewId(), nId)
   ::style := hb_bitor( iif(nStyle == NIL,0,nStyle ), WS_VISIBLE + WS_CHILD)
   ::oFont := oFont
   ::nX := nX
   ::nY := nY
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::bInit := bInit
   IF HB_ISNUMERIC(bSize)
      ::Anchor := bSize
   ELSE
      ::bSize := bSize
   ENDIF
   ::bPaint := bPaint
   ::tooltip := ctoolt
   ::tColor := tColor
   ::bColor := bColor

   ::oParent:AddControl( Self )

   RETURN Self

/* Removed:  lDop  */
METHOD HControl:NewId()

   LOCAL nId := ::oParent:nChildId++

RETURN nId

METHOD HControl:INIT()

   LOCAL o

   IF !::lInit
      IF ::oFont != NIL
         hwg_SetCtrlFont(::handle, NIL, ::oFont:handle)
      ELSEIF ::oParent:oFont != NIL
         ::oFont := ::oParent:oFont
         hwg_SetCtrlFont(::handle, NIL, ::oParent:oFont:handle)
      ENDIF
      hwg_Addtooltip(::handle, ::tooltip)
      IF hb_IsBlock(::bInit)
         Eval(::bInit, Self)
      ENDIF
      ::Setcolor(::tcolor, ::bcolor)

      IF ( o := hwg_getParentForm( Self ) ) != NIL .AND. o:lActivated
         hwg_ShowAll( o:handle )
         hwg_HideHidden( o )
      ENDIF
      ::lInit := .T.
   ENDIF

   RETURN NIL

METHOD HControl:Disable()

   hwg_Enablewindow(::handle, .F.)
RETURN NIL

METHOD HControl:Enable()

   hwg_Enablewindow(::handle, .T.)
RETURN NIL

METHOD HControl:Enabled( lEnabled )

   IF lEnabled != NIL
      IF lEnabled
         hwg_Enablewindow(::handle, .T.)
         RETURN .T.
      ELSE
         hwg_Enablewindow(::handle, .F.)
         RETURN .F.
      ENDIF
   ENDIF

   RETURN hwg_Iswindowenabled(::handle)

/* Added: lMoveParent */
METHOD HControl:Move( x1, y1, width, height, lMoveParent )
   
   LOCAL lMove := .F.
   LOCAL lSize := .F.

   IF x1 != NIL .AND. x1 != ::nX
      ::nX := x1
      lMove := .T.
   ENDIF
   IF y1 != NIL .AND. y1 != ::nY
      ::nY := y1
      lMove := .T.
   ENDIF
   IF width != NIL .AND. width != ::nWidth
      ::nWidth := width
      lSize := .T.
   ENDIF
   IF height != NIL .AND. height != ::nHeight
      ::nHeight := height
      lSize := .T.
   ENDIF
   IF lMove .OR. lSize
      hwg_MoveWidget(::handle, iif(lMove, ::nX, NIL), iif(lMove, ::nY, NIL), iif(lSize, ::nWidth, NIL), iif(lSize, ::nHeight, NIL), lMoveParent)
   ENDIF

   RETURN NIL

METHOD HControl:End()

   ::Super:End()
   IF ::tooltip != NIL
      // DelToolTip(::oParent:handle, ::handle)
      ::tooltip := NIL
   ENDIF

   RETURN NIL

METHOD HControl:onAnchor( x, y, w, h )
   
   LOCAL nAnchor
   LOCAL nXincRelative
   LOCAL nYincRelative
   LOCAL nXincAbsolute
   LOCAL nYincAbsolute
   LOCAL x1
   LOCAL y1
   LOCAL w1
   LOCAL h1
   LOCAL x9
   LOCAL y9
   LOCAL w9
   LOCAL h9

   nAnchor := ::anchor
   x9 := ::nX
   y9 := ::nY
   w9 := ::nWidth
   h9 := ::nHeight

   x1 := ::nX
   y1 := ::nY
   w1 := ::nWidth
   h1 := ::nHeight
   //- calculo relativo
   nXincRelative :=  w / x
   nYincRelative :=  h / y
   //- calculo ABSOLUTE
   nXincAbsolute := ( w - x )
   nYincAbsolute := ( h - y )

   IF nAnchor >= ANCHOR_VERTFIX
      //- vertical fixed center
      nAnchor := nAnchor - ANCHOR_VERTFIX
      y1 := y9 + Int( ( h - y ) * ( ( y9 + h9 / 2 ) / y ) )
   ENDIF
   IF nAnchor >= ANCHOR_HORFIX
      //- horizontal fixed center
      nAnchor := nAnchor - ANCHOR_HORFIX
      x1 := x9 + Int( ( w - x ) * ( ( x9 + w9 / 2 ) / x ) )
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTREL
      // relative - RIGHT RELATIVE
      nAnchor := nAnchor - ANCHOR_RIGHTREL
      x1 := w - Int( ( x - x9 - w9 ) * nXincRelative ) - w9
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMREL
      // relative - BOTTOM RELATIVE
      nAnchor := nAnchor - ANCHOR_BOTTOMREL
      y1 := h - Int( ( y - y9 - h9 ) * nYincRelative ) - h9
   ENDIF
   IF nAnchor >= ANCHOR_LEFTREL
      // relative - LEFT RELATIVE
      nAnchor := nAnchor - ANCHOR_LEFTREL
      IF x1 != x9
         w1 := x1 - ( Int( x9 * nXincRelative ) ) + w9
      ENDIF
      x1 := Int( x9 * nXincRelative )
   ENDIF
   IF nAnchor >= ANCHOR_TOPREL
      // relative  - TOP RELATIVE
      nAnchor := nAnchor - ANCHOR_TOPREL
      IF y1 != y9
         h1 := y1 - ( Int( y9 * nYincRelative ) ) + h9
      ENDIF
      y1 := Int( y9 * nYincRelative )
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTABS
      // Absolute - RIGHT ABSOLUTE
      nAnchor := nAnchor - ANCHOR_RIGHTABS
      IF x1 != x9
         w1 := x1 - ( x9 +  Int( nXincAbsolute ) ) + w9
      ENDIF
      x1 := x9 +  Int( nXincAbsolute )
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMABS
      // Absolute - BOTTOM ABSOLUTE
      nAnchor := nAnchor - ANCHOR_BOTTOMABS
      IF y1 != y9
         h1 := y1 - ( y9 +  Int( nYincAbsolute ) ) + h9
      ENDIF
      y1 := y9 +  Int( nYincAbsolute )
   ENDIF
   IF nAnchor >= ANCHOR_LEFTABS
      // Absolute - LEFT ABSOLUTE
      nAnchor := nAnchor - ANCHOR_LEFTABS
      IF x1 != x9
         w1 := x1 - x9 + w9
      ENDIF
      x1 := x9
   ENDIF
   IF nAnchor >= ANCHOR_TOPABS
      // Absolute - TOP ABSOLUTE
      //nAnchor := nAnchor - 1
      IF y1 != y9
         h1 := y1 - y9 + h9
      ENDIF
      y1 := y9
   ENDIF
   hwg_Invalidaterect(::oParent:handle, 1, ::nX, ::nY, ::nWidth, ::nHeight)
   ::Move( x1, y1, w1, h1 )
   ::nX := x1
   ::nY := y1
   ::nWidth := w1
   ::nHeight := h1
   hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)

   RETURN NIL
