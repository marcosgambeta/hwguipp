//
// HWGUI - Harbour Win32 GUI library source code:
// HRadioButton class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HRadioGroup INHERIT HObject

   CLASS VAR oGroupCurrent
   
   DATA aButtons
   DATA nValue INIT 1
   DATA bSetGet
   DATA oHGroup

   METHOD New(vari, bSetGet)
   METHOD NewRg(oWndParent, nId, nStyle, vari, bSetGet, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, tcolor, bColor)
   METHOD EndGroup(nSelected)
   METHOD Value(nValue) SETGET
   METHOD Refresh() INLINE IIf(hb_IsBlock(::bSetGet), ::Value := Eval(::bSetGet), .T.)

ENDCLASS

METHOD HRadioGroup:New(vari, bSetGet)

   ::oGroupCurrent := Self
   ::aButtons := {}

   IF vari != NIL
      IF hb_IsNumeric(vari)
         ::nValue := vari
      ENDIF
      ::bSetGet := bSetGet
   ENDIF

   RETURN Self

METHOD HRadioGroup:NewRg(oWndParent, nId, nStyle, vari, bSetGet, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, tcolor, bColor)

   ::oGroupCurrent := Self
   ::aButtons := {}

   ::oHGroup := HGroup():New(oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, cCaption, oFont, bInit, bSize, NIL, tcolor, bColor)

   IF vari != NIL
      IF hb_IsNumeric(vari)
         ::nValue := vari
      ENDIF
      ::bSetGet := bSetGet
   ENDIF

   RETURN Self

METHOD HRadioGroup:EndGroup(nSelected)
   
   LOCAL nLen

   IF ::oGroupCurrent != NIL .AND. (nLen := Len(::oGroupCurrent:aButtons)) > 0

      nSelected := IIf(nSelected != NIL .AND. nSelected <= nLen .AND. nSelected > 0, nSelected, ::oGroupCurrent:nValue)
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
   ::oGroupCurrent := NIL

   RETURN NIL

METHOD HRadioGroup:Value(nValue)
   
   LOCAL nLen

   IF nValue != NIL
      IF (nLen := Len(::aButtons)) > 0 .AND. nValue > 0 .AND. nValue <= nLen
         hwg_Checkradiobutton(::aButtons[nlen]:oParent:handle, ::aButtons[1]:id, ::aButtons[nLen]:id, ::aButtons[nValue]:id)
         ::nValue := nValue
         IF hb_IsBlock(::bSetGet)
            Eval(::bSetGet, nValue, Self)
         ENDIF
      ENDIF
   ENDIF

   RETURN ::nValue
