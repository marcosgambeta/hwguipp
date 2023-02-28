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

LRESULT APIENTRY EditSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static WNDPROC wpOrigEditProc;

/*
HWG_CREATEEDIT(hParentWIndow, nEditControlID, nStyle, nX, nY, nWidth, nHeight, cInitialString) --> hEdit
*/
HB_FUNC( HWG_CREATEEDIT )
{
   ULONG ulStyle = hb_parnl(3);
   ULONG ulStyleEx = (ulStyle & WS_BORDER) ? WS_EX_CLIENTEDGE : 0;
   HWND hWndEdit;

   if( (ulStyle & WS_BORDER) ) // && (ulStyle & WS_DLGFRAME) )
   {
      ulStyle &= ~WS_BORDER;
   }

   hWndEdit = CreateWindowEx(ulStyleEx,
                             TEXT("EDIT"),
                             nullptr,
                             WS_CHILD | WS_VISIBLE | ulStyle,
                             hwg_par_int(4),
                             hwg_par_int(5),
                             hwg_par_int(6),
                             hwg_par_int(7),
                             hwg_par_HWND(1),
                             reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                             GetModuleHandle(nullptr),
                             nullptr
                             );

   if( hb_pcount() > 7 )
   {
      void * hStr;
      LPCTSTR lpText = HB_PARSTR(8, &hStr, nullptr);
      if( lpText )
      {
         SendMessage(hWndEdit, WM_SETTEXT, 0, reinterpret_cast<LPARAM>(lpText));
      }
      hb_strfree(hStr);
   }

   HB_RETHANDLE(hWndEdit);
}

HB_FUNC( HWG_INITEDITPROC )
{
   wpOrigEditProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(EditSubclassProc)));
}

LRESULT APIENTRY EditSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
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
            return (CallWindowProc(wpOrigEditProc, hWnd, message, wParam, lParam));
         }
         else
         {
            return res;
         }
      }
   }
   else
   {
      return (CallWindowProc(wpOrigEditProc, hWnd, message, wParam, lParam));
   }
}
