//
// HWGUI - Harbour Win32 GUI library source code:
// HCombo class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HComboBox INHERIT HControl

   CLASS VAR winclass INIT "COMBOBOX"

   DATA aItems
   DATA bSetGet
   DATA xValue INIT 1
   DATA bValid INIT {||.T.}
   DATA bChangeSel
   DATA nDisplay
   DATA lText INIT .F.
   DATA lEdit INIT .F.

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, aItems, oFont, bInit, bSize, bPaint, bChange, ;
              ctooltip, lEdit, lText, bGFocus, tcolor, bcolor, bValid, nDisplay)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, bChange, ctooltip, bGFocus)
   METHOD Init()
   METHOD Refresh(xVal)
   METHOD Setitem(nPos)
   METHOD GetValue(nItem)
   METHOD Value(xValue) SETGET

ENDCLASS

METHOD HComboBox:New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, aItems, oFont, bInit, bSize, bPaint, bChange, ;
           ctooltip, lEdit, lText, bGFocus, tcolor, bcolor, bValid, nDisplay)

   IF pcount() == 0
      ::Super:New(NIL, NIL, CBS_DROPDOWNLIST + WS_TABSTOP, 0, 0, 0, 0, NIL, NIL, NIL, NIL, NIL, NIL, NIL)
      ::Activate()
      ::oParent:AddEvent(CBN_KILLFOCUS, ::id, {|o, id|__Valid(o:FindControl(id))})
      RETURN Self
   ENDIF

   IF lEdit == NIL
      lEdit := .F.
   ENDIF
   IF lText == NIL
      lText := .F.
   ENDIF

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), IIf(lEdit, CBS_DROPDOWN, CBS_DROPDOWNLIST) + WS_TABSTOP)
   IF !Empty(nDisplay)
      nStyle := hb_bitor(nStyle, CBS_NOINTEGRALHEIGHT + WS_VSCROLL)
      ::nDisplay := nDisplay
   ENDIF
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   ::lEdit := lEdit
   ::lText := lText

   IF lEdit
      ::lText := .T.
   ENDIF

   IF ::lText
      ::xValue := IIf(vari == NIL .OR. !hb_IsChar(vari), "", Trim(vari))
   ELSE
      ::xValue := IIf(vari == NIL .OR. !hb_IsNumeric(vari), 1, vari)
   ENDIF

   IF hb_IsBlock(bSetGet)
      ::bSetGet := bSetGet
      Eval(::bSetGet, ::xValue, Self)
   ENDIF

   ::aItems := aItems

   ::Activate()

   IF !Empty(bValid)
      ::bValid := bValid
   ENDIF
   ::bChangeSel := bChange
   ::oParent:AddEvent(CBN_KILLFOCUS, ::id, {|o, id|__Valid(o:FindControl(id))})
   IF ::bChangeSel != NIL
      ::oParent:AddEvent(CBN_SELCHANGE, ::id, {|o, id|__Valid(o:FindControl(id))})
   ENDIF

   IF bGFocus != NIL
      ::bGetFocus := bGFocus
      ::oParent:AddEvent(CBN_SETFOCUS, ::id, {|o, id|__When(o:FindControl(id))})
   ENDIF

   RETURN Self

METHOD HComboBox:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createcombo(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HComboBox:Redefine(oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, bChange, ctooltip, bGFocus)

   HB_SYMBOL_UNUSED(bGFocus)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip)

   IF ::lText
      ::xValue := IIf(vari == NIL .OR. !hb_IsChar(vari), "", Trim(vari))
   ELSE
      ::xValue := IIf(vari == NIL .OR. !hb_IsNumeric(vari), 1, vari)
   ENDIF
   ::bSetGet := bSetGet
   ::aItems := aItems

   IF bSetGet != NIL
      ::bChangeSel := bChange
      // By Luiz Henrique dos Santos (luizhsantos@gmail.com) 04/06/2006
      IF ::bChangeSel != NIL
         ::oParent:AddEvent(CBN_SELCHANGE, ::id, {|o, id|__Valid(o:FindControl(id))})
      ENDIF
   ELSEIF bChange != NIL
      ::oParent:AddEvent(CBN_SELCHANGE, ::id, bChange)
   ENDIF
   ::oParent:AddEvent(CBN_KILLFOCUS, ::id, {|o, id|__Valid(o:FindControl(id))})
   ::Refresh() // By Luiz Henrique dos Santos

   RETURN Self

METHOD HComboBox:Init()

   LOCAL i
   LOCAL nHeightBox
   LOCAL nHeightItem

   IF !::lInit
      ::Super:Init()
      IF !Empty(::aItems)
         IF Empty(::xValue)
            IF ::lText
               ::xValue := IIf(hb_IsArray(::aItems[1]), ::aItems[1, 1], ::aItems[1])
            ELSE
               ::xValue := 1
            ENDIF
         ENDIF
         hwg_Sendmessage(::handle, CB_RESETCONTENT, 0, 0)
         FOR i := 1 TO Len(::aItems)
            hwg_Comboaddstring(::handle, IIf(hb_IsArray(::aItems[i]), ::aItems[i, 1], ::aItems[i]))
         NEXT
         IF ::lText
            i := IIf(hb_IsArray(::aItems[1]), AScan(::aItems, {|a|a[1] == ::xValue}), hb_AScan(::aItems, ::xValue, NIL, NIL, .T.))
            hwg_Combosetstring(::handle, i)
         ELSE
            hwg_Combosetstring(::handle, ::xValue)
         ENDIF
      ENDIF
      IF !Empty(::nDisplay)
         nHeightBox := hwg_Sendmessage(::handle, CB_GETITEMHEIGHT, -1, 0)
         nHeightItem := hwg_Sendmessage(::handle, CB_GETITEMHEIGHT, -1, 0)
         ::nHeight := nHeightBox + nHeightItem * (::nDisplay)
         hwg_Movewindow(::handle, ::nX, ::nY, ::nWidth, ::nHeight)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HComboBox:Refresh(xVal)

   LOCAL vari
   LOCAL i

   IF !Empty(::aItems)
      IF xVal != NIL
         ::xValue := xVal
      ELSEIF hb_IsBlock(::bSetGet)
         vari := Eval(::bSetGet, NIL, Self)
         IF ::lText
            ::xValue := IIf(vari == NIL .OR. !hb_IsChar(vari), "", Trim(vari))
         ELSE
            ::xValue := IIf(vari == NIL .OR. !hb_IsNumeric(vari), 1, vari)
         ENDIF
      ENDIF

      hwg_Sendmessage(::handle, CB_RESETCONTENT, 0, 0)

      FOR i := 1 TO Len(::aItems)
         hwg_Comboaddstring(::handle, IIf(hb_IsArray(::aItems[i]), ::aItems[i, 1], ::aItems[i]))
      NEXT

      IF ::lText
         i := IIf(hb_IsArray(::aItems[1]), AScan(::aItems, {|a|a[1] == ::xValue}), hb_AScan(::aItems, ::xValue, NIL, NIL, .T.))
         hwg_Combosetstring(::handle, i)
      ELSE
         hwg_Combosetstring(::handle, ::xValue)
         ::SetItem(::xValue)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HComboBox:SetItem(nPos)

   IF ::lText
      ::xValue := IIf(hb_IsArray(::aItems[nPos]), ::aItems[nPos, 1], ::aItems[nPos])
   ELSE
      ::xValue := nPos
   ENDIF

   hwg_Sendmessage(::handle, CB_SETCURSEL, nPos - 1, 0)

   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::xValue, self)
   ENDIF

   IF hb_IsBlock(::bChangeSel)
      Eval(::bChangeSel, nPos, Self)
   ENDIF

   RETURN NIL

METHOD HComboBox:GetValue(nItem)

   LOCAL nPos
   LOCAL l := .F.

   IF ::lEdit
      ::xValue := ::GetText()
   ELSE
      nPos := hwg_Sendmessage(::handle, CB_GETCURSEL, 0, 0) + 1
      IF nPos > 0 .AND. nPos <= Len(::aItems)
         l := hb_IsArray(::aItems[nPos])
         ::xValue := IIf(::lText, IIf(l, ::aItems[nPos, 1], ::aItems[nPos]), nPos)
      ENDIF
   ENDIF
   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::xValue, Self)
   ENDIF

   RETURN IIf(l .AND. nItem != NIL, IIf(nItem > 0 .AND. nItem <= Len(::aItems[nPos]), ::aItems[nPos,nItem], NIL), ::xValue)

METHOD HComboBox:Value(xValue)

   IF xValue != NIL
      IF hb_IsChar(xValue)
         xValue := IIf(hb_IsArray(::aItems[1]), AScan(::aItems, {|a|a[1] == xValue}), hb_AScan(::aItems, xValue, NIL, NIL, .T.))
      ENDIF
      ::SetItem(xValue)

      RETURN ::xValue
   ENDIF

   RETURN ::GetValue()

STATIC FUNCTION __Valid(oCtrl)

   LOCAL nPos
   LOCAL lESC

   // by sauli
   IF __ObjHasMsg(oCtrl:oParent, "nLastKey")
      // caso o PARENT seja HDIALOG
      lESC := oCtrl:oParent:nLastKey != 27
   ELSE
      // caso o PARENT seja HTAB, HPANEL
      lESC := .T.
   ENDIF
   // end by sauli
   IF lESC // "if" by Luiz Henrique dos Santos (luizhsantos@gmail.com) 04/06/2006
      nPos := hwg_Sendmessage(oCtrl:handle, CB_GETCURSEL, 0, 0) + 1

      IF nPos > 0 .AND. nPos <= Len(oCtrl:aItems)
         IF oCtrl:lEdit
            oCtrl:xValue := oCtrl:GetText()
         ELSE
            oCtrl:xValue := IIf(oCtrl:lText, IIf(hb_IsArray(oCtrl:aItems[nPos]), oCtrl:aItems[nPos, 1], oCtrl:aItems[nPos]), nPos)
         ENDIF
         IF hb_IsBlock(oCtrl:bSetGet)
            Eval(oCtrl:bSetGet, oCtrl:xValue, oCtrl)
         ENDIF
         IF hb_IsBlock(oCtrl:bChangeSel)
            Eval(oCtrl:bChangeSel, nPos, oCtrl)
         ENDIF
      ENDIF
      // By Luiz Henrique dos Santos (luizhsantos@gmail.com.br) 03/06/2006
      IF hb_IsBlock(oCtrl:bValid)
         IF !Eval(oCtrl:bValid, oCtrl)
            hwg_Setfocus(oCtrl:handle)
            RETURN .F.
         ENDIF
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION __When(oCtrl)

   LOCAL res

   //oCtrl:Refresh()

   IF hb_IsBlock(oCtrl:bGetFocus)
      IF oCtrl:bSetGet == NIL
         res := Eval(oCtrl:bGetFocus, oCtrl:xValue, oCtrl)
      ELSE
         res := Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet, NIL, oCtrl), oCtrl)
         IF !res
            hwg_GetSkip(oCtrl:oParent, oCtrl:handle, 1)
         ENDIF
      ENDIF
      RETURN res
   ENDIF

   RETURN .T.
