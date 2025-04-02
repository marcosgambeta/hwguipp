//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HSayBmp class
//
// Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include "hbclass.ch"
#include "hwgui.ch"

CLASS HSayBmp INHERIT HSayImage

   DATA nOffsetV INIT 0
   DATA nOffsetH INIT 0
   DATA nZoom
   DATA lTransp
   DATA trcolor
   DATA nStretch
   DATA nBorder
   DATA oPen

   METHOD New(oWndParent, nId, nX, nY, nWidth, nHeight, Image, lRes, bInit, bSize, ctoolt, bClick, bDblClick, lTransp, nStretch, trcolor, bColor)
   METHOD INIT
   METHOD onEvent( msg, wParam, lParam )
   METHOD Paint()
   METHOD ReplaceBitmap( Image, lRes )
   METHOD Refresh() INLINE hwg_Redrawwindow(::handle)

ENDCLASS

METHOD HSayBmp:New(oWndParent, nId, nX, nY, nWidth, nHeight, Image, lRes, bInit, bSize, ctoolt, bClick, bDblClick, lTransp, nStretch, trcolor, bColor)

   HB_SYMBOL_UNUSED(nStretch)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nX, nY, nWidth, nHeight, bInit, bSize, ctoolt, bClick, bDblClick, bColor)

   ::lTransp := Iif(lTransp = NIL, .F. , lTransp)
   ::trcolor := Iif(trcolor = NIL, 16777215, trcolor)
   ::nBorder := 0
   ::tColor := 0

   IF Image != NIL
      IF lRes == NIL
         lRes := .F.
      ENDIF
      ::oImage := Iif(lRes .OR. HB_ISNUMERIC(Image),     ;
         HBitmap():AddResource( Image ), ;
         iif(HB_ISCHAR(Image),     ;
         HBitmap():AddFile( Image ), Image))
      IF !Empty(::oImage)
         IF nWidth == NIL .OR. nHeight == NIL
            ::nWidth := ::oImage:nWidth
            ::nHeight := ::oImage:nHeight
         ENDIF
      ELSE
         RETURN NIL
      ENDIF
   ENDIF
   ::Activate()

   RETURN Self

METHOD HSayBmp:INIT()

   IF !::lInit
      ::Super:Init()
      hwg_Setwindowobject(::handle, Self)
   ENDIF

   RETURN NIL

METHOD HSayBmp:onEvent( msg, wParam, lParam )

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_PAINT
      ::Paint()
   ENDIF

   RETURN 0

METHOD HSayBmp:Paint()

   LOCAL hDC := hwg_Getdc(::handle)

   IF ::brush != NIL
      hwg_Fillrect(hDC, ::nOffsetH, ::nOffsetV, ::nWidth, ::nHeight, ::brush:handle)
   ENDIF
   IF ::oImage != NIL
      IF ::nZoom == NIL
         IF ::lTransp
            hwg_Drawtransparentbitmap(hDC, ::oImage:handle, ::nOffsetH, ::nOffsetV, ::trColor, ::nWidth, ::nHeight)
         ELSE
            hwg_Drawbitmap(hDC, ::oImage:handle, NIL, ::nOffsetH, ::nOffsetV, ::nWidth, ::nHeight)
         ENDIF
      ELSE
         hwg_Drawbitmap(hDC, ::oImage:handle, NIL, ::nOffsetH, ::nOffsetV, ::oImage:nWidth * ::nZoom, ::oImage:nHeight * ::nZoom)
      ENDIF
   ENDIF
   IF ::nBorder > 0
      IF ::oPen == NIL
         ::oPen := HPen():Add( BS_SOLID, ::nBorder, ::tColor )
      ENDIF
      hwg_Selectobject(hDC, ::oPen:handle)
      hwg_Rectangle(hDC, ::nOffsetH, ::nOffsetV, ::nOffsetH + ::nWidth - 1 - ::nBorder, ::nOffsetV + ::nHeight - 1 - ::nBorder)
   ENDIF
   hwg_Releasedc(::handle, hDC)

   RETURN NIL

METHOD HSayBmp:ReplaceBitmap( Image, lRes )

   IF ::oImage != NIL
      ::oImage:Release()
      ::oImage := NIL
   ENDIF
   IF !Empty(Image)
      IF lRes == NIL
         lRes := .F.
      ENDIF
      ::oImage := iif(lRes .OR. HB_ISNUMERIC(Image), HBitmap():AddResource(Image), iif(HB_ISCHAR(Image), HBitmap():AddFile(Image), Image))
   ENDIF

   RETURN NIL
