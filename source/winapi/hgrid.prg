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

   DATA aBitMaps INIT {}
   DATA ItemCount
   DATA color
   DATA bkcolor
   DATA aColumns INIT {}
   DATA nRow INIT 0
   DATA nCol INIT 0
   DATA lNoScroll INIT .F.
   DATA lNoBorder INIT .F.
   DATA lNoLines INIT .F.
   DATA lNoHeader INIT .F.
   DATA bEnter
   DATA bKeyDown
   DATA bPosChg
   DATA bDispInfo
   DATA bGfocus
   DATA bLfocus

   METHOD New(oWnd, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoScroll, lNoBord, ;
      bKeyDown, bPosChg, bDispInfo, nItemCount, lNoLines, color, bkcolor, lNoHeader, aBit)
   METHOD Activate()
   METHOD Init()
   METHOD AddColumn(cHeader, nWidth, nJusHead, nBit) INLINE AAdd(::aColumns, {cHeader, nWidth, nJusHead, nBit})
   METHOD Refresh()
   METHOD RefreshLine()
   METHOD SetItemCount(nItem)
   METHOD Row()
   METHOD Notify(lParam)

ENDCLASS

METHOD HGrid:New(oWnd, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoScroll, lNoBord, ;
   bKeyDown, bPosChg, bDispInfo, nItemCount, lNoLines, color, bkcolor, lNoHeader, aBit)

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), LVS_SHOWSELALWAYS + WS_TABSTOP + IIf(lNoBord, 0, WS_BORDER) + LVS_REPORT + LVS_OWNERDATA + LVS_SINGLESEL)
   ::Super:New(oWnd, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint)
   DEFAULT aBit TO {}
   ::ItemCount := nItemCount
   ::aBitMaps := aBit
   ::bGfocus := bGfocus
   ::bLfocus := bLfocus

   ::color := color
   ::bkcolor := bkcolor

   ::lNoScroll := lNoScroll
   ::lNoBorder := lNoBord
   ::lNoLines := lNoLines
   ::lNoHeader := lNoHeader

   ::bEnter := bEnter
   ::bKeyDown := bKeyDown
   ::bPosChg := bPosChg
   ::bDispInfo := bDispInfo

   HWG_InitCommonControlsEx()

   ::Activate()

   RETURN Self

METHOD HGrid:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Listview_create(::oParent:handle, ::id, ::nX, ::nY, ::nWidth, ::nHeight, ::style, ::lNoHeader, ::lNoScroll)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HGrid:Init()

   LOCAL i
   LOCAL aButton := {}
   LOCAL aBmpSize
   LOCAL item

   IF !::lInit
      ::Super:Init()
      FOR EACH item IN ::aBitmaps
         AAdd(aButton, hwg_Loadimage(NIL, item, IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE + LR_CREATEDIBSECTION))
      NEXT

      IF Len(aButton) > 0

         aBmpSize := hwg_Getbitmapsize(aButton[1])

         IF aBmpSize[3] == 4
            ::hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR4 + ILC_MASK)
         ELSEIF aBmpSize[3] == 8
            ::hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR8 + ILC_MASK)
         ELSEIF aBmpSize[3] == 24
            ::hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLORDDB + ILC_MASK)
         ENDIF

         FOR EACH item IN aButton
            hwg_Imagelist_add(::hIm, item)
         NEXT

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

METHOD HGrid:Notify(lParam)

   LOCAL aCord
   LOCAL nCode := hwg_Getnotifycode(lParam)

   SWITCH nCode
   CASE LVN_KEYDOWN
      IF HB_ISBLOCK(::bKeydown)
         Eval(::bKeyDown, SELF, hwg_Listview_getgridkey(lParam))
      ENDIF
      EXIT
   CASE NM_DBLCLK
      IF HB_ISBLOCK(::bEnter)
         aCord := hwg_Listview_hittest(::handle, hwg_GetCursorPos()[2] - hwg_GetWindowRect(::handle)[2], hwg_GetCursorPos()[1] - hwg_GetWindowRect(::handle)[1])
         ::nRow := aCord[1]
         ::nCol := aCord[2]
         Eval(::bEnter, SELF)
      ENDIF
      EXIT
   CASE NM_SETFOCUS
      IF HB_ISBLOCK(::bGfocus)
         Eval(::bGfocus, SELF)
      ENDIF
      EXIT
   CASE NM_KILLFOCUS
      IF HB_ISBLOCK(::bLfocus)
         Eval(::bLfocus, SELF)
      ENDIF
      EXIT
   CASE LVN_ITEMCHANGED
      ::nRow := ::Row()
      IF HB_ISBLOCK(::bPosChg)
         Eval(::bPosChg, SELF, hwg_Listview_getfirstitem(::handle))
      ENDIF
      EXIT
   CASE LVN_GETDISPINFO
      IF HB_ISBLOCK(::bDispInfo)
         aCord := hwg_Listview_getdispinfo(lParam)
         ::nRow := aCord[1]
         ::nCol := aCord[2]
         hwg_Listview_setdispinfo(lParam, Eval(::bDispInfo, SELF, ::nRow, ::nCol))
      ENDIF
      EXIT
   ENDSWITCH

   RETURN 0

FUNCTION hwg_ListViewNotify(oCtrl, lParam) // TODO: nao utilizada - remover ?

   LOCAL aCord
   LOCAL nCode := hwg_Getnotifycode(lParam)

   SWITCH nCode
   CASE LVN_KEYDOWN
      IF HB_ISBLOCK(oCtrl:bKeydown)
         Eval(oCtrl:bKeyDown, oCtrl, hwg_Listview_getgridkey(lParam))
      ENDIF
      EXIT
   CASE NM_DBLCLK
      IF HB_ISBLOCK(oCtrl:bEnter)
         aCord := hwg_Listview_hittest(oCtrl:handle, hwg_GetCursorPos()[2] - hwg_GetWindowRect(oCtrl:handle)[2], hwg_GetCursorPos()[1] - hwg_GetWindowRect(oCtrl:handle)[1])
         oCtrl:nRow := aCord[1]
         oCtrl:nCol := aCord[2]
         Eval(oCtrl:bEnter, oCtrl)
      ENDIF
      EXIT
   CASE NM_SETFOCUS
      IF HB_ISBLOCK(oCtrl:bGfocus)
         Eval(oCtrl:bGfocus, oCtrl)
      ENDIF
      EXIT
   CASE NM_KILLFOCUS
      IF HB_ISBLOCK(oCtrl:bLfocus)
         Eval(oCtrl:bLfocus, oCtrl)
      ENDIF
      EXIT
   CASE LVN_ITEMCHANGED
      oCtrl:nRow := oCtrl:Row()
      IF HB_ISBLOCK(oCtrl:bPosChg)
         Eval(oCtrl:bPosChg, oCtrl, hwg_Listview_getfirstitem(oCtrl:handle))
      ENDIF
      EXIT
   CASE LVN_GETDISPINFO
      IF HB_ISBLOCK(oCtrl:bDispInfo)
         aCord := hwg_Listview_getdispinfo(lParam)
         oCtrl:nRow := aCord[1]
         oCtrl:nCol := aCord[2]
         hwg_Listview_setdispinfo(lParam, Eval(oCtrl:bDispInfo, oCtrl, oCtrl:nRow, oCtrl:nCol))
      ENDIF
      EXIT
   ENDSWITCH

   RETURN 0

#pragma BEGINDUMP

#define HB_OS_WIN_32_USED

#define OEMRESOURCE

#include "hwingui.hpp"
#include <commctrl.h>
#include <winuser.h>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include <hbapicls.hpp>
/* Suppress compiler warnings */
#include "incomp_pointer.hpp"
#include "warnings.hpp"

HB_FUNC_STATIC( HGRID_REFRESH )
{
   auto window = static_cast<HWND>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE"));
   LRESULT first = ListView_GetTopIndex(window);
   LRESULT last = first + ListView_GetCountPerPage(window);
   ListView_RedrawItems(window, first, last);
}

HB_FUNC_STATIC( HGRID_REFRESHLINE )
{
   auto window = static_cast<HWND>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE"));
   LRESULT first = ListView_GetNextItem(window, -1, LVNI_ALL | LVNI_SELECTED) + 1;
   ListView_Update(window, first - 1);
}

HB_FUNC_STATIC( HGRID_SETITEMCOUNT )
{
   ListView_SetItemCount(static_cast<HWND>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE")), hb_parni(1));
}

HB_FUNC_STATIC( HGRID_ROW )
{
   hb_retnl(ListView_GetNextItem(static_cast<HWND>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE")), -1, LVNI_ALL | LVNI_SELECTED) + 1);
}

#pragma ENDDUMP
