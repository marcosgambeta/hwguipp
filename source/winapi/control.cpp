/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C level controls functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#define HB_OS_WIN_32_USED

#define OEMRESOURCE

#include "hwingui.hpp"
#include <commctrl.h>
#include <winuser.h>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbdate.hpp>
#include <hbtrace.hpp>
/* Suppress compiler warnings */
#include "incomp_pointer.hpp"
#include "warnings.hpp"

#if defined(__BORLANDC__) || defined(_MSC_VER)
HB_EXTERN_BEGIN
WINUSERAPI HWND WINAPI GetAncestor(HWND hwnd, UINT gaFlags);
HB_EXTERN_END
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
LRESULT APIENTRY ListSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
LRESULT APIENTRY TrackSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static auto s_lInitCmnCtrl = false;
static WNDPROC wpOrigTrackProc, wpOrigListProc;

/*
HWG_INITCOMMONCONTROLSEX() --> NIL
*/
HB_FUNC( HWG_INITCOMMONCONTROLSEX )
{
   if( !s_lInitCmnCtrl ) {
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
   CreateOwnBtn(hParentWIndow, nBtnControlID, x, y, nWidth, nHeight)
*/
HB_FUNC( HWG_CREATEOWNBTN )
{
   auto hWndPanel = CreateWindowEx(0,
                                   TEXT("OWNBTN"),
                                   nullptr,
                                   WS_CHILD | WS_VISIBLE | SS_GRAYRECT | SS_OWNERDRAW,
                                   hwg_par_int(3),
                                   hwg_par_int(4),
                                   hwg_par_int(5),
                                   hwg_par_int(6),
                                   hwg_par_HWND(1),
                                   reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                                   GetModuleHandle(nullptr),
                                   nullptr);
   hb_retptr(hWndPanel);
}

/*
   CreateBrowse(hParentWIndow, nControlID, nStyle, x, y, nWidth, nHeight, cTitle)
*/
HB_FUNC( HWG_CREATEBROWSE )
{
   DWORD dwStyle = hb_parnl(3);
   void * hStr;
   auto hWndBrw = CreateWindowEx((dwStyle & WS_BORDER) ? WS_EX_CLIENTEDGE : 0,
                                 TEXT("BROWSE"),
                                 HB_PARSTR(8, &hStr, nullptr),
                                 WS_CHILD | WS_VISIBLE | dwStyle,
                                 hwg_par_int(4),
                                 hwg_par_int(5),
                                 hwg_par_int(6),
                                 hwg_par_int(7),
                                 hwg_par_HWND(1),
                                 reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                                 GetModuleHandle(nullptr),
                                 nullptr);
   hb_strfree(hStr);
   hb_retptr(hWndBrw);
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
   auto hwndStatus = CreateWindowEx(0,
                                    STATUSCLASSNAME,
                                    nullptr,
                                    SBARS_SIZEGRIP | WS_CHILD | WS_VISIBLE | WS_OVERLAPPED | WS_CLIPSIBLINGS,
                                    0,
                                    0,
                                    0,
                                    0,
                                    hwg_par_HWND(1),
                                    reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                                    GetModuleHandle(nullptr),
                                    nullptr);

   hb_retptr(hwndStatus);
}

HB_FUNC( HWG_INITSTATUS )
{
   auto hParent = hwg_par_HWND(1);
   auto hStatus = hwg_par_HWND(2);
   RECT rcClient;
   HLOCAL hloc;
   int nWidth, j;
   auto nParts = hb_parni(3);
   auto pArray = hb_param(4, Harbour::Item::ARRAY);

   // Allocate an array for holding the right edge coordinates.
   hloc = LocalAlloc(LHND, sizeof(int) * nParts);
   auto lpParts = static_cast<LPINT>(LocalLock(hloc));

   if( !pArray || hb_arrayGetNI(pArray, 1) == 0 ) {
      // Get the coordinates of the parent window's client area.
      GetClientRect(hParent, &rcClient);
      // Calculate the right edge coordinate for each part, and
      // copy the coordinates to the array.
      nWidth = rcClient.right / nParts;
      for( auto i = 0; i < nParts; i++ ) {
         lpParts[i] = nWidth;
         nWidth += nWidth;
      }
   } else {
      nWidth = 0;
      for( ULONG ul = 1; ul <= static_cast<ULONG>(nParts); ul++ ) {
         j = hb_arrayGetNI(pArray, ul);
         if( ul == static_cast<ULONG>(nParts) && j == 0 ) {
            nWidth = -1;
         } else {
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
   hb_retnl(static_cast<LONG>(((static_cast<NMMOUSE*>(hb_parptr(1)))->dwItemSpec)));
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
   hb_retni(static_cast<WORD>((static_cast<TC_KEYDOWN*>(hb_parptr(1)))->wVKey));
}

/*
 * CreateImagelist(array, cx, cy, nGrow, flags)
*/
HB_FUNC( HWG_CREATEIMAGELIST )
{
   auto pArray = hb_param(1, Harbour::Item::ARRAY);
   UINT flags = (HB_ISNIL(5)) ? ILC_COLOR : hb_parni(5);
   HIMAGELIST himl;
   ULONG ulLen = hb_arrayLen(pArray);
   HBITMAP hbmp;

   himl = ImageList_Create(hb_parni(2), hb_parni(3), flags, ulLen, hb_parni(4));

   for( ULONG ul = 1; ul <= ulLen; ul++ ) {
      hbmp = static_cast<HBITMAP>(hb_arrayGetPtr(pArray, ul));
      ImageList_Add(himl, hbmp, nullptr);
      DeleteObject(hbmp);
   }

   hb_retptr(himl);
}

HB_FUNC( HWG_IMAGELIST_ADD )
{
   hb_retnl(ImageList_Add(hwg_par_HIMAGELIST(1), hwg_par_HBITMAP(2), nullptr));
}

HB_FUNC( HWG_IMAGELIST_ADDMASKED )
{
   hb_retnl(ImageList_AddMasked(hwg_par_HIMAGELIST(1), hwg_par_HBITMAP(2), hwg_par_COLORREF(3)));
}

HB_FUNC( HWG_DESTROYIMAGELIST )
{
   ImageList_Destroy(hwg_par_HIMAGELIST(1));
}

HB_FUNC( HWG_GETPARENT )
{
   hb_retptr(GetParent(hwg_par_HWND(1)));
}

HB_FUNC( HWG_GETANCESTOR )
{
   hb_retptr(GetAncestor(hwg_par_HWND(1), hb_parni(2)));
}

HB_FUNC( HWG_LOADCURSOR )
{
   void * hStr;
   LPCTSTR lpStr = HB_PARSTR(1, &hStr, nullptr);

   if( lpStr ) {
      hb_retptr(LoadCursor(GetModuleHandle(nullptr), lpStr));
   } else {
      hb_retptr(LoadCursor(nullptr, MAKEINTRESOURCE(hb_parni(1))));
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
   if( hCursor == nullptr ) {
      /* in case of error return default cursor "Arrow" */
      hb_retptr(LoadCursor(nullptr, IDC_ARROW));
   } else {
      hb_retptr(hCursor);
   }

   hb_strfree(hStr);
}

HB_FUNC( HWG_SETCURSOR )
{
   hb_retptr(SetCursor(static_cast<HCURSOR>(hb_parptr(1))));
}

HB_FUNC( HWG_GETCURSOR )
{
   hb_retptr(GetCursor());
}

HB_FUNC( HWG_REGOWNBTN )
{
   static auto bRegistered = false;

   WNDCLASS wndclass;

   if( !bRegistered ) {
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
   static auto bRegistered = false;

   if( !bRegistered ) {
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

HB_FUNC( HWG_INITWINCTRL )
{
   SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(WinCtrlProc));
}

LRESULT CALLBACK WinCtrlProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

   if( !pSym_onEvent ) {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject ) {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
//      hb_vmPushLong(static_cast<LONG>(wParam));
//      hb_vmPushLong(static_cast<LONG>(lParam));
      hb_vmPushPointer(reinterpret_cast<void*>(wParam));
      hb_vmPushPointer(reinterpret_cast<void*>(lParam));
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) ) {
         return reinterpret_cast<LRESULT>(hb_parptr(-1));
      } else {
         long int res = hb_parnl(-1);
         if( res == -1 ) {
            return (DefWindowProc(hWnd, message, wParam, lParam));
         } else {
            return res;
         }
      }
   } else {
      return (DefWindowProc(hWnd, message, wParam, lParam));
   }
}

LRESULT APIENTRY ListSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

   if( !pSym_onEvent ) {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject ) {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
//      hb_vmPushLong(static_cast<LONG>(wParam));
//      hb_vmPushLong(static_cast<LONG>(lParam));
      hb_vmPushPointer(reinterpret_cast<void*>(wParam));
      hb_vmPushPointer(reinterpret_cast<void*>(lParam));
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) ) {
         return reinterpret_cast<LRESULT>(hb_parptr(-1));
      } else {
         long int res = hb_parnl(-1);
         if( res == -1 ) {
            return (CallWindowProc(wpOrigListProc, hWnd, message, wParam, lParam));
         } else {
            return res;
         }
      }
   } else {
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
   auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

   if( !pSym_onEvent ) {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject ) {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
//      hb_vmPushLong(static_cast<LONG>(wParam));
//      hb_vmPushLong(static_cast<LONG>(lParam));
      hb_vmPushPointer(reinterpret_cast<void*>(wParam));
      hb_vmPushPointer(reinterpret_cast<void*>(lParam));
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) ) {
         return reinterpret_cast<LRESULT>(hb_parptr(-1));
      } else {
         long int res = hb_parnl(-1);
         if( res == -1 ) {
            return (CallWindowProc(wpOrigTrackProc, hWnd, message, wParam, lParam));
         } else {
            return res;
         }
      }
   } else {
      return (CallWindowProc(wpOrigTrackProc, hWnd, message, wParam, lParam));
   }
}

HB_FUNC( HWG_CREATEPAGER )
{
   BOOL bVert = hb_parl(8);
   auto hWndPanel = CreateWindowEx(0,
                                   WC_PAGESCROLLER,
                                   nullptr,
                                   WS_CHILD | WS_VISIBLE | bVert ? PGS_VERT : PGS_HORZ | hb_parnl(3),
                                   hwg_par_int(4),
                                   hwg_par_int(5),
                                   hwg_par_int(6),
                                   hwg_par_int(7),
                                   hwg_par_HWND(1),
                                   reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                                   GetModuleHandle(nullptr),
                                   nullptr);
   hb_retptr(hWndPanel);
}

HB_FUNC( HWG_CREATEREBAR )
{
   ULONG ulStyle = hb_parnl(3);
   ULONG ulExStyle = ((!HB_ISNIL(8)) ? hb_parnl(8) : 0) | ((ulStyle & WS_BORDER) ? WS_EX_CLIENTEDGE : 0) | WS_EX_TOOLWINDOW;
   auto hWndCtrl = CreateWindowEx(ulExStyle,
                                  REBARCLASSNAME,
                                  nullptr,
                                  WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | RBS_VARHEIGHT | CCS_NODIVIDER | ulStyle,
                                  hwg_par_int(4),
                                  hwg_par_int(5),
                                  hwg_par_int(6),
                                  hwg_par_int(7),
                                  hwg_par_HWND(1),
                                  reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                                  GetModuleHandle(nullptr),
                                  nullptr);
   hb_retptr(hWndCtrl);
}

HB_FUNC( HWG_REBARSETIMAGELIST )
{
   HIMAGELIST p = (HB_ISNUM(2) || HB_ISPOINTER(2)) ? hwg_par_HIMAGELIST(2) : nullptr;
   REBARINFO rbi{};
   rbi.cbSize = sizeof(REBARINFO);
   rbi.fMask = (HB_ISNUM(2) || HB_ISPOINTER(2)) ? RBIM_IMAGELIST : 0;
   rbi.himl = (HB_ISNUM(2) || HB_ISPOINTER(2)) ? static_cast<HIMAGELIST>(p) : nullptr;
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
   bResult = SendMessage(pParent, RB_INSERTBAND, -1, reinterpret_cast<LPARAM>(pRBBI));

   return bResult;
}

static BOOL AddBar(HWND pParent, HWND pBar, LPCTSTR pszText, HBITMAP pbmp, DWORD dwStyle)
{
   REBARBANDINFO rbBand{};

   rbBand.fMask = RBBIM_STYLE;
   rbBand.fStyle = dwStyle;
   if( pszText != nullptr ) {
      rbBand.fMask |= RBBIM_TEXT;
      rbBand.lpText = const_cast<LPTSTR>(pszText);
   }
   if( pbmp != nullptr ) {
      rbBand.fMask |= RBBIM_BACKGROUND;
      rbBand.hbmBack = static_cast<HBITMAP>(pbmp);
   }
   return _AddBar(pParent, pBar, &rbBand);
}

static BOOL AddBar1(HWND pParent, HWND pBar, COLORREF clrFore, COLORREF clrBack, LPCTSTR pszText, DWORD dwStyle)
{
   REBARBANDINFO rbBand{};
   rbBand.fMask = RBBIM_STYLE | RBBIM_COLORS;
   rbBand.fStyle = dwStyle;
   rbBand.clrFore = clrFore;
   rbBand.clrBack = clrBack;
   if( pszText != nullptr ) {
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
   hb_retl(AddBar1(hwg_par_HWND(1), hwg_par_HWND(2), hwg_par_COLORREF(3), hwg_par_COLORREF(4), HB_PARSTR(5, &hStr, nullptr), hb_parnl(6)));
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
   TCHAR szBuffer[10] = {0};
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
   auto wpProc = reinterpret_cast<WNDPROC>(static_cast<ULONG_PTR>(hb_parnl(1)));
   hb_retnl(CallWindowProc(wpProc, hwg_par_HWND(2), hb_parnl(3), static_cast<WPARAM>(hb_parnl(4)), hwg_par_LPARAM(5)));
}

HB_FUNC( HWG_BUTTONGETDLGCODE )
{
   auto lParam = reinterpret_cast<LPARAM>(hb_parptr(1));
   if( lParam ) {
      auto pMsg = reinterpret_cast<MSG*>(lParam);

      if( pMsg && (pMsg->message == WM_KEYDOWN) && (pMsg->wParam == VK_TAB) ) {
         // don't interfere with tab processing
         hb_retnl(0);
         return;
      }
   }
   hb_retnl(DLGC_WANTALLKEYS); // we want all keys except TAB key
}

HB_FUNC( HWG_GETDLGMESSAGE )
{
   auto lParam = reinterpret_cast<LPARAM>(hb_parptr(1));
   if( lParam ) {
      auto pMsg = reinterpret_cast<MSG*>(lParam);

      if( pMsg ) {
         hb_retnl(pMsg->message);
         return;
      }
   }
   hb_retnl(0);
}

HB_FUNC( HWG_GETUTCTIMEDATE ) /* Format: W,YYYYMMDD-HH:MM:SS */
{
  SYSTEMTIME st = {0};
  TCHAR cst[41] = {0};
  GetSystemTime(&st);
  sprintf((char*) cst, "%01d.%04d%02d%02d-%02d:%02d:%02d", st.wDayOfWeek, st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
  HB_RETSTR(cst);
}

HB_FUNC( HWG_GETDATEANSI ) /* Format: YYYYMMDD, based on local time */
{
  SYSTEMTIME lt = {0};
  TCHAR cst[41] = {0};
  GetLocalTime(&lt);
  sprintf((char*) cst, "%04d%02d%02d", lt.wYear, lt.wMonth, lt.wDay);
  HB_RETSTR(cst);
}

HB_FUNC( HWG_GETLOCALEINFON )
{
   /* returns Windows LCID, type is int */
   hb_retni(GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SLIST, nullptr, 0));
}

HB_FUNC( HWG_DEFUSERLANG ) /* Windows only, on other OSs available, returns forever "-1". */
{
  TCHAR clang[25] = {0};
  LANGID l;  /* ==> WORD */
  l = GetUserDefaultUILanguage();
  sprintf((char*) clang, "%d", l);
  HB_RETSTR(clang);
}

/*
 DF7BE : Ticket #64
 hwg_ShowCursor(lcursor)
*/
HB_FUNC( HWG_SHOWCURSOR )
{
   hb_retni(ShowCursor(hb_parl(1)));
}
