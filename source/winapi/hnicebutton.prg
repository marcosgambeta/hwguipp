//
// HWGUI - Harbour Win32 GUI library source code:
//
// Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include <inkey.ch>
#include "hwguipp.ch"

#define TRANSPARENT 1

CLASS HNiceButton INHERIT HControl

   CLASSDATA oSelected INIT NIL

   DATA winclass INIT "NICEBUTT"
   DATA text
   DATA State INIT 0
   DATA ExStyle
   DATA bClick
   DATA cTooltip
   DATA lPress INIT .F.
   DATA r INIT 30
   DATA g INIT 90
   DATA b INIT 90
   DATA lFlat
   DATA nOrder

   METHOD New(oWndParent, nId, nStyle, nStyleEx, nX, nY, nWidth, nHeight, bInit, bClick, cText, cTooltip, r, g, b)
   METHOD Redefine(oWndParent, nId, nStyleEx, bInit, bClick, cText, cTooltip, r, g, b)
   METHOD Activate()
   METHOD INIT()
   METHOD Create()
   METHOD Size()
   METHOD Moving()
   METHOD Paint()
   METHOD MouseMove(wParam, lParam)
   METHOD MDown()
   METHOD MUp()
   METHOD Press() INLINE(::lPress := .T., ::MDown())
   METHOD RELEASE()
   METHOD END()

ENDCLASS

METHOD HNiceButton:New(oWndParent, nId, nStyle, nStyleEx, nX, nY, nWidth, nHeight, bInit, bClick, cText, cTooltip, r, g, b)

   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, NIL, bInit, NIL, NIL, cTooltip)

   DEFAULT g := ::g
   DEFAULT b := ::b
   DEFAULT r := ::r

   ::lFlat := .T.
   ::bClick := bClick
   ::nOrder := IIf(oWndParent == NIL, 0, Len(oWndParent:aControls))
   ::ExStyle := nStyleEx
   ::text := cText
   ::r := r
   ::g := g
   ::b := b
   ::nY := nY
   ::nX := nX
   ::nWidth := nWidth
   ::nHeight := nHeight

   hwg_Regnice()
   ::Activate()

RETURN Self

METHOD HNiceButton:Redefine(oWndParent, nId, nStyleEx, bInit, bClick, cText, cTooltip, r, g, b)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, NIL, bInit, NIL, NIL, cTooltip)

   DEFAULT g := ::g
   DEFAULT b := ::b
   DEFAULT r := ::r

   ::lFlat := .T.
   ::bClick := bClick
   ::ExStyle := nStyleEx
   ::text := cText
   ::r := r
   ::g := g
   ::b := b

   hwg_Regnice()

RETURN Self

METHOD HNiceButton:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createnicebtn(::oParent:handle, ::id, ::Style, ::nX, ::nY, ::nWidth, ::nHeight, ::ExStyle, ::Text)
      ::Init()
   ENDIF

RETURN NIL

METHOD HNiceButton:INIT()

   IF !::lInit
      ::Super:Init()
      ::Create()
   ENDIF

RETURN NIL

FUNCTION hwg_NICEBUTTPROC(hBtn, msg, wParam, lParam)

   LOCAL oBtn

   SWITCH msg
   CASE WM_PAINT
      IF (oBtn := hwg_FindSelf(hBtn)) == NIL
         RETURN .F.
      ENDIF
      oBtn:Paint()
      EXIT
   CASE WM_LBUTTONUP
      IF (oBtn := hwg_FindSelf(hBtn)) == NIL
         RETURN .F.
      ENDIF
      oBtn:MUp()
      EXIT
   CASE WM_LBUTTONDOWN
      IF (oBtn := hwg_FindSelf(hBtn)) == NIL
         RETURN .F.
      ENDIF
      oBtn:MDown()
      EXIT
   CASE WM_MOUSEMOVE
      IF (oBtn := hwg_FindSelf(hBtn)) == NIL
         RETURN .F.
      ENDIF
      oBtn:MouseMove(wParam, lParam)
      EXIT
   CASE WM_SIZE
      IF (oBtn := hwg_FindSelf(hBtn)) == NIL
         RETURN .F.
      ENDIF
      oBtn:Size()
      EXIT
   CASE WM_DESTROY
      IF (oBtn := hwg_FindSelf(hBtn)) == NIL
         RETURN .F.
      ENDIF
      oBtn:END()
      RETURN .T.
   ENDSWITCH

RETURN .F.

METHOD HNiceButton:Create()

   LOCAL Region
   LOCAL Rct
   LOCAL w
   LOCAL h

// Not used variables
//   LOCAL x
//   LOCAL y

   Rct := hwg_Getclientrect(::handle)
//   x := Rct[1]
//   y := Rct[2]
   w := Rct[3] - Rct[1]
   h := Rct[4] - Rct[2]
   Region := hwg_Createroundrectrgn(0, 0, w, h, h * 0.90, h * 0.90)
   hwg_Setwindowrgn(::Handle, Region, .T.)
   hwg_Invalidaterect(::Handle, 0, 0)

RETURN Self

METHOD HNiceButton:Size()

   ::State := OBTN_NORMAL
   hwg_Invalidaterect(::Handle, 0, 0)

RETURN Self

METHOD HNiceButton:Moving()

   ::State := .F.
   hwg_Invalidaterect(::Handle, 0, 0)

RETURN Self

METHOD HNiceButton:MouseMove(wParam, lParam)

   LOCAL otmp

// Not used variables
//     LOCAL aCoors
//     LOCAL xPos
//     LOCAL yPos

// Not used parameters
   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF ::lFlat .AND. ::state != OBTN_INIT

      otmp := hwg_SetNiceBtnSelected()

      IF otmp != NIL .AND. otmp:id != ::id .AND. !otmp:lPress
         otmp:state := OBTN_NORMAL
         hwg_Invalidaterect(otmp:handle, 0)
         hwg_Postmessage(otmp:handle, WM_PAINT, 0, 0)
         hwg_SetNiceBtnSelected(NIL)
      ENDIF

//      aCoors := hwg_Getclientrect(::handle)
//      xPos := hwg_Loword(lParam)
//      yPos := hwg_Hiword(lParam)

      IF ::state == OBTN_NORMAL
         ::state := OBTN_MOUSOVER
         // aBtn[CTRL_HANDLE] := hBtn
         hwg_Invalidaterect(::handle, 0)
         hwg_Postmessage(::handle, WM_PAINT, 0, 0)
         hwg_SetNiceBtnSelected(Self)
      ENDIF
   ENDIF

RETURN Self

METHOD HNiceButton:MUp()

   IF ::state == OBTN_PRESSED
      IF !::lPress
         ::state := IIf(::lFlat, OBTN_MOUSOVER, OBTN_NORMAL)
         hwg_Invalidaterect(::handle, 0)
         hwg_Postmessage(::handle, WM_PAINT, 0, 0)
      ENDIF
      IF !::lFlat
         hwg_SetNiceBtnSelected(NIL)
      ENDIF
      IF hb_IsBlock(::bClick)
         Eval(::bClick, ::oParent, ::id)
      ENDIF
   ENDIF

RETURN Self

METHOD HNiceButton:MDown()

   IF ::state != OBTN_PRESSED
      ::state := OBTN_PRESSED
      hwg_Invalidaterect(::Handle, 0, 0)
      hwg_Postmessage(::handle, WM_PAINT, 0, 0)
      hwg_SetNiceBtnSelected(Self)
   ENDIF

RETURN Self

METHOD HNiceButton:PAINT()

   LOCAL ps := hwg_Definepaintstru()
   LOCAL hDC := hwg_Beginpaint(::Handle, ps)
   LOCAL Rct
   LOCAL Size
   LOCAL XCtr
   LOCAL YCtr
   LOCAL x
   LOCAL y
   LOCAL w
   LOCAL h
   LOCAL T       // := Space(2048)
   //  *******************

// Variables not used
//
//    LOCAL p
// Preset of variable T with SPACE(2048)
// produces:
// Warning W0032  Variable 'T' is assigned but not used in function 'HNICEBUTTON_PAINT(276)'
//

   Rct := hwg_Getclientrect(::Handle)
   x := Rct[1]
   y := Rct[2]
   w := Rct[3] - Rct[1]
   h := Rct[4] - Rct[2]
   XCtr := (Rct[1] + Rct[3]) / 2
   YCtr := (Rct[2] + Rct[4]) / 2
   T := hwg_Getwindowtext(::Handle)
   // **********************************
   //         Draw our control
   // **********************************

   IF ::state == OBTN_INIT
      ::state := OBTN_NORMAL
   ENDIF

   Size := hwg_Gettextsize(hDC, T)

   hwg_Draw_gradient(hDC, x, y, w, h, ::r, ::g, ::b)
   hwg_Setbkmode(hDC, TRANSPARENT)

   IF (::State == OBTN_MOUSOVER)
//      p := hwg_Settextcolor(hDC, 0xFF0000)
      hwg_Settextcolor(hDC, 0xFF0000)
      hwg_Textout(hDC, XCtr - (Size[1] / 2) + 1, YCtr - (Size[2] / 2) + 1, T)
   ELSE
//      p := hwg_Settextcolor(hDC, 0x0000FF)
      hwg_Settextcolor(hDC, 0x0000FF)
      hwg_Textout(hDC, XCtr - Size[1] / 2, YCtr - Size[2] / 2, T)
   ENDIF

   hwg_Endpaint(::Handle, ps)

RETURN Self

METHOD HNiceButton:END()

RETURN NIL

METHOD HNiceButton:RELEASE()

   ::lPress := .F.
   ::state := OBTN_NORMAL
   hwg_Invalidaterect(::handle, 0)
   hwg_Postmessage(::handle, WM_PAINT, 0, 0)

RETURN NIL

FUNCTION hwg_SetNiceBtnSelected(oBtn)

   LOCAL otmp := HNiceButton():oSelected

   IF PCount() > 0
      HNiceButton():oSelected := oBtn
   ENDIF

RETURN otmp
