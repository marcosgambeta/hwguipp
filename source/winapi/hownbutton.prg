//
// HWGUI - Harbour Win32 GUI library source code:
// HOwnButton class, which implements owner drawn buttons
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include <common.ch>
#include <inkey.ch>
#include "hwguipp.ch"

CLASS HOwnButton INHERIT HControl

   CLASS VAR cPath SHARED

   DATA winclass INIT "OWNBTN"
   DATA lFlat
   DATA aStyle
   DATA state
   DATA bClick
   DATA lPress INIT .F.
   DATA lCheck INIT .F.
   DATA xt
   DATA yt
   DATA widtht
   DATA heightt
   DATA oBitmap
   DATA xb
   DATA yb
   DATA widthb
   DATA heightb
   DATA lTransp
   DATA trColor
   DATA oPen1
   DATA oPen2
   DATA lEnabled INIT .T.
   DATA nOrder
   DATA oTimer
   DATA nPeriod INIT 0

   METHOD New(oWndParent, nId, aStyles, nX, nY, nWidth, nHeight, bInit, bSize, bPaint, bClick, lflat, cText, color, ofont, xt, yt, ;
              widtht, heightt, bmp, lResour, xb, yb, widthb, heightb, lTr, trColor, cTooltip, lEnabled, lCheck, bColor)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Redefine(oWndParent, nId, bInit, bSize, bPaint, bClick, lflat, cText, color, font, xt, yt, widtht, heightt, bmp, lResour, xb, yb, widthb, heightb, lTr, cTooltip, lEnabled, lCheck)
   METHOD Paint()
   METHOD DrawItems(hDC)
   METHOD MouseMove(wParam, lParam)
   METHOD MDown()
   METHOD MUp()
   METHOD Press() INLINE (::lPress := .T., ::MDown())
   METHOD SetTimer(nPeriod)
   METHOD RELEASE()
   METHOD End()
   METHOD Enable()
   METHOD Disable()

ENDCLASS

METHOD HOwnButton:New(oWndParent, nId, aStyles, nX, nY, nWidth, nHeight, bInit, bSize, bPaint, bClick, lflat, ;
           cText, color, oFont, xt, yt, widtht, heightt, bmp, lResour, xb, yb, widthb, heightb, lTr, trColor, ;
           cTooltip, lEnabled, lCheck, bColor)

   ::Super:New(oWndParent, nId, NIL, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, cTooltip)

   IF oFont == NIL
      ::oFont := ::oParent:oFont
   ENDIF
   ::aStyle := aStyles
   ::lflat := IIf(lflat == NIL, .F., lflat)
   ::bClick := bClick
   ::state := OBTN_INIT
   ::nOrder := IIf(oWndParent == NIL, 0, Len(oWndParent:aControls))

   ::title := cText
   ::tcolor := IIf(color == NIL, hwg_Getsyscolor(COLOR_BTNTEXT), color)
   IF bColor != NIL
      ::bcolor := bcolor
      ::brush := HBrush():Add(bcolor)
   ENDIF
   ::xt := IIf(xt == NIL, 0, xt)
   ::yt := IIf(yt == NIL, 0, yt)
   ::widtht := IIf(widtht == NIL, 0, widtht)
   ::heightt := IIf(heightt == NIL, 0, heightt)

   IF lEnabled != NIL
      ::lEnabled := lEnabled
   ENDIF
   IF lCheck != NIL
      ::lCheck := lCheck
   ENDIF
   IF bmp != NIL
      IF hb_IsObject(bmp)
         // Valid bitmap object
         ::oBitmap := bmp
      ELSE
         ::oBitmap := IIf((lResour != NIL .AND. lResour) .OR. hb_IsNumeric(bmp), HBitmap():AddResource(bmp), HBitmap():AddFile(IIf(::cPath != NIL, ::cPath + bmp, bmp)))
      ENDIF
   ENDIF
   ::xb := xb
   ::yb := yb
   ::widthb := IIf(widthb == NIL, 0, widthb)
   ::heightb := IIf(heightb == NIL, 0, heightb)
   ::lTransp := IIf(lTr != NIL, lTr, .F.)
   ::trColor := trColor

   hwg_RegOwnBtn()
   ::Activate()

   RETURN Self

METHOD HOwnButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createownbtn(::oParent:handle, ::id, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
      IF !::lEnabled
         hwg_Enablewindow(::handle, .F.)
         ::Disable()
      ENDIF

   ENDIF

   RETURN NIL

METHOD HOwnButton:onEvent(msg, wParam, lParam)

   STATIC h

   SWITCH msg

   CASE WM_PAINT
      IF ::state == OBTN_INIT
         ::state := OBTN_NORMAL
      ENDIF
      IF hb_IsBlock(::bPaint)
         Eval(::bPaint, Self)
      ELSE
         ::Paint()
      ENDIF
      EXIT

   CASE WM_ERASEBKGND
      RETURN 1

   CASE WM_MOUSEMOVE
      IF ::MouseMove(wParam, lParam) .AND. !Empty(h)
         hwg_Setfocus(h)
         h := NIL
      ENDIF
      EXIT

   CASE WM_LBUTTONDOWN
      h := hwg_Setfocus(::handle)
      ::MDown()
      EXIT

   CASE WM_LBUTTONDBLCLK
      /* Asmith 2017-06-06 workaround for touch terminals */
      IF hb_IsBlock(::bClick) .AND. Empty(::oTimer)
         Eval(::bClick, Self, 0)
      ENDIF
      EXIT

   CASE WM_LBUTTONUP
      ::MUp()
      IF hwg_Isptreq(::handle, hwg_Getfocus()) .AND. !Empty(h)
         hwg_Setfocus(h)
      ENDIF
      h := NIL
      EXIT

   CASE WM_DESTROY
      ::End()
      EXIT

   CASE WM_SETFOCUS
      IF hb_IsBlock(::bGetfocus)
         Eval(::bGetfocus, Self, msg, wParam, lParam)
      ENDIF
      EXIT

   CASE WM_KILLFOCUS
      ::release()
      IF hb_IsBlock(::bLostfocus)
         Eval(::bLostfocus, Self, msg, wParam, lParam)
      ENDIF
      EXIT

   OTHERWISE
      IF hb_IsBlock(::bOther)
         Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF

   ENDSWITCH

   RETURN -1

METHOD HOwnButton:Init()

   IF !::lInit
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
      ::Super:Init()
   ENDIF

   RETURN NIL

METHOD HOwnButton:Redefine(oWndParent, nId, bInit, bSize, bPaint, bClick, lflat, cText, color, font, xt, yt, widtht, heightt, bmp, lResour, xb, yb, ;
                widthb, heightb, lTr, cTooltip, lEnabled, lCheck)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, NIL, bInit, bSize, bPaint, cTooltip)

   ::lflat := IIf(lflat == NIL, .F., lflat)
   ::bClick := bClick
   ::state := OBTN_INIT

   ::title := cText
   ::tcolor := IIf(color == NIL, hwg_Getsyscolor(COLOR_BTNTEXT), color)
   ::ofont := font
   ::xt := IIf(xt == NIL, 0, xt)
   ::yt := IIf(yt == NIL, 0, yt)
   ::widtht := IIf(widtht == NIL, 0, widtht)
   ::heightt := IIf(heightt == NIL, 0, heightt)

   IF lEnabled != NIL
      ::lEnabled := lEnabled
   ENDIF
   IF lEnabled != NIL
      ::lEnabled := lEnabled
   ENDIF
   IF lCheck != NIL
      ::lCheck := lCheck
   ENDIF

   IF bmp != NIL
      IF hb_IsObject(bmp)
         ::oBitmap := bmp
      ELSE
         ::oBitmap := IIf(lResour, HBitmap():AddResource(bmp), HBitmap():AddFile(bmp))
      ENDIF
   ENDIF
   ::xb := xb
   ::yb := yb
   ::widthb := IIf(widthb == NIL, 0, widthb)
   ::heightb := IIf(heightb == NIL, 0, heightb)
   ::lTransp := IIf(lTr != NIL, lTr, .F.)
   hwg_RegOwnBtn()

   RETURN Self

METHOD HOwnButton:Paint()

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors
   LOCAL n

   pps := hwg_Definepaintstru()

   hDC := hwg_Beginpaint(::handle, pps)

   aCoors := hwg_Getclientrect(::handle)

   IF ::nWidth != aCoors[3] .OR. ::nHeight != aCoors[4]
      ::nWidth := aCoors[3]
      ::nHeight := aCoors[4]
   ENDIF

   IF !Empty(::aStyle)
      n := Len(::aStyle)
      n := IIf(::state == OBTN_MOUSOVER, IIf(n > 2, 3, 1), IIf(::state == OBTN_PRESSED, IIf(n > 1, 2, 1), 1))
      ::aStyle[n]:Draw(hDC, 0, 0, aCoors[3], aCoors[4])
   ELSEIF ::lFlat
      SWITCH ::state
      CASE OBTN_NORMAL
         IF ::handle != hwg_Getfocus()
            hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 0) // NORM
         ELSE
            hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 1)
         ENDIF
         EXIT
      CASE OBTN_MOUSOVER
         hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 1)
         EXIT
      CASE OBTN_PRESSED
         hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 2)
      ENDSWITCH
   ELSE
      SWITCH ::state
      CASE OBTN_NORMAL
         hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 5)
         EXIT
      CASE OBTN_PRESSED
         hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 6)
      ENDSWITCH
   ENDIF

   ::DrawItems(hDC)

   hwg_Endpaint(::handle, pps)

   RETURN NIL

METHOD HOwnButton:DrawItems(hDC)

   LOCAL x1
   LOCAL y1
   LOCAL x2
   LOCAL y2
   LOCAL aCoors

   aCoors := hwg_Getclientrect(::handle)
   IF !Empty(::brush)
      hwg_Fillrect(hDC, aCoors[1] + 2, aCoors[2] + 2, aCoors[3] - 2, aCoors[4] - 2, ::brush:handle)
   ENDIF

   IF ::oBitmap != NIL
      IF ::widthb == 0
         ::widthb := ::oBitmap:nWidth
         ::heightb := ::oBitmap:nHeight
      ENDIF
      x1 := IIf(::xb != NIL .AND. ::xb != 0, ::xb, Round((::nWidth - ::widthb) / 2, 0))
      y1 := IIf(::yb != NIL .AND. ::yb != 0, ::yb, Round((::nHeight - ::heightb) / 2, 0))
      IF ::lEnabled
         IF ::oBitmap:ClassName() == "HICON"
            hwg_Drawicon(hDC, ::oBitmap:handle, x1, y1)
         ELSE
            IF ::lTransp
               hwg_Drawtransparentbitmap(hDC, ::oBitmap:handle, x1, y1, ::trColor)
            ELSE
               hwg_Drawbitmap(hDC, ::oBitmap:handle, NIL, x1, y1, ::widthb, ::heightb)
            ENDIF
         ENDIF
      ELSE
         hwg_Drawgraybitmap(hDC, ::oBitmap:handle, x1, y1)
      ENDIF
   ENDIF

   IF hb_IsChar(::title)
      IF hb_IsObject(::oFont)
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      IF ::lEnabled
         hwg_Settextcolor(hDC, ::tcolor)
      ELSE
         hwg_Settextcolor(hDC, hwg_ColorRgb2N(255, 255, 255))
      ENDIF
      x1 := IIf(::xt != 0, ::xt, 4)
      y1 := IIf(::yt != 0, ::yt, 4)
      x2 := ::nWidth - 4
      y2 := ::nHeight - 4
      hwg_Settransparentmode(hDC, .T.)
      hwg_Drawtext(hDC, ::title, x1, y1, x2, y2, IIf(::xt != 0, DT_LEFT, DT_CENTER) + IIf(::yt != 0, DT_TOP, DT_VCENTER + DT_SINGLELINE))
      hwg_Settransparentmode(hDC, .F.)
   ENDIF

   RETURN NIL

METHOD HOwnButton:MouseMove(wParam, lParam)

   LOCAL xPos
   LOCAL yPos
   LOCAL res := .F.

   HB_SYMBOL_UNUSED(wParam)

   IF ::state != OBTN_INIT
      xPos := hwg_Loword(lParam)
      yPos := hwg_Hiword(lParam)
      //hwg_writelog("mm-2 " + str(xpos) + "/" + str(ypos))
      IF xPos > ::nWidth .OR. yPos > ::nHeight
         hwg_Releasecapture()
         IF hb_IsObject(::oTimer)
            OwnBtnTimerProc(Self, 2)
            ::oTimer:End()
            ::oTimer := NIL
         ENDIF
         res := .T.
      ENDIF

      IF res .AND. !::lPress
         ::state := OBTN_NORMAL
         hwg_Invalidaterect(::handle, 0)
         // hwg_Postmessage(::handle, WM_PAINT, 0, 0)
      ENDIF
      IF ::state == OBTN_NORMAL .AND. !res
         ::state := OBTN_MOUSOVER
         hwg_Invalidaterect(::handle, 0)
         // hwg_Postmessage(::handle, WM_PAINT, 0, 0)
         hwg_Setcapture(::handle)
      ENDIF
   ENDIF

   RETURN res

METHOD HOwnButton:MDown()

   IF ::state != OBTN_PRESSED
      ::state := OBTN_PRESSED
      hwg_Invalidaterect(::handle, 0)
      IF ::nPeriod > 0
         ::oTimer := HTimer():New(Self, NIL, ::nPeriod, {|o|OwnBtnTimerProc(o, 1)})
         OwnBtnTimerProc(Self, 0)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HOwnButton:MUp()

   IF ::state == OBTN_PRESSED
      IF !::lPress
         ::state := IIf(::lFlat, OBTN_MOUSOVER, OBTN_NORMAL)
      ENDIF
      IF ::lCheck
         IF ::lPress
            ::Release()
         ELSE
            ::Press()
         ENDIF
      ENDIF
      IF hb_IsObject(::oTimer)
         hwg_Releasecapture()
         OwnBtnTimerProc(Self, 2)
         ::oTimer:End()
         ::oTimer := NIL
      ELSE
         IF hb_IsBlock(::bClick)
            hwg_Releasecapture()
            Eval(::bClick, Self)
         ENDIF
      ENDIF
      hwg_Invalidaterect(::handle, 0)
   ENDIF

   RETURN NIL

METHOD HOwnButton:SetTimer(nPeriod)

   IF nPeriod == NIL
      IF hb_IsObject(::oTimer)
         OwnBtnTimerProc(Self, 2)
         ::oTimer:End()
         ::oTimer := NIL
      ENDIF
      ::nPeriod := 0
   ELSE
      ::nPeriod := nPeriod
   ENDIF

   RETURN NIL

METHOD HOwnButton:RELEASE()

   ::lPress := .F.
   ::state := OBTN_NORMAL
   hwg_Invalidaterect(::handle, 0)

   RETURN NIL

METHOD HOwnButton:End()

   ::Super:End()
   ::oFont := NIL
   IF hb_IsObject(::oBitmap)
      ::oBitmap:Release()
      ::oBitmap := NIL
   ENDIF
   IF hb_IsObject(::oTimer)
      ::oTimer:End()
      ::oTimer := NIL
   ENDIF
   hwg_Postmessage(::handle, WM_CLOSE, 0, 0)

   RETURN NIL

METHOD HOwnButton:Enable()

   hwg_Enablewindow(::handle, .T.)
   ::lEnabled := .T.
   hwg_Invalidaterect(::handle, 0)
   // hwg_Sendmessage(::handle, WM_PAINT, 0, 0)
   //::Init() BECAUSE ERROR GPF

   RETURN NIL

METHOD HOwnButton:Disable()

   ::state := OBTN_INIT
   ::lEnabled := .F.
   hwg_Invalidaterect(::handle, 0)
   // hwg_Sendmessage(::handle, WM_PAINT, 0, 0)
   hwg_Enablewindow(::handle, .F.)

   RETURN NIL

STATIC FUNCTION OwnBtnTimerProc(oBtn, nType)

   IF hb_IsBlock(oBtn:bClick)
      Eval(oBtn:bClick, oBtn, nType)
   ENDIF

   RETURN NIL
