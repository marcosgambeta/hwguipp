//
// HWGUI - Harbour Win32 GUI library source code:
// TVideo component
//
// Copyright 2003 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include "hwguipp.ch"

#include <common.ch>


//----------------------------------------------------------------------------//

CLASS TVideo FROM hControl


   DATA oMci
   DATA cAviFile

   METHOD New(nRow, nCol, nWidth, nHeight, cFileName, oWnd, lNoBorder, nid) CONSTRUCTOR

   METHOD ReDefine(nId, cFileName, oDlg, bWhen, bValid) CONSTRUCTOR

   METHOD Initiate()

   METHOD Play(nFrom, nTo) INLINE ::oMci:Play(nFrom, nTo, ::oparent:handle)

ENDCLASS

//----------------------------------------------------------------------------//

/*  removed: bWhen, bValid */
METHOD TVideo:New(nRow, nCol, nWidth, nHeight, cFileName, oWnd, lNoBorder, nid)

   DEFAULT nWidth TO 200, nHeight TO 200, cFileName TO "", lNoBorder TO .F.

   ::nY := nRow *  VID_CHARPIX_H  // 8
   ::nX := nCol * VID_CHARPIX_W   // 14
   ::nHeight := ::nY + nHeight - 1
   ::nWidth := ::nX + nWidth + 1
   ::Style := hb_bitor(WS_CHILD + WS_VISIBLE + WS_TABSTOP, IIF(!lNoBorder, WS_BORDER, 0))

   ::oParent := IIf(oWnd == NIL, ::oDefaultParent, oWnd)
   ::id := IIf(nid == NIL, ::NewId(), nid)
   ::cAviFile := cFileName
   ::oMci := TMci():New("avivideo", cFileName)
   ::Initiate()

   IF !Empty(::oparent:handle)
      ::oMci:lOpen()
      ::oMci:SetWindow(Self)
   ELSE
      ::oparent:AddControl(Self)
   ENDIF

   RETURN Self

//----------------------------------------------------------------------------//

METHOD TVideo:ReDefine(nId, cFileName, oDlg, bWhen, bValid)

   ::nId      = nId
   ::cAviFile = cFileName
   ::bWhen    = bWhen
   ::bValid   = bValid
   ::oWnd     = oDlg
   ::oMci     = TMci():New("avivideo", cFileName)

   oDlg:AddControl(Self)

   RETURN Self

//----------------------------------------------------------------------------//

METHOD TVideo:Initiate()

   ::Super:Init()
   ::oMci:lOpen()
   ::oMci:SetWindow(Self)

   RETURN NIL

//----------------------------------------------------------------------------//
