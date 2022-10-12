/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HDatePicker class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define DTN_DATETIMECHANGE    -759
#define DTN_CLOSEUP           -753
#define DTM_GETMONTHCAL       4104   // 0x1008

#define NM_KILLFOCUS          -8
#define NM_SETFOCUS           -7

CLASS HDatePicker INHERIT HControl

   CLASS VAR winclass INIT "SYSDATETIMEPICK32"

   DATA bSetGet
   DATA dValue
   DATA bChange

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bGfocus, bLfocus, bChange, ctooltip, tcolor, bcolor)
   METHOD Activate()
   METHOD Init()
   METHOD Refresh()
   METHOD Value(dValue) SETGET

ENDCLASS

METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bGfocus, bLfocus, bChange, ;
           ctooltip, tcolor, bcolor) CLASS HDatePicker

   HWG_InitCommonControlsEx()

   IF pcount() == 0
      ::Super:New(NIL, NIL, WS_TABSTOP, 0, 0, 0, 0, NIL, NIL, NIL, NIL, NIL, NIL, NIL)
      ::dValue := ctod(space(8))
      ::Activate()
      ::oParent:AddEvent(DTN_DATETIMECHANGE, ::id, {|o, id|__Change(o:FindControl(id), DTN_DATETIMECHANGE)}, .T.)
      ::oParent:AddEvent(DTN_CLOSEUP, ::id, {|o, id|__Change(o:FindControl(id), DTN_CLOSEUP)}, .T.)
      RETURN Self
   ENDIF

   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, NIL, NIL, ctooltip, tcolor, bcolor)

   ::dValue  := iif(vari == NIL .OR. ValType(vari) != "D", CToD(Space(8)), vari)
   ::bSetGet := bSetGet
   ::bChange := bChange

   ::Activate()

   IF bGfocus != NIL
      ::oParent:AddEvent(NM_SETFOCUS, ::id, bGfocus, .T.)
   ENDIF
   ::oParent:AddEvent(DTN_DATETIMECHANGE, ::id, {|o, id|__Change(o:FindControl(id), DTN_DATETIMECHANGE)}, .T.)
   ::oParent:AddEvent(DTN_CLOSEUP, ::id, {|o, id|__Change(o:FindControl(id), DTN_CLOSEUP)}, .T.)
   IF bSetGet != NIL
      ::bLostFocus := bLFocus
      ::oParent:AddEvent(NM_KILLFOCUS, ::id, {|o, id|__Valid(o:FindControl(id))}, .T.)
   ELSE
      IF bLfocus != NIL
         ::oParent:AddEvent(NM_KILLFOCUS, ::id, bLfocus, .T.)
      ENDIF
   ENDIF

   RETURN Self

METHOD Activate() CLASS HDatePicker

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createdatepicker(::oParent:handle, ::id, ::nX, ::nY, ::nWidth, ::nHeight, ::style)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HDatePicker

   IF !::lInit
      ::Super:Init()
      IF Empty(::dValue)
         hwg_Setdatepickernull(::handle)
      ELSE
         hwg_Setdatepicker(::handle, ::dValue)
      ENDIF
   ENDIF

   RETURN NIL

METHOD Refresh() CLASS HDatePicker

   IF HB_ISBLOCK(::bSetGet)
      ::dValue := Eval(::bSetGet, NIL, Self)
   ENDIF

   IF Empty(::dValue)
      hwg_Setdatepickernull(::handle)
   ELSE
      hwg_Setdatepicker(::handle, ::dValue)
   ENDIF

   RETURN NIL

METHOD Value(dValue) CLASS HDatePicker

   IF dValue != NIL
      IF ValType(dValue) == "D"
         hwg_Setdatepicker(::handle, dValue)
         ::dValue := dValue
         IF HB_ISBLOCK(::bSetGet)
            Eval(::bSetGet, dValue, Self)
         ENDIF
      ENDIF
   ELSE
      ::dValue := hwg_Getdatepicker(::handle)
   ENDIF

   RETURN ::dValue

STATIC FUNCTION __Change(oCtrl, nMess)

   IF (nMess == DTN_DATETIMECHANGE .AND. hwg_Sendmessage(oCtrl:handle, DTM_GETMONTHCAL, 0, 0) == 0) .OR. nMess == DTN_CLOSEUP
      oCtrl:dValue := hwg_Getdatepicker(oCtrl:handle)
      IF HB_ISBLOCK(oCtrl:bSetGet)
         Eval(oCtrl:bSetGet, oCtrl:dValue, oCtrl)
      ENDIF
      IF HB_ISBLOCK(oCtrl:bChange)
         Eval(oCtrl:bChange, oCtrl:dValue, oCtrl)
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION __Valid(oCtrl)

   oCtrl:dValue := hwg_Getdatepicker(oCtrl:handle)
   IF HB_ISBLOCK(oCtrl:bSetGet)
      Eval(oCtrl:bSetGet, oCtrl:dValue, oCtrl)
   ENDIF
   IF HB_ISBLOCK(oCtrl:bLostFocus) .AND. !Eval(oCtrl:bLostFocus, oCtrl:dValue, oCtrl)
      RETURN .F.
   ENDIF

   RETURN .T.
