/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HScrollArea class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "error.ch"

CLASS HScrollArea INHERIT HObject

   DATA nCurWidth    INIT 0
   DATA nCurHeight   INIT 0
   DATA nVScrollPos   INIT 0
   DATA nHScrollPos   INIT 0
   DATA rect
   DATA nScrollBars INIT - 1
   DATA lAutoScroll INIT .T.
   DATA nHorzInc
   DATA nVertInc
   DATA nVscrollMax
   DATA nHscrollMax

   METHOD ResetScrollbars()
   METHOD SetupScrollbars()
   METHOD RedefineScrollbars()

ENDCLASS

METHOD RedefineScrollbars() CLASS HScrollArea

   ::rect := hwg_Getclientrect(::handle)
   IF ::nScrollBars > - 1 .AND. ::bScroll = Nil
      IF ::nVscrollPos = 0
         ::ncurHeight := 0                                                              //* 4
         AEval(::aControls, {|o|::ncurHeight := Int(Max(o:nTop + o:nHeight + VERT_PTS * 1, ::ncurHeight))})
      ENDIF
      IF ::nHscrollPos = 0
         ::ncurWidth  := 0                                                           // * 4
         AEval(::aControls, {|o|::ncurWidth := Int(Max(o:nLeft + o:nWidth + HORZ_PTS * 1, ::ncurWidth))})
      ENDIF
      ::ResetScrollbars()
      ::SetupScrollbars()
   ENDIF

   RETURN Nil

METHOD SetupScrollbars() CLASS HScrollArea
   LOCAL tempRect, nwMax, nhMax, aMenu, nPos

   tempRect := hwg_Getclientrect(::handle)
   aMenu := iif(__objHasData(Self, "MENU"), ::menu, Nil)
   // Calculate how many scrolling increments for the client area
   IF ::Type = WND_MDICHILD //.AND. ::aRectSave != Nil
      nwMax := Max(::ncurWidth, tempRect[3]) //::maxWidth
      nhMax := Max(::ncurHeight, tempRect[4]) //::maxHeight
      ::nHorzInc := Int((nwMax - tempRect[3]) / HORZ_PTS)
      ::nVertInc := Int((nhMax - tempRect[4]) / VERT_PTS)
   ELSE
      nwMax := Max(::ncurWidth, ::Rect[3])
      nhMax := Max(::ncurHeight, ::Rect[4])
      ::nHorzInc := Int((nwMax - tempRect[3]) / HORZ_PTS + HORZ_PTS)
      ::nVertInc := Int((nhMax - tempRect[4]) / VERT_PTS + VERT_PTS - iif(amenu != Nil, hwg_Getsystemmetrics(SM_CYMENU), 0))  // MENU
   ENDIF
   // Set the vertical and horizontal scrolling info
   IF ::nScrollBars = 0 .OR. ::nScrollBars = 2
      ::nHscrollMax := Max(0, ::nHorzInc)
      IF ::nHscrollMax < HORZ_PTS / 2
         //-  hwg_Scrollwindow(::Handle, ::nHscrollPos * HORZ_PTS, 0)
      ELSEIF ::nHScrollMax <= HORZ_PTS
         ::nHScrollMax := 0
      ENDIF
      ::nHscrollPos := Min(::nHscrollPos, ::nHscrollMax)
      hwg_Setscrollpos(::handle, SB_HORZ, ::nHscrollPos, .T.)
      hwg_Setscrollinfo(::Handle, SB_HORZ, 1, ::nHScrollPos, HORZ_PTS, ::nHscrollMax)
      IF ::nHscrollPos > 0
         nPos := hwg_Getscrollpos(::handle, SB_HORZ)
         IF nPos < ::nHscrollPos
            hwg_Scrollwindow(::Handle, 0, (::nHscrollPos - nPos) * SB_HORZ)
            ::nVscrollPos := nPos
            hwg_Setscrollpos(::Handle, SB_HORZ, ::nHscrollPos, .T.)
         ENDIF
      ENDIF
   ENDIF
   IF ::nScrollBars = 1 .OR. ::nScrollBars = 2
      ::nVscrollMax := Int(Max(0, ::nVertInc))
      IF ::nVscrollMax < VERT_PTS / 2
         //-  hwg_Scrollwindow(::Handle, 0, ::nVscrollPos * VERT_PTS)
      ELSEIF ::nVScrollMax <= VERT_PTS
         ::nVScrollMax := 0
      ENDIF
      hwg_Setscrollpos(::Handle, SB_VERT, ::nVscrollPos, .T.)
      hwg_Setscrollinfo(::Handle, SB_VERT, 1, ::nVscrollPos, VERT_PTS, ::nVscrollMax)
      IF ::nVscrollPos > 0 //.AND. nPosVert != ::nVscrollPos
         nPos := hwg_Getscrollpos(::handle, SB_VERT)
         IF nPos < ::nVscrollPos
            hwg_Scrollwindow(::Handle, 0, (::nVscrollPos - nPos) * VERT_PTS)
            ::nVscrollPos := nPos
            hwg_Setscrollpos(::Handle, SB_VERT, ::nVscrollPos, .T.)
         ENDIF
      ENDIF
   ENDIF

   RETURN Nil

METHOD ResetScrollbars() CLASS HScrollArea

   // Reset our window scrolling information
   LOCAL lMaximized := hwg_Getwindowplacement(::handle) == SW_MAXIMIZE

   IF lMaximized
      hwg_Scrollwindow(::Handle, ::nHscrollPos * HORZ_PTS, 0)
      hwg_Scrollwindow(::Handle, 0, ::nVscrollPos * VERT_PTS)
      ::nHscrollPos := 0
      ::nVscrollPos := 0
   ENDIF

   RETURN Nil
