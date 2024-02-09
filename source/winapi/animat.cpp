/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C++ functions for HAnimation class
 *
 * Copyright 2004,2022 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 * www - https://github.com/marcosgambeta/
 */

#include "hwingui.hpp"
#include <commctrl.h>

/*
HWG_ANIMATE_CREATE(hParent, nId, nStyle, nX, nY, nWidth, nHeight) --> handle
*/
#if 0
HB_FUNC( HWG_ANIMATE_CREATE ) // moved to hanimation.prg as static function
{
   HWND hwnd = Animate_Create(hwg_par_HWND(1), hwg_par_UINT(2), hwg_par_DWORD(3), GetModuleHandle(nullptr));
   MoveWindow(hwnd, hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), hwg_par_int(7), TRUE);
   hb_retptr(hwnd);
}
#endif

/*
HWG_ANIMATE_OPEN(HWND, cName) --> NIL
*/
#if 0
HB_FUNC( HWG_ANIMATE_OPEN ) // moved to hanimation.prg as static function
{
   void * hStr;
   Animate_Open(hwg_par_HWND(1), HB_PARSTR(2, &hStr, nullptr));
   hb_strfree(hStr);
}
#endif

/*
HWG_ANIMATE_PLAY(HWND, nFrom, nTo, nReplay) --> NIL
*/
#if 0
HB_FUNC( HWG_ANIMATE_PLAY ) // deprecated
{
   Animate_Play(hwg_par_HWND(1), hwg_par_UINT(2), hwg_par_UINT(3), hwg_par_UINT(4));
}
#endif

/*
HWG_ANIMATE_SEEK(HWND, nFrame) --> NIL
*/
#if 0
HB_FUNC( HWG_ANIMATE_SEEK ) // deprecated
{
   Animate_Seek(hwg_par_HWND(1), hwg_par_UINT(2));
}
#endif

/*
HWG_ANIMATE_STOP(HWND) --> NIL
*/
#if 0
HB_FUNC( HWG_ANIMATE_STOP ) // deprecated
{
   Animate_Stop(hwg_par_HWND(1));
}
#endif

/*
HWG_ANIMATE_CLOSE(HWND) --> NIL
*/
#if 0
HB_FUNC( HWG_ANIMATE_CLOSE ) // deprecated
{
   Animate_Close(hwg_par_HWND(1));
}
#endif

/*
HWG_ANIMATE_DESTROY(HWND) --> NIL
*/
#if 0
HB_FUNC( HWG_ANIMATE_DESTROY ) // deprecated
{
   DestroyWindow(hwg_par_HWND(1));
}
#endif

/*
HWG_ANIMATE_OPENEX(HWND, hInstance, cName|nName) --> NIL
*/
#if 0
HB_FUNC( HWG_ANIMATE_OPENEX ) // moved to hanimation.prg as static function
{
   void * hResource;
   LPCTSTR lpResource = HB_PARSTR(3, &hResource, nullptr);

   if( !lpResource && HB_ISNUM(3) ) {
      lpResource = MAKEINTRESOURCE(hb_parni(3));
   }

   Animate_OpenEx(hwg_par_HWND(1), reinterpret_cast<HINSTANCE>(hb_parnl(2)), lpResource); // TODO: hwg_par_HINSTANCE

   hb_strfree(hResource);
}
#endif

/*
HWG_ANIMATE_ISPLAYING(HWND) --> .T.|.F.
*/
#if 0
HB_FUNC( HWG_ANIMATE_ISPLAYING ) // deprecated
{
   hb_retl(Animate_IsPlaying(hwg_par_HWND(1)));
}
#endif
