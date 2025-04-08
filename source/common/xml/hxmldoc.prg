//
// Harbour XML Library
// HXmlDoc class
//
// Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include <fileio.ch>
#include "hxml.ch"

#define XML_ERROR_FILEOPEN     11

STATIC s_cNewLine := e"\r\n"

/*
 *  CLASS DEFINITION
 *  HXMLNode
 */

CLASS HXMLNode

   CLASS VAR nLastErr SHARED

   DATA title
   DATA type
   DATA aItems INIT {}
   DATA aAttr INIT {}
   DATA cargo

   METHOD New(cTitle, type, aAttr, cValue)
   METHOD Add(xItem)
   METHOD GetAttribute(cName, cType, xDefault)
   METHOD SetAttribute(cName, cValue)
   METHOD DelAttribute(cName)
   METHOD Save(handle, level)
   METHOD Find(cTitle, nStart, block)

ENDCLASS

/* Added: cValue */
METHOD HXMLNode:New(cTitle, type, aAttr, cValue)

   IF cTitle != NIL
      ::title := cTitle
   ENDIF
   IF aAttr != NIL
      ::aAttr := aAttr
   ENDIF
   ::type := IIf(type != NIL, type, HBXML_TYPE_TAG)
   IF cValue != NIL
      ::Add(cValue)
   ENDIF

RETURN Self

METHOD HXMLNode:Add(xItem)

   Aadd(::aItems, xItem)

RETURN xItem

METHOD HXMLNode:GetAttribute(cName, cType, xDefault)

   LOCAL i := Ascan(::aAttr, {|a|a[1] == cName})

   IF i != 0
      IF cType == NIL .OR. cType == "C"
         RETURN ::aAttr[i, 2]
      ELSEIF cType == "N"
         RETURN Val(::aAttr[i, 2])
      ELSEIF cType == "L"
         RETURN Lower(::aAttr[i, 2]) $ ".t.;on;yes;true"
      ENDIF
   ENDIF

RETURN xDefault

METHOD HXMLNode:SetAttribute(cName, cValue)

   LOCAL i := Ascan(::aAttr, {|a|a[1] == cName})

   IF i == 0
      Aadd(::aAttr, {cName, cValue})
   ELSE
      ::aAttr[i, 2] := cValue
   ENDIF

   RETURN .T.

METHOD HXMLNode:DelAttribute(cName)

   LOCAL i := Ascan(::aAttr, {|a|a[1] == cName})

   IF i != 0
      Adel(::aAttr, i)
      Asize(::aAttr, Len(::aAttr) - 1)
   ENDIF

RETURN .T.

METHOD HXMLNode:Save(handle, level)

   LOCAL i
   LOCAL s := Space(level * 2) + "<"
   LOCAL lNewLine

   IF !__mvExist("HXML_NEWLINE")
      __mvPrivate("HXML_NEWLINE")
      __mvPut("HXML_NEWLINE", .T.)
   ENDIF
   lNewLine := m->hxml_newline
   IF ::type == HBXML_TYPE_COMMENT
      s += "!--"
   ELSEIF ::type == HBXML_TYPE_CDATA
      s += "![CDATA["
   ELSEIF ::type == HBXML_TYPE_PI
      s += "?" + ::title
   ELSE
      s += ::title
   ENDIF
   IF ::type == HBXML_TYPE_TAG .OR. ::type == HBXML_TYPE_SINGLE
      FOR i := 1 TO Len(::aAttr)
         //s += ' ' + ::aAttr[i, 1] + '="' + HBXML_PreSave(::aAttr[i, 2]) + '"'
         s += " " + ::aAttr[i, 1] + "=" + Chr(34) + ::aAttr[i, 2] + Chr(34)
      NEXT i
   ENDIF
   IF ::type == HBXML_TYPE_PI
      s += "?>" + s_cNewLine
      m->hxml_newline := .T.
   ELSEIF ::type == HBXML_TYPE_SINGLE
      s += "/>" + s_cNewLine
      m->hxml_newline := .T.
   ELSEIF ::type == HBXML_TYPE_TAG
      s += ">"
      IF Empty(::aItems) .OR. (Len(::aItems) == 1 .AND. HB_ISCHAR(::aItems[1]) .AND. Len(::aItems[1]) + Len(s) < 80)
         lNewLine := m->hxml_newline := .F.
      ELSE
         s += s_cNewLine
         lNewLine := m->hxml_newline := .T.
      ENDIF
   ENDIF
   IF handle >= 0
      FWrite(handle, s)
   ENDIF

   FOR i := 1 TO Len(::aItems)
      IF HB_ISCHAR(::aItems[i])
        IF handle >= 0
           IF ::type == HBXML_TYPE_CDATA .OR. ::type == HBXML_TYPE_COMMENT
              FWrite(handle, ::aItems[i])
           ELSE
              FWrite(handle, HBXML_PreSave(::aItems[i]))
           ENDIF
           IF lNewLine .AND. Right(::aItems[i], 1) != Chr(10)
              FWrite(handle, s_cNewLine)
           ENDIF
        ELSE
           IF ::type == HBXML_TYPE_CDATA .OR. ::type == HBXML_TYPE_COMMENT
              s += ::aItems[i]
           ELSE
              s += HBXML_PreSave(::aItems[i])
           ENDIF
           IF lNewLine .AND. Right(s, 1) != Chr(10)
              s += s_cNewLine
           ENDIF
        ENDIF
        m->hxml_newline := .F.
      ELSE
        s += ::aItems[i]:Save(handle, level + 1)
      ENDIF
   NEXT
   m->hxml_newline := .T.
   IF handle >= 0
      IF ::type == HBXML_TYPE_TAG
         FWrite(handle, IIf(lNewLine, Space(level * 2), "") + "</" + ::title + ">" + s_cNewLine)
      ELSEIF ::type == HBXML_TYPE_CDATA
         FWrite(handle, "]]>" + s_cNewLine)
      ELSEIF ::type == HBXML_TYPE_COMMENT
         FWrite(handle, "-->" + s_cNewLine)
      ENDIF
   ELSE
      IF ::type == HBXML_TYPE_TAG
         s += IIf(lNewLine, Space(level * 2), "") + "</" + ::title + ">" + s_cNewLine
      ELSEIF ::type == HBXML_TYPE_CDATA
         s += "]]>" + s_cNewLine
      ELSEIF ::type == HBXML_TYPE_COMMENT
         s += "-->" + s_cNewLine
      ENDIF
      Return s
   ENDIF

RETURN ""

/* Added: block */
METHOD HXMLNode:Find(cTitle, nStart, block)

   LOCAL i

   IF nStart == NIL
      nStart := 1
   ENDIF
   DO WHILE .T.
      i := Ascan(::aItems, {|a|Valtype(a) != "C" .AND. a:title == cTitle}, nStart)
      IF i == 0
         EXIT
      ELSE
         nStart := i
         IF block == NIL .OR. Eval(block, ::aItems[i])
            Return ::aItems[i]
         ELSE
            nStart ++
         ENDIF
      ENDIF
   ENDDO

RETURN NIL


/*
 *  CLASS DEFINITION
 *  HXMLDoc
 */

CLASS HXMLDoc INHERIT HXMLNode

   METHOD New(encoding)
   METHOD Read(fname, buffer)
   METHOD ReadString(buffer) INLINE ::Read(, buffer)
   METHOD Save(fname, lNoHeader)
   METHOD Save2String() INLINE ::Save()

ENDCLASS

METHOD HXMLDoc:New(encoding)

   IF encoding != NIL
      Aadd(::aAttr, {"version", "1.0"})
      Aadd(::aAttr, {"encoding", encoding})
   ENDIF

RETURN Self

/* Added: buffer */
METHOD HXMLDoc:Read(fname, buffer)

   LOCAL han

   IF fname != NIL
      han := FOpen(fname, FO_READ)
      ::nLastErr := 0
      IF han != -1
         ::nLastErr := hbxml_GetDoc(Self, han)
         FClose(han)
      ELSE
         ::nLastErr := XML_ERROR_FILEOPEN
      ENDIF
   ELSEIF buffer != NIL
      ::nLastErr := hbxml_GetDoc(Self, buffer)
   ELSE
      Return NIL
   ENDIF

RETURN IIf(::nLastErr == 0, Self, NIL)

METHOD HXMLDoc:Save(fname, lNoHeader)

   LOCAL handle := -2
   LOCAL cEncod
   LOCAL i
   LOCAL s

   IF fname != NIL
      handle := FCreate(fname)
   ENDIF
   IF handle != -1
      IF lNoHeader == NIL .OR. !lNoHeader
         IF (cEncod := ::GetAttribute("encoding")) == NIL
            cEncod := "UTF-8"
         ENDIF
         s := "<?xml version=" + Chr(34) + "1.0" + Chr(34) + " encoding=" + Chr(34) + cEncod + Chr(34) + "?>" + s_cNewLine
         IF fname != NIL
            FWrite(handle, s)
         ENDIF
      ELSE
         s := ""
      ENDIF
      FOR i := 1 TO Len(::aItems)
         s += ::aItems[i]:Save(handle, 0)
      NEXT
      IF fname != NIL
         FClose(handle)
      ELSE
         Return s
      ENDIF
   ENDIF

RETURN .T.
