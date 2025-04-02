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

CLASS HToolBar INHERIT HControl

   CLASSDATA oSelected // INIT NIL

   DATA winclass INIT "ToolbarWindow32"
   DATA text
   DATA id
   DATA State INIT 0
   DATA ExStyle
   DATA bClick
   DATA cTooltip
   DATA lPress INIT .F.
   DATA lVertical INIT .F.
   DATA lFlat
   DATA nOrder
   Data aItem INIT {}
   DATA Line

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, lVertical, aItem)
   METHOD Activate()
   METHOD INIT()
   METHOD REFRESH()
   METHOD AddButton(nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu) // a,s,d,f,g,h
   METHOD onEvent( msg, wParam, lParam )
   METHOD EnableAllButtons()
   METHOD DisableAllButtons()
   METHOD EnableButtons(n)
   METHOD DisableButtons(n)

ENDCLASS

/* Added: lVertical */
METHOD hToolBar:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, lVertical, aItem)

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)

   DEFAULT aItem TO {}
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   ::aItem := aItem
   ::lVertical := IIF(lVertical != NIL .AND. HB_ISLOGICAL(lVertical), lVertical, ::lVertical)

   ::Activate()

RETURN Self

METHOD hToolBar:Activate()

   IF !Empty(::oParent:handle )
      ::handle := hwg_Createtoolbar(::oParent:handle )
      hwg_Setwindowobject(::handle, Self)
      ::Init()
   ENDIF

RETURN NIL

METHOD hToolBar:INIT()

   LOCAL n
   LOCAL aButton := {}
   LOCAL oImage
   LOCAL aItem

   // Variables not used
   // Local n1
   // Local aTemp
   // Local hIm
   // Local aBmpSize
   // Local nPos

   IF !::lInit
      ::Super:Init()
      For n := 1 TO len(::aItem)

         if HB_ISNUMERIC(::aItem[n, 1])
            IF !Empty(::aItem[n, 1])
               AAdd(aButton, ::aItem[n , 1])
            ENDIF
         elseif HB_ISCHAR(::aItem[n, 1])
            if ".ico" $ lower(::aItem[n, 1]) //if ".ico" in lower(::aItem[n, 1])
               oImage:=hIcon():AddFile(::aItem[n, 1])
            else
               oImage:=hBitmap():AddFile(::aItem[n, 1])
            endif
            if HB_ISOBJECT(oImage)
               aadd(aButton,Oimage:handle)
               ::aItem[n, 1] := Oimage:handle
            endif
         ENDIF

      NEXT n

      if len(::aItem) >0
         For Each aItem in ::aItem

            if aItem[4] == TBSTYLE_BUTTON

               aItem[11] := hwg_Createtoolbarbutton(::handle,aItem[1],aItem[6],.f.)
               aItem[2] := aItem:__enumIndex()
               hwg_Toolbar_setaction(aItem[11],aItem[7])
               if !Empty(aItem[8])
                  hwg_Addtooltip(::handle, aItem[11],aItem[8])
               endif
            elseif aitem[4] == TBSTYLE_SEP
               aItem[11] := hwg_Createtoolbarbutton(::handle,,,.t.)
               aItem[2] := aItem:__enumIndex()
            endif
         next
      endif

   ENDIF
RETURN NIL

METHOD hToolBar:AddButton(nBitIp,nId,bState,bStyle,cText,bClick,c,aMenu)
   
   LOCAL hMenu // := NIL

   DEFAULT nBitIp to -1
   DEFAULT bstate to TBSTATE_ENABLED
   DEFAULT bstyle to 0x0000
   DEFAULT c to ""
   DEFAULT ctext to ""
   AAdd(::aItem, {nBitIp, nId, bState, bStyle, 0, cText, bClick, c, aMenu, hMenu, 0})
RETURN Self

METHOD hToolBar:onEvent( msg, wParam, lParam )

   LOCAL nPos

   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_LBUTTONUP
      nPos := ascan(::aItem,{|x| x[2] == wParam})
      if nPos>0
         IF hb_IsBlock(::aItem[nPos,7])
            Eval(::aItem[nPos, 7] ,Self)
         ENDIF
      endif
   ENDIF
Return  NIL

METHOD hToolBar:REFRESH()
   if ::lInit
      ::lInit := .f.
   endif
   ::init()
return NIL

METHOD hToolBar:EnableAllButtons()
   
   LOCAL xItem

   For Each xItem in ::aItem
      hwg_Enablewindow( xItem[11], .T. )
   Next
RETURN Self

METHOD hToolBar:DisableAllButtons()
   
   LOCAL xItem

   For Each xItem in ::aItem
      hwg_Enablewindow( xItem[11], .F. )
   Next
RETURN Self

METHOD hToolBar:EnableButtons(n)
   hwg_Enablewindow(::aItem[n, 11], .T.)
RETURN Self

METHOD hToolBar:DisableButtons(n)
   hwg_Enablewindow(::aItem[n, 11], .T.)
RETURN Self
