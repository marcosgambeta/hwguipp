/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C++ functions for HAnimation class
 *
 * Copyright 2004,2022 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 * www - https://github.com/marcosgambeta/
*/

#include "hwingui.h"
#include <commctrl.h>

/*
HWG_ANIMATE_CREATE(hParent, nId, nStyle, nX, nY, nWidth, nHeight) --> handle
*/
HB_FUNC( HWG_ANIMATE_CREATE )
{
   HWND hwnd = Animate_Create(hwg_par_HWND(1), hwg_par_UINT(2), hwg_par_DWORD(3), GetModuleHandle(nullptr));
   MoveWindow(hwnd, hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), hwg_par_int(7), TRUE);
   HB_RETHANDLE(hwnd);
}

/*
HWG_ANIMATE_OPEN(HWND, cName) --> NIL
*/
HB_FUNC( HWG_ANIMATE_OPEN )
{
   void * hStr;
   Animate_Open(hwg_par_HWND(1), HB_PARSTR(2, &hStr, nullptr));
   hb_strfree(hStr);
}

/*
HWG_ANIMATE_PLAY(HWND, nFrom, nTo, nReplay) --> NIL
*/
HB_FUNC( HWG_ANIMATE_PLAY )
{
   Animate_Play(hwg_par_HWND(1), hwg_par_UINT(2), hwg_par_UINT(3), hwg_par_UINT(4));
}

/*
HWG_ANIMATE_SEEK(HWND, nFrame) --> NIL
*/
HB_FUNC( HWG_ANIMATE_SEEK )
{
   Animate_Seek(hwg_par_HWND(1), hwg_par_UINT(2));
}

/*
HWG_ANIMATE_STOP(HWND) --> NIL
*/
HB_FUNC( HWG_ANIMATE_STOP )
{
   Animate_Stop(hwg_par_HWND(1));
}

/*
HWG_ANIMATE_CLOSE(HWND) --> NIL
*/
HB_FUNC( HWG_ANIMATE_CLOSE )
{
   Animate_Close(hwg_par_HWND(1));
}

/*
HWG_ANIMATE_DESTROY(HWND) --> NIL
*/
HB_FUNC( HWG_ANIMATE_DESTROY )
{
   DestroyWindow(hwg_par_HWND(1));
}

/*
HWG_ANIMATE_OPENEX(HWND, hInstance, cName|nName) --> NIL
*/
HB_FUNC( HWG_ANIMATE_OPENEX )
{
   void * hResource;
   LPCTSTR lpResource = HB_PARSTR(3, &hResource, nullptr);

   if( !lpResource && HB_ISNUM(3) )
   {
      lpResource = MAKEINTRESOURCE(hb_parni(3));
   }

   Animate_OpenEx(hwg_par_HWND(1), reinterpret_cast<HINSTANCE>(hb_parnl(2)), lpResource); // TODO: hwg_par_HINSTANCE

   hb_strfree(hResource);
}

/*
HWG_ANIMATE_ISPLAYING(HWND) --> .T.|.F.
*/
HB_FUNC( HWG_ANIMATE_ISPLAYING )
{
   hb_retl(Animate_IsPlaying(hwg_par_HWND(1)));
}
