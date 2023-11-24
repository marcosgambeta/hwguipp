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

#ifndef TTS_BALLOON
   #define TTS_BALLOON             0x40    // added by MAG
#endif

static HWND s_hWndTT = nullptr;
static auto s_lToolTipBalloon = false;

/*
HWG_ADDTOOLTIP(HWND, cText) --> .T.|.F.
*/
HB_FUNC( HWG_ADDTOOLTIP )
{
   auto hWnd = hwg_par_HWND(1);
   int iStyle = 0;
   void * hStr;

   if( s_lToolTipBalloon ) {
      iStyle = TTS_BALLOON;
   }

   if( !s_hWndTT ) {
      s_hWndTT = CreateWindowEx(0,
                                TOOLTIPS_CLASS,
                                nullptr,
                                WS_POPUP | TTS_ALWAYSTIP | iStyle,
                                CW_USEDEFAULT,
                                CW_USEDEFAULT,
                                CW_USEDEFAULT,
                                CW_USEDEFAULT,
                                nullptr,
                                nullptr,
                                GetModuleHandle(nullptr),
                                nullptr);
   }
   if( !s_hWndTT ) {
      hb_retl(false);
      return;
   }

   TOOLINFO ti{};
   ti.cbSize = sizeof(TOOLINFO);
   ti.uFlags = TTF_SUBCLASS | TTF_IDISHWND;
   ti.hwnd = GetParent(static_cast<HWND>(hWnd));
   ti.uId = reinterpret_cast<UINT_PTR>(hWnd);
   ti.hinst = GetModuleHandle(nullptr);
   ti.lpszText = const_cast<PTSTR>(HB_PARSTR(2, &hStr, nullptr));

   hb_retl(SendMessage(s_hWndTT, TTM_ADDTOOL, 0, reinterpret_cast<LPARAM>(static_cast<LPTOOLINFO>(&ti))));
   hb_strfree(hStr);
}

/*
HWG_DELTOOLTIP(HWND) --> NIL
*/
HB_FUNC( HWG_DELTOOLTIP )
{
   auto hWnd = hwg_par_HWND(1);

   if( s_hWndTT ) {
      TOOLINFO ti{};
      ti.cbSize = sizeof(TOOLINFO);
      ti.uFlags = TTF_IDISHWND;
      ti.hwnd = GetParent(static_cast<HWND>(hWnd));
      ti.uId = reinterpret_cast<UINT_PTR>(hWnd);
      ti.hinst = GetModuleHandle(nullptr);

      SendMessage(s_hWndTT, TTM_DELTOOL, 0, reinterpret_cast<LPARAM>(static_cast<LPTOOLINFO>(&ti)));
   }
}

/*
HWG_SETTOOLTIPTITLE(HWND, cTitle) --> .T.|.F.
*/
HB_FUNC( HWG_SETTOOLTIPTITLE )
{
   auto hWnd = hwg_par_HWND(1);

   if( s_hWndTT ) {
      void * hStr;

      TOOLINFO ti{};
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

/*
HWG_GETTOOLTIPHANDLE() --> pointer
*/
HB_FUNC( HWG_GETTOOLTIPHANDLE )
{
   hb_retptr(s_hWndTT);
}

/*
HWG_SETTOOLTIPBALLOON(lToolTipBalloon) --> NIL
*/
HB_FUNC( HWG_SETTOOLTIPBALLOON )
{
   s_lToolTipBalloon = hb_parl(1);
   s_hWndTT = nullptr;
}

/*
HWG_GETTOOLTIPBALLOON() --> .T.|.F.
*/
HB_FUNC( HWG_GETTOOLTIPBALLOON )
{
   hb_retl(s_lToolTipBalloon);
}
