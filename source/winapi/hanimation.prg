//
// HWGUI - Harbour Win32 GUI library source code:
// HAnimation class
//
// Copyright 2004,2022 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
// www - https://github.com/marcosgambeta/
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HAnimation INHERIT HControl

   CLASS VAR winclass INIT "SysAnimate32"

   DATA cFileName
   DATA xResID

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cFilename, lAutoPlay, lCenter, lTransparent, xResID)
   METHOD Activate()
   METHOD Init()
   METHOD Open(cFileName)
   METHOD Play(nFrom, nTo, nRep)
   METHOD IsPlaying()
   METHOD Seek(nFrame)
   METHOD Stop()
   METHOD Close()
   METHOD Destroy()
   METHOD End() INLINE ::Destroy()

ENDCLASS

METHOD HAnimation:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cFilename, lAutoPlay, lCenter, lTransparent, xResID)

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE)
   nStyle += IIf(lAutoPlay == NIL .OR. lAutoPlay, ACS_AUTOPLAY, 0)
   nStyle += IIf(lCenter == NIL .OR. !lCenter, 0, ACS_CENTER)
   nStyle += IIf(lTransparent == NIL .OR. !lTransparent, 0, ACS_TRANSPARENT)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight)
   ::xResID := xResID
   ::cFilename := cFilename
   ::brush := ::oParent:brush
   ::bColor := ::oParent:bColor
   HWG_InitCommonControlsEx()
   ::Activate()

   RETURN Self

METHOD HAnimation:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Animate_Create(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HAnimation:Init()

   IF !::lInit
      ::Super:Init()
      IF ::xResID != NIL
         hwg_Animate_OpenEx(::handle, hwg_Getresources(), ::xResID)
      ELSEIF ::cFileName != NIL
         hwg_Animate_Open(::handle, ::cFileName)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HAnimation:Open(cFileName)

   IF cFileName != NIL
      ::cFileName := cFileName
      hwg_Animate_Open(::handle, ::cFileName)
   ENDIF

   RETURN NIL

#if 0
METHOD HAnimation:Play(nFrom, nTo, nRep)

   nFrom := IIf(nFrom == NIL, 0, nFrom)
   nTo := IIf(nTo == NIL, -1, nTo)
   nRep := IIf(nRep == NIL, -1, nRep)
   hwg_Animate_Play(::handle, nFrom, nTo, nRep)

   RETURN Self
#endif

#if 0
METHOD HAnimation:IsPlaying()

   RETURN hwg_Animate_IsPlaying(::handle)
#endif

#if 0
METHOD HAnimation:Seek(nFrame)

   nFrame := IIf(nFrame == NIL, 0, nFrame)
   hwg_Animate_Seek(::handle, nFrame)

   RETURN Self
#endif

#if 0
METHOD HAnimation:Stop()

   hwg_Animate_Stop(::handle)

   RETURN Self
#endif

#if 0
METHOD HAnimation:Close()

   hwg_Animate_Close(::handle)

   RETURN NIL
#endif

#if 0
METHOD HAnimation:Destroy()

   hwg_Animate_Destroy(::handle)

   RETURN NIL
#endif

#pragma BEGINDUMP

#include "hwingui.hpp"
#include <commctrl.h>
#include <hbapicls.hpp>

HB_FUNC_STATIC(HANIMATION_PLAY)
{
  auto self = hb_stackSelfItem();
  UINT from = HB_ISNUM(1) ? hb_parni(1) : 0;
  UINT to   = HB_ISNUM(2) ? hb_parni(2) : -1;
  UINT rep  = HB_ISNUM(3) ? hb_parni(3) : -1;
  Animate_Play(static_cast<HWND>(hb_objDataGetPtr(self, "HANDLE")), from, to, rep);
  hb_itemReturn(self);
}

HB_FUNC_STATIC(HANIMATION_ISPLAYING)
{
  hb_retl(Animate_IsPlaying(static_cast<HWND>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE"))));
}

HB_FUNC_STATIC(HANIMATION_SEEK)
{
  auto self = hb_stackSelfItem();
  UINT frame = HB_ISNUM(1) ? hb_parni(1) : 0;
  Animate_Seek(static_cast<HWND>(hb_objDataGetPtr(self, "HANDLE")), frame);
  hb_itemReturn(self);
}

HB_FUNC_STATIC(HANIMATION_STOP)
{
  auto self = hb_stackSelfItem();
  Animate_Stop(static_cast<HWND>(hb_objDataGetPtr(self, "HANDLE")));
  hb_itemReturn(self);
}

HB_FUNC_STATIC(HANIMATION_CLOSE)
{
  Animate_Close(static_cast<HWND>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE")));
}

HB_FUNC_STATIC(HANIMATION_DESTROY)
{
  DestroyWindow(static_cast<HWND>(hb_objDataGetPtr(hb_stackSelfItem(), "HANDLE")));
}

// HWG_ANIMATE_CREATE(hParent, nId, nStyle, nX, nY, nWidth, nHeight) --> handle
HB_FUNC_STATIC(HWG_ANIMATE_CREATE)
{
  HWND hwnd = Animate_Create(hwg_par_HWND(1), hwg_par_UINT(2), hwg_par_DWORD(3), GetModuleHandle(nullptr));
  MoveWindow(hwnd, hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), hwg_par_int(7), TRUE);
  hb_retptr(hwnd);
}

// HWG_ANIMATE_OPEN(HWND, cName) --> NIL
HB_FUNC_STATIC(HWG_ANIMATE_OPEN)
{
  void * hStr;
  Animate_Open(hwg_par_HWND(1), HB_PARSTR(2, &hStr, nullptr));
  hb_strfree(hStr);
}

// HWG_ANIMATE_OPENEX(HWND, hInstance, cName|nName) --> NIL
HB_FUNC_STATIC(HWG_ANIMATE_OPENEX)
{
  void * hResource;
  LPCTSTR lpResource = HB_PARSTR(3, &hResource, nullptr);

  if (!lpResource && HB_ISNUM(3)) {
    lpResource = MAKEINTRESOURCE(hb_parni(3));
  }

  Animate_OpenEx(hwg_par_HWND(1), reinterpret_cast<HINSTANCE>(hb_parnl(2)), lpResource); // TODO: hwg_par_HINSTANCE

  hb_strfree(hResource);
}

#pragma ENDDUMP
