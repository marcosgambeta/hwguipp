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

CLASS HSayIcon INHERIT HSayImage

   METHOD New(oWndParent, nId, nX, nY, nWidth, nHeight, Image, lRes, bInit, bSize, ctooltip, lOEM, bClick, bDblClick)
   METHOD Redefine(oWndParent, nId, xImage, lRes, bInit, bSize, ctooltip)
   METHOD Init()
   METHOD REFRESH() INLINE hwg_Sendmessage(::handle, STM_SETIMAGE, IMAGE_ICON, ::oImage:handle)

ENDCLASS

METHOD HSayIcon:New(oWndParent, nId, nX, nY, nWidth, nHeight, Image, lRes, bInit, bSize, ctooltip, lOEM, bClick, bDblClick)

   ::Super:New(oWndParent, nId, SS_ICON, nX, nY, nWidth, nHeight, bInit, bSize, ctooltip, bClick, bDblClick)

   IF lRes == NIL
      lRes := .F.
   ENDIF
   IF lOEM == NIL
      lOEM := .F.
   ENDIF
   IF ::oImage == NIL
      // Ticket #60
      // hwg_writelog("::oImage == NIL" + Str(nWidth) + "/" + str(nHeight))
      ::oImage := iif(lRes .OR. HB_ISNUMERIC(Image), HIcon():AddResource(Image, nWidth, nHeight, NIL, lOEM), iif(HB_ISCHAR(Image), HIcon():AddFile(Image, nWidth, nHeight), Image))
   ENDIF
   ::Activate()

   RETURN Self


/* Image ==> xImage */   
METHOD HSayIcon:Redefine(oWndParent, nId, xImage, lRes, bInit, bSize, ctooltip)

   ::Super:Redefine(oWndParent, nId, bInit, bSize, ctooltip)

   IF lRes == NIL
      lRes := .F.
   ENDIF
   IF ::oImage == NIL
      ::oImage := iif(lRes .OR. HB_ISNUMERIC(xImage), HIcon():AddResource(xImage), iif(HB_ISCHAR(xImage), HIcon():AddFile(xImage), xImage))
   ENDIF

   RETURN Self

METHOD HSayIcon:Init()

   IF !::lInit
      ::Super:Init()
      hwg_Sendmessage(::handle, STM_SETIMAGE, IMAGE_ICON, ::oImage:handle)
   ENDIF

   RETURN NIL
