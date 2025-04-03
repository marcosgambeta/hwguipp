//
// HWGUI - Harbour Win32 GUI library source code:
// HSplitter class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"
#include "gtk.ch"

CLASS HSplitter INHERIT HControl

   CLASS VAR winclass INIT "STATIC"

   DATA aLeft
   DATA aRight
   DATA lVertical
   DATA oStyle
   DATA lRepaint INIT .F.
   DATA nFrom
   DATA nTo
   DATA hCursor
   DATA lCaptured INIT .F.
   DATA lMoved INIT .F.
   DATA bEndDrag

   METHOD New(oWndParent, nId, nX, nY, nWidth, nHeight, bSize, bDraw, color, bcolor, aLeft, aRight, nFrom, nTo, oStyle)
   METHOD Activate()
   METHOD onEvent( msg, wParam, lParam )
   METHOD Init()
   METHOD Paint()
   //METHOD Move( x1, y1, width, height )
   METHOD Drag( xPos, yPos )
   METHOD DragAll( xPos, yPos )

ENDCLASS

/* bPaint ==> bDraw */
METHOD HSplitter:New(oWndParent, nId, nX, nY, nWidth, nHeight, bSize, bDraw, color, bcolor, aLeft, aRight, nFrom, nTo, oStyle)

   ::Super:New( oWndParent, nId, WS_CHILD + WS_VISIBLE + SS_OWNERDRAW, nX, nY, nWidth, nHeight, NIL, NIL, bSize, bDraw, NIL, IIf(color == NIL, 0, color), bcolor )

   ::title := ""
   ::aLeft := IIf(aLeft == NIL, {}, aLeft)
   ::aRight := IIf(aRight == NIL, {}, aRight)
   ::lVertical := (::nHeight > ::nWidth)
   ::nFrom := nFrom
   ::nTo := nTo
   ::oStyle := oStyle

   ::Activate()

   RETURN Self

METHOD HSplitter:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createsplitter(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HSplitter:onEvent( msg, wParam, lParam )

   HB_SYMBOL_UNUSED(wParam)

   IF msg == WM_MOUSEMOVE
      IF ::hCursor == NIL
         ::hCursor := hwg_Loadcursor( GDK_SIZING )
      ENDIF
      Hwg_SetCursor(::hCursor, ::handle)
      IF ::lCaptured
         IF ::lRepaint
            ::DragAll( hwg_Loword(lParam), hwg_Hiword(lParam) )
         ELSE
            ::Drag( hwg_Loword(lParam), hwg_Hiword(lParam) )
         ENDIF
      ENDIF
   ELSEIF msg == WM_PAINT
      ::Paint()
   ELSEIF msg == WM_LBUTTONDOWN
      Hwg_SetCursor(::hCursor, ::handle)
      ::lCaptured := .T.
   ELSEIF msg == WM_LBUTTONUP
      ::DragAll()
      ::lCaptured := .F.
      IF hb_IsBlock(::bEndDrag)
         Eval(::bEndDrag, Self)
      ENDIF
   ELSEIF msg == WM_DESTROY
      ::End()
   ENDIF

   Return - 1

METHOD HSplitter:Init()

   IF !::lInit
      ::Super:Init()
      hwg_Setwindowobject(::handle, Self)
   ENDIF

   RETURN NIL

METHOD HSplitter:Paint()
   
   LOCAL hDC
   LOCAL aCoors

   IF hb_IsBlock(::bPaint)
      Eval(::bPaint, Self)
   ELSE
      hDC := hwg_Getdc(::handle)
      IF ::oStyle == NIL
         hwg_Drawbutton(hDC, 0, 0, ::nWidth - 1, ::nHeight - 1, 6)
      ELSE
         aCoors := hwg_Getclientrect(::handle)
         ::oStyle:Draw(hDC, 0, 0, aCoors[3], aCoors[4])
      ENDIF
   hwg_Releasedc(::handle, hDC)
   ENDIF

   RETURN NIL
/*
METHOD HSplitter:Move( x1, y1, width, height )

   ::Super:Move( x1, y1, width, height, .T. )

   RETURN NIL
*/
METHOD HSplitter:Drag( xPos, yPos )
   
   LOCAL nFrom
   LOCAL nTo

   nFrom := IIf(::nFrom == NIL, 1, ::nFrom)
   nTo := IIf(::nTo == NIL, IIf(::lVertical, ::oParent:nWidth - 1, ::oParent:nHeight - 1), ::nTo)
   IF ::lVertical
      IF xPos > 32000
         xPos -= 65535
      ENDIF
      IF (xPos := (::nX + xPos)) >= nFrom .AND. xPos <= nTo
         ::nX := xPos
      ENDIF
   ELSE
      IF yPos > 32000
         yPos -= 65535
      ENDIF
      IF (yPos := (::nY + yPos)) >= nFrom .AND. yPos <= nTo
         ::nY := yPos
      ENDIF
   ENDIF
   hwg_MoveWidget(::handle, ::nX, ::nY, ::nWidth, ::nHeight) //, .T.)
   ::lMoved := .T.

   RETURN NIL

METHOD HSplitter:DragAll( xPos, yPos )
   
   LOCAL i
   LOCAL oCtrl
   LOCAL nDiff
   LOCAL wold
   LOCAL hold

   IF xPos != NIL .OR. yPos != NIL
      ::Drag( xPos, yPos )
   ENDIF
   FOR i := 1 TO Len(::aRight)
      oCtrl := ::aRight[i]
      wold := oCtrl:nWidth
      hold := oCtrl:nHeight
      IF ::lVertical
         nDiff := ::nX + ::nWidth - oCtrl:nX
         oCtrl:Move( oCtrl:nX + nDiff, NIL, oCtrl:nWidth - nDiff )
      ELSE
         nDiff := ::nY + ::nHeight - oCtrl:nY
         oCtrl:Move(NIL, oCtrl:nY + nDiff, NIL, oCtrl:nHeight - nDiff)
      ENDIF
      hwg_onAnchor( oCtrl, wold, hold, oCtrl:nWidth, oCtrl:nHeight )
   NEXT
   FOR i := 1 TO Len(::aLeft)
      oCtrl := ::aLeft[i]
      wold := oCtrl:nWidth
      hold := oCtrl:nHeight
      IF ::lVertical
         nDiff := ::nX - ( oCtrl:nX + oCtrl:nWidth )
         oCtrl:Move(NIL, NIL, oCtrl:nWidth + nDiff)
      ELSE
         nDiff := ::nY - ( oCtrl:nY + oCtrl:nHeight )
         oCtrl:Move(NIL, NIL, NIL, oCtrl:nHeight + nDiff)
      ENDIF
      hwg_onAnchor( oCtrl, wold, hold, oCtrl:nWidth, oCtrl:nHeight )
   NEXT
   ::lMoved := .F.

   RETURN NIL
