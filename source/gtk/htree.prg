/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HBrowse class - browse databases and arrays
 *
 * Copyright 2013 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "gtk.ch"
#include "hwgui.ch"
#include "inkey.ch"
#include "dbstruct.ch"
#include "hbclass.ch"

#ifndef SB_HORZ
#define SB_HORZ             0
#define SB_VERT             1
#define SB_CTL              2
#define SB_BOTH             3
#endif
 /* Moved to windows.ch */
 // #define HDM_GETITEMCOUNT    4608

#define  CLR_WHITE      16777215
#define  CLR_MGREEN      8421440
#define  CLR_VDBLUE     10485760

STATIC crossCursor := NIL
STATIC arrowCursor := NIL
STATIC vCursor     := NIL

CLASS HTree INHERIT HControl

   CLASS VAR winclass INIT "SysTreeView32"

   DATA aItems INIT {}
   DATA nNodeCount INIT 0
   DATA aScreen
   DATA oFirst
   DATA oSelected
   DATA aImages
   DATA bItemChange
   DATA bExpand
   DATA bRClick
   DATA bDblClick
   DATA bClick
   DATA lEmpty INIT .T.
   DATA area
   DATA width
   DATA height
   DATA rowCount // Number of visible data rows
   DATA rowCurrCount INIT 0
   DATA oPenLine
   DATA oPenPlus
   DATA nIndent INIT 20
   DATA tcolorSel INIT CLR_WHITE
   DATA bcolorSel INIT CLR_VDBLUE
   DATA brushSel
   DATA hScrollV
   DATA hScrollH
   DATA nScrollV INIT 0
   DATA nScrollH INIT 0
   DATA bScrollPos

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, color, bcolor, aImages, lResour, lEditLabels, bClick, nBC)
   METHOD Init()
   METHOD Activate()
   METHOD onEvent( msg, wParam, lParam )
   METHOD AddNode( cTitle, oPrev, oNext, bClick, aImages )
   METHOD GetSelected()   INLINE ::oSelected
   //METHOD EditLabel( oNode ) BLOCK { | Self, o | hwg_Sendmessage(::handle, TVM_EDITLABEL, 0, o:handle) }
   METHOD Expand( oNode ) BLOCK {|Self,o| o:lExpanded := .T., hwg_Redrawwindow(::area) }
   METHOD SELECT( oNode, lNoRedraw )
   METHOD Clean()
   METHOD Refresh()
   METHOD END()
   METHOD Paint()
   METHOD PaintNode(hDC, oNode, nNode, nLine)
   METHOD ButtonDown( lParam )
   METHOD ButtonUp( lParam )
   METHOD ButtonDbl( lParam )
   METHOD ButtonRDown( lParam )
   METHOD GoDown( n )
   METHOD GoUp( n )
   METHOD MouseWheel( nKeys, nDelta )
   METHOD DoHScroll()
   METHOD DoVScroll()

ENDCLASS

METHOD New( oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, ;
      bInit, bSize, color, bcolor, aImages, lResour, lEditLabels, bClick, nBC ) CLASS HTree
   
   LOCAL i
   
   // Variables not used
   // LOCAL aBmpSize

   HB_SYMBOL_UNUSED(lEditLabels)
   HB_SYMBOL_UNUSED(nBC)

   IF color == NIL
      color := 0
   ENDIF
   IF bcolor == NIL
      bcolor := CLR_WHITE
   ENDIF
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, NIL, NIL, color, bcolor)

   ::title   := ""
   ::Type    := iif(lResour == NIL, .F. , lResour)
   ::bClick := bClick

   IF aImages != NIL .AND. !Empty(aImages)
      ::aImages := {}
      FOR i := 1 TO Len(aImages)
         AAdd(::aImages, iif(::Type, hwg_BmpFromRes(aImages[i]), hwg_Openimage(AddPath(aImages[i], HBitmap():cPath))))
      NEXT
   ENDIF

   ::oPenLine := HPen():Add( PS_DOT, 0.6, 7566195 )
   ::oPenPlus := HPen():Add( PS_SOLID, 2, 0 )

   ::Activate()

   RETURN Self

METHOD Init() CLASS HTree

   IF !::lInit
      ::Super:Init()
   ENDIF

   RETURN NIL

METHOD Activate() CLASS HTree

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbrowse( Self )
      ::Init()
   ENDIF

   RETURN NIL

METHOD onEvent( msg, wParam, lParam )  CLASS HTree

   LOCAL retValue := -1
   // Variables not used
   // LOCAL aCoors 

   IF ::bOther != NIL
      Eval(::bOther, Self, msg, wParam, lParam)
   ENDIF

   IF msg == WM_PAINT
      ::Paint()
      retValue := 1

   ELSEIF msg == WM_SETFOCUS
      IF ::bGetFocus != NIL
         Eval(::bGetFocus, Self)
      ENDIF

   ELSEIF msg == WM_KILLFOCUS
      IF ::bLostFocus != NIL
         Eval(::bLostFocus, Self)
      ENDIF

   ELSEIF msg == WM_HSCROLL
      ::DoHScroll()

   ELSEIF msg == WM_VSCROLL
      ::DoVScroll( wParam )

   ELSEIF msg == WM_KEYUP
      IF wParam == GDK_Control_L .OR. wParam == GDK_Control_R
         IF wParam == ::nCtrlPress
            ::nCtrlPress := 0
         ENDIF
      ENDIF
      retValue := 1
   ELSEIF msg == WM_KEYDOWN
      IF wParam == GDK_Down        // Down
         ::GoDown(1)
      ELSEIF wParam == GDK_Up    // Up
         ::GoUp(1)
      ELSEIF wParam == GDK_Page_Down    // PageDown
         ::GoDown(2)
      ELSEIF wParam == GDK_Page_Up    // PageUp
         ::GoUp(2)
      ENDIF
      retValue := 1

   ELSEIF msg == WM_LBUTTONDOWN
      ::ButtonDown( lParam )

   ELSEIF msg == WM_LBUTTONUP
      ::ButtonUp( lParam )

   ELSEIF msg == WM_LBUTTONDBLCLK
      ::ButtonDbl( lParam )

   ELSEIF msg == WM_RBUTTONDOWN
      ::ButtonRDown( lParam )

   ELSEIF msg == WM_MOUSEWHEEL
      ::MouseWheel(hwg_Loword(wParam),      ;
         iif(hwg_Hiword(wParam) > 32768, ;
         hwg_Hiword(wParam) - 65535, hwg_Hiword(wParam)))

   ELSEIF msg == WM_DESTROY
      ::End()
   ENDIF

   RETURN retValue

METHOD AddNode( cTitle, oPrev, oNext, bClick, aImages ) CLASS HTree
   
   LOCAL oNode := HTreeNode():New( Self, Self, oPrev, oNext, cTitle, bClick, aImages )

   ::lEmpty := .F.

   RETURN oNode

METHOD SELECT( oNode, lNoRedraw ) CLASS HTree

   LOCAL oParent := oNode

   ::oSelected := oNode
   DO WHILE oParent:nLevel > 1
      ( oParent := oParent:oParent ):lExpanded := .T.
   ENDDO

   IF oNode:bClick != NIL
      Eval( oNode:bClick, oNode )
   ELSEIF ::bClick != NIL
      Eval(::bClick, oNode)
   ENDIF

   IF Empty(lNoRedraw)
      hwg_Redrawwindow(::area)
   ENDIF

   RETURN NIL

METHOD Clean() CLASS HTree

   ::lEmpty := .T.
   ReleaseTree(::aItems, .T.)
   ::aItems := { }
   ::nNodeCount := 0
   ::aScreen := NIL
   ::oFirst := NIL
   hwg_Redrawwindow(::area)

   RETURN NIL

METHOD Refresh() CLASS HTree

   hwg_Redrawwindow(::area)

   RETURN NIL

METHOD Paint() CLASS HTree
   
   LOCAL hDC
   LOCAL aCoors
   LOCAL aMetr
   LOCAL y1
   LOCAL y2
   LOCAL oNode
   LOCAL nNode
   LOCAL nLine := 1
   // Variables not used
   // LOCAL pps
   // LOCAL x1, x2   

   hDC := hwg_Getdc(::area)

   IF ::oFont != NIL
      hwg_Selectobject(hDC, ::oFont:handle)
   ENDIF
   IF ::brushSel == NIL
      ::brushSel := HBrush():Add(::bcolorSel)
   ENDIF

   aCoors := hwg_Getclientrect(::handle)
   hwg_Fillrect(hDC, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, ::brush:handle)
   hwg_gtk_drawedge(hDC, aCoors[1], aCoors[2], aCoors[3] - 1, aCoors[4] - 1, 6)
   aMetr := hwg_Gettextmetric(hDC)

   IF Empty(::aItems)
      RETURN NIL
   ELSEIF Empty(::oFirst)
      ::oFirst := ::aItems[1]
   ENDIF

   ::width := aMetr[2]
   ::height := aMetr[1]
   * x1 := aCoors[1] + 2
   y1 := aCoors[2] + 2
   * x2 := aCoors[3] - 2
   y2 := aCoors[4] - 2

   ::rowCount := Int( ( y2 - y1 ) / (::height + 1) )
   IF Empty(::aScreen) .OR. Len(::aScreen) < ::rowCount
      ::aScreen := Array(::rowCount + 5)
   ENDIF

   oNode := ::oFirst
   nNode := oNode:getNodeIndex()

   DO WHILE .T.

      ::aScreen[nLine] := oNode
      ::PaintNode(hDC, oNode, nNode, nLine++)
      IF nLine > ::rowCount() .OR. Empty(oNode := oNode:NextNode( @nNode ))
         EXIT
      ENDIF
   ENDDO
   ::rowCurrCount := nLine - 1

   RETURN NIL

/* Added: nNode */
METHOD PaintNode(hDC, oNode, nNode, nLine) CLASS HTree
   
   LOCAL y1 := (::height + 1) * (nLine - 1) + 1
   LOCAL x1 := 10 + oNode:nLevel * ::nIndent
   LOCAL i
   LOCAL hBmp
   LOCAL aBmpSize
   LOCAL nTextWidth

   hwg_Selectobject(hDC, ::oPenLine:handle)
   hwg_Drawline(hDC, iif(Empty(oNode:aItems), x1 + 5, x1 + 1), y1 + 9, x1 + ::nIndent - 4, y1 + 9)
   IF nNode > 1 .OR. oNode:nLevel > 1
      hwg_Drawline(hDC, x1 + 5, y1, x1 + 5, iif(Empty(oNode:aItems), y1 + 9, y1 + 4))
   ENDIF
   IF nNode < Len(oNode:oParent:aItems)
      hwg_Drawline(hDC, x1 + 5, iif(Empty(oNode:aItems), y1 + 9, y1 + 12), x1 + 5, y1 + ::height + 1)
   ENDIF
   IF !Empty(oNode:aItems)
      hwg_Rectangle(hDC, x1, y1 + 4, x1 + 8, y1 + 12)
      IF !oNode:lExpanded
         hwg_Selectobject(hDC, ::oPenPlus:handle)
         hwg_Drawline(hDC, x1 + 5, y1 + 5, x1 + 5, y1 + 12)
         hwg_Drawline(hDC, x1 + 1, y1 + 9, x1 + 8, y1 + 9)
         hwg_Selectobject(hDC, ::oPenLine:handle)
      ENDIF
   ENDIF

   IF !Empty(oNode:aImages)
      hBmp := iif(::oSelected == oNode .AND. Len(oNode:aImages) > 1, oNode:aImages[2], oNode:aImages[1] )
   ELSEIF !Empty(::aImages)
      hBmp := iif(::oSelected == oNode .AND. Len(::aImages) > 1, ::aImages[2], ::aImages[1])
   ENDIF
   IF !Empty(hBmp)
      aBmpSize := hwg_Getbitmapsize( hBmp )
      hwg_Drawbitmap(hDC, hBmp, NIL, x1 + ::nIndent, y1, aBmpSize[1], aBmpSize[2])
   ENDIF

   nTextWidth := hwg_GetTextWidth(hDC, oNode:title)
   x1 += ::nIndent + iif(!Empty(aBmpSize), aBmpSize[1] + 4, 0)
   IF ::oSelected == oNode
      hwg_Settextcolor(hDC, ::tcolorSel)
      hwg_Fillrect(hDC, x1, y1, x1 + nTextWidth, y1 + (::height + 1), ::brushSel:handle)
   ELSE
      hwg_Fillrect(hDC, x1, y1, x1 + nTextWidth, y1 + (::height + 1), ::brush:handle)
   ENDIF
   hwg_Drawtext(hDC, oNode:title, x1, y1, ::nX + ::nWidth - 1, y1 + (::height + 1), NIL, .T.)
   hwg_Settextcolor(hDC, ::tcolor)

   FOR i := oNode:nLevel - 1 TO 1 STEP - 1
      oNode := oNode:oParent
      IF !( oNode == Atail( oNode:oParent:aItems ) )
         x1 := 10 + oNode:nLevel * ::nIndent
         hwg_Drawline(hDC, x1 + 5, y1, x1 + 5, y1 + ::height + 1)
      ENDIF
   NEXT

   RETURN NIL

METHOD ButtonDown( lParam )  CLASS HTree
   
   LOCAL nLine := Int( hwg_Hiword(lParam) / (::height + 1) ) + 1
   LOCAL xm := hwg_Loword(lParam)
   LOCAL x1
   LOCAL hDC
   LOCAL oNode
   LOCAL nWidth
   LOCAL lRedraw := .F.

   IF nLine <= Len(::aScreen) .AND. !Empty(oNode := ::aScreen[nLine])
      x1 := 10 + oNode:nLevel * ::nIndent
      hDC := hwg_Getdc(::handle)
      IF !Empty(::oFont)
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      nWidth := hwg_GetTextWidth(hDC, oNode:title)
      hwg_Releasedc(::handle, hDC)
      IF !Empty(oNode:aItems) .AND.  xm >= x1 .AND. xm <= x1 + ::nIndent
         oNode:lExpanded := !oNode:lExpanded
         lRedraw := .T.

      ENDIF
      IF xm >= x1 .AND. xm <= x1 + ::nIndent + nWidth + 24
         ::Select( oNode, .T. )
         lRedraw := .T.
      ENDIF
      IF lRedraw
         hwg_Redrawwindow(::area)
      ENDIF
   ENDIF

   RETURN 0

METHOD ButtonUp( lParam ) CLASS HTree

   HB_SYMBOL_UNUSED(lParam)

   RETURN 0

METHOD ButtonDbl( lParam ) CLASS HTree
   
   LOCAL nLine := Int( hwg_Hiword(lParam) / (::height + 1) ) + 1
   LOCAL xm := hwg_Loword(lParam)
   LOCAL x1
   LOCAL hDC
   LOCAL oNode
   LOCAL nWidth

   IF nLine <= Len(::aScreen) .AND. !Empty(oNode := ::aScreen[nLine])
      x1 := 10 + oNode:nLevel * ::nIndent
      hDC := hwg_Getdc(::handle)
      IF !Empty(::oFont)
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      nWidth := hwg_GetTextWidth(hDC, oNode:title)
      hwg_Releasedc(::handle, hDC)
      IF xm >= x1 .AND. xm <= x1 + ::nIndent + nWidth
         ::Select( oNode, .T. )
         IF ::bDblClick != NIL
            Eval(::bDblClick, Self, oNode)
         ENDIF
         hwg_Redrawwindow(::area)
      ENDIF
   ENDIF

   RETURN 0

METHOD ButtonRDown( lParam ) CLASS HTree
   
   LOCAL nLine := Int( hwg_Hiword(lParam) / (::height + 1) ) + 1
   LOCAL xm := hwg_Loword(lParam)
   LOCAL x1
   LOCAL hDC
   LOCAL oNode
   LOCAL nWidth

   IF nLine <= Len(::aScreen) .AND. !Empty(oNode := ::aScreen[nLine])
      x1 := 10 + oNode:nLevel * ::nIndent
      hDC := hwg_Getdc(::handle)
      IF !Empty(::oFont)
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      nWidth := hwg_GetTextWidth(hDC, oNode:title)
      hwg_Releasedc(::handle, hDC)
      IF xm >= x1 .AND. xm <= x1 + ::nIndent + nWidth
         ::Select( oNode, .T. )
         IF ::bRClick != NIL
            Eval(::bRClick, Self, oNode)
         ENDIF
         hwg_Redrawwindow(::area)
      ENDIF
   ENDIF

   RETURN 0

METHOD GoDown( n ) CLASS HTree

   IF Empty(::aItems)
      RETURN 0
   ELSEIF Empty(::oFirst)
      ::oFirst := ::aItems[1]
   ENDIF
   IF ::rowCurrCount < ::rowCount .OR. Empty(::aScreen[::rowCurrCount]:NextNode())
      RETURN 0
   ENDIF
   ::oFirst := iif(n == 1, ::oFirst:NextNode(), ::aScreen[::rowCurrCount])
   hwg_Redrawwindow(::area)

   RETURN 0

METHOD GoUp( n ) CLASS HTree

   IF Empty(::aItems)
      RETURN 0
   ELSEIF Empty(::oFirst)
      ::oFirst := ::aItems[1]
   ENDIF
   IF ::oFirst == ::aItems[1]
      RETURN 0
   ENDIF

   IF n == 1
      ::oFirst := ::oFirst:PrevNode()
   ELSE
   ENDIF
   hwg_Redrawwindow(::area)

   RETURN 0

METHOD MouseWheel( nKeys, nDelta )  CLASS HTree

   IF hb_bitand( nKeys, MK_MBUTTON ) != 0
      IF nDelta > 0
         ::GoUp(2)
      ELSE
         ::GoDown(2)
      ENDIF
   ELSE
      IF nDelta > 0
         ::GoUp(1)
      ELSE
         ::GoDown(1)
      ENDIF
   ENDIF

   RETURN 0

METHOD DoHScroll() CLASS HTree

   RETURN 0

METHOD DoVScroll() CLASS HTree
   
   LOCAL nScrollV := hwg_getAdjValue(::hScrollV)

   IF nScrollV - ::nScrollV == 1
      ::GoDown(1)
   ELSEIF nScrollV - ::nScrollV == - 1
      ::GoUp(1)
   ELSEIF nScrollV - ::nScrollV == 10
      ::GoDown(2)
   ELSEIF nScrollV - ::nScrollV == - 10
      ::GoUp(2)
   ELSE
      IF ::bScrollPos != NIL
         Eval(::bScrollPos, Self, SB_THUMBTRACK, .F., nScrollV)
      ENDIF
   ENDIF
   ::nScrollV := nScrollV

   RETURN 0

METHOD End() CLASS HTree

   LOCAL j

   ::Super:END()
   IF !Empty(::aImages)
      FOR j := 1 TO Len(::aImages)
         IF !Empty(::aImages[j])
            hwg_Deleteobject(::aImages[j])
            ::aImages[j] := NIL
         ENDIF
      NEXT
   ENDIF
   ReleaseTree(::aItems, .T.)
   IF ::brush != NIL
      ::brush:Release()
   ENDIF
   IF ::brushSel != NIL
      ::brushSel:Release()
   ENDIF

   RETURN NIL

STATIC PROCEDURE ReleaseTree( aItems, lDelImages )
   
   LOCAL i
   LOCAL j
   LOCAL iLen := Len(aItems)

   FOR i := 1 TO iLen
      IF lDelImages .AND. !Empty(aItems[i]:aImages)
         FOR j := 1 TO Len(aItems[i]:aImages)
            IF aItems[i]:aImages[j] != NIL
               hwg_Deleteobject( aItems[i]:aImages[j] )
               aItems[i]:aImages[j] := NIL
            ENDIF
         NEXT
      ENDIF
      ReleaseTree( aItems[i]:aItems, lDelImages )
   NEXT

   RETURN
