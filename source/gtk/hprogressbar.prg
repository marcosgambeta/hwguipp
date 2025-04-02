//
// HWGUI - Harbour Win32 GUI library source code:
// HProgressBar class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//
// Copyright 2008 Luiz Rafal Culik Guimaraes <luiz at xharbour.com.br>
// port for linux version
//
// Bugfix by DF7BE September 2020
// Checked on Windows Cross Development Environment and
// Ubuntu-Linux
//

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HProgressBar INHERIT HControl

   CLASS VAR winclass INIT "ProgressBar"

   DATA maxPos
   DATA lNewBox
   DATA nCount INIT 0
   DATA nLimit

   METHOD New( oWndParent, nId, nX, nY, nWidth, nHeight, maxPos, nRange, bInit, bSize, bPaint, ctooltip )
   METHOD NewBox( cTitle, nX, nY, nWidth, nHeight, maxPos, nRange , bExit )
   METHOD Activate()
   METHOD Increment() INLINE hwg_Updateprogressbar(::handle)
   METHOD Step()
   METHOD SET( cTitle, nPos )
   METHOD RESET()
   METHOD CLOSE()

ENDCLASS

METHOD HProgressBar:New( oWndParent, nId, nX, nY, nWidth, nHeight, maxPos, nRange, bInit, bSize, bPaint, ctooltip )

   ::Super:New( oWndParent, nId, NIL, nX, nY, nWidth, nHeight, NIL, bInit, bSize, bPaint, ctooltip )

   ::maxPos := iif(maxPos == NIL, 20, maxPos)
   ::lNewBox := .F.
   ::nLimit := iif(nRange != NIL, Int( nRange/::maxPos ), 1)

   ::Activate()

   RETURN Self

/* Removed: bInit, bSize, bPaint, ctooltip */
METHOD HProgressBar:NewBox( cTitle, nX, nY, nWidth, nHeight, maxPos, nRange, bExit )

   // ::classname:= "HPROGRESSBAR"
   ::style := WS_CHILD + WS_VISIBLE
   nWidth := iif(nWidth == NIL, 220, nWidth)
   nHeight := iif(nHeight == NIL, 60, nHeight)
   nX := iif(nX == NIL, 0, nX)
   nY := iif(nY == NIL, 0, nY)
   nWidth := iif(nWidth == NIL, 220, nWidth)
   nHeight := iif(nHeight == NIL, 60, nHeight)
   ::nX := 20
   ::nY := 25
   ::nWidth := nWidth - 40
   ::nheight := 20
   ::maxPos := iif(maxPos == NIL, 20, maxPos)
   ::lNewBox := .T.
   ::nLimit := iif(nRange != NIL, Int( nRange/::maxPos ), 1)

   INIT DIALOG ::oParent TITLE cTitle       ;
      AT nX, nY SIZE nWidth, nHeight   ;
      STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + iif(nY == 0, DS_CENTER, nY) + DS_SYSMODAL
      // DF7BE: iif(nY == 0, DS_CENTER, 0)  ??? 

   IF bExit != NIL
      ::oParent:bDestroy := bExit
   ENDIF

   ACTIVATE DIALOG ::oParent NOMODAL

   ::id := ::NewId()
   ::Activate()
   ::oParent:AddControl( Self )

   RETURN Self

METHOD HProgressBar:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createprogressbar(::oParent:handle, ::maxPos, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HProgressBar:Step()

   ::nCount ++
   IF ::nCount == ::nLimit
      ::nCount := 0
      hwg_Updateprogressbar(::handle)
   ENDIF

   RETURN NIL

METHOD HProgressBar:SET( cTitle, nPos )

   IF cTitle != NIL
      hwg_Setwindowtext(::oParent:handle, cTitle)
   ENDIF
   IF nPos != NIL
      IF ::nLimit * ::maxpos != 0
         nPos := nPos / (::nLimit*::maxpos)
      ENDIF
      /*
       DF7BE: Ticket #52: avoid message:
       Gtk-CRITICAL ... IA__gtk_progress_set_percentage:
       assertion 'percentage >= 0 // percentage <= 1.0' failed
       if progbar reached end.
      */
      IF ( nPos >= 0  ) .AND. (nPos <= 1 ) 
       hwg_Setprogressbar(::handle, nPos)
      END
   ENDIF

   RETURN NIL
 

METHOD HProgressBar:RESET()
 IF ::handle != NIL
    ::nCount := 0
    hwg_Resetprogressbar(::handle)
    // hwg_Updateprogressbar(::handle)
 ENDIF
RETURN NIL
 

METHOD HProgressBar:CLOSE()

   HWG_DestroyWindow(::handle)
   IF ::lNewBox
      hwg_EndDialog(::oParent:handle)
   ENDIF

   RETURN NIL
