//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HComboBox class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

#ifndef CBN_SELCHANGE
#define CBN_SELCHANGE       1
#endif

CLASS HComboBox INHERIT HControl

   CLASS VAR winclass INIT "COMBOBOX"

   DATA aItems
   DATA bSetGet
   DATA bValid
   DATA xValue INIT 1
   DATA bChangeSel
   DATA lText INIT .F.
   DATA lEdit INIT .F.
   DATA hEdit

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, aItems, oFont, bInit, bSize, bPaint, bChange, cToolt, lEdit, lText, bGFocus, tcolor, bcolor, bValid)
   METHOD Activate()
   METHOD onEvent( msg, wParam, lParam )
   METHOD Init()
   METHOD Refresh( xVal )
   METHOD Setitem( nPos )
   METHOD GetValue( nItem )
   METHOD Value ( xValue ) SETGET
   METHOD End()

ENDCLASS

METHOD HComboBox:New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, aItems, oFont, bInit, bSize, bPaint, bChange, cToolt, lEdit, lText, bGFocus, tcolor, bcolor, bValid)

   IF lEdit == NIL
      lEdit := .F.
   ENDIF
   IF lText == NIL
      lText := .F.
   ENDIF

   nStyle := hb_bitor( IIf(nStyle == NIL, 0, nStyle), IIf(lEdit, CBS_DROPDOWN, CBS_DROPDOWNLIST) + WS_TABSTOP )
   ::Super:New( oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctoolt, tcolor, bcolor )

   ::lEdit := lEdit
   ::lText := lText

   IF lEdit
      ::lText := .T.
   ENDIF

   IF ::lText
      ::xValue := IIf(vari == NIL .OR. ValType( vari ) != "C", "", vari)
   ELSE
      ::xValue := IIf(vari == NIL .OR. ValType( vari ) != "N", 1, vari)
   ENDIF

   IF hb_IsBlock(bSetGet)
      ::bSetGet := bSetGet
      Eval(::bSetGet, ::xValue, self)
   ENDIF

   ::aItems := aItems

   ::Activate()
   ::bValid := bValid
   ::bGetFocus := bGFocus
   ::bChangeSel := bChange

   hwg_SetEvent(::handle, "focus_in_event", EN_SETFOCUS, 0, 0)
   hwg_SetEvent(::handle, "focus_out_event", EN_KILLFOCUS, 0, 0)
   hwg_SetSignal(::handle, "changed", CBN_SELCHANGE, 0, 0)

   IF Left(::oParent:ClassName(), 6) == "HPANEL" .AND. hb_bitand(::oParent:style, SS_OWNERDRAW) != 0
      ::oParent:SetPaintCB(PAINT_ITEM, { |o,h|HB_SYMBOL_UNUSED(o),IIf(!::lHide, hwg__DrawCombo(h,::nX + ::nWidth - 22,::nY,::nX + ::nWidth - 1,::nY + ::nHeight - 1 ), .T.) }, "hc" + LTrim(Str(::id)))
   ENDIF

   RETURN Self

METHOD HComboBox:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createcombo(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
      hwg_Setwindowobject(::handle, Self)
   ENDIF

   RETURN NIL

METHOD HComboBox:onEvent( msg, wParam, lParam )

   LOCAL i

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == EN_SETFOCUS
      IF ::bSetGet == NIL
         IF hb_IsBlock(::bGetFocus)
            i := hwg_ComboGet(::handle)
            Eval(::bGetFocus, IIf(HB_ISARRAY(::aItems[1]), ::aItems[i, 1], ::aItems[i]), Self)
         ENDIF
      ELSE
         __When( Self )
      ENDIF
   ELSEIF msg == EN_KILLFOCUS
      IF ::bSetGet == NIL
         IF hb_IsBlock(::bLostFocus)
            i := hwg_ComboGet(::handle)
            Eval(::bLostFocus, IIf(HB_ISARRAY(::aItems[1]), ::aItems[i, 1], ::aItems[i]), Self)
         ENDIF
      ELSE
         __Valid( Self )
      ENDIF

   ELSEIF msg == CBN_SELCHANGE
      ::GetValue()
      IF hb_IsBlock(::bChangeSel)
         Eval(::bChangeSel, ::xValue, Self)
      ENDIF

   ENDIF

   RETURN 0

/* Removed: aCombo, nCurrent */
METHOD HComboBox:Init()

   IF !::lInit
      ::Super:Init()
      IF !Empty(::aItems)
         hwg_ComboSetArray(::handle, ::aItems)
         IF Empty(::xValue)
            IF ::lText
               ::xValue := IIf(HB_ISARRAY(::aItems[1]), ::aItems[1, 1], ::aItems[1])
            ELSE
               ::xValue := 1
            ENDIF
         ENDIF
         ::Value := ::xValue
         IF hb_IsBlock(::bSetGet)
            Eval(::bSetGet, ::xValue, Self)
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

METHOD HComboBox:Refresh( xVal )

   LOCAL vari

   IF xVal != NIL
      ::xValue := xVal
   ELSEIF hb_IsBlock(::bSetGet)
      vari := Eval(::bSetGet, NIL, Self)
      IF ::lText
         ::xValue := IIf(vari == NIL .OR. ValType( vari ) != "C", "", vari)
      ELSE
         ::xValue := IIf(vari == NIL .OR. ValType( vari ) != "N", 1, vari)
      ENDIF
   ENDIF

   IF !Empty(::aItems)
      hwg_ComboSetArray(::handle, ::aItems)

      IF ::lText
         hwg_ComboSet(::handle, 1)
      ELSE
         hwg_ComboSet(::handle, ::xValue)
      ENDIF

   ENDIF

   RETURN NIL

METHOD HComboBox:SetItem( nPos )

   IF ::lText
      ::xValue := IIf(HB_ISARRAY(::aItems[nPos]), ::aItems[nPos, 1], ::aItems[nPos])
   ELSE
      ::xValue := nPos
   ENDIF

   hwg_ComboSet(::handle, nPos)

   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::xValue, self)
   ENDIF

   IF hb_IsBlock(::bChangeSel)
      Eval(::bChangeSel, ::xValue, Self)
   ENDIF

   RETURN NIL

METHOD HComboBox:GetValue( nItem )
   
   LOCAL nPos := hwg_ComboGet(::handle)
   LOCAL vari := IIf(!Empty(::aItems) .AND. nPos > 0, IIf(HB_ISARRAY(::aItems[1]), ::aItems[nPos, 1], ::aItems[nPos]), "")
   LOCAL l := nPos > 0 .AND. HB_ISARRAY(::aItems[nPos])

   ::xValue := IIf(::lText, vari, nPos)
   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::xValue, Self)
   ENDIF

   RETURN IIf(l .AND. nItem != NIL, IIf(nItem > 0 .AND. nItem <= Len(::aItems[nPos] ), ::aItems[nPos,nItem], NIL), ::xValue)

METHOD HComboBox:Value ( xValue )

   IF xValue != NIL
      IF HB_ISCHAR(xValue)
         xValue := IIf(HB_ISARRAY(::aItems[1]), AScan(::aItems, {|a|a[1] == xValue}), hb_AScan(::aItems, xValue, NIL, NIL, .T.))
      ENDIF
      ::SetItem( xValue )

      RETURN ::xValue
   ENDIF

   RETURN ::GetValue()

METHOD HComboBox:End()

   hwg_ReleaseObject(::handle)
   ::Super:End()

   RETURN NIL

STATIC FUNCTION __Valid( oCtrl )

   oCtrl:GetValue()
   IF hb_IsBlock(oCtrl:bValid)
      IF !Eval(oCtrl:bValid, oCtrl)
         hwg_Setfocus( oCtrl:handle )
         RETURN .F.
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION __When( oCtrl )
   
   LOCAL res

   IF hb_IsBlock(oCtrl:bGetFocus)
      res := Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet, , oCtrl), oCtrl)
      IF !res
         hwg_GetSkip( oCtrl:oParent, oCtrl:handle, 1 )
      ENDIF
      RETURN res
   ENDIF

   RETURN .T.
