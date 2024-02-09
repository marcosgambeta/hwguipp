/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HTrackBar class
 *
 * Copyright 2004 Marcos Antonio Gambeta <marcos_gambeta@hotmail.com>
 * www - http://geocities.yahoo.com.br/marcosgambeta/
 *
 * HTrack class
 * Copyright 2021 Alexander S.Kresin <alex@kresin.ru>
 */

#define _WIN32_IE 0x0500
#define HB_OS_WIN_32_USED
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif

#include "guilib.hpp"
#include <windows.h>
#include <commctrl.h>
#include <hbapi.hpp>

HB_FUNC(HWG_INITTRACKBAR)
{
  auto hTrackBar = CreateWindowEx(
      0, TRACKBAR_CLASS, 0, hb_parnl(3), hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), hwg_par_int(7),
      hwg_par_HWND(1), reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))), GetModuleHandle(nullptr), nullptr);

  hb_retptr(hTrackBar);
}

HB_FUNC(HWG_TRACKBARSETRANGE)
{
  SendMessage(hwg_par_HWND(1), TBM_SETRANGE, TRUE, MAKELONG(hb_parni(2), hb_parni(3)));
}
