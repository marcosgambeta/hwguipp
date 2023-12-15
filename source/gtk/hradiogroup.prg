/*
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * HRadioButton class
 *
 * Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HRadioGroup INHERIT HObject

   CLASS VAR oGroupCurrent

   DATA handle INIT 0
   DATA aButtons
   DATA nValue INIT 1
   DATA bSetGet
   DATA oHGroup

   METHOD New(vari, bSetGet)
   METHOD NewRg(oWndParent, nId, nStyle, vari, bSetGet, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, tcolor, bColor)
   METHOD EndGroup(nSelected)
   METHOD Value(nValue) SETGET
   METHOD Refresh() INLINE iif(::bSetGet != NIL, ::Value := Eval(::bSetGet), .T.)

ENDCLASS

METHOD HRadioGroup:New( vari, bSetGet )

   ::oGroupCurrent := Self
   ::aButtons := {}

   IF vari != NIL
      IF HB_ISNUMERIC(vari)
         ::nValue := vari
      ENDIF
      ::bSetGet := bSetGet
   ENDIF

   RETURN Self

METHOD HRadioGroup:NewRg( oWndParent, nId, nStyle, vari, bSetGet, nX, nY, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, tcolor, bColor )

   ::oGroupCurrent := Self
   ::aButtons := {}

   ::oHGroup := HGroup():New( oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, ;
      oFont, bInit, bSize, NIL, tcolor, bColor )

   IF vari != NIL
      IF HB_ISNUMERIC(vari)
         ::nValue := vari
      ENDIF
      ::bSetGet := bSetGet
   ENDIF

   RETURN Self

METHOD HRadioGroup:EndGroup( nSelected )
   
   LOCAL nLen

   IF ::oGroupCurrent != NIL .AND. ( nLen := Len(::oGroupCurrent:aButtons) ) > 0

      nSelected := iif(nSelected != NIL .AND. nSelected <= nLen .AND. nSelected > 0, ;
         nSelected, ::oGroupCurrent:nValue)
      IF nSelected != 0 .AND. nSelected <= nlen
         hwg_CheckButton(::oGroupCurrent:aButtons[nSelected]:handle, .T.)
      ENDIF
   ENDIF
   ::oGroupCurrent := NIL

   RETURN NIL

METHOD HRadioGroup:Value( nValue )
   
   LOCAL nLen

   IF nValue != NIL
      IF ( nLen := Len(::aButtons) ) > 0 .AND. nValue > 0 .AND. nValue <= nLen
         hwg_CheckButton(::aButtons[nValue]:handle, .T.)
         ::nValue := nValue
         IF ::bSetGet != NIL
            Eval(::bSetGet, nValue, Self)
         ENDIF
      ENDIF
   ENDIF

   RETURN ::nValue
