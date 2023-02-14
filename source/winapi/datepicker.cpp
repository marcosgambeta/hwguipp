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

LRESULT APIENTRY DatePickerSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static WNDPROC wpOrigDatePickerProc;

HB_FUNC( HWG_CREATEDATEPICKER )
{
   HWND hCtrl = CreateWindowEx(WS_EX_CLIENTEDGE,
                               TEXT("SYSDATETIMEPICK32"),
                               nullptr,
                               hb_parnl(7) | WS_CHILD | WS_VISIBLE | WS_TABSTOP,
                               hwg_par_int(3),
                               hwg_par_int(4),
                               hwg_par_int(5),
                               hwg_par_int(6),
                               hwg_par_HWND(1),
                               reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                               GetModuleHandle(nullptr),
                               nullptr
                               );

   HB_RETHANDLE(hCtrl);
}

HB_FUNC( HWG_SETDATEPICKER )
{
   PHB_ITEM pDate = hb_param(2, Harbour::Item::DATE);
   ULONG ulLen;
   long lSeconds = 0;

   if( pDate )
   {
      SYSTEMTIME sysTime, st;
      int lYear, lMonth, lDay;
      int lHour, lMinute;
      int lMilliseconds = 0;
      int lSecond;

      hb_dateDecode(hb_itemGetDL(pDate), &lYear, &lMonth, &lDay);
      if( hb_pcount() < 3 )
      {
         GetLocalTime(&st);
         lHour = st.wHour;
         lMinute = st.wMinute;
         lSecond = st.wSecond;
      }
      else
      {
         const char * szTime =  hb_parc(3);
         if( szTime )
         {
            ulLen = strlen(szTime);
            if( ulLen >= 4 )
            {
               lSeconds = static_cast<LONG>(hb_strVal(szTime, 2)) * 3600 * 1000 +
                          static_cast<LONG>(hb_strVal(szTime + 2, 2)) * 60 * 1000 +
                          static_cast<LONG>(hb_strVal(szTime + 4, ulLen - 4) * 1000);
            }
         }
         hb_timeDecode(lSeconds, &lHour, &lMinute, &lSecond, &lMilliseconds);
      }

      sysTime.wYear = static_cast<unsigned short>(lYear);
      sysTime.wMonth = static_cast<unsigned short>(lMonth);
      sysTime.wDay = static_cast<unsigned short>(lDay);
      sysTime.wDayOfWeek = 0;
      sysTime.wHour = static_cast<unsigned short>(lHour);
      sysTime.wMinute = static_cast<unsigned short>(lMinute);
      sysTime.wSecond = static_cast<WORD>(lSecond);
      sysTime.wMilliseconds = static_cast<unsigned short>(lMilliseconds);

      SendMessage(hwg_par_HWND(1), DTM_SETSYSTEMTIME, GDT_VALID, reinterpret_cast<LPARAM>(&sysTime));
   }
}

HB_FUNC( HWG_SETDATEPICKERNULL )
{
   SendMessage(hwg_par_HWND(1), DTM_SETSYSTEMTIME, GDT_NONE, static_cast<LPARAM>(0));
}

HB_FUNC( HWG_GETDATEPICKER )
{
   SYSTEMTIME st;
   int iret;
   WPARAM wParam = (hb_pcount() > 1) ? hb_parnl(2) : GDT_VALID;

   iret = SendMessage(hwg_par_HWND(1), DTM_GETSYSTEMTIME, wParam, reinterpret_cast<LPARAM>(&st));
   if( wParam == GDT_VALID )
   {
      hb_retd(st.wYear, st.wMonth, st.wDay);
   }
   else
   {
      hb_retni(iret);
   }
}

HB_FUNC( HWG_INITDATEPICKERPROC )
{
   wpOrigDatePickerProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(DatePickerSubclassProc)));
}

LRESULT APIENTRY DatePickerSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
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
            return (CallWindowProc(wpOrigDatePickerProc, hWnd, message, wParam, lParam));
         }
         else
         {
            return res;
         }
      }
   }
   else
   {
      return (CallWindowProc(wpOrigDatePickerProc, hWnd, message, wParam, lParam));
   }
}

