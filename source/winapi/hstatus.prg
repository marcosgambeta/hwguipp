/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HStatus class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HStatus INHERIT HControl

   CLASS VAR winclass INIT "msctls_statusbar32"

   DATA aParts

   METHOD New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint)
   METHOD Activate()
   METHOD Init()
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aParts)
   METHOD SetText(cText, nPart) INLINE  hwg_WriteStatus(::oParent, nPart, cText)

ENDCLASS

METHOD HStatus:New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint)

   bSize := iif(bSize != NIL, bSize, {|o, x, y|o:Move(0, y - 20, x, 20)})
   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + WS_OVERLAPPED + WS_CLIPSIBLINGS)
   ::Super:New(oWndParent, nId, nStyle, 0, 0, 0, 0, oFont, bInit, bSize, bPaint)

   ::aParts := aParts

   ::Activate()

   RETURN Self

METHOD HStatus:Activate()
   
   LOCAL aCoors

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatuswindow(::oParent:handle, ::id)
      ::Init()
      IF __ObjHasMsg(::oParent, "AOFFSET")
         aCoors := hwg_Getwindowrect(::handle)
         ::oParent:aOffset[4] := aCoors[4] - aCoors[2]
      ENDIF
   ENDIF

   RETURN NIL

METHOD HStatus:Init()

   IF !::lInit
      ::Super:Init()
      IF !Empty(::aParts)
         hwg_InitStatus(::oParent:handle, ::handle, Len(::aParts), ::aParts)
      ENDIF
   ENDIF

   RETURN  NIL

METHOD HStatus:Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aParts)

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()
   ::style := ::nX := ::nY := ::nWidth := ::nHeight := 0
   ::aparts := aparts

   RETURN Self
