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
#include <hbapiitm.h>
#include <hbvm.h>
#include <hbdate.h>
#include <hbtrace.h>
/* Suppress compiler warnings */
#include "incomp_pointer.h"
#include "warnings.h"

static void CALLBACK s_timerProc(HWND, UINT, UINT, DWORD);

/*
 *  SetTimer(hWnd, idTimer, i_MilliSeconds)
 */

/* 22/09/2005 - <maurilio.longo@libero.it>
      If I pass a fourth parameter as 0 (zero) I don't set
      the TimerProc, this way I can receive WM_TIMER messages
      inside an ON OTHER MESSAGES code block
*/
HB_FUNC( HWG_SETTIMER )
{
   SetTimer(hwg_par_HWND(1), hwg_par_UINT_PTR(2), hwg_par_UINT(3), hb_pcount() == 3 ?  reinterpret_cast<TIMERPROC>(reinterpret_cast<UINT_PTR>(s_timerProc)) : nullptr);
}

/*
 *  KillTimer(hWnd, idTimer)
 */

HB_FUNC( HWG_KILLTIMER )
{
   hb_retl(KillTimer(hwg_par_HWND(1), hwg_par_UINT_PTR(2)));
}

static void CALLBACK s_timerProc(HWND hWnd, UINT message, UINT idTimer, DWORD dwTime) /* DWORD dwTime as last parameter unused */
{
   static PHB_DYNS s_pSymTest = nullptr;

   HB_SYMBOL_UNUSED(message);

   if( s_pSymTest == nullptr )
   {
      s_pSymTest = hb_dynsymGetCase("HWG_TIMERPROC");
   }

   if( hb_dynsymIsFunction(s_pSymTest) )
   {
      hb_vmPushDynSym(s_pSymTest);
      hb_vmPushNil();   /* places NIL at self */
      //hb_vmPushLong(static_cast<LONG>(hWnd));    /* pushes parameters on to the hvm stack */
      HB_PUSHITEM(hWnd);
      hb_vmPushLong(static_cast<LONG>(idTimer));
      //hb_vmPushLong(static_cast<LONG>(dwTime));
      hb_vmDo(2);             /* where iArgCount is the number of pushed parameters */
   }
}
