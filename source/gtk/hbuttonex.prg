/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HButtonEx class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
 * ButtonEx class
 *
 * Copyright 2008 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
 * www - http://sites.uol.com.br/culikr/
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HButtonEX INHERIT HButton

   DATA hBitmap
   DATA hIcon

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, hBitmap, iStyle, hIcon, Transp)

   METHOD Activate

END CLASS

/* Removed: bClick  Added: hBitmap, iStyle, Transp */
METHOD HButtonEx:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, hBitmap, iStyle, hIcon, Transp)

   HB_SYMBOL_UNUSED(Transp)
   HB_SYMBOL_UNUSED(iStyle)

   ::hBitmap := hBitmap
   ::hIcon := hIcon

   ::super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor)

   RETURN Self

METHOD HButtonEx:Activate()

   IF !Empty(::oParent:handle)
      IF !Empty(::hBitmap)
         ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title, ::hBitmap)
      ELSEIF !Empty(::hIcon)
         ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title, ::hIcon)
      ELSE
         ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::title, NIL)
      endif
      hwg_Setwindowobject(::handle, Self)
      ::Init()
   ENDIF

   RETURN NIL
