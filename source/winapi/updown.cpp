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

LRESULT APIENTRY UpDownSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static WNDPROC wpOrigUpDownProc;

/*
HWG_CREATEUPDOWNCONTROL(hParent, nID, nStyle, nX, nY, nWidth, nHeight, hBuddy, nUpper, nLower, nPos) --> hUpDown
*/
HB_FUNC( HWG_CREATEUPDOWNCONTROL ) // TODO: CreateUpDownControl is obsolet
{
   HB_RETHANDLE(CreateUpDownControl(WS_CHILD | WS_BORDER | WS_VISIBLE | hb_parni(3),
                                    hb_parni(4),
                                    hb_parni(5),
                                    hb_parni(6),
                                    hb_parni(7),
                                    hwg_par_HWND(1),
                                    hb_parni(2),
                                    GetModuleHandle(nullptr),
                                    hwg_par_HWND(8),
                                    hb_parni(9),
                                    hb_parni(10),
                                    hb_parni(11)
                                    ));
}

HB_FUNC( HWG_SETUPDOWN )
{
   SendMessage(hwg_par_HWND(1), UDM_SETPOS, 0, hb_parnl(2));
}

HB_FUNC( HWG_GETUPDOWN )
{
   hb_retnl(SendMessage(hwg_par_HWND(1), UDM_GETPOS, 0, 0));
}

HB_FUNC( HWG_SETRANGEUPDOWN )
{
   SendMessage(hwg_par_HWND(1), UDM_SETRANGE32, hb_parnl(2), hb_parnl(3));
}

HB_FUNC( HWG_GETNOTIFYDELTAPOS )
{
   int iItem = hb_parnl(2);
   if( iItem < 2 ) {
      hb_retni(static_cast<LONG>((static_cast<NMUPDOWN*>(HB_PARHANDLE(1)))->iPos));
   } else {
      hb_retni(static_cast<LONG>((static_cast<NMUPDOWN*>(HB_PARHANDLE(1)))->iDelta));
   }
}

HB_FUNC( HWG_INITUPDOWNPROC )
{
   wpOrigUpDownProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(UpDownSubclassProc)));
}

LRESULT APIENTRY UpDownSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
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
      HB_PUSHITEM(wParam);
      HB_PUSHITEM(lParam);
      hb_vmSend(3);
      if( HB_ISPOINTER(-1) ) {
         return reinterpret_cast<LRESULT>(HB_PARHANDLE(-1));
      } else {
         res = hb_parnl(-1);
         if( res == -1 ) {
            return (CallWindowProc(wpOrigUpDownProc, hWnd, message, wParam, lParam));
         } else {
            return res;
         }
      }
   } else {
      return (CallWindowProc(wpOrigUpDownProc, hWnd, message, wParam, lParam));
   }
}
