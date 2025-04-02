//
// HWGUI - Harbour Win32 GUI library source code:
// HFreeImage - Image handling class
//
// To use this class you need to have the FreeImage library
// http://freeimage.sourceforge.net/
// Authors: Floris van den Berg (flvdberg@wxs.nl) and
//          Hervé Drolon (drolon@infonie.fr)
//
// Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "windows.ch"
#include "guilib.ch"

CLASS HFreeImage INHERIT HObject

   CLASS VAR aImages INIT {}
   
   DATA handle
   DATA hBitmap
   DATA name
   DATA nWidth, nHeight
   DATA nCounter INIT 1

   METHOD AddFile(name)
   METHOD AddFromVar(cImage, cType)
   METHOD FromBitmap(oBitmap)
   METHOD Draw(hDC, nLeft, nTop, nWidth, nHeight)
   METHOD Release()

ENDCLASS

METHOD HFreeImage:AddFile(name)
   
   LOCAL i

   FOR i := 1 TO Len(::aImages) // TODO: FOR EACH
      IF ::aImages[i]:name == name
         ::aImages[i]:nCounter++
         RETURN ::aImages[i]
      ENDIF
   NEXT
   IF Empty(::handle := hwg_Fi_load(name))
      RETURN NIL
   ENDIF
   ::name := name
   ::nWidth := hwg_Fi_getwidth(::handle)
   ::nHeight := hwg_Fi_getheight(::handle)
   AAdd(::aImages, Self)

   RETURN Self

METHOD HFreeImage:AddFromVar(cImage, cType)

   IF Empty(::handle := hwg_Fi_loadfrommem(cImage, cType))
      RETURN NIL
   ENDIF
   ::name := LTrim(Str(::handle))
   ::nWidth := hwg_Fi_getwidth(::handle)
   ::nHeight := hwg_Fi_getheight(::handle)
   AAdd(::aImages, Self)

   RETURN Self

METHOD HFreeImage:FromBitmap(oBitmap)

   ::handle := hwg_Fi_bmp2fi(oBitmap:handle)
   ::name := LTrim(Str(oBitmap:handle))
   ::nWidth := hwg_Fi_getwidth(::handle)
   ::nHeight := hwg_Fi_getheight(::handle)
   AAdd(::aImages, Self)

   RETURN Self

METHOD HFreeImage:Draw(hDC, nLeft, nTop, nWidth, nHeight)

   hwg_Fi_draw(::handle, hDC, ::nWidth, ::nHeight, nLeft, nTop, nWidth, nHeight)
   // hwg_Drawbitmap(hDC, ::hBitmap, NIL, nLeft, nTop, ::nWidth, ::nHeight)
   RETURN NIL

METHOD HFreeImage:Release()
   
   LOCAL i
   LOCAL nlen := Len(::aImages)

   ::nCounter--
   IF ::nCounter == 0
      FOR i := 1 TO nlen // TODO: FOR EACH
         IF ::aImages[i]:handle == ::handle
            hwg_Fi_unload(::handle)
            IF ::hBitmap != NIL
               hwg_Deleteobject(::hBitmap)
            ENDIF
            ADel(::aImages, i)
            ASize(::aImages, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF
   RETURN NIL

//- HSayFImage

CLASS HSayFImage INHERIT HSayImage

   DATA nOffsetV INIT 0
   DATA nOffsetH INIT 0
   DATA nZoom

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, bInit, bSize, ctooltip, cType)
   METHOD Redefine(oWndParent, nId, Image, bInit, bSize, ctooltip)
   METHOD ReplaceImage(Image, cType)
   METHOD Paint(lpdis)
   METHOD Refresh() INLINE hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_UPDATENOW)

ENDCLASS

METHOD HSayFImage:New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, bInit, bSize, ctooltip, cType)

   IF Image != NIL
      ::oImage := IIf(HB_ISCHAR(Image), IIf(cType != NIL, HFreeImage():AddFromVar(Image, cType), HFreeImage():AddFile(Image)), Image)
      IF nWidth == NIL
         nWidth := ::oImage:nWidth
         nHeight := ::oImage:nHeight
      ENDIF
   ENDIF
   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctooltip)
   // ::classname:= "HSAYFIMAGE"

   ::bPaint := {|o, lpdis|o:Paint(lpdis)}

   ::Activate()

   RETURN Self

METHOD HSayFImage:Redefine(oWndParent, nId, Image, bInit, bSize, ctooltip)

   ::oImage := IIf(HB_ISCHAR(Image), HFreeImage():AddFile(Image), Image)

   ::Super:Redefine(oWndParent, nId, bInit, bSize, ctooltip)
   // ::classname:= "HSAYFIMAGE"

   ::bPaint := {|o, lpdis|o:Paint(lpdis)}

   RETURN Self

METHOD HSayFImage:ReplaceImage(Image, cType)

   IF ::oImage != NIL
      ::oImage:Release()
   ENDIF
   ::oImage := IIf(HB_ISCHAR(Image), IIf(cType != NIL, HFreeImage():AddFromVar(Image, cType), HFreeImage():AddFile(Image)), Image)

   RETURN NIL

METHOD HSayFImage:Paint(lpdis)
   
   LOCAL drawInfo := hwg_Getdrawiteminfo(lpdis)
   LOCAL hDC := drawInfo[3] //, x1 := drawInfo[4], y1 := drawInfo[5], x2 := drawInfo[6], y2 := drawInfo[7]

   IF ::oImage != NIL
      IF ::nZoom == NIL
         ::oImage:Draw(hDC, ::nOffsetH, ::nOffsetV, ::oImage:nWidth, ::oImage:nHeight)
      ELSE
         ::oImage:Draw(hDC, ::nOffsetH, ::nOffsetV, ::oImage:nWidth * ::nZoom, ::oImage:nHeight * ::nZoom)
      ENDIF
   ENDIF

   RETURN Self


   EXIT PROCEDURE CleanImages
   
   LOCAL i

   FOR i := 1 TO Len(HFreeImage():aImages)
      hwg_Fi_unload(HFreeImage():aImages[i]:handle)
      IF HFreeImage():aImages[i]:hBitmap != NIL
         hwg_Deleteobject(HFreeImage():aImages[i]:hBitmap)
      ENDIF
   NEXT
   hwg_Fi_end()

   RETURN
