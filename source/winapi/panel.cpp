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

/*
   CreatePanel(hParentWindow, nPanelControlID, nStyle, x1, y1, nWidth, nHeight)
*/
HB_FUNC( HWG_CREATEPANEL )
{
   auto hWndPanel = CreateWindowEx(0, TEXT("PANEL"),   /* predefined class  */
         nullptr,                  /* no window title   */
         WS_CHILD | WS_VISIBLE | SS_GRAYRECT | SS_OWNERDRAW | CCS_TOP | hb_parnl(3),
         hwg_par_int(4), hwg_par_int(5),  hwg_par_int(6), hwg_par_int(7),
         hwg_par_HWND(1),
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
         GetModuleHandle(nullptr), nullptr);
   hb_retptr(hWndPanel);
   // SS_ETCHEDHORZ
}

HB_FUNC( HWG_REGPANEL )
{
   static bool bRegistered = false;

   if( !bRegistered ) {
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
