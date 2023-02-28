/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HMonthCalendar class
 *
 * Copyright 2004 Marcos Antonio Gambeta <marcos_gambeta@hotmail.com>
 * www - http://geocities.yahoo.com.br/marcosgambeta/
*/

#define _WIN32_IE      0x0500
#define HB_OS_WIN_32_USED
#ifndef _WIN32_WINNT
   #define _WIN32_WINNT   0x0400
#endif

#include "guilib.hpp"
#include <windows.h>
#include <commctrl.h>
#include <hbapi.hpp>
#include <hbapiitm.hpp>
#include <hbdate.hpp>

#if 0
HB_FUNC( HWG_INITMONTHCALENDAR ) // moved to hmonthcalendar.prg as static function
{
   RECT rc;

   HWND hMC = CreateWindowEx(0, MONTHCAL_CLASS, "", static_cast<LONG>(hb_parnl(3)),
      hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), hwg_par_int(7),
      hwg_par_HWND(1),
      reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
      GetModuleHandle(nullptr), nullptr);

   MonthCal_GetMinReqRect(hMC, &rc);

   //Setwindowpos(hMC, nullptr, hb_parni(4), hb_parni(5), rc.right, rc.bottom, SWP_NOZORDER);
   SetWindowPos(hMC, nullptr, hb_parni(4), hb_parni(5), hb_parni(6),hb_parni(7), SWP_NOZORDER);

   HB_RETHANDLE(hMC);
}
#endif

#if 0
HB_FUNC( HWG_SETMONTHCALENDARDATE ) // adaptation of hwg_Setdatepicker of file Control.c // // moved to hmonthcalendar.prg
{
   PHB_ITEM pDate = hb_param(2, Harbour::Item::DATE);

   if( pDate )
   {
      SYSTEMTIME sysTime;
      int lYear, lMonth, lDay;

      hb_dateDecode(hb_itemGetDL(pDate), &lYear, &lMonth, &lDay);

      sysTime.wYear = static_cast<unsigned short>(lYear);
      sysTime.wMonth = static_cast<unsigned short>(lMonth);
      sysTime.wDay = static_cast<unsigned short>(lDay);
      sysTime.wDayOfWeek = 0;
      sysTime.wHour = 0;
      sysTime.wMinute = 0;
      sysTime.wSecond = 0;
      sysTime.wMilliseconds = 0;

      MonthCal_SetCurSel(hwg_par_HWND(1), &sysTime);
   }
}
#endif

#if 0
HB_FUNC( HWG_GETMONTHCALENDARDATE ) // adaptation of hwg_Getdatepicker of file Control.c // // moved to hmonthcalendar.prg
{
   SYSTEMTIME st;
   char szDate[9];

   SendMessage(hwg_par_HWND(1), MCM_GETCURSEL, 0, reinterpret_cast<LPARAM>(&st));

   hb_dateStrPut(szDate, st.wYear, st.wMonth, st.wDay);
   szDate[8] = 0;
   hb_retds(szDate);
}
#endif
