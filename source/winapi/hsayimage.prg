/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HSayImage class
 *
 * Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HSayImage INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA  oImage
   DATA bClick, bDblClick

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctooltip, bClick, bDblClick, bColor)
   METHOD Redefine(oWndParent, nId, bInit, bSize, ctooltip)
   METHOD Activate()
   METHOD END()  INLINE (::Super:END(), iif(::oImage <> NIL, ::oImage:Release(), ::oImage := NIL), ::oImage := NIL)
   METHOD onClick()
   METHOD onDblClick()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctooltip, bClick, bDblClick, bColor) CLASS HSayImage

   nStyle := hb_bitor(nStyle, SS_NOTIFY)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, Iif(nWidth != NIL, nWidth, 0), iif(nHeight != NIL, nHeight, 0), NIL, bInit, bSize, NIL, ctooltip, NIL, bColor)

   ::title := ""

   ::bClick := bClick
   ::oParent:AddEvent(STN_CLICKED, ::id, {||::onClick()})

   ::bDblClick := bDblClick
   ::oParent:AddEvent(STN_DBLCLK, ::id, {||::onDblClick()})

   RETURN Self

/* Parameters bClick, bDblClick were removed a long time ago */
METHOD Redefine(oWndParent, nId, bInit, bSize, ctooltip) CLASS HSayImage

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, NIL, bInit, bSize, NIL, ctooltip)

   RETURN Self

METHOD Activate() CLASS HSayImage

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD onClick()  CLASS HSayImage

   IF ::bClick != NIL
      Eval(::bClick, Self)
   ENDIF

   RETURN NIL

METHOD onDblClick()  CLASS HSayImage

   IF ::bDblClick != NIL
      Eval(::bDblClick, Self)
   ENDIF

   RETURN NIL

// TODO: move to another file and rewrite in C++

FUNCTION hwg_GetBitmapHeight(handle)
LOCAL aBmpSize
aBmpSize  := hwg_Getbitmapsize(handle)
RETURN aBmpSize[2]

FUNCTION hwg_GetBitmapWidth(handle)
LOCAL aBmpSize
aBmpSize  := hwg_Getbitmapsize(handle)
RETURN aBmpSize[1]
