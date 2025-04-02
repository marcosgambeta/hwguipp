//
// HWGUI - Harbour Win32 GUI library source code:
// HSayImage class
//
// Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

#define STM_SETIMAGE        370    // 0x0172

CLASS HSayBmp INHERIT HSayImage

   DATA nOffsetV INIT 0
   DATA nOffsetH INIT 0
   DATA nZoom
   DATA lTransp, trcolor
   DATA nStretch
   DATA nBorder, oPen

   METHOD New(oWndParent, nId, nX, nY, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctooltip, bClick, bDblClick, lTransp, nStretch, trcolor, bColor)
   METHOD Redefine(oWndParent, nId, xImage, lRes, bInit, bSize, ctooltip, lTransp)
   METHOD Init()
   METHOD Paint(lpdis)
   METHOD ReplaceBitmap(Image, lRes)
   METHOD Refresh() INLINE hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_UPDATENOW)

ENDCLASS

METHOD HSayBmp:New(oWndParent, nId, nX, nY, nWidth, nHeight, Image, lRes, bInit, ;
      bSize, ctooltip, bClick, bDblClick, lTransp, nStretch, trcolor, bColor)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nX, nY, nWidth, nHeight, bInit, bSize, ctooltip, bClick, bDblClick, bColor)

   ::bPaint := {|o, lpdis|o:Paint(lpdis)}
   ::lTransp := Iif(lTransp = NIL, .F., lTransp)
   ::nStretch := Iif(nStretch = NIL, 0, nStretch)
   ::trcolor := Iif(trcolor = NIL, NIL, trcolor)
   ::nBorder := 0
   ::tColor := 0

   IF Image != NIL .AND. !Empty(Image)
      IF lRes == NIL
         lRes := .F.
      ENDIF
      ::oImage := Iif(lRes .OR. HB_ISNUMERIC(Image), HBitmap():AddResource(Image), iif(HB_ISCHAR(Image), HBitmap():AddFile(Image), Image))
      IF ::oImage != NIL .AND. ( nWidth == NIL .OR. nHeight == NIL )
         ::nWidth := ::oImage:nWidth
         ::nHeight := ::oImage:nHeight
         ::nStretch = 2
      ENDIF
   ENDIF
   ::Activate()

   RETURN Self

/* Image ==> xImage */   
METHOD HSayBmp:Redefine(oWndParent, nId, xImage, lRes, bInit, bSize, ctooltip, lTransp)

   ::Super:Redefine(oWndParent, nId, bInit, bSize, ctooltip)
   ::bPaint := {|o, lpdis|o:Paint(lpdis)}
   ::lTransp := iif(lTransp = NIL, .F., lTransp)
   ::nBorder := 0
   ::tColor := 0
   IF lRes == NIL
      lRes := .F.
   ENDIF
   ::oImage := iif(lRes .OR. HB_ISNUMERIC(xImage), HBitmap():AddResource(xImage), iif(HB_ISCHAR(xImage), HBitmap():AddFile(xImage), xImage))

   RETURN Self

METHOD HSayBmp:Init()

   IF !::lInit
      ::Super:Init()
      IF ::oImage != NIL .AND. !Empty(::oImage:Handle)
         hwg_Sendmessage(::handle, STM_SETIMAGE, IMAGE_BITMAP, ::oImage:handle)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HSayBmp:Paint(lpdis)
   
   LOCAL drawInfo := hwg_Getdrawiteminfo(lpdis)
   LOCAL n

   IF ::brush != NIL
      hwg_Fillrect(drawInfo[3], drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7], ::brush:handle)
   ENDIF
   IF ::oImage != NIL .AND. !Empty(::oImage:Handle)
      IF ::nZoom == NIL
         IF ::lTransp
            IF ::nStretch = 1  // isometric
               hwg_Drawtransparentbitmap(drawInfo[3], ::oImage:handle, drawInfo[4] + ::nOffsetH, drawInfo[5] + ::nOffsetV, ::trcolor)
            ELSEIF ::nStretch = 2  // CLIP
               hwg_Drawtransparentbitmap(drawInfo[3], ::oImage:handle, drawInfo[4] + ::nOffsetH, drawInfo[5] + ::nOffsetV, ::trcolor, ::nWidth + 1, ::nHeight + 1)
            ELSE // stretch (DEFAULT)
               hwg_Drawtransparentbitmap(drawInfo[3], ::oImage:handle, drawInfo[4] + ::nOffsetH, drawInfo[5] + ::nOffsetV, ::trcolor, drawInfo[6] - drawInfo[4] + 1, drawInfo[7] - drawInfo[5] + 1)
            ENDIF
         ELSE
            IF ::nStretch = 1  // isometric
               hwg_Drawbitmap(drawInfo[3], ::oImage:handle, NIL, drawInfo[4] + ::nOffsetH, drawInfo[5] + ::nOffsetV) //, ::nWidth + 1, ::nHeight + 1)
            ELSEIF ::nStretch = 2  // CLIP
               hwg_Drawbitmap(drawInfo[3], ::oImage:handle, NIL, drawInfo[4] + ::nOffsetH, drawInfo[5] + ::nOffsetV, ::nWidth + 1, ::nHeight + 1)
            ELSE // stretch (DEFAULT)
               hwg_Drawbitmap(drawInfo[3], ::oImage:handle, NIL, drawInfo[4] + ::nOffsetH, drawInfo[5] + ::nOffsetV, drawInfo[6] - drawInfo[4] + 1, drawInfo[7] - drawInfo[5] + 1)
            ENDIF
         ENDIF
      ELSE
         hwg_Drawbitmap(drawInfo[3], ::oImage:handle, NIL, drawInfo[4] + ::nOffsetH, drawInfo[5] + ::nOffsetV, ::oImage:nWidth * ::nZoom, ::oImage:nHeight * ::nZoom)
      ENDIF
   ENDIF
   IF ::nBorder > 0
      IF ::oPen == NIL
         ::oPen := HPen():Add(BS_SOLID, ::nBorder, ::tColor)
      ENDIF
      hwg_Selectobject(drawInfo[3], ::oPen:handle)
      n := Int(::nBorder / 2)
      hwg_Rectangle(drawInfo[3], ::nOffsetH+n, ::nOffsetV+n, ::nOffsetH + ::nWidth - n, ::nOffsetV + ::nHeight - n)
   ENDIF

   RETURN NIL

METHOD HSayBmp:ReplaceBitmap(Image, lRes)

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
