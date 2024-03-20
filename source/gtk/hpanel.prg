/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HPanel class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "gtk.ch"
#include "hwgui.ch"

CLASS HPanel INHERIT HControl

   DATA winclass INIT "PANEL"
   DATA hBox
   DATA oStyle
   DATA aPaintCB INIT {}       // Array of items to draw: { cIt, bDraw(hDC,aCoors) }
   DATA lDragWin INIT .F.
   DATA lCaptured INIT .F.
   DATA hCursor
   DATA nOldX, nOldY HIDDEN
   DATA hScrollV // INIT NIL
   DATA hScrollH // INIT NIL
   DATA nScrollV INIT 0
   DATA nScrollH INIT 0
   DATA bVScroll
   DATA bHScroll

   METHOD New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, bInit, bSize, bPaint, bColor, oStyle)
   METHOD Activate()
   METHOD onEvent( msg, wParam, lParam )
   METHOD Init()
   METHOD DrawItems(hDC, aCoors)
   METHOD Paint()
   METHOD Move( x1, y1, width, height )
   METHOD SetPaintCB(nId, block, cId)
   METHOD Drag( xPos, yPos )

ENDCLASS

METHOD HPanel:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, bInit, bSize, bPaint, bColor, oStyle)

   LOCAL oParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)

   IF !Empty(bPaint) .OR. bColor != NIL .OR. oStyle != NIL
      nStyle := hb_bitor( nStyle, SS_OWNERDRAW )
   ENDIF
   ::Super:New(oWndParent, nId, nStyle, nX, nY, iif(nWidth == NIL, 0, nWidth), nHeight, oParent:oFont, bInit, bSize, bPaint, NIL, NIL, bColor)
   ::oStyle := oStyle
   ::bPaint := bPaint
   ::Activate()

   RETURN Self

METHOD HPanel:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createpanel(Self, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HPanel:onEvent( msg, wParam, lParam )

   IF msg == WM_MOUSEMOVE
      IF ::lDragWin .AND. ::lCaptured
         ::Drag( hwg_Loword(lParam), hwg_Hiword(lParam) )
      ENDIF
   ELSEIF msg == WM_PAINT
      ::Paint()
   ELSEIF msg == WM_HSCROLL
      IF hb_IsBlock(::bHScroll)
         Eval(::bHScroll, Self)
      ENDIF
   ELSEIF msg == WM_VSCROLL
      IF hb_IsBlock(::bVScroll)
         Eval(::bVScroll, Self)
      ENDIF
   ELSEIF msg == WM_LBUTTONDOWN
      IF ::lDragWin
         IF ::hCursor == NIL
            ::hCursor := hwg_Loadcursor( GDK_HAND1 )
         ENDIF
         Hwg_SetCursor(::hCursor, ::handle)
         ::lCaptured := .T.
         ::nOldX := hwg_Loword(lParam)
         ::nOldY := hwg_Hiword(lParam)
      ENDIF
   ELSEIF msg == WM_LBUTTONUP
      ::lCaptured := .F.
      Hwg_SetCursor( NIL, ::handle )
   ENDIF

   RETURN ::Super:onEvent( msg, wParam, lParam )

METHOD HPanel:Init()

   IF !::lInit
      IF ::bSize == NIL .AND. Empty(::Anchor)
         IF ::nHeight != 0 .AND. (::nWidth > ::nHeight .OR. ::nWidth == 0)
            ::bSize := {|o, x, y|o:Move(NIL, iif(::nY > 0, y - ::nHeight, 0), x, ::nHeight)}
         ELSEIF ::nWidth != 0 .AND. (::nHeight > ::nWidth .OR. ::nHeight == 0)
            ::bSize := {|o, x, y|o:Move(iif(::nX > 0, x - ::nX, 0), NIL, ::nWidth, y)}
         ENDIF
      ENDIF
      ::Super:Init()
      hwg_Setwindowobject(::handle, Self)
   ENDIF

   RETURN NIL

METHOD HPanel:DrawItems(hDC, aCoors)

   LOCAL i
   LOCAL aCB

   IF Empty(aCoors)
      aCoors := hwg_Getclientrect(::handle)
   ENDIF
   IF !Empty(aCB := hwg_getPaintCB(::aPaintCB, PAINT_ITEM))
      FOR i := 1 TO Len(aCB)
         Eval( aCB[i], Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4] )
      NEXT
   ENDIF

   RETURN NIL

METHOD HPanel:Paint()

   LOCAL hDC
   LOCAL aCoors
   LOCAL block

   IF hb_IsBlock(::bPaint)
      RETURN Eval(::bPaint, Self)
   ENDIF
   hDC := hwg_Getdc(::handle)
   aCoors := hwg_Getclientrect(::handle)
   IF hb_IsBlock(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
      Eval( block, Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4] )
   ELSEIF ::oStyle == NIL
      hwg_Drawbutton(hDC, 0, 0, ::nWidth - 1, ::nHeight - 1, 5)
   ELSE
      ::oStyle:Draw(hDC, 0, 0, aCoors[3], aCoors[4])
   ENDIF
   ::DrawItems(hDC, aCoors)
   hwg_Releasedc(::handle, hDC)

   RETURN NIL

METHOD HPanel:Move( x1, y1, width, height )

   LOCAL lMove := .F.
   LOCAL lSize := .F.

   IF x1 != NIL .AND. x1 != ::nX
      ::nX := x1
      lMove := .T.
   ENDIF
   IF y1 != NIL .AND. y1 != ::nY
      ::nY := y1
      lMove := .T.
   ENDIF
   IF width != NIL .AND. width != ::nWidth
      ::nWidth := width
      lSize := .T.
   ENDIF
   IF height != NIL .AND. height != ::nHeight
      ::nHeight := height
      lSize := .T.
   ENDIF
   IF lMove .OR. lSize
      hwg_MoveWidget(::hbox, iif(lMove, ::nX, NIL), iif(lMove, ::nY, NIL), iif(lSize, ::nWidth, NIL), iif(lSize, ::nHeight, NIL), .F.)
      IF lSize
         hwg_MoveWidget(::handle, NIL, NIL, ::nWidth, ::nHeight, .F.)
         hwg_Redrawwindow(::handle)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HPanel:SetPaintCB(nId, block, cId)

   LOCAL i
   LOCAL nLen

   IF Empty(cId)
      cId := "_"
   ENDIF
   IF Empty(::aPaintCB)
      ::aPaintCB := {}
   ENDIF
   nLen := Len(::aPaintCB)
   FOR i := 1 TO nLen
      IF ::aPaintCB[i,1] == nId .AND. ::aPaintCB[i,2] == cId
         EXIT
      ENDIF
   NEXT
   IF Empty(block)
      IF i <= nLen
         ADel(::aPaintCB, i)
         ::aPaintCB := ASize(::aPaintCB, nLen - 1)
      ENDIF
   ELSE
      IF i > nLen
         AAdd(::aPaintCB, {nId, cId, block})
      ELSE
         ::aPaintCB[i,3] := block
      ENDIF
   ENDIF

   RETURN NIL

METHOD HPanel:Drag( xPos, yPos )

   LOCAL oWnd := hwg_getParentForm( Self )

   IF xPos > 32000
      xPos -= 65535
   ENDIF
   IF yPos > 32000
      yPos -= 65535
   ENDIF
   IF Abs( xPos - ::nOldX ) > 1 .OR. Abs( yPos - ::nOldY ) > 1
      oWnd:Move( oWnd:nX + ( xPos - ::nOldX ), oWnd:nY + ( yPos - ::nOldY ) )
   ENDIF

   RETURN NIL

CLASS HPanelStS INHERIT HPANEL

   DATA aParts
   DATA aText
   METHOD New( oWndParent, nId, nHeight, oFont, bInit, bPaint, bcolor, oStyle, aParts )
   METHOD Write(cText, nPart, lRedraw)
   METHOD SetText( cText ) INLINE ::Write(cText, NIL, .T.)
   METHOD PaintText(hDC)
   METHOD Paint()

ENDCLASS

METHOD HPanelStS:New( oWndParent, nId, nHeight, oFont, bInit, bPaint, bcolor, oStyle, aParts )

   oWndParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)
   IF bColor == NIL
      bColor := 0xeeeeee
   ENDIF
   ::Super:New( oWndParent, nId, SS_OWNERDRAW, 0, oWndParent:nHeight - nHeight, ;
      oWndParent:nWidth, nHeight, bInit, { |o, h|o:Move( 0, h - o:nHeight ) }, bPaint, bcolor )

*      oWndParent:nWidth, nHeight, bInit, { |o, w, h|o:Move( 0, h - o:nHeight ) }, bPaint, bcolor )

   ::Anchor := ANCHOR_LEFTABS + ANCHOR_RIGHTABS
   ::oFont := iif(oFont == NIL, ::oParent:oFont, oFont)
   ::oStyle := oStyle
   IF !Empty(aParts)
      ::aParts := aParts
   ELSE
      ::aParts := { 0 }
   ENDIF
   ::aText := Array( Len(::aParts) )
   AFill(::aText, "")

   RETURN Self

METHOD HPanelStS:Write(cText, nPart, lRedraw)

   ::aText[Iif(nPart==NIL,1,nPart)] := cText
   IF ValType( lRedraw ) != "L" .OR. lRedraw
      hwg_Invalidaterect(::handle, 0)
   ENDIF

   RETURN NIL

METHOD HPanelStS:PaintText(hDC)

   LOCAL i
   LOCAL x1
   LOCAL x2
   LOCAL nWidth := ::nWidth
   LOCAL oldTColor

   IF ::oFont != NIL
      hwg_Selectobject(hDC, ::oFont:handle)
   ENDIF
   hwg_Settransparentmode(hDC, .T.)
   oldTColor := hwg_Settextcolor(hDC, ::tcolor)
   FOR i := 1 TO Len(::aParts)
      x1 := iif(i == 1, 4, x2 + 4)
      IF ::aParts[i] == 0
         x2 := x1 + Int( nWidth/ (Len(::aParts ) - i + 1 ) )
      ELSE
         x2 := x1 + ::aParts[i]
      ENDIF
      nWidth -= ( x2 - x1 + 1 )
      IF !Empty(::aText[i])
         hwg_Drawtext(hDC, ::aText[i], x1, 6, x2, ::nHeight - 2, DT_LEFT + DT_VCENTER)
      ENDIF
   NEXT
   hwg_Settextcolor(hDC, oldTColor)
   hwg_Settransparentmode(hDC, .F.)

   RETURN NIL

METHOD HPanelStS:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL block
   LOCAL aCoors

   IF hb_IsBlock(::bPaint)
      RETURN Eval(::bPaint, Self)
   ENDIF
   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)
   IF hb_IsBlock(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
      aCoors := hwg_Getclientrect(::handle)
      Eval( block, Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4] )
   ELSEIF Empty(::oStyle)
      ::oStyle := HStyle():New( { ::bColor }, 1, NIL, 0.4, 0 )
   ENDIF
   ::oStyle:Draw(hDC, 0, 0, ::nWidth, ::nHeight)
   ::PaintText(hDC)
   ::DrawItems(hDC)
   hwg_Endpaint(::handle, pps)

   RETURN NIL

CLASS HPanelHea INHERIT HPANEL

   DATA xt
   DATA yt
   DATA lMaximized INIT .F.
   DATA lPreDef HIDDEN

   METHOD New(oWndParent, nId, nHeight, oFont, bInit, bPaint, tcolor, bcolor, oStyle, cText, xt, yt, lBtnClose, lBtnMax, lBtnMin)
   METHOD SetText( c , lrefresh )  && INLINE (::title := c)
   METHOD SetSysbtnColor( tColor, bColor )
   METHOD PaintText(hDC)
   METHOD Paint()

ENDCLASS

METHOD HPanelHea:New(oWndParent, nId, nHeight, oFont, bInit, bPaint, tcolor, bcolor, oStyle, cText, xt, yt, lBtnClose, lBtnMax, lBtnMin)

   LOCAL btnClose
   LOCAL btnMax
   LOCAL btnMin

   oWndParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)
   IF bColor == NIL
      bColor := 0xeeeeee
   ENDIF

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, 0, 0, oWndParent:nWidth, nHeight, bInit, ANCHOR_TOPABS+ANCHOR_LEFTABS+ANCHOR_RIGHTABS, bPaint, bcolor, oStyle)

   ::title := cText
   ::xt := xt
   ::yt := yt
   ::oFont := Iif(oFont == NIL, ::oParent:oFont, oFont)
   ::oStyle := oStyle
   ::tColor := Iif(tcolor==NIL, 0, tcolor)
   ::lDragWin := .T.
   ::lPreDef := .F.

   IF !Empty(lBtnClose) .OR. !Empty(lBtnMax) .OR. !Empty(lBtnMin)
      ::lPreDef := .T.

      IF !Empty(lBtnClose)
         @ 0, 0 OWNERBUTTON btnClose OF Self SIZE 1, 1 ;
            ON PAINT {|o|fPaintBtn(o)} ;
            ON CLICK {||::oParent:Close()}
      ENDIF
      IF !Empty(lBtnMax)
         @ 0, 0 OWNERBUTTON btnMax OF Self SIZE 1, 1 ;
            ON PAINT {|o|fPaintBtn(o)} ;
            ON CLICK {||Iif(::lMaximized,::oParent:Restore(),::oParent:Maximize()),::lMaximized:=!::lMaximized}
      ENDIF
      IF !Empty(lBtnMin)
         @ 0, 0 OWNERBUTTON btnMin OF Self SIZE 1, 1 ;
            ON PAINT {|o|fPaintBtn(o)} ;
            ON CLICK {||::oParent:Minimize()}
      ENDIF
      ::SetSysbtnColor( 0, 0xededed )
   ENDIF

   RETURN Self

METHOD HPanelHea:SetText( c , lrefresh)
// DF7BE: Set lrefresh to .T. for refreshing the header text
// (compatibility to INLINE definition)

   LOCAL hDC

 IF lrefresh == NIL
   lrefresh := .F.
 ENDIF

 ::title := c

 IF lrefresh

   hDC := hwg_Getdc(::handle)

   ::PaintText(hDC)

  hwg_Redrawwindow(::handle)
   /*
      This only for WinAPI
      RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW
      (2nd parameter)
    */

 ENDIF

RETURN NIL


METHOD HPanelHea:SetSysbtnColor( tColor, bColor )

   LOCAL oBtn
   LOCAL oPen1
   LOCAL oPen2

   oPen1 := HPen():Add( BS_SOLID, 2, tColor )
   oPen2 := HPen():Add( BS_SOLID, 1, tColor )

   IF !Empty(oBtn := ::FindControl( "btnclose" ))
      oBtn:SetColor( tColor, bColor )
      oBtn:oPen1 := oPen1; oBtn:oPen2 := oPen2
   ENDIF
   IF !Empty(oBtn := ::FindControl( "btnmax" ))
      oBtn:SetColor( tColor, bColor )
      oBtn:oPen1 := oPen1; oBtn:oPen2 := oPen2
   ENDIF
   IF !Empty(oBtn := ::FindControl( "btnmin" ))
      oBtn:SetColor( tColor, bColor )
      oBtn:oPen1 := oPen1; oBtn:oPen2 := oPen2
   ENDIF
   RETURN NIL

METHOD HPanelHea:PaintText(hDC)

   LOCAL x1
   LOCAL y1
   LOCAL oldTColor

   IF ::title != NIL

      IF ::oFont != NIL
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      hwg_Settransparentmode(hDC, .T.)
      oldTColor := hwg_Settextcolor(hDC, ::tcolor)
      x1 := Iif(::xt == NIL, 4, ::xt)
      y1 := Iif(::yt == NIL, 4, ::yt)
      hwg_Drawtext(hDC, ::title, x1, y1, ::nWidth - 4, ::nHeight - 4, DT_LEFT + DT_VCENTER)
      hwg_Settextcolor(hDC, oldTColor)
      hwg_Settransparentmode(hDC, .F.)
   ENDIF

   RETURN NIL

METHOD HPanelHea:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL block
   LOCAL aCoors
   LOCAL oBtn
   LOCAL nBtnSize
   LOCAL x1
   LOCAL y1

   IF hb_IsBlock(::bPaint)
      RETURN Eval(::bPaint, Self)
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(::handle, pps)

   IF hb_IsBlock(block := hwg_getPaintCB(::aPaintCB, PAINT_BACK))
      aCoors := hwg_Getclientrect(::handle)
      Eval( block, Self, hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4] )
   ELSEIF Empty(::oStyle)
      ::oStyle := HStyle():New( {::bColor}, 1 )
   ENDIF
   ::oStyle:Draw(hDC, 0, 0, ::nWidth, ::nHeight)

   ::PaintText(hDC)
   ::DrawItems(hDC)

   hwg_Endpaint(::handle, pps)

   IF ::lPreDef
      ::lPreDef := .F.
      nBtnSize := Min( 24, ::nHeight )
      x1 := ::nWidth-nBtnSize-4
      y1 := Int((::nHeight-nBtnSize)/2)
      IF !Empty(oBtn := ::FindControl( "btnclose" ))
         oBtn:oBitmap := HBitmap():AddWindow( Self, x1, y1, nBtnSize, nBtnSize )
         oBtn:Move( x1, y1, nBtnSize, nBtnSize )
         oBtn:Anchor := ANCHOR_RIGHTABS
         x1 -= nBtnSize
      ENDIF
      IF !Empty(oBtn := ::FindControl( "btnmax" ))
         oBtn:oBitmap := HBitmap():AddWindow( Self, x1, y1, nBtnSize, nBtnSize )
         oBtn:Move( x1, y1, nBtnSize, nBtnSize )
         oBtn:Anchor := ANCHOR_RIGHTABS
         x1 -= nBtnSize
      ENDIF
      IF !Empty(oBtn := ::FindControl( "btnmin" ))
         oBtn:oBitmap := HBitmap():AddWindow( Self, x1, y1, nBtnSize, nBtnSize )
         oBtn:Move( x1, y1, nBtnSize, nBtnSize )
         oBtn:Anchor := ANCHOR_RIGHTABS
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION fPaintBtn( oBtn )

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors

   IF oBtn:nWidth <= 1
      RETURN NIL
   ENDIF
   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint( oBtn:handle, pps )
   aCoors := hwg_Getclientrect( oBtn:handle )

   IF oBtn:state == OBTN_NORMAL
      hwg_Drawbitmap(hDC, oBtn:oBitmap:handle, NIL, 0, 0)
   ELSEIF oBtn:state == OBTN_MOUSOVER
      hwg_Fillrect(hDC, 0, 0, aCoors[3] - 1, aCoors[4] - 1, oBtn:brush:handle)
   ELSEIF oBtn:state == OBTN_PRESSED
      hwg_Fillrect(hDC, 0, 0, aCoors[3] - 1, aCoors[4] - 1, oBtn:brush:handle)
      hwg_Selectobject(hDC, oBtn:oPen2:handle)
      hwg_Rectangle(hDC, 0, 0, aCoors[3] - 1, aCoors[4] - 1)
   ENDIF

   hwg_Selectobject(hDC, oBtn:oPen1:handle)
   IF oBtn:objname == "BTNCLOSE"
      hwg_Drawline(hDC, 6, 6, aCoors[3] - 6, aCoors[4] - 6)
      hwg_Drawline(hDC, aCoors[3] - 6, 6, 6, aCoors[4] - 6)
   ELSEIF oBtn:objname == "BTNMAX"
      hwg_Drawline(hDC, 6, 6, aCoors[3] - 6, 6)
      hwg_Drawline(hDC, 6, aCoors[4] - 6, aCoors[3] - 6, aCoors[4] - 6)
      hwg_Selectobject(hDC, oBtn:oPen2:handle)
      hwg_Drawline(hDC, 6, 6, 6, aCoors[4] - 6)
      hwg_Drawline(hDC, aCoors[3] - 6, 6, aCoors[3] - 6, aCoors[4] - 6)
   ELSEIF oBtn:objname == "BTNMIN"
      hwg_Drawline(hDC, 6, aCoors[4] - 6, aCoors[3] - 12, aCoors[4] - 6)
   ENDIF

   hwg_Endpaint( oBtn:handle, pps )

   RETURN NIL
