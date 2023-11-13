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

LRESULT APIENTRY ButtonSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

// static WNDPROC wpOrigButtonProc;
static LONG_PTR wpOrigButtonProc;

/*
HWG_CREATEBUTTON(hParentWIndow, nButtonID, nStyle, nX, nY, nWidth, nHeight, cCaption) --> hButton
*/
HB_FUNC( HWG_CREATEBUTTON )
{
   void * hStr;
   HWND hBtn = CreateWindowEx(0,
                              TEXT("BUTTON"),
                              HB_PARSTR(8, &hStr, nullptr),
                              WS_CHILD | WS_VISIBLE | hwg_par_DWORD(3),
                              hwg_par_int(4),
                              hwg_par_int(5),
                              hwg_par_int(6),
                              hwg_par_int(7),
                              hwg_par_HWND(1),
                              reinterpret_cast<HMENU>(hb_parni(2)),
                              GetModuleHandle(nullptr),
                              nullptr);
   hb_strfree(hStr);
   hb_retptr(hBtn);
}

HB_FUNC( HWG_INITBUTTONPROC )
{
//   wpOrigButtonProc = static_cast<WNDPROC>(SetWindowLong(hwg_par_HWND(1), GWL_WNDPROC, static_cast<LONG>(ButtonSubclassProc)));
   wpOrigButtonProc = static_cast<LONG_PTR>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(ButtonSubclassProc)));
}

LRESULT APIENTRY ButtonSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   long int res;
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
         res = hb_parnl(-1);
         if( res == -1 ) {
            return (CallWindowProc(reinterpret_cast<WNDPROC>(wpOrigButtonProc), hWnd, message, wParam, lParam));
         } else {
            return res;
         }
      }
   } else {
      return (CallWindowProc(reinterpret_cast<WNDPROC>(wpOrigButtonProc), hWnd, message, wParam, lParam));
   }
}
