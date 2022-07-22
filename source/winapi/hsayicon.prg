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

#define STM_SETIMAGE        370    // 0x0172

CLASS HSayIcon INHERIT HSayImage

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, bSize, ctooltip, lOEM, bClick, bDblClick)
   METHOD Redefine(oWndParent, nId, xImage, lRes, bInit, bSize, ctooltip)
   METHOD Init()
   METHOD REFRESH() INLINE hwg_Sendmessage(::handle, STM_SETIMAGE, IMAGE_ICON, ::oImage:handle)

ENDCLASS

METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, bSize, ctooltip, lOEM, bClick, bDblClick) CLASS HSayIcon

   ::Super:New(oWndParent, nId, SS_ICON, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctooltip, bClick, bDblClick)

   IF lRes == Nil
      lRes := .F.
   ENDIF
   IF lOEM == Nil
      lOEM := .F.
   ENDIF
   IF ::oImage == NIL
      // Ticket #60
      // hwg_writelog("::oImage == NIL" + Str(nWidth) + "/" + str(nHeight))
      ::oImage := iif(lRes .OR. ValType(Image) == "N", HIcon():AddResource(Image, nWidth, nHeight, NIL, lOEM), iif(ValType(Image) == "C", HIcon():AddFile(Image, nWidth, nHeight), Image))
   ENDIF
   ::Activate()

   RETURN Self


/* Image ==> xImage */   
METHOD Redefine(oWndParent, nId, xImage, lRes, bInit, bSize, ctooltip) CLASS HSayIcon

   ::Super:Redefine(oWndParent, nId, bInit, bSize, ctooltip)

   IF lRes == Nil
      lRes := .F.
   ENDIF
   IF ::oImage == NIL
      ::oImage := iif(lRes .OR. ValType(xImage) == "N", HIcon():AddResource(xImage), iif(ValType(xImage) == "C", HIcon():AddFile(xImage), xImage))
   ENDIF

   RETURN Self

METHOD Init() CLASS HSayIcon

   IF !::lInit
      ::Super:Init()
      hwg_Sendmessage(::handle, STM_SETIMAGE, IMAGE_ICON, ::oImage:handle)
   ENDIF

   RETURN Nil
