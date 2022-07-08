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

LRESULT APIENTRY TabSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static WNDPROC wpOrigTabProc;

/*
HWG_CREATETABCONTROL(hParent, nID, nStyle, nX, nY, nWidth, nHeight) --> hTab
*/
HB_FUNC( HWG_CREATETABCONTROL )
{
   HWND hTab = CreateWindow(WC_TABCONTROL,
                            nullptr,
                            WS_CHILD | WS_VISIBLE | hb_parnl(3),
                            hwg_par_int(4),
                            hwg_par_int(5),
                            hwg_par_int(6),
                            hwg_par_int(7),
                            hwg_par_HWND(1),
                            reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                            GetModuleHandle(nullptr),
                            nullptr
                            );
   HB_RETHANDLE(hTab);
}

HB_FUNC( HWG_INITTABCONTROL )
{
   HWND hTab = hwg_par_HWND(1);
   PHB_ITEM pArr = hb_param(2, HB_IT_ARRAY);
   int iItems = hb_parnl(3);
   TC_ITEM tie;
   ULONG ulTabs = hb_arrayLen(pArr);

   tie.mask = TCIF_TEXT | TCIF_IMAGE;
   tie.iImage = iItems == 0 ? -1 : 0;

   for( ULONG ul = 1; ul <= ulTabs; ul++ )
   {
      void * hStr;

      tie.pszText = const_cast<LPTSTR>(HB_ARRAYGETSTR(pArr, ul, &hStr, nullptr));
      if( tie.pszText == nullptr )
      {
         tie.pszText = const_cast<LPTSTR>(TEXT(""));
      }

      if( TabCtrl_InsertItem(hTab, ul - 1, &tie) == -1 )
      {
         DestroyWindow(hTab);
         hTab = nullptr;
      }
      hb_strfree(hStr);

      if( tie.iImage > -1 )
      {
         tie.iImage++;
      }
   }
}

HB_FUNC( HWG_ADDTAB )
{
   TC_ITEM tie;
   void * hStr;
   tie.mask = TCIF_TEXT | TCIF_IMAGE;
   tie.iImage = -1;
   tie.pszText = const_cast<LPTSTR>(HB_PARSTR(3, &hStr, nullptr));
   TabCtrl_InsertItem(hwg_par_HWND(1), hb_parni(2), &tie);
   hb_strfree(hStr);
}

HB_FUNC( HWG_ADDTABDIALOG )
{
   TC_ITEM tie;
   void * hStr;
   HWND pWnd = hwg_par_HWND(4);

   tie.mask = TCIF_TEXT | TCIF_IMAGE | TCIF_PARAM;
   tie.lParam = reinterpret_cast<LPARAM>(pWnd);
   tie.iImage = -1;
   tie.pszText = const_cast<LPTSTR>(HB_PARSTR(3, &hStr, nullptr));
   TabCtrl_InsertItem(hwg_par_HWND(1), hb_parni(2), &tie);
   hb_strfree(hStr);
}

HB_FUNC( HWG_DELETETAB )
{
   TabCtrl_DeleteItem(hwg_par_HWND(1), hb_parni(2));
}

HB_FUNC( HWG_GETCURRENTTAB )
{
   hb_retni(TabCtrl_GetCurSel( hwg_par_HWND(1) ) + 1);
}

HB_FUNC( HWG_SETTABSIZE )
{
   SendMessage(hwg_par_HWND(1), TCM_SETITEMSIZE, 0, MAKELPARAM(hb_parni(2), hb_parni(3)));
}

HB_FUNC( HWG_SETTABNAME )
{
   TC_ITEM tie;
   void * hStr;
   tie.mask = TCIF_TEXT;
   tie.pszText = const_cast<LPTSTR>(HB_PARSTR(3, &hStr, nullptr));
   TabCtrl_SetItem(hwg_par_HWND(1), hb_parni(2)-1, &tie);
   hb_strfree(hStr);
}

HB_FUNC( HWG_TAB_HITTEST )
{
   TC_HITTESTINFO ht;
   HWND hTab = hwg_par_HWND(1);
   int res;

   if( hb_pcount() > 1 && HB_ISNUM(2) && HB_ISNUM(3) )
   {
      ht.pt.x = hb_parni(2);
      ht.pt.y = hb_parni(3);
   }
   else
   {
      GetCursorPos(&(ht.pt));
      ScreenToClient(hTab, &(ht.pt));
   }

   res = static_cast<int>(SendMessage(hTab, TCM_HITTEST, 0, reinterpret_cast<LPARAM>(&ht)));

   hb_storni(ht.flags, 4);
   hb_retni(res);
}

HB_FUNC( HWG_TABITEMPOS )
{
   RECT pRect;
   TabCtrl_GetItemRect(hwg_par_HWND(1), hb_parni(2), &pRect);
   hb_itemRelease(hb_itemReturn(Rect2Array(&pRect)));
}

HB_FUNC( HWG_GETTABNAME )
{
   TC_ITEM tie;
   TCHAR d[255] = { 0 };

   tie.mask = TCIF_TEXT;
   tie.cchTextMax = HB_SIZEOFARRAY(d) - 1;
   tie.pszText = d;
   TabCtrl_GetItem(hwg_par_HWND(1), hb_parni(2) - 1, static_cast<LPTCITEM>(&tie));
   HB_RETSTR(tie.pszText);
}

HB_FUNC( HWG_INITTABPROC )
{
   wpOrigTabProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(TabSubclassProc)));
}

LRESULT APIENTRY TabSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
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
            return (CallWindowProc(wpOrigTabProc, hWnd, message, wParam, lParam));
         }
         else
         {
            return res;
         }
      }
   }
   else
   {
      return (CallWindowProc(wpOrigTabProc, hWnd, message, wParam, lParam));
   }
}
