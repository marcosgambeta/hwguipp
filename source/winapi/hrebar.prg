//
// HWGUI - Harbour Win32 GUI library source code:
//
//
// Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <inkey.ch>
#include <hbclass.ch>
#include "hwguipp.ch"
#include <common.ch>

#define TRANSPARENT 1

CLASS hrebar INHERIT HControl

   DATA winclass INIT "ReBarWindow32"
   DATA TEXT, id
   CLASSDATA oSelected INIT NIL
   DATA ExStyle
   DATA bClick
   DATA lVert
   DATA hTool
   DATA m_nWidth, m_nHeight
   DATA aBands INIT {}

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lVert)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lVert)
   METHOD Activate()
   METHOD INIT()
   METHOD ADDBARColor(pBar, clrFore, clrBack, pszText, dwStyle) INLINE hwg_Addbarcolors(::handle, pBar, clrFore, clrBack, pszText, dwStyle)
   METHOD Addbarbitmap(pBar, pszText, pbmp, dwStyle) INLINE hwg_Addbarbitmap(::handle, pBar, pszText, pbmp, dwStyle)
   METHOD RebarBandNew(pBar, pszText, clrFore, clrBack, pbmp, dwStyle) INLINE ::CreateBands(pBar, pszText, clrFore, clrBack, pbmp, dwStyle)
   METHOD CreateBands(pBar, pszText, clrFore, clrBack, pbmp, dwStyle)

ENDCLASS

METHOD hrebar:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lvert)

   HB_SYMBOL_UNUSED(cCaption)

   DEFAULT lvert TO .F.
   nStyle := hb_bitor(IIf(nStyle == NIL, 0, RBS_BANDBORDERS), WS_CHILD)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   ::Title := ""
   HWG_InitCommonControlsEx()

   ::Activate()

   RETURN Self

METHOD hrebar:Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lVert)

   HB_SYMBOL_UNUSED(cCaption)

   DEFAULT lVert TO .F.
   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()

   ::style := ::nX := ::nY := ::nWidth := ::nHeight := 0

   RETURN Self

METHOD hrebar:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createrebar(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD hrebar:INIT()

   IF !::lInit
      ::Super:Init()
      ::CreateBands()
   ENDIF

   RETURN NIL

METHOD hrebar:CreateBands(pBar, pszText, clrFore, clrBack, pbmp, dwStyle)

   LOCAL i

   IF pBar != NIL
      AADD(::aBands, {pBar, pszText, clrFore, clrBack, pbmp, dwStyle})
   ENDIF
   IF !::lInit
       RETURN NIL
   ENDIF
   dwStyle := RBBS_GRIPPERALWAYS + RBBS_USECHEVRON
   FOR i = 1 TO LEN(::aBands)
      ::aBands[i, 4] := IIF(::aBands[i, 4] = NIL, hwg_Getsyscolor(COLOR_3DFACE), ::aBands[i, 4])
      ::aBands[i, 6] := IIF(::aBands[i, 6] = NIL, dwStyle, ::aBands[i, 6])
      IF !Empty(::aBands[i, 1])
         ::aBands[i, 1] := IIF(HB_ISCHAR(::aBands[i, 1]), &(::aBands[i, 1]), ::aBands[i, 1])
         IF (::aBands[i, 5] != NIL)
            hwg_Addbarbitmap(::handle, ::aBands[i, 1]:handle, ::aBands[i, 2], ::aBands[i, 5], ::aBands[i, 6])
         ELSE
            hwg_Addbarcolors(::handle, ::aBands[i, 1]:handle, ::aBands[i, 3], ::aBands[i, 4], ::aBands[i, 2], ::aBands[i, 6])
         ENDIF
      ENDIF
   NEXT
   ::aBands := {}

   RETURN NIL
