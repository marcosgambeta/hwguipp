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

LRESULT APIENTRY StaticSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static WNDPROC wpOrigStaticProc;

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
