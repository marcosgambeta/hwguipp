/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HTab class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define  IPN_FIELDCHANGED   4294966436

//- HIPedit

CLASS HIPedit INHERIT HControl

   CLASS VAR winclass INIT "SysIPAddress32"
   
   DATA bSetGet
   DATA bChange
   DATA bKillFocus
   DATA bGetFocus

   METHOD New(oWndParent, nId, aValue, bSetGet, nStyle, nX, nY, nWidth, nHeight, oFont, bGetFocus, bKillFocus)
   METHOD Activate()
   METHOD Init()
   METHOD Value(aValue) SETGET
   METHOD Clear()
   METHOD END()

   HIDDEN:
   DATA aValue           // Valor atual

ENDCLASS

METHOD HIPedit:New(oWndParent, nId, aValue, bSetGet, nStyle, nX, nY, nWidth, nHeight, oFont, bGetFocus, bKillFocus)

   nStyle := hb_bitor(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont)

   ::title := ""

   ::bSetGet := bSetGet
   DEFAULT aValue := { 0, 0, 0, 0 }
   ::aValue := aValue
   ::bGetFocus := bGetFocus
   ::bKillFocus := bKillFocus

   HWG_InitCommonControlsEx()
   ::Activate()


   IF bKillFocus != NIL
      ::oParent:AddEvent(IPN_FIELDCHANGED, ::id, ::bKillFocus, .T., "onChange")
   ENDIF
  // ENDIF

   // Notificacoes de Ganho e perda de foco
   ::oParent:AddEvent(EN_SETFOCUS, ::id, {|o, id|__GetFocus(o:FindControl(id))}, NIL, "onGotFocus")
   ::oParent:AddEvent(EN_KILLFOCUS, ::id, {|o, id|__KillFocus(o:FindControl(id))}, NIL, "onLostFocus")


   RETURN Self

METHOD HIPedit:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_Initipaddress(::oParent:handle, ::id, ::style, ::nX, ::nY, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HIPedit:Init()

   IF !::lInit
      ::Super:Init()
      hwg_Setipaddress(::handle, ::aValue[1], ::aValue[2], ::aValue[3], ::aValue[4])
      ::lInit := .T.
   ENDIF

   RETURN NIL

METHOD HIPedit:Value(aValue)

   IF aValue != NIL
      hwg_Setipaddress(::handle, aValue[1], aValue[2], aValue[3], aValue[4])
      ::aValue := aValue
   ELSE
      ::aValue := hwg_Getipaddress(::handle)
   ENDIF

   RETURN ::aValue


METHOD HIPedit:Clear()
   hwg_Clearipaddress(::handle)
   ::aValue := { 0, 0, 0, 0 }
   RETURN (::aValue)


METHOD HIPedit:END()

   // Nothing to do here, yet!
   ::Super:END()

   RETURN NIL


STATIC FUNCTION __GetFocus(oCtrl)
   
   LOCAL xRet

   IF HB_ISBLOCK(oCtrl:bGetFocus)
      xRet := Eval(oCtrl:bGetFocus, oCtrl)
   ENDIF

   RETURN xRet


STATIC FUNCTION __KillFocus(oCtrl)
   
   LOCAL xRet

   IF HB_ISBLOCK(oCtrl:bKillFocus)
      xRet := Eval(oCtrl:bKillFocus, oCtrl)
   ENDIF

   RETURN xRet
