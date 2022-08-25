#include "hwingui.h"
#include <commctrl.h>

HB_FUNC( HWG_PAGERSETCHILD )
{
   HWND m_hWnd = hwg_par_HWND(1);
   HWND hWnd = hwg_par_HWND(2);

#ifndef __GNUC__
   Pager_SetChild(m_hWnd, hWnd);
#else
   SendMessage(m_hWnd, PGM_SETCHILD, 0, reinterpret_cast<LPARAM>(hWnd));
#endif
}

HB_FUNC( HWG_PAGERRECALCSIZE )
{
   HWND m_hWnd = hwg_par_HWND(1);

#ifndef __GNUC__
   Pager_RecalcSize(m_hWnd);
#else
   SendMessage(m_hWnd, PGM_RECALCSIZE, 0, 0);
#endif
}

HB_FUNC( HWG_PAGERFORWARDMOUSE )
{
   HWND m_hWnd = hwg_par_HWND(1);
   BOOL bForward = hb_parl(2);

#ifndef __GNUC__
   Pager_ForwardMouse(m_hWnd, bForward);
#else
   SendMessage(m_hWnd, PGM_FORWARDMOUSE, static_cast<WPARAM>(bForward), 0);
#endif
}

HB_FUNC( HWG_PAGERSETBKCOLOR )
{
   HWND m_hWnd = hwg_par_HWND(1);
   COLORREF clr = hwg_par_COLORREF(2);

#ifndef __GNUC__
   hb_retnl(static_cast<LONG>(Pager_SetBkColor(m_hWnd, clr)));
#else
   hb_retnl(static_cast<LONG>(SendMessage(m_hWnd, PGM_SETBKCOLOR, 0, static_cast<LPARAM>(clr))));
#endif
}

HB_FUNC( HWG_PAGERGETBKCOLOR )
{
   HWND m_hWnd = hwg_par_HWND(1);

#ifndef __GNUC__
   hb_retnl(static_cast<LONG>(Pager_GetBkColor(m_hWnd)));
#else
   hb_retnl(static_cast<LONG>(SendMessage(m_hWnd, PGM_GETBKCOLOR, 0, 0)));
#endif
}

HB_FUNC( HWG_PAGERSETBORDER )
{
   HWND m_hWnd = hwg_par_HWND(1);
   int iBorder = hb_parni(2);

#ifndef __GNUC__
   hb_retni(Pager_SetBorder(m_hWnd, iBorder));
#else
   hb_retni(SendMessage(m_hWnd, PGM_SETBORDER, 0, static_cast<LPARAM>(iBorder)));
#endif
}

HB_FUNC( HWG_PAGERGETBORDER )
{
   HWND m_hWnd = hwg_par_HWND(1);

#ifndef __GNUC__
   hb_retni(Pager_GetBorder(m_hWnd));
#else
   hb_retni(SendMessage(m_hWnd, PGM_GETBORDER, 0, 0));
#endif
}

HB_FUNC( HWG_PAGERSETPOS )
{
   HWND m_hWnd = hwg_par_HWND(1);
   int iPos = hb_parni(2);

#ifndef __GNUC__
   hb_retni(Pager_SetPos(m_hWnd, iPos));
#else
   hb_retni(SendMessage(m_hWnd, PGM_SETPOS, 0, static_cast<LPARAM>(iPos)));
#endif
}

HB_FUNC( HWG_PAGERGETPOS )
{
   HWND m_hWnd = hwg_par_HWND(1);

#ifndef __GNUC__
   hb_retni(Pager_GetPos(m_hWnd));
#else
   hb_retni(SendMessage(m_hWnd, PGM_GETPOS, 0, 0));
#endif
}

HB_FUNC( HWG_PAGERSETBUTTONSIZE )
{
   HWND m_hWnd = hwg_par_HWND(1);
   int iSize = hb_parni(2);

#ifndef __GNUC__
   hb_retni(Pager_SetButtonSize(m_hWnd, iSize));
#else
   hb_retni(SendMessage(m_hWnd, PGM_SETBUTTONSIZE, 0, static_cast<LPARAM>(iSize)));
#endif
}

HB_FUNC( HWG_PAGERGETBUTTONSIZE )
{
   HWND m_hWnd = hwg_par_HWND(1);

#ifndef __GNUC__
   hb_retni(Pager_GetButtonSize(m_hWnd));
#else
   hb_retni(SendMessage(m_hWnd, PGM_GETBUTTONSIZE, 0, 0));
#endif
}

HB_FUNC( HWG_PAGERGETBUTTONSTATE )
{
   HWND m_hWnd = hwg_par_HWND(1);
   int iButton = hb_parni(1);

#ifndef __GNUC__
   hb_retnl(Pager_GetButtonState(m_hWnd, iButton));
#else
   hb_retnl(static_cast<LONG>(SendMessage(m_hWnd, PGM_GETBUTTONSTATE, 0, static_cast<LPARAM>(iButton))));
#endif
}

HB_FUNC( HWG_PAGERONPAGERCALCSIZE )
{
   LPNMPGCALCSIZE pNMPGCalcSize = ( LPNMPGCALCSIZE ) HB_PARHANDLE(1);
   HWND hwndToolbar = hwg_par_HWND(2);
   SIZE size;

   SendMessage(hwndToolbar, TB_GETMAXSIZE, 0, reinterpret_cast<LPARAM>(&size));

   switch ( pNMPGCalcSize->dwFlag )
   {
      case PGF_CALCWIDTH:
         pNMPGCalcSize->iWidth = size.cx;
         break;

      case PGF_CALCHEIGHT:
         pNMPGCalcSize->iHeight = size.cy;
         break;
   }

   hb_retnl(0);
}

HB_FUNC( HWG_PAGERONPAGERSCROLL )
{
   LPNMPGSCROLL pNMPGScroll = ( LPNMPGSCROLL ) HB_PARHANDLE(1);

   switch ( pNMPGScroll->iDir )
   {
      case PGF_SCROLLLEFT:
      case PGF_SCROLLRIGHT:
      case PGF_SCROLLUP:
      case PGF_SCROLLDOWN:
         pNMPGScroll->iScroll = 20;

         break;
   }

   hb_retnl(0);
}
