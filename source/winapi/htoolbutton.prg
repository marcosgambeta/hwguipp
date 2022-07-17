/*
 * HWGUI - Harbour Win32 GUI library source code:
 *
 *
 * Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
 * www - http://sites.uol.com.br/culikr/
*/
#include "windows.ch"
#include "inkey.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define TRANSPARENT 1
#define IDTOOLBAR 700
#define IDMAXBUTTONTOOLBAR 64
#define RT_MANIFEST  24

CLASS HToolButton INHERIT HObject

   DATA Name
   DATA id
   DATA nBitIp INIT - 1
   DATA bState INIT TBSTATE_ENABLED
   DATA bStyle INIT  0x0000
   DATA tooltip
   DATA aMenu INIT {}
   DATA hMenu
   DATA Title
   DATA lEnabled  INIT .T. HIDDEN
   DATA lChecked  INIT .F. HIDDEN
   DATA lPressed  INIT .F. HIDDEN
   DATA bClick
   DATA oParent
   //DATA oFont   // not implemented

   METHOD New( oParent, cName, nBitIp, nId, bState, bStyle, cText, bClick, ctip, aMenu )
   METHOD Enable() INLINE ::oParent:EnableButton(::id, .T.)
   METHOD Disable() INLINE ::oParent:EnableButton(::id, .F.)
   METHOD Show() INLINE hwg_Sendmessage(::oParent:handle, TB_HIDEBUTTON, Int(::id), hwg_Makelong(0, 0))
   METHOD Hide() INLINE hwg_Sendmessage(::oParent:handle, TB_HIDEBUTTON, Int(::id), hwg_Makelong(1, 0))
   METHOD Enabled(lEnabled) SETGET
   METHOD Checked(lCheck) SETGET
   METHOD Pressed(lPressed) SETGET
   METHOD onClick()
   METHOD Caption( cText ) SETGET

ENDCLASS

METHOD New( oParent, cName, nBitIp, nId, bState, bStyle, cText, bClick, ctip, aMenu ) CLASS  HToolButton

   ::Name := cName
   ::iD := nId
   ::title  := cText
   ::nBitIp := nBitIp
   ::bState := bState
   ::bStyle := bStyle
   ::tooltip := ctip
   ::bClick  := bClick
   ::aMenu := amenu
   ::oParent := oParent
   __objAddData(::oParent, cName)
   ::oParent:&( cName ) := Self

   RETURN Self

METHOD Caption( cText )  CLASS HToolButton

   IF cText != Nil
      ::Title := cText
      hwg_Toolbar_setbuttoninfo(::oParent:handle, ::id, cText)
   ENDIF

   RETURN ::Title

METHOD onClick()  CLASS HToolButton

   IF ::bClick != Nil
      Eval(::bClick, self, ::id)
   ENDIF

   RETURN Nil

METHOD Enabled(lEnabled) CLASS HToolButton

   IF lEnabled != Nil
      IF lEnabled
         ::enable()
      ELSE
         ::disable()
      ENDIF
      ::lEnabled := lEnabled
   ENDIF

   RETURN ::lEnabled

METHOD Pressed(lPressed) CLASS HToolButton
   LOCAL nState

   IF lPressed != Nil
      nState := hwg_Sendmessage(::oParent:handle, TB_GETSTATE, Int(::id), 0)
      hwg_Sendmessage(::oParent:handle, TB_SETSTATE, Int(::id), hwg_Makelong(iif(lPressed, HWG_BITOR(nState, TBSTATE_PRESSED), nState - HWG_BITAND(nState, TBSTATE_PRESSED)), 0))
      ::lPressed := lPressed
   ENDIF

   RETURN ::lPressed

METHOD Checked(lcheck) CLASS HToolButton
   LOCAL nState

   IF lCheck != Nil
      nState := hwg_Sendmessage(::oParent:handle, TB_GETSTATE, Int(::id), 0)
      hwg_Sendmessage(::oParent:handle, TB_SETSTATE, Int(::id), hwg_Makelong(iif(lCheck, HWG_BITOR(nState, TBSTATE_CHECKED), nState - HWG_BITAND(nState, TBSTATE_CHECKED)), 0))
      ::lChecked := lCheck
   ENDIF

   RETURN ::lChecked
