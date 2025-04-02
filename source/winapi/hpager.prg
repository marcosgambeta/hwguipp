//
// HWGUI - Harbour Win32 GUI library source code:
//
// Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include "windows.ch"
#include "inkey.ch"
#include <hbclass.ch>
#include "guilib.ch"
#include <common.ch>

#define TRANSPARENT 1

CLASS HPager INHERIT HControl

   DATA winclass INIT "SysPager"
   DATA TEXT
   DATA id
   CLASSDATA oSelected INIT NIL
   DATA ExStyle
   DATA bClick
   DATA lVert
   DATA hTool
   DATA m_nWidth
   DATA m_nHeight

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lVert)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lVert)
   METHOD SetScrollArea(nWidth, nHeight) INLINE ::m_nWidth := nWidth, ::m_nHeight := nHeight
   METHOD Activate()
   METHOD INIT()

   METHOD Notify(lParam)
   METHOD Pagersetchild(b) INLINE ::hTool := b, hwg_Pagersetchild(::handle, b)
   METHOD Pagerrecalcsize() INLINE hwg_Pagerrecalcsize(::handle)
   METHOD Pagerforwardmouse(b) INLINE hwg_Pagerforwardmouse(::handle, b)
   METHOD Pagersetbkcolor(b) INLINE hwg_Pagersetbkcolor(::handle, b)
   METHOD Pagergetbkcolor() INLINE hwg_Pagergetbkcolor(::handle)
   METHOD Pagersetborder(b) INLINE hwg_Pagersetborder(::handle, b)
   METHOD Pagergetborder() INLINE hwg_Pagergetborder(::handle)
   METHOD Pagersetpos(b) INLINE hwg_Pagersetpos(::handle, b)
   METHOD Pagergetpos() INLINE hwg_Pagergetpos(::handle)
   METHOD Pagersetbuttonsize(b) INLINE hwg_Pagersetbuttonsize(::handle, b)
   METHOD Pagergetbuttonsize() INLINE hwg_Pagergetbuttonsize(::handle)
   METHOD Pagergetbuttonstate() INLINE hwg_Pagergetbuttonstate(::handle)

ENDCLASS

METHOD HPager:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lvert)

   HB_SYMBOL_UNUSED(cCaption)

   DEFAULT lvert TO .F.
   ::lvert := lvert
   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), WS_VISIBLE + WS_CHILD + IIF(lvert, PGS_VERT, PGS_HORZ))
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()

   ::Activate()

   RETURN Self

METHOD HPager:Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lVert)

   HB_SYMBOL_UNUSED(cCaption)

   DEFAULT lVert TO .F.
   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()

   ::style := ::nX := ::nY := ::nWidth := ::nHeight := 0

   RETURN Self

METHOD HPager:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createpager(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, IIF(::lVert, PGS_VERT, PGS_HORZ))
      ::Init()
   ENDIF
   RETURN NIL

METHOD HPager:INIT()

   IF !::lInit
      ::Super:Init()
   ENDIF
   RETURN NIL

METHOD HPager:Notify(lParam)

   LOCAL nCode := hwg_Getnotifycode(lParam)

   IF nCode == PGN_CALCSIZE
      hwg_Pageronpagercalcsize(lParam, ::hTool)
   ELSEIF nCode == PGN_SCROLL
      hwg_Pageronpagerscroll(lParam)
   ENDIF

   RETURN 0
