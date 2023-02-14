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
#include <hbapiitm.h>
#include <hbvm.h>
#include <hbdate.h>
#include <hbtrace.h>
/* Suppress compiler warnings */
#include "incomp_pointer.hpp"
#include "warnings.hpp"

#ifndef TTS_BALLOON
   #define TTS_BALLOON             0x40    // added by MAG
#endif

static HWND s_hWndTT = nullptr;
static bool s_lToolTipBalloon = false;

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
         nullptr, nullptr, GetModuleHandle(nullptr), nullptr);
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
