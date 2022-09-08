/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HUpDown class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HUpDown INHERIT HControl

   CLASS VAR winclass   INIT "EDIT"
   DATA bSetGet
   DATA nValue
   DATA hUpDown, idUpDown, styleUpDown
   DATA nLower INIT 0
   DATA nUpper INIT 999
   DATA nUpDownWidth INIT 12
   DATA lChanged    INIT .F.

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctooltip, tcolor, bcolor, nUpDWidth, nLower, nUpper)
   METHOD Activate()
   METHOD Init()
   METHOD Value(nValue) SETGET
   METHOD SetRange(n1, n2)  INLINE hwg_SetRangeUpdown(::hUpDown, n1, n2)
   METHOD Refresh()
   METHOD Hide()          INLINE ( hwg_Hidewindow(::hUpDown), ::Super:Hide() )
   METHOD Show()          INLINE ( hwg_Showwindow(::hUpDown), ::Super:Show() )

ENDCLASS

METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
      oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctooltip, tcolor, bcolor, ;
      nUpDWidth, nLower, nUpper) CLASS HUpDown

   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   ::idUpDown := ::NewId()
   IF Empty(vari)
      vari := 0
   ENDIF
   IF vari != NIL
      IF ValType(vari) != "N"
         vari := 0
         Eval(bSetGet, vari)
      ENDIF
      ::title := Str(vari)
   ENDIF
   ::bSetGet := bSetGet

   ::styleUpDown := UDS_SETBUDDYINT + UDS_ALIGNRIGHT

   IF nLower != NIL
      ::nLower := nLower
   ENDIF
   IF nUpper != NIL
      ::nUpper := nUpper
   ENDIF
   IF nUpDWidth != NIL
      ::nUpDownWidth := nUpDWidth
   ENDIF

   ::Activate()

   IF bSetGet != NIL
      ::bGetFocus := bGFocus
      ::bLostFocus := bLFocus
      ::oParent:AddEvent(EN_SETFOCUS, ::id, {|o, id|__When(o:FindControl(id))})
      ::oParent:AddEvent(EN_KILLFOCUS, ::id, {|o, id|__Valid(o:FindControl(id))})
   ELSE
      IF bGfocus != NIL
         ::oParent:AddEvent(EN_SETFOCUS, ::id, bGfocus)
      ENDIF
      IF bLfocus != NIL
         ::oParent:AddEvent(EN_KILLFOCUS, ::id, bLfocus)
      ENDIF
   ENDIF

   RETURN Self

METHOD Activate() CLASS HUpDown

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createedit(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init()  CLASS HUpDown

   IF !::lInit
      ::Super:Init()
      ::hUpDown := hwg_Createupdowncontrol(::oParent:handle, ::idUpDown, ::styleUpDown, 0, 0, ::nUpDownWidth, 0, ::handle, ::nUpper, ::nLower, Val(::title))
   ENDIF

   RETURN NIL

METHOD Value(nValue) CLASS HUpDown

   IF nValue != NIL
      IF HB_ISNUMERIC(nValue)
         hwg_SetUpdown(::hUpDown, nValue)
         ::nValue := nValue
         IF HB_ISBLOCK(::bSetGet)
            Eval(::bSetGet, nValue, Self)
         ENDIF
      ENDIF
   ELSE
      //::nValue := Val(LTrim(::title := hwg_Getedittext(::oParent:handle, ::id)))
      ::nValue := hwg_GetUpdown(::hUpDown)
   ENDIF

   RETURN ::nValue

METHOD Refresh()  CLASS HUpDown

   // Variables not used
   // LOCAL vari

   IF HB_ISBLOCK(::bSetGet)
      ::nValue := Eval(::bSetGet)
      IF Str(::nValue) != ::title
         ::title := Str(::nValue)
         hwg_Setupdown(::hUpDown, ::nValue)
      ENDIF
   ELSE
      hwg_Setupdown(::hUpDown, Val(::title))
   ENDIF

   RETURN NIL

STATIC FUNCTION __When(oCtrl)

   oCtrl:Refresh()
   IF HB_ISBLOCK(oCtrl:bGetFocus)
      RETURN Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet), oCtrl)
   ENDIF

   RETURN .T.

STATIC FUNCTION __Valid(oCtrl)

   oCtrl:nValue := oCtrl:Value
   IF HB_ISBLOCK(oCtrl:bSetGet)
      Eval(oCtrl:bSetGet, oCtrl:nValue)
   ENDIF
   IF HB_ISBLOCK(oCtrl:bLostFocus) .AND. !Eval(oCtrl:bLostFocus, oCtrl:nValue, oCtrl) .OR. ;
         oCtrl:nValue > oCtrl:nUpper .OR. oCtrl:nValue < oCtrl:nLower
      hwg_Setfocus(oCtrl:handle)
   ENDIF

   RETURN .T.
