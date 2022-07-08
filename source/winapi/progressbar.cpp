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

/*
HWG_CREATEPROGRESSBAR(hParentWindow, nRange, ...)
*/
HB_FUNC( HWG_CREATEPROGRESSBAR )
{
   HWND hPBar, hParentWindow = hwg_par_HWND(1);
   RECT rcClient;
   ULONG ulStyle;
   int cyVScroll = GetSystemMetrics(SM_CYVSCROLL);
   int x1, y1, nwidth, nheight;

   if( hb_pcount() > 2 )
   {
      ulStyle = hb_parnl(3);
      x1 = hb_parni(4);
      y1 = hb_parni(5);
      nwidth = hb_parni(6);
      nheight = hb_pcount() > 6 && !HB_ISNIL(7) ? hb_parni(7) : cyVScroll;
   }
   else
   {
      GetClientRect(hParentWindow, &rcClient);
      ulStyle = 0;
      x1 = rcClient.left;
      y1 = rcClient.bottom - cyVScroll;
      nwidth = rcClient.right;
      nheight = cyVScroll;
   }

   hPBar = CreateWindowEx(0,
                          PROGRESS_CLASS,
                          nullptr,
                          WS_CHILD | WS_VISIBLE | ulStyle,
                          x1,
                          y1,
                          nwidth,
                          nheight,
                          hParentWindow,
                          static_cast<HMENU>(nullptr),
                          GetModuleHandle(nullptr),
                          nullptr
                          );

   SendMessage(hPBar, PBM_SETRANGE, 0, MAKELPARAM(0, hb_parni(2)));
   SendMessage(hPBar, PBM_SETSTEP, static_cast<WPARAM>(1), 0);

   HB_RETHANDLE(hPBar);
}

/*
   UpdateProgressBar(hPBar)
*/
HB_FUNC( HWG_UPDATEPROGRESSBAR )
{
   SendMessage(hwg_par_HWND(1), PBM_STEPIT, 0, 0);
}

/*
   ResetProgressBar(hPBar)
   Added by DF7BE
*/
HB_FUNC( HWG_RESETPROGRESSBAR )
{
   SendMessage(hwg_par_HWND(1), PBM_SETPOS, static_cast<WPARAM>(0) , 0);
}

/*
   SetProgressBar(hPBar , nPercent)
*/
HB_FUNC( HWG_SETPROGRESSBAR )
{
   SendMessage(hwg_par_HWND(1), PBM_SETPOS, static_cast<WPARAM>(hb_parni(2)), 0);
}

HB_FUNC( HWG_SETRANGEPROGRESSBAR )
{
   SendMessage(hwg_par_HWND(1), PBM_SETRANGE, 0, MAKELPARAM(0, hb_parni(2)));
   SendMessage(hwg_par_HWND(1), PBM_SETSTEP, 1, 0);
}
