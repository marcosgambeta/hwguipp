/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C functions for HAnimation class
 *
 * Copyright 2004 Marcos Antonio Gambeta <marcos_gambeta@hotmail.com>
 * www - http://geocities.yahoo.com.br/marcosgambeta/
*/

#include "hwingui.h"
#include <commctrl.h>

HB_FUNC( HWG_ANIMATE_CREATE )
{
   HWND hwnd = Animate_Create(hwg_par_HWND(1), static_cast<LONG>(hb_parnl(2)), static_cast<LONG>(hb_parnl(3)), GetModuleHandle(nullptr));
   MoveWindow(hwnd, hb_parnl(4), hb_parnl(5), hb_parnl(6), hb_parnl(7), TRUE);
   HB_RETHANDLE(hwnd);
}

HB_FUNC( HWG_ANIMATE_OPEN )
{
   void * hStr;
   Animate_Open(hwg_par_HWND(1), HB_PARSTR(2, &hStr, nullptr));
   hb_strfree(hStr);
}

HB_FUNC( HWG_ANIMATE_PLAY )
{
   Animate_Play(hwg_par_HWND(1), hb_parni(2), hb_parni(3), hb_parni(4));
}

HB_FUNC( HWG_ANIMATE_SEEK )
{
   Animate_Seek(hwg_par_HWND(1), hb_parni(2));
}

HB_FUNC( HWG_ANIMATE_STOP )
{
   Animate_Stop(hwg_par_HWND(1));
}

HB_FUNC( HWG_ANIMATE_CLOSE )
{
   Animate_Close(hwg_par_HWND(1));
}

HB_FUNC( HWG_ANIMATE_DESTROY )
{
   DestroyWindow(hwg_par_HWND(1));
}

HB_FUNC( HWG_ANIMATE_OPENEX )
{
   void * hResource;
   LPCTSTR lpResource = HB_PARSTR(3, &hResource, nullptr);

   if( !lpResource && HB_ISNUM(3) )
   {
      lpResource = MAKEINTRESOURCE(hb_parni(3));
   }

   Animate_OpenEx(hwg_par_HWND(1), reinterpret_cast<HINSTANCE>(static_cast<ULONG_PTR>(hb_parnl(2))), lpResource);

   hb_strfree(hResource);
}
