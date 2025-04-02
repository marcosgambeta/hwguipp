//
// HWGUI - Harbour Win32 GUI library source code:
// HMonthCalendar class
//
// Copyright 2004,2023 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
// www - http://github.com/marcosgambeta/
//

#include "windows.ch"
#include <hbclass.ch>
#include "guilib.ch"

#define MCS_DAYSTATE             1
#define MCS_MULTISELECT          2
#define MCS_WEEKNUMBERS          4
#define MCS_NOTODAYCIRCLE        8
#define MCS_NOTODAY             16

CLASS HMonthCalendar INHERIT HControl

   CLASS VAR winclass INIT "SysMonthCal32"

   DATA dValue
   DATA bChange

   METHOD New(oWndParent, nId, vari, nStyle, nX, nY, nWidth, nHeight, ;
              oFont, bInit, bChange, cTooltip, lNoToday, lNoTodayCircle, ;
              lWeekNumbers)
   METHOD Activate()
   METHOD Init()
   METHOD Value(dValue) SETGET

ENDCLASS

METHOD HMonthCalendar:New(oWndParent, nId, vari, nStyle, nX, nY, nWidth, nHeight, ;
           oFont, bInit, bChange, cTooltip, lNoToday, lNoTodayCircle, ;
           lWeekNumbers)

   IF pcount() == 0
      ::Super:New(NIL, NIL, WS_TABSTOP, 0, 0, 200, 200, NIL, NIL, NIL, NIL, NIL, NIL, NIL)
      HWG_InitCommonControlsEx()
      ::Activate()
      RETURN Self
   ENDIF

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP)
   nStyle += IIf(lNoToday == NIL .OR. !lNoToday, 0, MCS_NOTODAY)
   nStyle += IIf(lNoTodayCircle == NIL .OR. !lNoTodayCircle, 0, MCS_NOTODAYCIRCLE)
   nStyle += IIf(lWeekNumbers == NIL .OR. !lWeekNumbers, 0, MCS_WEEKNUMBERS)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, NIL, NIL, cTooltip)

   ::dValue := IIf(ValType(vari) == "D" .And. !Empty(vari), vari, Date())

   ::bChange := bChange

   HWG_InitCommonControlsEx()

   IF bChange != NIL
      ::oParent:AddEvent(MCN_SELECT, ::id, bChange, .T., "onChange")
      ::oParent:AddEvent(MCN_SELCHANGE, ::id, bChange, .T., "onChange")
   ENDIF

   ::Activate()
   RETURN Self

METHOD HMonthCalendar:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_initmonthcalendar(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HMonthCalendar:Init()

   IF !::lInit
      ::Super:Init()
      IF !Empty(::dValue)
         hwg_setmonthcalendardate(::handle, ::dValue)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HMonthCalendar:Value(dValue)

   IF dValue != NIL
      IF ValType(dValue) == "D" .And. !Empty(dValue)
         hwg_setmonthcalendardate(::handle, dValue)
         ::dValue := dValue
      ENDIF
   ELSE
      ::dValue := hwg_getmonthcalendardate(::handle)
   ENDIF
   RETURN ::dValue

FUNCTION hwg_pCalendar(dstartdate, cTitle, cOK, cCancel, nx, ny, wid, hei)
// Date picker command for all platforms in the design of original
// Windows only DATEPICKER command

   LOCAL oDlg
   LOCAL oMC
   LOCAL oFont
   LOCAL dolddate
   LOCAL dnewdate
   LOCAL lcancel

   IF cTitle == NIL
      cTitle := "Calendar"
   ENDIF

   IF cOK == NIL
      cOK := "OK"
   ENDIF

   IF cCancel == NIL
      cCancel := "Cancel"
   ENDIF

   IF dstartdate == NIL
      dstartdate := DATE()
   ENDIF

   IF nx == NIL
      nx := 0  // old: 20
   ENDIF

   IF ny == NIL
      ny := 0  // old: 20
   ENDIF

   IF wid == NIL
      wid := 200 // old: 80
   ENDIF

   IF hei == NIL
      hei := 160 // old: 20
   ENDIF

  oFont := hwg_DefaultFont()

  lcancel := .T.

  // Remember old date
  dolddate := dstartdate

   INIT DIALOG oDlg TITLE cTitle AT nx, ny SIZE wid, hei + 23 // wid, hei, 22 = height of buttons

   @ 0, 0 MONTHCALENDAR oMC SIZE wid - 1, hei - 1 INIT dstartdate ; // Date(), if NIL
      FONT oFont

   @ 0, hei BUTTON cOK FONT oFont ON CLICK {||lcancel := .F., dnewdate := oMC:Value, oDlg:Close()} SIZE 80, 22
   @ 81, hei BUTTON cCancel FONT oFont ON CLICK {||oDlg:Close()} SIZE 80, 22

   ACTIVATE DIALOG oDlg

   IF lcancel
      dnewdate := dolddate
   ENDIF

   RETURN dnewdate

FUNCTION hwg_oDatepicker_bmp()
// Returns the bimap object of image Datepick_Button2.bmp
// (size 11 x 11)
// for the multi platform datepicker based on HMONTHCALENDAR class

RETURN HBitmap():AddString("Datepick_Button", hwg_cHex2Bin(;
"42 4D 6A 00 00 00 00 00 00 00 3E 00 00 00 28 00 " + ;
"00 00 0B 00 00 00 0B 00 00 00 01 00 01 00 00 00 " + ;
"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 " + ;
"00 00 00 00 00 00 F0 FB FF 00 00 00 00 00 00 00 " + ;
"00 00 00 00 00 00 00 00 00 00 04 00 00 00 0E 00 " + ;
"00 00 1F 00 00 00 3F 80 00 00 00 00 00 00 00 00 " + ;
"00 00 00 00 00 00 00 00 00 00 "))

#pragma BEGINDUMP

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

HB_FUNC( HWG_INITMONTHCALENDAR )
{
   RECT rc;

   auto hMC = CreateWindowEx(0,
                             MONTHCAL_CLASS,
                             TEXT(""),
                             hb_parnl(3),
                             hwg_par_int(4),
                             hwg_par_int(5),
                             hwg_par_int(6),
                             hwg_par_int(7),
                             hwg_par_HWND(1),
                             reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                             GetModuleHandle(nullptr),
                             nullptr);

   MonthCal_GetMinReqRect(hMC, &rc);

   //Setwindowpos(hMC, nullptr, hb_parni(4), hb_parni(5), rc.right, rc.bottom, SWP_NOZORDER);
   SetWindowPos(hMC, nullptr, hb_parni(4), hb_parni(5), hb_parni(6), hb_parni(7), SWP_NOZORDER);

   hb_retptr(hMC);
}

HB_FUNC( HWG_SETMONTHCALENDARDATE ) // adaptation of hwg_Setdatepicker of file Control.c
{
   auto pDate = hb_param(2, Harbour::Item::DATE);

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

HB_FUNC( HWG_GETMONTHCALENDARDATE ) // adaptation of hwg_Getdatepicker of file Control.c
{
   SYSTEMTIME st;
   char szDate[9];

   SendMessage(hwg_par_HWND(1), MCM_GETCURSEL, 0, reinterpret_cast<LPARAM>(&st));

   hb_dateStrPut(szDate, st.wYear, st.wMonth, st.wDay);
   szDate[8] = 0;
   hb_retds(szDate);
}

#pragma ENDDUMP
