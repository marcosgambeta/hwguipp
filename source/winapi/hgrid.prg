 /*
 * HWGUI - Harbour Win32 GUI library source code:
 * HGrid class
 *
 * Copyright 2004 Rodrigo Moreno <rodrigo_moreno@yahoo.com>
 *
*/

/*
TODO: 1) In line edit
         The better way is using hwg_Listview_hittest to determine the item and subitem position
      2) Imagelist
         The way is using the hwg_Listview_setimagelist
      3) Checkbox
         The way is using the NM_CUSTOMDRAW and hwg_Drawframecontrol()

*/

#include "hwgui.ch"
#include "hbclass.ch"
#include "common.ch"

#define LVS_REPORT              1
#define LVS_SINGLESEL           4
#define LVS_SHOWSELALWAYS       8
#define LVS_OWNERDATA        4096

#define LVN_ITEMCHANGED      - 101
#define LVN_KEYDOWN          - 155
#define LVN_GETDISPINFO      - 150
#define NM_DBLCLK              - 3
#define NM_KILLFOCUS           - 8
#define NM_SETFOCUS            - 7

CLASS HGrid INHERIT HControl

   CLASS VAR winclass INIT "SYSLISTVIEW32"
   
   DATA aBitMaps  INIT {}
   DATA ItemCount
   DATA color
   DATA bkcolor
   DATA aColumns  INIT {}
   DATA nRow      INIT 0
   DATA nCol      INIT 0
   DATA lNoScroll INIT .F.
   DATA lNoBorder INIT .F.
   DATA lNoLines  INIT .F.
   DATA lNoHeader INIT .F.
   DATA bEnter
   DATA bKeyDown
   DATA bPosChg
   DATA bDispInfo
   DATA bGfocus
   DATA bLfocus

   METHOD New(oWnd, nId, nStyle, x, y, width, height, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoScroll, lNoBord, ;
      bKeyDown, bPosChg, bDispInfo, nItemCount, lNoLines, color, bkcolor, lNoHeader, aBit)
   METHOD Activate()
   METHOD Init()
   METHOD AddColumn(cHeader, nWidth, nJusHead, nBit) INLINE AAdd(::aColumns, {cHeader, nWidth, nJusHead, nBit})
   METHOD Refresh()
   METHOD RefreshLine() INLINE hwg_Listview_update(::handle, hwg_Listview_getfirstitem(::handle))
   METHOD SetItemCount(nItem) INLINE hwg_Listview_setitemcount(::handle, nItem)
   METHOD Row() INLINE hwg_Listview_getfirstitem(::handle)
   METHOD Notify(lParam)

ENDCLASS

METHOD New(oWnd, nId, nStyle, x, y, width, height, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoScroll, lNoBord, ;
   bKeyDown, bPosChg, bDispInfo, nItemCount, lNoLines, color, bkcolor, lNoHeader, aBit) CLASS HGrid

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), LVS_SHOWSELALWAYS + WS_TABSTOP + IIf(lNoBord, 0, WS_BORDER) + LVS_REPORT + LVS_OWNERDATA + LVS_SINGLESEL)
   ::Super:New(oWnd, nId, nStyle, x, y, width, height, oFont, bInit, bSize, bPaint)
   DEFAULT aBit TO {}
   ::ItemCount := nItemCount
   ::aBitMaps := aBit
   ::bGfocus := bGfocus
   ::bLfocus := bLfocus

   ::color   := color
   ::bkcolor := bkcolor

   ::lNoScroll := lNoScroll
   ::lNoBorder := lNoBord
   ::lNoLines  := lNoLines
   ::lNoHeader := lNoHeader

   ::bEnter    := bEnter
   ::bKeyDown  := bKeyDown
   ::bPosChg   := bPosChg
   ::bDispInfo := bDispInfo

   HWG_InitCommonControlsEx()

   ::Activate()

   RETURN Self

METHOD Activate() CLASS HGrid

   IF !Empty(::oParent:handle)
      ::handle := hwg_Listview_create(::oParent:handle, ::id, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::style, ::lNoHeader, ::lNoScroll)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HGrid

   LOCAL i
   LOCAL nPos
   LOCAL aButton := {}
   LOCAL aBmpSize
   LOCAL n

   IF !::lInit
      ::Super:Init()
      FOR n := 1 TO Len(::aBitmaps)
         AAdd(aButton, hwg_Loadimage(NIL, ::aBitmaps[n], IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE + LR_CREATEDIBSECTION))
      NEXT n

      IF Len(aButton) > 0

         aBmpSize := hwg_Getbitmapsize(aButton[1])

         IF aBmpSize[3] == 4
            ::hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR4 + ILC_MASK)
         ELSEIF aBmpSize[3] == 8
            ::hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR8 + ILC_MASK)
         ELSEIF aBmpSize[3] == 24
            ::hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLORDDB + ILC_MASK)
         ENDIF

         FOR nPos := 1 TO Len(aButton)

            aBmpSize := hwg_Getbitmapsize(aButton[nPos])

            IF aBmpSize[3] == 24
               hwg_Imagelist_add(::hIm, aButton[nPos])
            ELSE
               hwg_Imagelist_add(::hIm, aButton[nPos])
            ENDIF

         NEXT nPos

         hwg_Listview_setimagelist(::handle, ::him)

      ENDIF

      hwg_Listview_init(::handle, ::ItemCount, ::lNoLines)

      FOR i := 1 TO Len(::aColumns)
         hwg_Listview_addcolumn(::handle, i, ::aColumns[i, 2], ::aColumns[i, 1], ::aColumns[i, 3], IIF(::aColumns[i, 4] != NIL, ::aColumns[i, 4], 0))
      NEXT i

      IF ::color != NIL
         hwg_Listview_settextcolor(::handle, ::color)
      ENDIF

      IF ::bkcolor != NIL
         hwg_Listview_setbkcolor(::handle, ::bkcolor)
         hwg_Listview_settextbkcolor(::handle, ::bkcolor)
      ENDIF
   ENDIF

   RETURN NIL

METHOD Refresh() CLASS HGrid

   LOCAL iFirst
   LOCAL iLast

   iFirst := hwg_Listview_gettopindex(::handle)

   iLast := iFirst + hwg_Listview_getcountperpage(::handle)

   hwg_Listview_redrawitems(::handle, iFirst, iLast)

   RETURN NIL

METHOD Notify(lParam) CLASS HGrid

   RETURN hwg_ListViewNotify(Self, lParam)

FUNCTION hwg_ListViewNotify(oCtrl, lParam)

   LOCAL aCord
   LOCAL nCode := hwg_Getnotifycode(lParam)

   SWITCH nCode
   CASE LVN_KEYDOWN
      IF oCtrl:bKeydown != NIL
         Eval(oCtrl:bKeyDown, oCtrl, hwg_Listview_getgridkey(lParam))
      ENDIF
      EXIT
   CASE NM_DBLCLK
      IF oCtrl:bEnter != NIL
         aCord := hwg_Listview_hittest(oCtrl:handle, hwg_GetCursorPos()[2] - hwg_GetWindowRect(oCtrl:handle)[2], hwg_GetCursorPos()[1] - hwg_GetWindowRect(oCtrl:handle)[1])
         oCtrl:nRow := aCord[1]
         oCtrl:nCol := aCord[2]
         Eval(oCtrl:bEnter, oCtrl)
      ENDIF
      EXIT
   CASE NM_SETFOCUS
      IF oCtrl:bGfocus != NIL
         Eval(oCtrl:bGfocus, oCtrl)
      ENDIF
      EXIT
   CASE NM_KILLFOCUS
      IF oCtrl:bLfocus != NIL
         Eval(oCtrl:bLfocus, oCtrl)
      ENDIF
      EXIT
   CASE LVN_ITEMCHANGED
      oCtrl:nRow := oCtrl:Row()
      IF oCtrl:bPosChg != NIL
         Eval(oCtrl:bPosChg, oCtrl, hwg_Listview_getfirstitem(oCtrl:handle))
      ENDIF
      EXIT
   CASE LVN_GETDISPINFO
      IF oCtrl:bDispInfo != NIL
         aCord := hwg_Listview_getdispinfo(lParam)
         oCtrl:nRow := aCord[1]
         oCtrl:nCol := aCord[2]
         hwg_Listview_setdispinfo(lParam, Eval(oCtrl:bDispInfo, oCtrl, oCtrl:nRow, oCtrl:nCol))
      ENDIF
      EXIT
   ENDSWITCH

   RETURN 0
