//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HUpDown class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

#ifndef UDS_SETBUDDYINT
#define UDS_SETBUDDYINT     2
#define UDS_ALIGNRIGHT      4
#endif

CLASS HUpDown INHERIT HControl

   CLASS VAR winclass INIT "EDIT"

   DATA bSetGet
   DATA nValue
   DATA nLower INIT 0
   DATA nUpper INIT 999
   DATA nUpDownWidth INIT 12
   DATA lChanged INIT .F.

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctoolt, tcolor, bcolor, nUpDWidth, nLower, nUpper)
   METHOD Activate()
   METHOD onEvent( msg, wParam, lParam )
   METHOD Refresh()
   METHOD Value( nValue ) SETGET
   METHOD SetRange( n1, n2 ) INLINE hwg_SetRangeUpdown(::handle, n1, n2)

ENDCLASS

METHOD HUpDown:New( oWndParent, nId, vari, bSetGet, nStyle, nX, nY, nWidth, nHeight, ;
      oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctoolt, tcolor, bcolor,   ;
      nUpDWidth, nLower, nUpper )

   nStyle := hb_bitor( IIf(nStyle == NIL, 0,nStyle), WS_TABSTOP )
   ::Super:New( oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, bInit, ;
      bSize, bPaint, ctoolt, tcolor, bcolor )

   IF Empty(vari)
      vari := 0
   ENDIF
   IF vari != NIL
      IF !hb_isNumeric(vari)
         vari := 0
         Eval(bSetGet, vari)
      ENDIF
      ::title := Str(vari)
   ENDIF
   ::bSetGet := bSetGet

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

   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus
   hwg_SetEvent(::handle, "focus_in_event", WM_SETFOCUS, 0, 0)
   hwg_SetEvent(::handle, "focus_out_event", WM_KILLFOCUS, 0, 0)

   RETURN Self

METHOD HUpDown:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createupdowncontrol(::oParent:handle, ::nX, ::nY, ::nWidth, ::nHeight, Val(::title), ::nLower, ::nUpper)
      hwg_Setwindowobject(::handle, Self)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HUpDown:onEvent( msg, wParam, lParam )

   // Variables not used
   // LOCAL oParent := ::oParent
   // LOCAL nPos

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   //hwg_WriteLog( "UpDown: "+Str(msg, 10)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10) )
   IF msg == WM_SETFOCUS
      IF ::bSetGet == NIL
         IF hb_IsBlock(::bGetFocus)
            Eval(::bGetFocus, ::nValue := hwg_GetUpDown(::handle), Self)
         ENDIF
      ELSE
         __When( Self )
      ENDIF
   ELSEIF msg == WM_KILLFOCUS
      __Valid( Self )
   ENDIF
   RETURN 0

METHOD HUpDown:Refresh()

   // Variables not used
   // LOCAL vari

   IF hb_IsBlock(::bSetGet)
      ::nValue := Eval(::bSetGet)
      IF Str(::nValue) != ::title
         ::title := Str(::nValue)
         hwg_SetUpDown(::handle, ::nValue)
      ENDIF
   ELSE
      hwg_SetUpDown(::handle, Val(::title))
   ENDIF

   RETURN NIL

METHOD HUpDown:Value( nValue )

   IF nValue != NIL
      IF HB_ISNUMERIC(nValue)
         hwg_SetUpdown(::handle, nValue)
         ::nValue := nValue
         IF hb_IsBlock(::bSetGet)
            Eval(::bSetGet, nValue, Self)
         ENDIF
      ENDIF
   ELSE
      ::nValue := hwg_GetUpDown(::handle)
   ENDIF

   RETURN ::nValue

STATIC FUNCTION __When( oCtrl )

   oCtrl:Refresh()
   IF hb_IsBlock(oCtrl:bGetFocus)
      RETURN Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet), oCtrl)
   ENDIF

   RETURN .T.

STATIC FUNCTION __Valid( oCtrl )

   oCtrl:nValue := hwg_GetUpDown( oCtrl:handle )
   IF hb_IsBlock(oCtrl:bSetGet)
      Eval(oCtrl:bSetGet, oCtrl:nValue)
   ENDIF
   IF hb_IsBlock(oCtrl:bLostFocus) .AND. !Eval(oCtrl:bLostFocus, oCtrl:nValue, oCtrl) .OR. ;
         oCtrl:nValue > oCtrl:nUpper .OR. oCtrl:nValue < oCtrl:nLower
      hwg_Setfocus( oCtrl:handle )
   ENDIF

   RETURN .T.
