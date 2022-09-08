/*
 * HWGUI - Harbour Win32 GUI library source code:
 *
 *
 * Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
 * www - http://sites.uol.com.br/culikr/
*/
#include "windows.ch"
#include "inkey.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define TRANSPARENT 1
#define IDTOOLBAR 700
#define IDMAXBUTTONTOOLBAR 64
#define RT_MANIFEST  24

CLASS HToolBar INHERIT HControl

   CLASS VAR WindowsManifest INIT !EMPTY(hwg_Findresource(NIL, 1, RT_MANIFEST)) SHARED
   DATA winclass INIT "ToolbarWindow32"
   DATA TEXT, id, nTop, nLeft, nwidth, nheight
   CLASSDATA oSelected INIT NIL
   DATA State INIT 0
   DATA ExStyle
   DATA bClick, cTooltip

   DATA lPress INIT .F.
   DATA lFlat
   DATA lTransp    INIT .F. //
   DATA lVertical  INIT .F. //
   DATA lCreate    INIT .F. HIDDEN
   DATA lResource  INIT .F. HIDDEN
   DATA nOrder
   DATA BtnWidth, BtnHeight
   DATA nIDB
   DATA aButtons    INIT {}
   DATA aSeparators INIT {}
   DATA aItem       INIT {}
   DATA Line
   DATA nIndent
   DATA nwSize, nHSize
   DATA nDrop
   DATA lNoThemes   INIT .F.

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, btnWidth, oFont, bInit, ;
      bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, lVertical, aItem, nWSize, nHSize, nIndent, nIDB)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aItem)

   METHOD Activate()
   METHOD INIT()
   METHOD CreateTool()
   METHOD AddButton(nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu, cName, nIndex)
   METHOD Notify(lParam)
   METHOD EnableButton(idButton, lEnable) INLINE hwg_Sendmessage(::handle, TB_ENABLEBUTTON, Int(idButton), hwg_Makelong(iif(lEnable, 1, 0), 0))
   METHOD ShowButton(idButton) INLINE hwg_Sendmessage(::handle, TB_HIDEBUTTON, Int(idButton), hwg_Makelong(0, 0))
   METHOD HideButton(idButton) INLINE hwg_Sendmessage(::handle, TB_HIDEBUTTON, Int(idButton), hwg_Makelong(1, 0))
   METHOD REFRESH() VIRTUAL
   METHOD RESIZE(xIncrSize, lWidth, lHeight)
   METHOD onAnchor(x, y, w, h)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, btnWidth, oFont, bInit, ;
      bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, lVertical, aItem, nWSize, nHSize, nIndent, nIDB) CLASS hToolBar

   DEFAULT  aitem TO { }

   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), iif(hb_bitand(nStyle, WS_DLGFRAME + WS_BORDER) > 0, CCS_NODIVIDER, 0))
   nHeight += iif(hb_bitand(nStyle, WS_DLGFRAME + WS_BORDER) > 0, 1, 0)
   nWidth  -= iif(hb_bitand(nStyle, WS_DLGFRAME + WS_BORDER) > 0, 2, 0)

   ::lTransp := iif(lTransp != NIL, lTransp, .F.)
   ::lVertical := iif(lVertical != NIL .AND. ValType(lVertical) = "L", lVertical, ::lVertical)
   IF ::lTransp  .OR. ::lVertical
      nStyle += iif(::lTransp, TBSTYLE_TRANSPARENT, iif(::lVertical, CCS_VERT, 0))
   ENDIF

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   ::BtnWidth :=  BtnWidth //!= NIL, BtnWidth, 32 )
   ::nIDB := nIDB
   ::aItem := aItem
   ::nIndent := iif(nIndent != NIL, nIndent, 1)
   ::nwSize := iif(nwSize != NIL .AND. nwSize > 11, nwSize, 16)
   ::nhSize := iif(nhSize != NIL .AND. nhSize > 11, nhSize, ::nwSize - 1)
   //::lnoThemes := !hwg_Isthemeactive() .OR. !::WindowsManifest
   IF hb_bitand(::Style, WS_DLGFRAME + WS_BORDER + CCS_NODIVIDER) = 0
      IF !::lVertical
         ::Line := HLine():New(oWndParent, NIL, NIL, nLeft, nTop + nHeight + iif(::lnoThemes .AND. hb_bitand(nStyle, TBSTYLE_FLAT) > 0, 2, 1), nWidth)
      ELSE
         ::Line := HLine():New(oWndParent, NIL, ::lVertical, nLeft + nWidth + 1, nTop, nHeight)
      ENDIF
   ENDIF
   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:type == WND_MDI .AND. ::oParent:aOffset[2] + ::oParent:aOffset[3] = 0
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] += ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nLeft == 0
            ::oParent:aOffset[1] += ::nWidth
         ELSE
            ::oParent:aOffset[3] += ::nWidth
         ENDIF
      ENDIF
   ENDIF

   ::extstyle := TBSTYLE_EX_MIXEDBUTTONS

   HWG_InitCommonControlsEx()

   ::Activate()

   RETURN Self

METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aItem)  CLASS hToolBar

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)

   DEFAULT  aItem TO { }
   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()
   ::aItem := aItem

   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::nIndent := 1
   ::lResource := .T.

   RETURN Self

METHOD Activate() CLASS hToolBar

   IF !Empty(::oParent:handle)
      ::lCreate := .T.
      ::handle := hwg_Createtoolbar(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::extStyle)
      ::Init()
   ENDIF

   RETURN NIL

METHOD INIT() CLASS hToolBar

   IF !::lInit
      IF ::Line != NIL
         ::Line:Anchor := ::Anchor
      ENDIF
      ::Super:Init()
      ::CreateTool()
   ENDIF

   RETURN NIL

METHOD CREATETOOL() CLASS hToolBar
   LOCAL n, n1
   LOCAL aTemp
   LOCAL aButton := {}
   LOCAL aBmpSize, hIm, nPos
   LOCAL nMax := 0
   LOCAL hImage, img, nlistimg, ndrop := 0

   IF !::lResource
      IF Empty(::handle)
         RETURN NIL
      ENDIF
      IF !::lCreate
         hwg_Destroywindow(::Handle)
         ::Activate()
         //IF !EMPTY(::oFont)
         //::SetFont(::oFont)
         //ENDIF
      ENDIF
   ELSE
      FOR n = 1 TO Len(::aitem)
         ::AddButton(::aitem[n, 1], ::aitem[n, 2], ::aitem[n, 3], ::aitem[n, 4], ::aitem[n, 6], ::aitem[n, 7], ::aitem[n, 8], ::aitem[n, 9], NIL, n)
      NEXT
   ENDIF

   nlistimg := 0
   IF ::nIDB != NIL .AND. ::nIDB >= 0
      nlistimg := hwg_Toolbar_loadstandartimage(::handle, ::nIDB)
   ENDIF
   IF hb_bitand(::Style, TBSTYLE_LIST) > 0 .AND. ::nwSize = NIL
      ::nwSize := Max(16, (::nHeight - 16))
   ENDIF
   IF ::nwSize != NIL
      hwg_Sendmessage(::HANDLE, TB_SETBITMAPSIZE, 0, hwg_Makelong(::nwSize, ::nhSize))
   ENDIF

   FOR n := 1 TO Len(::aItem)
      IF HB_ISBLOCK(::aItem[n, 7])
         //::oParent:AddEvent(BN_CLICKED, ::aItem[n, 2], ::aItem[n, 7])
      ENDIF
      IF HB_ISARRAY(::aItem[n, 9])
         ::aItem[n, 10] := hwg__CreatePopupMenu()
         ::aItem[n, 11]:hMenu := ::aItem[n, 10]
         aTemp := ::aItem[n, 9]

         FOR n1 := 1 TO Len(aTemp)
            aTemp[n1, 1] := iif(aTemp[n1, 1] = "-", NIL, aTemp[n1, 1])
            hwg__AddMenuItem(::aItem[n, 10], aTemp[n1, 1], -1, .F., aTemp[n1, 2], NIL, .F.)
            ::oParent:AddEvent(BN_CLICKED, aTemp[n1, 2], aTemp[n1, 3])
         NEXT
      ENDIF
      IF ::aItem[n, 4] = BTNS_SEP
         LOOP
      ENDIF
      nDrop := Max(nDrop, iif(hb_bitand(::aItem[n, 4], BTNS_WHOLEDROPDOWN) != 0, 0, iif(hb_bitand(::aItem[n, 4], BTNS_DROPDOWN) != 0, 8, 0)))

      IF HB_ISCHAR(::aItem[n, 1]) .OR. ::aItem[n, 1] > 1
         IF HB_ISCHAR(::aItem[n, 1]) .AND. At(".", ::aitem[n, 1]) != 0
            IF !File(::aitem[n, 1])
               LOOP
            ENDIF
            //AAdd(aButton, hwg_Loadimage(NIL, ::aitem[n, 1], IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE + LR_CREATEDIBSECTION+ LR_LOADFROMFILE))
            hImage := HBITMAP():AddFile(::aitem[n, 1], NIL, .T., ::nwSize, ::nhSize):handle
         ELSE
            // AAdd(aButton, HBitmap():AddResource(::aitem[n, 1]):handle)
            hImage := HBitmap():AddResource(::aitem[n, 1], LR_LOADTRANSPARENT + LR_LOADMAP3DCOLORS, NIL, ::nwSize, ::nhSize):handle
         ENDIF
         IF ( img := Ascan(aButton, hImage) ) = 0
            AAdd(aButton, hImage)
            img := Len(aButton)
         ENDIF
         ::aItem[n, 1] := img + nlistimg //n
         IF !::lResource
            hwg_Toolbar_loadimage(::Handle, aButton[img])
         ENDIF
      ELSE
      ENDIF
   NEXT
   IF Len(aButton) > 0 .AND. ::lResource
      aBmpSize := hwg_Getbitmapsize(aButton[1])
      hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLORDDB + ILC_MASK)
      FOR nPos := 1 TO Len(aButton)
         hwg_Imagelist_add(hIm, aButton[nPos])
      NEXT
      hwg_Sendmessage(::Handle, TB_SETIMAGELIST, 0, hIm)
   ELSEIF Len(aButton) = 0
      hwg_Sendmessage(::HANDLE, TB_SETBITMAPSIZE, 0, hwg_Makelong(0, 0))
   ENDIF
   hwg_Sendmessage(::Handle, TB_SETINDENT, ::nIndent, 0)
   IF !Empty(::BtnWidth)
      hwg_Sendmessage(::Handle, TB_SETBUTTONWIDTH, 0, hwg_Makelparam(::BtnWidth - 1, ::BtnWidth + 1))
   ENDIF
   IF Len(::aItem) > 0
      hwg_Toolbaraddbuttons(::handle, ::aItem, Len(::aItem))
      hwg_Sendmessage(::handle, TB_SETEXTENDEDSTYLE, 0, TBSTYLE_EX_DRAWDDARROWS)
   ENDIF
   IF ::BtnWidth != NIL
      IF hb_bitand(::Style, CCS_NODIVIDER) > 0
         nMax := iif(hb_bitand(::Style, WS_DLGFRAME + WS_BORDER) > 0, 4, 2)
      ELSEIF hb_bitand(::Style, TBSTYLE_FLAT) > 0
         nMax := 2
      ENDIF
      ::ndrop := nMax + iif(!::WindowsManifest, 0, nDrop)
      ::BtnHeight := Max(hwg_Hiword(hwg_Sendmessage(::handle, TB_GETBUTTONSIZE, 0, 0)), ::nHeight - ::nDrop - ;
         iif(!::lnoThemes .AND. hb_bitand(::Style, TBSTYLE_FLAT) > 0, 0, 2))
      IF !::lVertical
         hwg_Sendmessage(::handle, TB_SETBUTTONSIZE, 0, hwg_Makelparam(::BtnWidth, ::BtnHeight))
      ELSE
         hwg_Sendmessage(::handle, TB_SETBUTTONSIZE, 0, hwg_Makelparam(::nWidth - ::nDrop - 1, ::BtnWidth))
      ENDIF
   ENDIF
   ::BtnWidth := hwg_Loword(hwg_Sendmessage(::handle, TB_GETBUTTONSIZE, 0, 0))

   RETURN NIL

METHOD Notify(lParam) CLASS hToolBar

   LOCAL nCode :=  hwg_Getnotifycode(lParam)
   LOCAL nId

   LOCAL nButton
   LOCAL nPos

   // TODO: usar SWITCH
   IF nCode == TTN_GETDISPINFO

      nButton := hwg_Toolbar_getdispinfoid(lParam)
      nPos := AScan(::aItem, {|x|x[2] == nButton})
      hwg_Toolbar_setdispinfo(lParam, ::aItem[nPos, 8])

   ELSEIF nCode == TBN_GETINFOTIP

      nId := hwg_Toolbar_getinfotipid(lParam)
      nPos := AScan(::aItem, {|x|x[2] == nId})
      hwg_Toolbar_getinfotip(lParam, ::aItem[nPos, 8])

   ELSEIF nCode == TBN_DROPDOWN
      nId := hwg_Toolbar_submenuexgetid(lParam)
      IF nId > 0
         nPos := AScan(::aItem, {|x|x[2] == nId})
         hwg_Toolbar_submenuex(lParam, ::aItem[nPos, 10], ::oParent:handle)
      ELSE
         hwg_Toolbar_submenu(lParam, 1, ::oParent:handle)
      ENDIF
   ELSEIF nCode == NM_CLICK
      nId := hwg_Toolbar_idclick(lParam)
      nPos := AScan(::aItem, {|x|x[2] == nId})
      IF nPos > 0 .AND. HB_ISBLOCK(::aItem[nPos, 7])
         Eval(::aItem[nPos, 7], ::aItem[nPos, 11], nId)
      ENDIF
   ENDIF

   RETURN 0

METHOD AddButton(nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu, cName, nIndex) CLASS hToolBar
   LOCAL hMenu := NIL, oButton

   DEFAULT nBitIp to - 1
   DEFAULT bstate TO TBSTATE_ENABLED
   DEFAULT bstyle TO 0x0000
   DEFAULT c TO ""
   DEFAULT ctext TO ""
   IF nId = NIL .OR. Empty(nId)
      //IDTOOLBAR
      nId := Val(Right(Str(::id, 6), 1)) * IDMAXBUTTONTOOLBAR
      nId := nId + ::id + IDTOOLBAR + Len(::aButtons) + Len(::aSeparators) + 1
   ENDIF

   IF bStyle != BTNS_SEP  //1
      DEFAULT cName TO "oToolButton" + LTrim(Str(Len(::aButtons) + 1))
      AAdd(::aButtons, {AllTrim(cName), nid})
   ELSE
      bstate := iif(!(::lVertical .AND. Len(::aButtons) = 0), bState, 8) // TBSTATE_HIDE
      DEFAULT nBitIp TO 0
      DEFAULT cName TO "oSeparator" + LTrim(Str(Len(::aSeparators) + 1))
      AAdd(::aSeparators, {cName, nid})
   ENDIF

   oButton := HToolButton():New(Self, cName, nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu)
   IF !::lResource
      AAdd(::aItem, {nBitIp, nId, bState, bStyle, 0, cText, bClick, c, aMenu, hMenu, oButton})
   ELSE
      ::aItem[nIndex] := { nBitIp, nId, bState, bStyle, 0, cText, bClick, c, aMenu, hMenu, oButton }
   ENDIF

   RETURN oButton

METHOD RESIZE(xIncrSize, lWidth, lHeight) CLASS hToolBar
   LOCAL nSize

   IF ::Anchor = 0 .OR. ( !lWidth .AND. !lHeight )
      RETURN NIL
   ENDIF
   nSize := hwg_Sendmessage(::handle, TB_GETBUTTONSIZE, 0, 0)
   IF xIncrSize != 1
      ::Move(::nLeft, ::nTop, ::nWidth, ::nHeight, 0)
   ENDIF
   IF xIncrSize < 1 .OR. hwg_Loword(nSize) <= ::BtnWidth
      ::BtnWidth :=  ::BtnWidth  * xIncrSize
   ELSE
      ::BtnWidth :=  hwg_Loword(nSize) * xIncrSize
   ENDIF
   hwg_Sendmessage(::Handle, TB_SETBUTTONWIDTH, hwg_Makelparam(::BtnWidth - 1, ::BtnWidth + 1))
   IF ::BtnWidth != NIL
      IF !::lVertical
         hwg_Sendmessage(::handle, TB_SETBUTTONSIZE, 0, hwg_Makelparam(::BtnWidth, ::BtnHeight))
      ELSE
         hwg_Sendmessage(::handle, TB_SETBUTTONSIZE, 0, hwg_Makelparam(::nWidth - ::nDrop - 1, ::BtnWidth))
      ENDIF
      hwg_Sendmessage(::handle, WM_SIZE, 0, 0)
   ENDIF

   RETURN NIL

METHOD onAnchor(x, y, w, h) CLASS hToolBar

   IF ::Super:onAnchor(x, y, w, h)
      ::Resize(iif(x > 0, w / x, 1), .T., .T.)
   ENDIF

   RETURN .T.
