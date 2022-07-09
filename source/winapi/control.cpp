/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C level controls functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#define HB_OS_WIN_32_USED

#define OEMRESOURCE
#include "hwingui.h"
#include <commctrl.h>
#include <winuser.h>

#include "hbapiitm.h"
#include "hbvm.h"
#include "hbdate.h"
#include "hbtrace.h"

/* Suppress compiler warnings */
#include "incomp_pointer.h"
#include "warnings.h"

#if defined(__BORLANDC__) || defined(_MSC_VER)
HB_EXTERN_BEGIN
WINUSERAPI HWND WINAPI GetAncestor(HWND hwnd, UINT gaFlags);
HB_EXTERN_END
#endif

#ifndef TTS_BALLOON
   #define TTS_BALLOON             0x40    // added by MAG
#endif
#ifndef CCM_SETVERSION
   #define CCM_SETVERSION (CCM_FIRST + 0x7)
#endif
#ifndef CCM_GETVERSION
   #define CCM_GETVERSION (CCM_FIRST + 0x8)
#endif
#ifndef TB_GETIMAGELIST
   #define TB_GETIMAGELIST         (WM_USER + 49)
#endif

/*
#if _MSC_VER
#define snprintf _snprintf
#endif
*/

// LRESULT CALLBACK OwnBtnProc(HWND, UINT, WPARAM, LPARAM);
LRESULT CALLBACK WinCtrlProc(HWND, UINT, WPARAM, LPARAM);
LRESULT APIENTRY SplitterProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
LRESULT APIENTRY StaticSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
LRESULT APIENTRY ListSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
LRESULT APIENTRY TrackSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
LRESULT APIENTRY TreeViewSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
static void CALLBACK s_timerProc(HWND, UINT, UINT, DWORD);

static HWND s_hWndTT = nullptr;
static bool s_lInitCmnCtrl = false;
static bool s_lToolTipBalloon = false;
static WNDPROC wpOrigTrackProc, wpOrigStaticProc, wpOrigListProc, wpOrigTreeViewProc;

/*
HWG_INITCOMMONCONTROLSEX() --> NIL
*/
HB_FUNC( HWG_INITCOMMONCONTROLSEX )
{
   if( !s_lInitCmnCtrl )
   {
      INITCOMMONCONTROLSEX i;
      i.dwSize = sizeof(INITCOMMONCONTROLSEX);
      i.dwICC = ICC_DATE_CLASSES | ICC_INTERNET_CLASSES | ICC_BAR_CLASSES | ICC_LISTVIEW_CLASSES | ICC_TAB_CLASSES | ICC_TREEVIEW_CLASSES;
      InitCommonControlsEx(&i);
      s_lInitCmnCtrl = true;
   }
}

/*
HWG_MOVEWINDOW(HWND, nLeft, nTop, nRight, nBottom, lRepaint) --> NIL
*/
HB_FUNC( HWG_MOVEWINDOW )
{
   RECT rc;
   GetWindowRect(hwg_par_HWND(1), &rc);
   MoveWindow(hwg_par_HWND(1),
              (HB_ISNIL(2)) ? rc.left : hb_parni(2),
              (HB_ISNIL(3)) ? rc.top : hb_parni(3),
              (HB_ISNIL(4)) ? rc.right - rc.left : hb_parni(4),
              (HB_ISNIL(5)) ? rc.bottom - rc.top : hb_parni(5),
              (hb_pcount() < 6) ? TRUE : hb_parl(6));
}

/*
   CreatePanel(hParentWindow, nPanelControlID, nStyle, x1, y1, nWidth, nHeight)
*/
HB_FUNC( HWG_CREATEPANEL )
{
   HWND hWndPanel = CreateWindow(TEXT("PANEL"),   /* predefined class  */
         nullptr,                  /* no window title   */
         WS_CHILD | WS_VISIBLE | SS_GRAYRECT | SS_OWNERDRAW | CCS_TOP | hb_parnl(3),
         hwg_par_int(4), hwg_par_int(5),  hwg_par_int(6), hwg_par_int(7),
         hwg_par_HWND(1),
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
         GetModuleHandle(nullptr), nullptr);
   HB_RETHANDLE(hWndPanel);
   // SS_ETCHEDHORZ
}

/*
   CreateOwnBtn(hParentWIndow, nBtnControlID, x, y, nWidth, nHeight)
*/
HB_FUNC( HWG_CREATEOWNBTN )
{
   HWND hWndPanel = CreateWindow(TEXT("OWNBTN"),  /* predefined class  */
         nullptr,                  /* no window title   */
         WS_CHILD | WS_VISIBLE | SS_GRAYRECT | SS_OWNERDRAW,
         hwg_par_int(3), hwg_par_int(4), hwg_par_int(5), hwg_par_int(6),
         hwg_par_HWND(1),
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
         GetModuleHandle(nullptr), nullptr);
   HB_RETHANDLE(hWndPanel);
}

/*
   CreateStatic(hParentWyndow, nControlID, nStyle, x, y, nWidth, nHeight)
*/
HB_FUNC( HWG_CREATESTATIC )
{
   ULONG ulStyle = hb_parnl(3);
   ULONG ulExStyle = ((!HB_ISNIL(8)) ? hb_parnl(8) : 0) | ((ulStyle & WS_BORDER) ? WS_EX_CLIENTEDGE : 0);
   HWND hWndCtrl = CreateWindowEx(ulExStyle, TEXT("STATIC"),      /* predefined class  */
         nullptr,                  /* title   */
         WS_CHILD | WS_VISIBLE | ulStyle,
         hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), hwg_par_int(7),
         hwg_par_HWND(1),
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
         GetModuleHandle(nullptr),
         nullptr);

   /*
      if( hb_pcount() > 7 )
      {
         void * hStr;
         LPCTSTR lpText = HB_PARSTR(8, &hStr, nullptr);
         if( lpText )
         {
            SendMessage(hWndEdit, WM_SETTEXT, 0, static_cast<LPARAM>(lpText));
         }
         hb_strfree(hStr);
      }
    */

   HB_RETHANDLE(hWndCtrl);
}

/*
   CreateBrowse(hParentWIndow, nControlID, nStyle, x, y, nWidth, nHeight, cTitle)
*/
HB_FUNC( HWG_CREATEBROWSE )
{
   DWORD dwStyle = hb_parnl(3);
   void * hStr;
   HWND hWndBrw = CreateWindowEx((dwStyle & WS_BORDER) ? WS_EX_CLIENTEDGE : 0,
      TEXT("BROWSE"), HB_PARSTR(8, &hStr, nullptr), WS_CHILD | WS_VISIBLE | dwStyle,
      hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), hwg_par_int(7),
      hwg_par_HWND(1), reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
      GetModuleHandle(nullptr), nullptr);
   hb_strfree(hStr);
   HB_RETHANDLE(hWndBrw);
}

/* CreateStatusWindow - creates a status window and divides it into
     the specified number of parts.
 Returns the handle to the status window.
 hwndParent - parent window for the status window
 nStatusID - child window identifier
 nParts - number of parts into which to divide the status window
 pArray - Array with Lengths of parts, if first item == 0, status window
          will be divided into equal parts.
*/
HB_FUNC( HWG_CREATESTATUSWINDOW )
{
   // Ensure that the common control DLL is loaded.
   InitCommonControls();

   // Create the status window.
   HWND hwndStatus = CreateWindowEx(0,      // style
         STATUSCLASSNAME,       // name of status window class
         nullptr,                  // no text when first created
         SBARS_SIZEGRIP |       // includes a sizing grip
         WS_CHILD | WS_VISIBLE | WS_OVERLAPPED | WS_CLIPSIBLINGS,       // creates a child window
         0, 0, 0, 0,            // ignores size and position
         hwg_par_HWND(1),            // handle to parent window
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),       // child window identifier
         GetModuleHandle(nullptr),       // handle to application instance
         nullptr);                // no window creation data

   HB_RETHANDLE(hwndStatus);
}

HB_FUNC( HWG_INITSTATUS )
{
   HWND hParent = hwg_par_HWND(1);
   HWND hStatus = hwg_par_HWND(2);
   RECT rcClient;
   HLOCAL hloc;
   LPINT lpParts;
   int nWidth, j, nParts = hb_parni(3);
   PHB_ITEM pArray = hb_param(4, HB_IT_ARRAY);

   // Allocate an array for holding the right edge coordinates.
   hloc = LocalAlloc(LHND, sizeof(int) * nParts);
   lpParts = static_cast<LPINT>(LocalLock(hloc));

   if( !pArray || hb_arrayGetNI(pArray, 1) == 0 )
   {
      // Get the coordinates of the parent window's client area.
      GetClientRect(hParent, &rcClient);
      // Calculate the right edge coordinate for each part, and
      // copy the coordinates to the array.
      nWidth = rcClient.right / nParts;
      for( int i = 0; i < nParts; i++ )
      {
         lpParts[i] = nWidth;
         nWidth += nWidth;
      }
   }
   else
   {
      nWidth = 0;
      for( ULONG ul = 1; ul <= static_cast<ULONG>(nParts); ul++ )
      {
         j = hb_arrayGetNI(pArray, ul);
         if( ul == static_cast<ULONG>(nParts) && j == 0 )
         {
            nWidth = -1;
         }
         else
         {
            nWidth += j;
         }
         lpParts[ul - 1] = nWidth;
      }
   }

   // Tell the status window to create the window parts.
   SendMessage(hStatus, SB_SETPARTS, static_cast<WPARAM>(nParts), reinterpret_cast<LPARAM>(lpParts));

   // Free the array, and return.
   LocalUnlock(hloc);
   LocalFree(hloc);
}

HB_FUNC( HWG_GETNOTIFYSBPARTS )
{
   hb_retnl(static_cast<LONG>(((static_cast<NMMOUSE*>(HB_PARHANDLE(1)))->dwItemSpec)));
}

HB_FUNC( HWG_ADDTOOLTIP )
{
   HWND hWnd = hwg_par_HWND(1);
   TOOLINFO ti;
   int iStyle = 0;
   void * hStr;

   if( s_lToolTipBalloon )
   {
      iStyle = TTS_BALLOON;
   }

   if( !s_hWndTT )
   {
      s_hWndTT = CreateWindow(TOOLTIPS_CLASS, nullptr, WS_POPUP | TTS_ALWAYSTIP | iStyle,
         CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
         nullptr, static_cast<HMENU>(nullptr), GetModuleHandle(nullptr), nullptr);
   }
   if( !s_hWndTT )
   {
      hb_retl(false);
      return;
   }
   memset(&ti, 0, sizeof(TOOLINFO));
   ti.cbSize = sizeof(TOOLINFO);
   ti.uFlags = TTF_SUBCLASS | TTF_IDISHWND;
   ti.hwnd = GetParent(static_cast<HWND>(hWnd));
   ti.uId = reinterpret_cast<UINT_PTR>(hWnd);
   ti.hinst = GetModuleHandle(nullptr);
   ti.lpszText = const_cast<PTSTR>(HB_PARSTR(2, &hStr, nullptr));

   hb_retl(SendMessage(s_hWndTT, TTM_ADDTOOL, 0, reinterpret_cast<LPARAM>(static_cast<LPTOOLINFO>(&ti))));
   hb_strfree(hStr);
}

HB_FUNC( HWG_DELTOOLTIP )
{
   HWND hWnd = hwg_par_HWND(1);
   TOOLINFO ti;

   if( s_hWndTT )
   {
      memset(&ti, 0, sizeof(TOOLINFO));
      ti.cbSize = sizeof(TOOLINFO);
      ti.uFlags = TTF_IDISHWND;
      ti.hwnd = GetParent(static_cast<HWND>(hWnd));
      ti.uId = reinterpret_cast<UINT_PTR>(hWnd);
      ti.hinst = GetModuleHandle(nullptr);

      SendMessage(s_hWndTT, TTM_DELTOOL, 0, reinterpret_cast<LPARAM>(static_cast<LPTOOLINFO>(&ti)));
   }
}

HB_FUNC( HWG_SETTOOLTIPTITLE )
{
   HWND hWnd = hwg_par_HWND(1);

   if( s_hWndTT )
   {
      TOOLINFO ti;
      void * hStr;

      ti.cbSize = sizeof(TOOLINFO);
      ti.uFlags = TTF_IDISHWND;
      ti.hwnd = GetParent(static_cast<HWND>(hWnd));
      ti.uId = reinterpret_cast<UINT_PTR>(hWnd);
      ti.hinst = GetModuleHandle(nullptr);
      //ti.lpszText = static_cast<LPTSTR>(HB_PARSTR(3, &hStr, nullptr));
      ti.lpszText = const_cast<LPTSTR>(HB_PARSTR(2, &hStr, nullptr));

      hb_retl(SendMessage(s_hWndTT, TTM_SETTOOLINFO, 0, reinterpret_cast<LPARAM>(static_cast<LPTOOLINFO>(&ti))));
      hb_strfree(hStr);
   }
}

HB_FUNC( HWG_GETTIMEPICKER )
{
   SYSTEMTIME st;
   char szTime[9];

   SendMessage(hwg_par_HWND(1), DTM_GETSYSTEMTIME, 0, reinterpret_cast<LPARAM>(&st));

   //sprintf(szTime, "%02d:%02d:%02d", st.wHour, st.wMinute, st.wSecond);
   hb_snprintf(szTime, 9, "%02d:%02d:%02d", st.wHour, st.wMinute, st.wSecond);
   hb_retc(szTime);
}

HB_FUNC( HWG_GETNOTIFYKEYDOWN )
{
   hb_retni(static_cast<WORD>((static_cast<TC_KEYDOWN*>(HB_PARHANDLE(1)))->wVKey));
}

/*
HWG_CREATETREE(hParent, nControlId, nStyle, nX, nY, nWidth, nHeight) --> nCtrl
*/
HB_FUNC( HWG_CREATETREE )
{
   HWND hCtrl = CreateWindowEx(WS_EX_CLIENTEDGE, WC_TREEVIEW, 0, WS_CHILD | WS_VISIBLE | WS_TABSTOP | hb_parnl(3),
      hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), hwg_par_int(7),
      hwg_par_HWND(1), reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
      GetModuleHandle(nullptr), nullptr);

   if( !HB_ISNIL(8) )
   {
      SendMessage(hCtrl, TVM_SETTEXTCOLOR, 0, hwg_par_LPARAM(8));
   }
   if( !HB_ISNIL(9) )
   {
      SendMessage(hCtrl, TVM_SETBKCOLOR, 0, hwg_par_LPARAM(9));
   }

   HB_RETHANDLE(hCtrl);
}

HB_FUNC( HWG_TREEADDNODE )
{
   TV_ITEM tvi;
   TV_INSERTSTRUCT is;

   int nPos = hb_parni(5);
   PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
   void * hStr;

   tvi.iImage = 0;
   tvi.iSelectedImage = 0;

   tvi.mask = TVIF_TEXT | TVIF_PARAM;
   tvi.pszText = const_cast<LPTSTR>(HB_PARSTR(6, &hStr, nullptr));
   tvi.lParam = reinterpret_cast<LPARAM>(hb_itemNew(pObject));
   if( hb_pcount() > 6 && !HB_ISNIL(7) )
   {
      tvi.iImage = hb_parni(7);
      tvi.mask |= TVIF_IMAGE;
      if( hb_pcount() > 7 && !HB_ISNIL(8) )
      {
         tvi.iSelectedImage = hb_parni(8);
         tvi.mask |= TVIF_SELECTEDIMAGE;
      }
   }

#if !defined(__BORLANDC__) ||  (__BORLANDC__ > 1424)
   is.item = tvi;
#else
   is.DUMMYUNIONNAME.item = tvi;
#endif

   is.hParent = (HB_ISNIL(3) ? nullptr : static_cast<HTREEITEM>(HB_PARHANDLE(3)));
   if( nPos == 0 )
   {
      is.hInsertAfter = static_cast<HTREEITEM>(HB_PARHANDLE(4));
   }
   else if( nPos == 1 )
   {
      is.hInsertAfter = TVI_FIRST;
   }
   else if( nPos == 2 )
   {
      is.hInsertAfter = TVI_LAST;
   }

   HB_RETHANDLE(SendMessage(hwg_par_HWND(2), TVM_INSERTITEM, 0, reinterpret_cast<LPARAM>(&is)));

   if( tvi.mask & TVIF_IMAGE )
   {
      if( tvi.iImage )
      {
         DeleteObject(reinterpret_cast<HGDIOBJ>(static_cast<UINT_PTR>(tvi.iImage)));
      }
   }
   if( tvi.mask & TVIF_SELECTEDIMAGE )
   {
      if( tvi.iSelectedImage )
      {
         DeleteObject(reinterpret_cast<HGDIOBJ>(static_cast<UINT_PTR>(tvi.iSelectedImage)));
      }
   }

   hb_strfree(hStr);
}

/*
HB_FUNC( HWG_TREEDELNODE )
{
   hb_parl(TreeView_DeleteItem(hwg_par_HWND(1), static_cast<HTREEITEM>(HB_PARHANDLE(2))));
}

HB_FUNC( HWG_TREEDELALLNODES )
{
   TreeView_DeleteAllItems(hwg_par_HWND(1));
}
*/

HB_FUNC( HWG_TREEGETSELECTED )
{
   TV_ITEM TreeItem;

   memset(&TreeItem, 0, sizeof(TV_ITEM));
   TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
   TreeItem.hItem = TreeView_GetSelection(hwg_par_HWND(1));

   if( TreeItem.hItem )
   {
      PHB_ITEM oNode; // = hb_itemNew(nullptr);
      SendMessage(hwg_par_HWND(1), TVM_GETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
      oNode = reinterpret_cast<PHB_ITEM>(TreeItem.lParam);
      hb_itemReturn(oNode);
   }
}

/*
HB_FUNC( HWG_TREENODEHASCHILDREN )
{
   TV_ITEM TreeItem;

   memset(&TreeItem, 0, sizeof(TV_ITEM));
   TreeItem.mask = TVIF_HANDLE | TVIF_CHILDREN;
   TreeItem.hItem = static_cast<HTREEITEM>(HB_PARHANDLE(2));

   SendMessage(hwg_par_HWND(1), TVM_GETITEM, 0, static_cast<LPARAM>(&TreeItem));
   hb_retni(TreeItem.cChildren);
}
*/

HB_FUNC( HWG_TREEGETNODETEXT )
{
   TV_ITEM TreeItem;
   TCHAR ItemText[256] = { 0 };

   memset(&TreeItem, 0, sizeof(TV_ITEM));
   TreeItem.mask = TVIF_HANDLE | TVIF_TEXT;
   TreeItem.hItem = static_cast<HTREEITEM>(HB_PARHANDLE(2));
   TreeItem.pszText = ItemText;
   TreeItem.cchTextMax = 256;

   SendMessage(hwg_par_HWND(1), TVM_GETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
   HB_RETSTR(TreeItem.pszText);
}

#define TREE_SETITEM_TEXT       1
#define TREE_SETITEM_CHECK      2

HB_FUNC( HWG_TREESETITEM )
{
   TV_ITEM TreeItem;
   int iType = hb_parni(3);
   void * hStr = nullptr;

   memset(&TreeItem, 0, sizeof(TV_ITEM));
   TreeItem.mask = TVIF_HANDLE;
   TreeItem.hItem = static_cast<HTREEITEM>(HB_PARHANDLE(2));

   if( iType == TREE_SETITEM_TEXT )
   {
      TreeItem.mask |= TVIF_TEXT;
      TreeItem.pszText = const_cast<LPTSTR>(HB_PARSTR(4, &hStr, nullptr));
   }
   if( iType == TREE_SETITEM_CHECK )
   {
      TreeItem.mask |= TVIF_STATE;
      TreeItem.stateMask = TVIS_STATEIMAGEMASK;
      TreeItem.state =  hb_parni(4);
      TreeItem.state = TreeItem.state << 12;
   }

   SendMessage(hwg_par_HWND(1), TVM_SETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
   hb_strfree(hStr);
}

#define TREE_GETNOTIFY_HANDLE       1
#define TREE_GETNOTIFY_PARAM        2
#define TREE_GETNOTIFY_EDIT         3
#define TREE_GETNOTIFY_EDITPARAM    4
#define TREE_GETNOTIFY_ACTION       5
#define TREE_GETNOTIFY_OLDPARAM     6

HB_FUNC( HWG_TREEGETNOTIFY )
{
   int iType = hb_parni(2);

   if( iType == TREE_GETNOTIFY_HANDLE )
   {
      HB_RETHANDLE(static_cast<HTREEITEM>((static_cast<NM_TREEVIEW*>(HB_PARHANDLE(1)))->itemNew.hItem));
   }

   if( iType == TREE_GETNOTIFY_ACTION )
   {
      hb_retni(static_cast<UINT>((static_cast<NM_TREEVIEW*>(HB_PARHANDLE(1)))->action));
   }

   else if( iType == TREE_GETNOTIFY_PARAM || iType == TREE_GETNOTIFY_EDITPARAM || iType == TREE_GETNOTIFY_OLDPARAM )
   {
      PHB_ITEM oNode; // = hb_itemNew(nullptr);
      if( iType == TREE_GETNOTIFY_EDITPARAM )
      {
         oNode = reinterpret_cast<PHB_ITEM>((static_cast<TV_DISPINFO*>(HB_PARHANDLE(1)))->item.lParam);
      }
      else if( iType == TREE_GETNOTIFY_OLDPARAM )
      {
         oNode = reinterpret_cast<PHB_ITEM>((static_cast<NM_TREEVIEW*>(HB_PARHANDLE(1)))->itemOld.lParam);
      }
      else
      {
         oNode = reinterpret_cast<PHB_ITEM>(((static_cast<NM_TREEVIEW*>(HB_PARHANDLE(1)))->itemNew.lParam));
      }

      hb_itemReturn(oNode);

   }
   else if( iType == TREE_GETNOTIFY_EDIT )
   {
      TV_DISPINFO *tv;
      tv = static_cast<TV_DISPINFO*>(HB_PARHANDLE(1));

      HB_RETSTR((tv->item.pszText) ? tv->item.pszText : TEXT(""));
   }
}

/*
 * Tree_Hittest(hTree, x, y) --> oNode
 */
HB_FUNC( HWG_TREEHITTEST )
{
   TV_HITTESTINFO ht;
   HWND hTree = hwg_par_HWND(1);

   if( hb_pcount() > 1 && HB_ISNUM(2) && HB_ISNUM(3) )
   {
      ht.pt.x = hb_parni(2);
      ht.pt.y = hb_parni(3);
   }
   else
   {
      GetCursorPos(&(ht.pt));
      ScreenToClient(hTree, &(ht.pt));
   }

   SendMessage(hTree, TVM_HITTEST, 0, reinterpret_cast<LPARAM>(&ht));

   if( ht.hItem )
   {
      PHB_ITEM oNode; // = hb_itemNew(nullptr);
      TV_ITEM TreeItem;

      memset(&TreeItem, 0, sizeof(TV_ITEM));
      TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
      TreeItem.hItem = ht.hItem;

      SendMessage(hTree, TVM_GETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
      oNode = reinterpret_cast<PHB_ITEM>(TreeItem.lParam);
      hb_itemReturn(oNode);
      if( hb_pcount() > 3 )
      {
         hb_storni(static_cast<int>(ht.flags), 4);
      }
   }
   else
   {
      hb_ret();
   }
}

HB_FUNC( HWG_TREERELEASENODE )
{
   TV_ITEM TreeItem;

   memset(&TreeItem, 0, sizeof(TV_ITEM));
   TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
   TreeItem.hItem = static_cast<HTREEITEM>(HB_PARHANDLE(2));

   if( TreeItem.hItem )
   {
      SendMessage(hwg_par_HWND(1), TVM_GETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
      hb_itemRelease(reinterpret_cast<PHB_ITEM>(TreeItem.lParam));
      TreeItem.lParam = 0;
      SendMessage(hwg_par_HWND(1), TVM_SETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
   }
}

/*
 * CreateImagelist(array, cx, cy, nGrow, flags)
*/
HB_FUNC( HWG_CREATEIMAGELIST )
{
   PHB_ITEM pArray = hb_param(1, HB_IT_ARRAY);
   UINT flags = (HB_ISNIL(5)) ? ILC_COLOR : hb_parni(5);
   HIMAGELIST himl;
   ULONG ulLen = hb_arrayLen(pArray);
   HBITMAP hbmp;

   himl = ImageList_Create(hb_parni(2), hb_parni(3), flags, ulLen, hb_parni(4));

   for( ULONG ul = 1; ul <= ulLen; ul++ )
   {
      hbmp = static_cast<HBITMAP>(HB_GETPTRHANDLE(pArray, ul));
      ImageList_Add(himl, hbmp, static_cast<HBITMAP>(nullptr));
      DeleteObject(hbmp);
   }

   HB_RETHANDLE(himl);
}

HB_FUNC( HWG_IMAGELIST_ADD )
{
   hb_retnl(ImageList_Add(static_cast<HIMAGELIST>(HB_PARHANDLE(1)), hwg_par_HBITMAP(2), static_cast<HBITMAP>(nullptr)));
}

HB_FUNC( HWG_IMAGELIST_ADDMASKED )
{
   hb_retnl(ImageList_AddMasked(static_cast<HIMAGELIST>(HB_PARHANDLE(1)), hwg_par_HBITMAP(2), static_cast<COLORREF>(hb_parnl(3))));
}

HB_FUNC( HWG_DESTROYIMAGELIST )
{
   ImageList_Destroy(static_cast<HIMAGELIST>(HB_PARHANDLE(1)));
}

/*
 *  SetTimer(hWnd, idTimer, i_MilliSeconds)
 */

/* 22/09/2005 - <maurilio.longo@libero.it>
      If I pass a fourth parameter as 0 (zero) I don't set
      the TimerProc, this way I can receive WM_TIMER messages
      inside an ON OTHER MESSAGES code block
*/
HB_FUNC( HWG_SETTIMER )
{
   SetTimer(hwg_par_HWND(1), static_cast<UINT>(hb_parni(2)),
            static_cast<UINT>(hb_parni(3)),
            hb_pcount() == 3 ?  reinterpret_cast<TIMERPROC>(reinterpret_cast<UINT_PTR>(s_timerProc)) : static_cast<TIMERPROC>(reinterpret_cast<UINT_PTR>(nullptr)));
}

/*
 *  KillTimer(hWnd, idTimer)
 */

HB_FUNC( HWG_KILLTIMER )
{
   hb_retl(KillTimer(hwg_par_HWND(1), static_cast<UINT>(hb_parni(2))));
}

HB_FUNC( HWG_GETPARENT )
{
   HB_RETHANDLE(GetParent(hwg_par_HWND(1)));
}

HB_FUNC( HWG_GETANCESTOR )
{
   HB_RETHANDLE(GetAncestor(hwg_par_HWND(1), hb_parni(2)));
}

HB_FUNC( HWG_LOADCURSOR )
{
   void * hStr;
   LPCTSTR lpStr = HB_PARSTR(1, &hStr, nullptr);

   if( lpStr )
   {
      HB_RETHANDLE(LoadCursor(GetModuleHandle(nullptr), lpStr));
   }
   else
   {
      HB_RETHANDLE(LoadCursor(nullptr, MAKEINTRESOURCE(hb_parni(1))));
   }
   hb_strfree(hStr);
}

/*
hwg_LoadCursorFromFile(ccurFname)
*/
HB_FUNC( HWG_LOADCURSORFROMFILE )
{
   void * hStr;
   HCURSOR hCursor;

   LPCTSTR ccurFname = HB_PARSTR(1, &hStr, nullptr);

   hCursor = LoadCursorFromFile(ccurFname);
   if( hCursor == nullptr )
   {
      /* in case of error return default cursor "Arrow" */
      HB_RETHANDLE(LoadCursor(nullptr, IDC_ARROW));
   }
   else
   {
      HB_RETHANDLE(hCursor);
   }

   hb_strfree(hStr);
}

HB_FUNC( HWG_SETCURSOR )
{
   HB_RETHANDLE(SetCursor(static_cast<HCURSOR>(HB_PARHANDLE(1))));
}

HB_FUNC( HWG_GETCURSOR )
{
   HB_RETHANDLE(GetCursor());
}

HB_FUNC( HWG_GETTOOLTIPHANDLE )
{
   HB_RETHANDLE(s_hWndTT);
}

HB_FUNC( HWG_SETTOOLTIPBALLOON )
{
   s_lToolTipBalloon = hb_parl(1);
   s_hWndTT = nullptr;
}

HB_FUNC( HWG_GETTOOLTIPBALLOON )
{
   hb_retl(s_lToolTipBalloon);
}

HB_FUNC( HWG_REGPANEL )
{
   static bool bRegistered = false;

   if( !bRegistered )
   {
      WNDCLASS wndclass;

      wndclass.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
      wndclass.lpfnWndProc = DefWindowProc;
      wndclass.cbClsExtra = 0;
      wndclass.cbWndExtra = 0;
      wndclass.hInstance = GetModuleHandle(nullptr);
      wndclass.hIcon = nullptr;
      wndclass.hCursor = LoadCursor(nullptr, IDC_ARROW);
      wndclass.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_3DFACE + 1);
      wndclass.lpszMenuName = nullptr;
      wndclass.lpszClassName = TEXT("PANEL");

      RegisterClass(&wndclass);
      bRegistered = true;
   }
}

HB_FUNC( HWG_REGOWNBTN )
{
   static bool bRegistered = false;

   WNDCLASS wndclass;

   if( !bRegistered )
   {
      wndclass.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
      wndclass.lpfnWndProc = WinCtrlProc;
      wndclass.cbClsExtra = 0;
      wndclass.cbWndExtra = 0;
      wndclass.hInstance = GetModuleHandle(nullptr);
      wndclass.hIcon = nullptr;
      wndclass.hCursor = LoadCursor(nullptr, IDC_ARROW);
      wndclass.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_3DFACE + 1);
      wndclass.lpszMenuName = nullptr;
      wndclass.lpszClassName = TEXT("OWNBTN");

      RegisterClass(&wndclass);
      bRegistered = true;
   }
}

HB_FUNC( HWG_REGBROWSE )
{
   static bool bRegistered = false;

   if( !bRegistered )
   {
      WNDCLASS wndclass;

      wndclass.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
      wndclass.lpfnWndProc = WinCtrlProc;
      wndclass.cbClsExtra = 0;
      wndclass.cbWndExtra = 0;
      wndclass.hInstance = GetModuleHandle(nullptr);
      // wndclass.hIcon         = LoadIcon(nullptr, IDI_APPLICATION);
      wndclass.hIcon = nullptr;
      wndclass.hCursor = LoadCursor(nullptr, IDC_ARROW);
      wndclass.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_WINDOW + 1);
      wndclass.lpszMenuName = nullptr;
      wndclass.lpszClassName = TEXT("BROWSE");

      RegisterClass(&wndclass);
      bRegistered = true;
   }
}

static void CALLBACK s_timerProc(HWND hWnd, UINT message, UINT idTimer, DWORD dwTime) /* DWORD dwTime as last parameter unused */
{
   static PHB_DYNS s_pSymTest = nullptr;

   HB_SYMBOL_UNUSED(message);

   if( s_pSymTest == nullptr )
   {
      s_pSymTest = hb_dynsymGetCase("HWG_TIMERPROC");
   }

   if( hb_dynsymIsFunction(s_pSymTest) )
   {
      hb_vmPushDynSym(s_pSymTest);
      hb_vmPushNil();   /* places NIL at self */
//      hb_vmPushLong(static_cast<LONG>(hWnd));    /* pushes parameters on to the hvm stack */
      HB_PUSHITEM(hWnd);
      hb_vmPushLong(static_cast<LONG>(idTimer));
      //hb_vmPushLong(static_cast<LONG>(dwTime));
      hb_vmDo(2);             /* where iArgCount is the number of pushed parameters */
   }
}

BOOL RegisterWinCtrl(void)    // Added by jamaj - Used by WinCtrl
{
   WNDCLASS wndclass;

   wndclass.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
   wndclass.lpfnWndProc = WinCtrlProc;
   wndclass.cbClsExtra = 0;
   wndclass.cbWndExtra = 0;
   wndclass.hInstance = GetModuleHandle(nullptr);
   wndclass.hCursor = LoadCursor(nullptr, IDC_ARROW);
   wndclass.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_3DFACE + 1);
   wndclass.lpszMenuName = nullptr;
   wndclass.lpszClassName = TEXT("WINCTRL");

   return RegisterClass(&wndclass);
}

HB_FUNC( HWG_INITTREEVIEW )
{
   wpOrigTreeViewProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(TreeViewSubclassProc)));
}

LRESULT APIENTRY TreeViewSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   long int res;
   PHB_ITEM pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject )
   {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
//      hb_vmPushLong(static_cast<LONG>(wParam));
//      hb_vmPushLong(static_cast<LONG>(lParam));
      HB_PUSHITEM(wParam);
      HB_PUSHITEM(lParam);
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) )
      {
         return reinterpret_cast<LRESULT>(HB_PARHANDLE(-1));
      }
      else
      {
         res = hb_parnl(-1);
         if( res == -1 )
         {
            return (CallWindowProc(wpOrigTreeViewProc, hWnd, message, wParam, lParam));
         }
         else
         {
            return res;
         }
      }
   }
   else
   {
      return (CallWindowProc(wpOrigTreeViewProc, hWnd, message, wParam, lParam));
   }
}

HB_FUNC( HWG_INITWINCTRL )
{
   SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(WinCtrlProc));
}

LRESULT CALLBACK WinCtrlProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   long int res;
   PHB_ITEM pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject )
   {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
//      hb_vmPushLong(static_cast<LONG>(wParam));
//      hb_vmPushLong(static_cast<LONG>(lParam));
      HB_PUSHITEM(wParam);
      HB_PUSHITEM(lParam);
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) )
      {
         return reinterpret_cast<LRESULT>(HB_PARHANDLE(-1));
      }
      else
      {
         res = hb_parnl(-1);
         if( res == -1 )
         {
            return (DefWindowProc(hWnd, message, wParam, lParam));
         }
         else
         {
            return res;
         }
      }
   }
   else
   {
      return (DefWindowProc(hWnd, message, wParam, lParam));
   }
}

HB_FUNC( HWG_INITSTATICPROC )
{
   wpOrigStaticProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(StaticSubclassProc)));
}

LRESULT APIENTRY StaticSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   long int res;
   PHB_ITEM pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject )
   {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
//      hb_vmPushLong(static_cast<LONG>(wParam));
//      hb_vmPushLong(static_cast<LONG>(lParam));
      HB_PUSHITEM(wParam);
      HB_PUSHITEM(lParam);
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) )
      {
         return reinterpret_cast<LRESULT>(HB_PARHANDLE(-1));
      }
      else
      {
         res = hb_parnl(-1);
         if( res == -1 )
         {
            return (CallWindowProc(wpOrigStaticProc, hWnd, message, wParam, lParam));
         }
         else
         {
            return res;
         }
      }
   }
   else
   {
      return (CallWindowProc(wpOrigStaticProc, hWnd, message, wParam, lParam));
   }
}

LRESULT APIENTRY ListSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   long int res;
   PHB_ITEM pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject )
   {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
//      hb_vmPushLong(static_cast<LONG>(wParam));
//      hb_vmPushLong(static_cast<LONG>(lParam));
      HB_PUSHITEM(wParam);
      HB_PUSHITEM(lParam);
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) )
      {
         return reinterpret_cast<LRESULT>(HB_PARHANDLE(-1));
      }
      else
      {
         res = hb_parnl(-1);
         if( res == -1 )
         {
            return (CallWindowProc(wpOrigListProc, hWnd, message, wParam, lParam));
         }
         else
         {
            return res;
         }
      }
   }
   else
   {
      return (CallWindowProc(wpOrigListProc, hWnd, message, wParam, lParam));
   }
}

HB_FUNC( HWG_INITLISTPROC )
{
   wpOrigListProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(ListSubclassProc)));
}

HB_FUNC( HWG_INITTRACKPROC )
{
   wpOrigTrackProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(TrackSubclassProc)));
}

LRESULT APIENTRY TrackSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   long int res;
   PHB_ITEM pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

   if( !pSym_onEvent )
   {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject )
   {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
//      hb_vmPushLong(static_cast<LONG>(wParam));
//      hb_vmPushLong(static_cast<LONG>(lParam));
      HB_PUSHITEM(wParam);
      HB_PUSHITEM(lParam);
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) )
      {
         return reinterpret_cast<LRESULT>(HB_PARHANDLE(-1));
      }
      else
      {
         res = hb_parnl(-1);
         if( res == -1 )
         {
            return (CallWindowProc(wpOrigTrackProc, hWnd, message, wParam, lParam));
         }
         else
         {
            return res;
         }
      }
   }
   else
   {
      return (CallWindowProc(wpOrigTrackProc, hWnd, message, wParam, lParam));
   }
}

HB_FUNC( HWG_CREATEPAGER )
{
   BOOL bVert = hb_parl(8);
   HWND hWndPanel = CreateWindow(WC_PAGESCROLLER,   /* predefined class  */
         nullptr,                  /* no window title   */
         WS_CHILD | WS_VISIBLE | bVert ? PGS_VERT : PGS_HORZ | hb_parnl(3),   /* style  */
         hwg_par_int(4), hwg_par_int(5),  /* x, y       */
         hwg_par_int(6), hwg_par_int(7),  /* nWidth, nHeight */
         hwg_par_HWND(1),    /* parent window    */
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),       /* control ID  */
         GetModuleHandle(nullptr), nullptr);
   HB_RETHANDLE(hWndPanel);
}

HB_FUNC( HWG_CREATEREBAR )
{
   ULONG ulStyle = hb_parnl(3);
   ULONG ulExStyle = ((!HB_ISNIL(8)) ? hb_parnl(8) : 0) | ((ulStyle & WS_BORDER) ? WS_EX_CLIENTEDGE : 0) | WS_EX_TOOLWINDOW;
   HWND hWndCtrl = CreateWindowEx(ulExStyle,   /* extended style */
         REBARCLASSNAME,        /* predefined class  */
         nullptr,                  /* title   */
         WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | RBS_VARHEIGHT | CCS_NODIVIDER | ulStyle,   /* style  */
         hwg_par_int(4), hwg_par_int(5),  /* x, y       */
         hwg_par_int(6), hwg_par_int(7),  /* nWidth, nHeight */
         hwg_par_HWND(1),    /* parent window    */
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),       /* control ID  */
         GetModuleHandle(nullptr),
         nullptr);
   HB_RETHANDLE(hWndCtrl);
}

HB_FUNC( HWG_REBARSETIMAGELIST )
{
   HIMAGELIST p = (HB_ISNUM(2) || HB_ISPOINTER(2)) ? static_cast<HIMAGELIST>(HB_PARHANDLE(2)) : nullptr;
   REBARINFO rbi;
   memset(&rbi, '\0', sizeof(rbi));
   rbi.cbSize = sizeof(REBARINFO);
   rbi.fMask = (HB_ISNUM(2) || HB_ISPOINTER(2)) ? RBIM_IMAGELIST : 0;
   rbi.himl = (HB_ISNUM(2) || HB_ISPOINTER(2)) ? static_cast<HIMAGELIST>(p) : static_cast<HIMAGELIST>(nullptr);
   SendMessage(hwg_par_HWND(1), RB_SETBARINFO, 0, reinterpret_cast<LPARAM>(&rbi));
}

static BOOL _AddBar(HWND pParent, HWND pBar, REBARBANDINFO * pRBBI)
{
   SIZE size;
   RECT rect;
   BOOL bResult;

   pRBBI->cbSize = sizeof(REBARBANDINFO);
   pRBBI->fMask |= RBBIM_CHILD | RBBIM_CHILDSIZE;
   pRBBI->hwndChild = pBar;

   GetWindowRect(pBar, &rect);

   size.cx = rect.right - rect.left;
   size.cy = rect.bottom - rect.top;

   pRBBI->cxMinChild = size.cx;
   pRBBI->cyMinChild = size.cy;
   bResult = SendMessage(pParent, RB_INSERTBAND, static_cast<WPARAM>(-1), reinterpret_cast<LPARAM>(pRBBI));

   return bResult;
}

static BOOL AddBar(HWND pParent, HWND pBar, LPCTSTR pszText, HBITMAP pbmp, DWORD dwStyle)
{
   REBARBANDINFO rbBand;

   memset(&rbBand, '\0', sizeof(rbBand));

   rbBand.fMask = RBBIM_STYLE;
   rbBand.fStyle = dwStyle;
   if( pszText != nullptr )
   {
      rbBand.fMask |= RBBIM_TEXT;
      rbBand.lpText = const_cast<LPTSTR>(pszText);
   }
   if( pbmp != nullptr )
   {
      rbBand.fMask |= RBBIM_BACKGROUND;
      rbBand.hbmBack = static_cast<HBITMAP>(pbmp);
   }
   return _AddBar(pParent, pBar, &rbBand);
}

static BOOL AddBar1(HWND pParent, HWND pBar, COLORREF clrFore, COLORREF clrBack, LPCTSTR pszText, DWORD dwStyle)
{
   REBARBANDINFO rbBand;
   memset(&rbBand, '\0', sizeof(rbBand));
   rbBand.fMask = RBBIM_STYLE | RBBIM_COLORS;
   rbBand.fStyle = dwStyle;
   rbBand.clrFore = clrFore;
   rbBand.clrBack = clrBack;
   if( pszText != nullptr )
   {
      rbBand.fMask |= RBBIM_TEXT;
      rbBand.lpText = const_cast<LPTSTR>(pszText);
   }
   return _AddBar(pParent, pBar, &rbBand);
}

HB_FUNC( HWG_ADDBARBITMAP )
{
   void * hStr;
   hb_retl(AddBar(hwg_par_HWND(1), hwg_par_HWND(2), HB_PARSTR(3, &hStr, nullptr), hwg_par_HBITMAP(4), hb_parnl(5)));
   hb_strfree(hStr);
}

HB_FUNC( HWG_ADDBARCOLORS )
{
   void * hStr;
   hb_retl(AddBar1(hwg_par_HWND(1), hwg_par_HWND(2), static_cast<COLORREF>(hb_parnl(3)), static_cast<COLORREF>(hb_parnl(4)), HB_PARSTR(5, &hStr, nullptr), hb_parnl(6)));
   hb_strfree(hStr);
}

HB_FUNC( HWG_COMBOGETITEMRECT )
{
   RECT rcItem;
   SendMessage(hwg_par_HWND(1), LB_GETITEMRECT, hb_parnl(2), reinterpret_cast<LPARAM>(&rcItem));
   hb_itemRelease(hb_itemReturn(Rect2Array(&rcItem)));
}

HB_FUNC( HWG_GETLOCALEINFO )
{
   TCHAR szBuffer[10] = { 0 };
   GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SLIST, szBuffer, HB_SIZEOFARRAY(szBuffer));
   HB_RETSTR(szBuffer);
}

HB_FUNC( HWG_DEFWINDOWPROC )
{
//   WNDPROC wpProc = static_cast<WNDPROC>(hb_parnl(1));
   hb_retnl(DefWindowProc(hwg_par_HWND(1), hb_parnl(2), static_cast<WPARAM>(hb_parnl(3)), hwg_par_LPARAM(4)));
}

HB_FUNC( HWG_CALLWINDOWPROC )
{
   WNDPROC wpProc = reinterpret_cast<WNDPROC>(static_cast<ULONG_PTR>(hb_parnl(1)));
   hb_retnl(CallWindowProc(wpProc, hwg_par_HWND(2), hb_parnl(3), static_cast<WPARAM>(hb_parnl(4)), hwg_par_LPARAM(5)));
}

HB_FUNC( HWG_BUTTONGETDLGCODE )
{
   LPARAM lParam = reinterpret_cast<LPARAM>(HB_PARHANDLE(1));
   if( lParam )
   {
      MSG *pMsg = reinterpret_cast<MSG*>(lParam);

      if( pMsg && (pMsg->message == WM_KEYDOWN) && (pMsg->wParam == VK_TAB) )
      {
         // don't interfere with tab processing
         hb_retnl(0);
         return;
      }
   }
   hb_retnl(DLGC_WANTALLKEYS); // we want all keys except TAB key
}

HB_FUNC( HWG_GETDLGMESSAGE )
{
   LPARAM lParam = reinterpret_cast<LPARAM>(HB_PARHANDLE(1));
   if( lParam )
   {
      MSG *pMsg = reinterpret_cast<MSG*>(lParam);

      if( pMsg )
      {
         hb_retnl(pMsg->message);
         return;
      }
   }
   hb_retnl(0);
}

HB_FUNC( HWG_GETUTCTIMEDATE ) /* Format: W,YYYYMMDD-HH:MM:SS */
{
  SYSTEMTIME st = { 0 };
  char cst[41] = { 0 };
  GetSystemTime(&st);
  sprintf(cst, "%01d.%04d%02d%02d-%02d:%02d:%02d", st.wDayOfWeek, st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
  HB_RETSTR(cst);
}

HB_FUNC( HWG_GETDATEANSI ) /* Format: YYYYMMDD, based on local time */
{
  SYSTEMTIME lt = { 0 };
  char cst[41] = { 0 };
  GetLocalTime(&lt);
  sprintf(cst, "%04d%02d%02d", lt.wYear, lt.wMonth, lt.wDay);
  HB_RETSTR(cst);
}

HB_FUNC( HWG_GETLOCALEINFON )
{
   /* returns Windows LCID, type is int */
   hb_retni(GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SLIST, nullptr, 0));
}

HB_FUNC( HWG_DEFUSERLANG ) /* Windows only , on other OSs available, returns forever "-1". */
{
  char clang[25] = { 0 };
  LANGID l;  /* ==> WORD */
  l = GetUserDefaultUILanguage();
  sprintf(clang, "%d", l);
  HB_RETSTR(clang);
}

/*
 DF7BE : Ticket #64
 hwg_ShowCursor( lcursor )
*/
HB_FUNC( HWG_SHOWCURSOR )
{
   hb_retni(ShowCursor(hb_parl(1)));
}
