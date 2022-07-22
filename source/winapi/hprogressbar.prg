/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HProgressBar class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HProgressBar INHERIT HControl

   CLASS VAR winclass   INIT "msctls_progress32"
   DATA  maxPos
   DATA  nRange
   DATA  lNewBox
   DATA  nCount INIT 0
   DATA  nLimit
   DATA  nAnimation
   DATA  LabelBox
   DATA  nPercent INIT 0
   DATA  lPercent INIT .F.

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bInit, bSize, bPaint, ctooltip, nAnimation, lVertical)
   METHOD NewBox(cTitle, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bExit, lPercent)
   METHOD Init()
   METHOD Activate()
   METHOD Increment() INLINE hwg_Updateprogressbar(::handle)
   METHOD STEP(cTitle)
   METHOD RESET(cTitle)
   METHOD SET(cTitle, nPos)
   METHOD SetLabel(cCaption)
   METHOD CLOSE()
   METHOD End() INLINE hwg_Destroywindow(::handle)
   METHOD Redefine(oWndParent, nId, maxPos, nRange, bInit, bSize, bPaint, ctooltip, nAnimation, lVertical)

ENDCLASS

METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bInit, bSize, bPaint, ctooltip, nAnimation, lVertical) CLASS HProgressBar

   ::Style := iif(lvertical != NIL .AND. lVertical, PBS_VERTICAL, 0)
   ::Style += iif(nAnimation != NIL .AND. nAnimation > 0, PBS_MARQUEE, 0)
   ::nAnimation := nAnimation

   ::Super:New(oWndParent, nId, ::Style, nLeft, nTop, nWidth, nHeight, NIL, bInit, bSize, bPaint, ctooltip)

   ::maxPos  := iif(maxPos == NIL, 20, maxPos)
   ::lNewBox := .F.
   ::nRange  := iif(nRange != NIL .AND. nRange != 0, nRange, 100)
   ::nLimit  := iif(nRange != NIL, Int(::nRange / ::maxPos ), 1)

   ::Activate()

   RETURN Self

METHOD Redefine(oWndParent, nId, maxPos, nRange, bInit, bSize, bPaint, ctooltip, nAnimation, lVertical)

   HB_SYMBOL_UNUSED(lVertical)

   ::Super:New(oWndParent,nId, 0, 0, 0, 0, 0, NIL, bInit, bSize, bPaint, ctooltip, NIL, NIL)
   HWG_InitCommonControlsEx()
   //::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::maxPos      := iif(maxPos == NIL, 20, maxPos)
   ::lNewBox     := .F.
   ::nRange      := iif(nRange != NIL .AND. nRange != 0, nRange, 100)
   ::nLimit      := iif(nRange != NIL, Int(::nRange / ::maxPos), 1)
   ::nAnimation  := nAnimation

   RETURN Self

/*
  Former definition was:
  METHOD NewBox(cTitle, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bExit, bInit, bSize, bPaint, ctooltip)
*/

METHOD NewBox(cTitle, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bExit, lPercent) CLASS HProgressBar

   // ::classname:= "HPROGRESSBAR"
   ::style    := WS_CHILD + WS_VISIBLE
   nWidth     := iif(nWidth == NIL, 220, nWidth)
   nHeight    := iif(nHeight == NIL, 55, nHeight)
   nLeft      := iif(nLeft == NIL, 0, nLeft)
   nTop       := iif(nTop == NIL, 0, nTop)
   ::nLeft    := 20
   ::nTop     := 25
   ::nWidth   := nWidth - 40
   ::maxPos   := iif(maxPos == NIL, 20, maxPos)
   ::lNewBox  := .T.
   ::nRange   := iif(nRange != NIL .AND. nRange != 0, nRange, 100)
   ::nLimit   := iif(nRange != NIL, Int(::nRange / ::maxPos), 1)
   ::lPercent := lPercent

   INIT DIALOG ::oParent TITLE cTitle       ;
      At nLeft, nTop SIZE nWidth, nHeight   ;
      STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + /* WS_SYSMENU + */ WS_SIZEBOX + iif(nTop == 0, DS_CENTER, 0) + /* DS_SYSMODAL + */ DS_SETFOREGROUND + MB_USERICON

   @ ::nLeft, nTop + 5 SAY ::LabelBox CAPTION iif(Empty(lPercent), "", "%")  SIZE ::nWidth, 19 STYLE SS_CENTER

   IF bExit != NIL
      ::oParent:bDestroy := bExit
   ENDIF

   ACTIVATE DIALOG ::oParent NOMODAL

   ::id := ::NewId()
   ::Activate()
   ::oParent:AddControl(Self)

   RETURN Self

METHOD Activate() CLASS HProgressBar

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createprogressbar(::oParent:handle, ::maxPos, ::style, ::nLeft, ::nTop, ::nWidth, iif(::nHeight = 0, NIL, ::nHeight))
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init()  CLASS HProgressBar

   IF !::lInit
      ::Super:Init()
      //hwg_Sendmessage(::handle, PBM_SETRANGE, 0, hwg_Makelparam(0, ::nRange))
      //hwg_Sendmessage(::handle, PBM_SETSTEP, ::maxPos, 0)
      //hwg_Sendmessage(::handle, PBM_SETSTEP, ::nLimit, 0)
      IF ::nAnimation != NIL .AND. ::nAnimation > 0
         hwg_Sendmessage(::handle, PBM_SETMARQUEE, 1, ::nAnimation)
      ENDIF
   ENDIF

   RETURN NIL

METHOD STEP(cTitle)

   ::nCount++
   IF ::nCount == ::nLimit
      ::nCount := 0
      hwg_Updateprogressbar(::handle)
      ::Set(cTitle)
      IF !Empty(::lPercent)
         ::nPercent += ::maxPos  //::nLimit
         ::setLabel(LTrim(Str(::nPercent, 3)) + " %")
      ENDIF
   ENDIF

   RETURN NIL

// Added by DF7BE
METHOD RESET(cTitle)

   IF cTitle != NIL
      hwg_Setwindowtext(::oParent:handle, cTitle)
   ENDIF
   hwg_Resetprogressbar(::handle)

   RETURN NIL

METHOD SET(cTitle, nPos) CLASS HProgressBar

   IF cTitle != NIL
      hwg_Setwindowtext(::oParent:handle, cTitle)
   ENDIF
   IF nPos != NIL
      hwg_Setprogressbar(::handle, nPos)
   ENDIF

   RETURN NIL

METHOD SetLabel(cCaption) CLASS HProgressBar

   IF cCaption != NIL .AND. ::lNewBox
      ::LabelBox:SetText(cCaption)
   ENDIF

   RETURN NIL

METHOD CLOSE()

   hwg_Destroywindow(::handle)
   IF ::lNewBox
      hwg_EndDialog(::oParent:handle)
   ENDIF

   RETURN NIL
