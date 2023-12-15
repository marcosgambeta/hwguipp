/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HTrackBar class
 *
 * Copyright 2004 Marcos Antonio Gambeta <marcos_gambeta@hotmail.com>
 * www - http://geocities.yahoo.com.br/marcosgambeta/
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define TBS_AUTOTICKS                1
#define TBS_VERT                     2
#define TBS_TOP                      4
#define TBS_LEFT                     4
#define TBS_BOTH                     8
#define TBS_NOTICKS                 16

#define CLR_WHITE    0xffffff
#define CLR_BLACK    0x000000

CLASS HTrackBar INHERIT HControl

   CLASS VAR winclass   INIT "msctls_trackbar32"

   DATA nValue
   DATA bChange
   DATA bThumbDrag
   DATA nLow
   DATA nHigh
   DATA hCursor

   METHOD New(oWndParent, nId, vari, nStyle, nX, nY, nWidth, nHeight, ;
              bInit, bSize, bPaint, cTooltip, bChange, bDrag, nLow, nHigh, ;
              lVertical, TickStyle, TickMarks)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Value(nValue) SETGET
   METHOD GetNumTics()  INLINE hwg_Sendmessage(::handle, TBM_GETNUMTICS, 0, 0)

ENDCLASS

METHOD HTrackBar:New(oWndParent, nId, vari, nStyle, nX, nY, nWidth, nHeight, ;
           bInit, bSize, bPaint, cTooltip, bChange, bDrag, nLow, nHigh, ;
           lVertical, TickStyle, TickMarks)

   IF TickStyle == NIL
      TickStyle := TBS_AUTOTICKS
   ENDIF
   IF TickMarks == NIL
      TickMarks := 0
   ENDIF
   IF bPaint != NIL
      TickStyle := hb_bitor(TickStyle, TBS_AUTOTICKS)
   ENDIF
   nstyle   := hb_bitor(IIF(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + WS_TABSTOP)
   nstyle   += IIF(lVertical != NIL .AND. lVertical, TBS_VERT, 0)
   nstyle   += TickStyle + TickMarks

   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, NIL, bInit, bSize, bPaint, cTooltip)

   ::nValue     := IIF(HB_ISNUMERIC(vari), vari, 0)
   ::bChange    := bChange
   ::bThumbDrag := bDrag
   ::nLow       := IIF(nLow == NIL, 0, nLow)
   ::nHigh      := IIF(nHigh == NIL, 100, nHigh)

   HWG_InitCommonControlsEx()
   ::Activate()

RETURN Self

METHOD HTrackBar:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_inittrackbar(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight, ::nLow, ::nHigh)
      ::Init()
   ENDIF
RETURN NIL

METHOD HTrackBar:onEvent(msg, wParam, lParam)

   LOCAL aCoors

   IF msg == WM_PAINT
      IF HB_ISBLOCK(::bPaint)
         Eval(::bPaint, Self)
         RETURN 0
      ENDIF

   ELSEIF msg == WM_MOUSEMOVE
      IF ::hCursor != NIL
         Hwg_SetCursor(::hCursor)
      ENDIF

   ELSEIF msg == WM_ERASEBKGND
      IF ::brush != NIL
         aCoors := hwg_Getclientrect(::handle)
         hwg_Fillrect(wParam, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, ::brush:handle)
         RETURN 1
      ENDIF

   ELSEIF msg == WM_DESTROY
      ::End()

   ELSEIF HB_ISBLOCK(::bOther)
      RETURN Eval(::bOther, Self, msg, wParam, lParam)

   ENDIF

RETURN -1

METHOD HTrackBar:Init()

   IF !::lInit
      ::Super:Init()
      hwg_trackbarsetrange(::handle, ::nLow, ::nHigh)
      hwg_Sendmessage(::handle, TBM_SETPOS, 1, ::nValue)

      IF ::bPaint != NIL
         ::nHolder := 1
         hwg_Setwindowobject(::handle, Self)
         Hwg_InitTrackProc(::handle)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HTrackBar:Value(nValue)

   IF nValue != NIL
      IF HB_ISNUMERIC(nValue)
         hwg_Sendmessage(::handle, TBM_SETPOS, 1, nValue)
         ::nValue := nValue
      ENDIF
   ELSE
      ::nValue := hwg_Sendmessage(::handle, TBM_GETPOS, 0, 0)
   ENDIF

   RETURN ::nValue
