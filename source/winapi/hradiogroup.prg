/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HRadioButton class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

CLASS HRadioGroup INHERIT HObject

   CLASS VAR oGroupCurrent
   DATA aButtons
   DATA nValue  INIT 1
   DATA bSetGet
   DATA oHGroup

   METHOD New( vari, bSetGet )
   METHOD NewRg( oWndParent, nId, nStyle, vari, bSetGet, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, tcolor, bColor )
   METHOD EndGroup( nSelected )
   METHOD Value(nValue) SETGET
   METHOD Refresh()   INLINE iif(::bSetGet != Nil, ::Value := Eval(::bSetGet), .T.)

ENDCLASS

METHOD New( vari, bSetGet ) CLASS HRadioGroup

   ::oGroupCurrent := Self
   ::aButtons := {}

   IF vari != Nil
      IF ValType(vari) == "N"
         ::nValue := vari
      ENDIF
      ::bSetGet := bSetGet
   ENDIF

   RETURN Self

METHOD NewRg( oWndParent, nId, nStyle, vari, bSetGet, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, tcolor, bColor ) CLASS HRadioGroup

   ::oGroupCurrent := Self
   ::aButtons := {}

   ::oHGroup := HGroup():New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, ;
         oFont, bInit, bSize, , tcolor, bColor )

   IF vari != NIL
      IF Valtype(vari) == "N"
         ::nValue := vari
      ENDIF
      ::bSetGet := bSetGet
   ENDIF

   RETURN Self

METHOD EndGroup( nSelected )  CLASS HRadioGroup
   LOCAL nLen

   IF ::oGroupCurrent != Nil .AND. ( nLen := Len(::oGroupCurrent:aButtons) ) > 0

      nSelected := iif( nSelected != Nil .AND. nSelected <= nLen .AND. nSelected > 0, ;
         nSelected, ::oGroupCurrent:nValue )
      IF nSelected != 0 .AND. nSelected <= nlen
         IF !Empty(::oGroupCurrent:aButtons[nlen]:handle)
            hwg_Checkradiobutton(::oGroupCurrent:aButtons[nlen]:oParent:handle, ::oGroupCurrent:aButtons[1]:id, ;
               ::oGroupCurrent:aButtons[nLen]:id, ::oGroupCurrent:aButtons[nSelected]:id)
         ELSE
            ::oGroupCurrent:aButtons[nLen]:bInit := &("{|o|hwg_Checkradiobutton(o:oParent:handle," + ;
               LTrim(Str(::oGroupCurrent:aButtons[1]:id)) + "," + ;
               LTrim(Str(::oGroupCurrent:aButtons[nLen]:id)) + "," + ;
               LTrim(Str(::oGroupCurrent:aButtons[nSelected]:id)) + ")}")
         ENDIF
      ENDIF
   ENDIF
   ::oGroupCurrent := Nil

   RETURN Nil

METHOD Value(nValue) CLASS HRadioGroup
   LOCAL nLen

   IF nValue != Nil
      IF ( nLen := Len(::aButtons) ) > 0 .AND. nValue > 0 .AND. nValue <= nLen
         hwg_Checkradiobutton(::aButtons[nlen]:oParent:handle, ::aButtons[1]:id, ::aButtons[nLen]:id, ::aButtons[nValue]:id)
         ::nValue := nValue
         IF ::bSetGet != NIL
            Eval(::bSetGet, nValue, Self)
         ENDIF
      ENDIF
   ENDIF

   RETURN ::nValue
