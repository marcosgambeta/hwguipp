/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HAnimation class
 *
 * Copyright 2004,2022 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 * www - https://github.com/marcosgambeta/
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

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

METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cFilename, lAutoPlay, lCenter, lTransparent, xResID) CLASS HAnimation

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

METHOD Activate() CLASS HAnimation

   IF !Empty(::oParent:handle)
      ::handle := hwg_Animate_Create(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HAnimation

   IF !::lInit
      ::Super:Init()
      IF ::xResID != NIL
         hwg_Animate_OpenEx(::handle, hwg_Getresources(), ::xResID)
      ELSEIF ::cFileName != NIL
         hwg_Animate_Open(::handle, ::cFileName)
      ENDIF
   ENDIF

   RETURN NIL

METHOD Open(cFileName) CLASS HAnimation

   IF cFileName != NIL
      ::cFileName := cFileName
      hwg_Animate_Open(::handle, ::cFileName)
   ENDIF

   RETURN NIL

METHOD Play(nFrom, nTo, nRep) CLASS HAnimation

   nFrom := IIf(nFrom == NIL, 0, nFrom)
   nTo   := IIf(nTo == NIL, -1, nTo)
   nRep  := IIf(nRep == NIL, -1, nRep)
   hwg_Animate_Play(::handle, nFrom, nTo, nRep)

   RETURN Self

METHOD IsPlaying() CLASS HAnimation

   RETURN hwg_Animate_IsPlaying(::handle)

METHOD Seek(nFrame) CLASS HAnimation

   nFrame := IIf(nFrame == NIL, 0, nFrame)
   hwg_Animate_Seek(::handle, nFrame)

   RETURN Self

METHOD Stop() CLASS HAnimation

   hwg_Animate_Stop(::handle)

   RETURN Self

METHOD Close() CLASS HAnimation

   hwg_Animate_Close(::handle)

   RETURN NIL

METHOD Destroy() CLASS HAnimation

   hwg_Animate_Destroy(::handle)

   RETURN NIL
