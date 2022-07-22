/*
 * $Id: hsayimg.prg 3053 2022-02-08 23:58:25Z df7be $
 *
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HSayImage class
 *
 * Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "hwgui.ch"

   //- HSayImage

CLASS HSayImage INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA  oImage
   DATA bClick, bDblClick

   METHOD New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, bInit, ;
      bSize, ctoolt, bClick, bDblClick, bColor )
   METHOD Activate()
   METHOD END()  INLINE ( ::Super:END(), iif( ::oImage <> NIL,::oImage:Release(),::oImage := NIL ), ::oImage := NIL )

ENDCLASS

METHOD New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, bInit, ;
      bSize, ctoolt, bClick, bDblClick, bColor ) CLASS HSayImage

   ::Super:New( oWndParent, nId, nStyle, nLeft, nTop, ;
      Iif( nWidth != NIL, nWidth, 0 ), iif( nHeight != NIL, nHeight, 0 ),, ;
      bInit, bSize,, ctoolt,, bColor )

   ::title := ""

   ::bClick := bClick
   ::bDblClick := bDblClick

   RETURN Self

METHOD Activate() CLASS HSayImage

   IF !Empty( ::oParent:handle )
      ::handle := hwg_Createstatic( ::oParent:handle, ::id, ;
         ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight )
      ::Init()
   ENDIF

   RETURN NIL

   //- HSayBmp

CLASS HSayBmp INHERIT HSayImage

   DATA nOffsetV  INIT 0
   DATA nOffsetH  INIT 0
   DATA nZoom
   DATA lTransp, trcolor
   DATA nStretch
   DATA nBorder, oPen

   METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctoolt, bClick, bDblClick, lTransp, nStretch, trcolor, bColor )
   METHOD INIT
   METHOD onEvent( msg, wParam, lParam )
   METHOD Paint()
   METHOD ReplaceBitmap( Image, lRes )
   METHOD Refresh() INLINE hwg_Redrawwindow( ::handle )

ENDCLASS

METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctoolt, bClick, bDblClick, lTransp, nStretch, trcolor, bColor ) CLASS HSayBmp

   * Parameters not used
   HB_SYMBOL_UNUSED(nStretch)

   ::Super:New( oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, nWidth, nHeight, ;
         bInit, bSize, ctoolt, bClick, bDblClick, bColor )

   ::lTransp := Iif( lTransp = NIL, .F. , lTransp )
   ::trcolor := Iif( trcolor = NIL, 16777215, trcolor )
   ::nBorder := 0
   ::tColor := 0

   IF Image != NIL
      IF lRes == NIL ; lRes := .F. ; ENDIF
      ::oImage := Iif( lRes .OR. ValType( Image ) == "N",     ;
         HBitmap():AddResource( Image ), ;
         iif( ValType( Image ) == "C",     ;
         HBitmap():AddFile( Image ), Image ) )
      IF !Empty( ::oImage )
         IF nWidth == NIL .OR. nHeight == NIL
            ::nWidth  := ::oImage:nWidth
            ::nHeight := ::oImage:nHeight
         ENDIF
      ELSE
         RETURN NIL
      ENDIF
   ENDIF
   ::Activate()

   RETURN Self

METHOD INIT() CLASS HSayBmp

   IF !::lInit
      ::Super:Init()
      hwg_Setwindowobject( ::handle, Self )
   ENDIF

   RETURN NIL

METHOD onEvent( msg, wParam, lParam ) CLASS HSayBmp

   * Parameters not used
   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_PAINT
      ::Paint()
   ENDIF

   RETURN 0

METHOD Paint() CLASS HSayBmp
   LOCAL hDC := hwg_Getdc( ::handle )

   IF ::brush != NIL
      hwg_Fillrect( hDC, ::nOffsetH, ::nOffsetV, ::nWidth, ::nHeight, ::brush:handle )
   ENDIF
   IF ::oImage != NIL
      IF ::nZoom == NIL
         IF ::lTransp
            hwg_Drawtransparentbitmap( hDC, ::oImage:handle, ::nOffsetH, ;
               ::nOffsetV, ::trColor, ::nWidth, ::nHeight )
         ELSE
            hwg_Drawbitmap( hDC, ::oImage:handle, , ::nOffsetH, ;
               ::nOffsetV, ::nWidth, ::nHeight )
         ENDIF
      ELSE
         hwg_Drawbitmap( hDC, ::oImage:handle, , ::nOffsetH, ;
            ::nOffsetV, ::oImage:nWidth * ::nZoom, ::oImage:nHeight * ::nZoom )
      ENDIF
   ENDIF
   IF ::nBorder > 0
      IF ::oPen == NIL
         ::oPen := HPen():Add( BS_SOLID, ::nBorder, ::tColor )
      ENDIF
      hwg_Selectobject( hDC, ::oPen:handle )
      hwg_Rectangle( hDC, ::nOffsetH, ::nOffsetV, ::nOffsetH+::nWidth-1-::nBorder, ::nOffsetV+::nHeight-1-::nBorder )
   ENDIF
   hwg_Releasedc( ::handle, hDC )

   RETURN NIL

METHOD ReplaceBitmap( Image, lRes ) CLASS HSayBmp

   IF ::oImage != NIL
      ::oImage:Release()
      ::oImage := NIL
   ENDIF
   IF !Empty( Image )
      IF lRes == NIL ; lRes := .F. ; ENDIF
      ::oImage := iif( lRes .OR. ValType( Image ) == "N",  ;
         HBitmap():AddResource( Image ), ;
         iif( ValType( Image ) == "C",   ;
         HBitmap():AddFile( Image ), Image ) )
   ENDIF

   RETURN NIL

   //- HSayIcon

CLASS HSayIcon INHERIT HSayImage

   METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctoolt )

ENDCLASS

METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctoolt ) CLASS HSayIcon

   ::Super:New( oWndParent, nId, SS_ICON, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctoolt )

   IF lRes == NIL ; lRes := .F. ; ENDIF
   ::oImage := iif( lRes .OR. ValType( Image ) == "N", ;
      HIcon():AddResource( Image , nWidth, nHeight ),  ;
      iif( ValType( Image ) == "C",  ;
      HIcon():AddFile( Image , nWidth, nHeight ), Image ) )
   ::Activate()

   RETURN Self
 
   
   FUNCTION hwg_GetBitmapHeight( handle )
   LOCAL aBmpSize
   aBmpSize  := hwg_Getbitmapsize( handle )

   RETURN aBmpSize[2]

   FUNCTION hwg_GetBitmapWidth( handle )
   LOCAL aBmpSize
   aBmpSize  := hwg_Getbitmapsize( handle )
   
   RETURN aBmpSize[1]   
   
* ====================== EOF of hsayimg.prg ========================
   
