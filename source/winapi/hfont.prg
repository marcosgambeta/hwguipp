//
// HWGUI - Harbour Win32 GUI library source code:
// HFont class
//
// Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

CLASS HFont INHERIT HObject

   CLASS VAR aFonts INIT {}

   DATA handle
   DATA name, width, height, weight
   DATA charset, italic, Underline, StrikeOut
   DATA nCounter INIT 1

   METHOD Add(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle)
   METHOD SELECT(oFont, nCharSet)
   METHOD RELEASE()
   METHOD SetFontStyle(lBold, nCharSet, lItalic, lUnder, lStrike, nHeight)
   METHOD PrintFont()
   METHOD Props2Arr()
   // METHOD AddC(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle)

ENDCLASS

METHOD HFont:Add(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle)

   LOCAL i
   LOCAL nlen := Len(::aFonts)

   nHeight := iif(nHeight == NIL, -13, nHeight)
   fnWeight := iif(fnWeight == NIL, 0, fnWeight)
   fdwCharSet := iif(fdwCharSet == NIL, 0, fdwCharSet)
   fdwItalic := iif(fdwItalic == NIL, 0, fdwItalic)
   fdwUnderline := iif(fdwUnderline == NIL, 0, fdwUnderline)
   fdwStrikeOut := iif(fdwStrikeOut == NIL, 0, fdwStrikeOut)

   FOR i := 1 TO nlen
      IF ::aFonts[i]:name == fontName .AND.             ;
            ( ( Empty(::aFonts[i]:width) .AND. Empty(nWidth) ) ;
            .OR. ::aFonts[i]:width == nWidth ) .AND.    ;
            ::aFonts[i]:height == nHeight .AND.         ;
            ::aFonts[i]:weight == fnWeight .AND.        ;
            ::aFonts[i]:CharSet == fdwCharSet .AND.     ;
            ::aFonts[i]:Italic == fdwItalic .AND.       ;
            ::aFonts[i]:Underline == fdwUnderline .AND. ;
            ::aFonts[i]:StrikeOut == fdwStrikeOut

         ::aFonts[i]:nCounter++
         IF nHandle != NIL
            hwg_Deleteobject(nHandle)
         ENDIF
         RETURN ::aFonts[i]
      ENDIF
   NEXT

   IF nHandle == NIL
      ::handle := hwg_Createfont(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut)
   ELSE
      ::handle := nHandle
   ENDIF

   ::name := fontName
   ::width := nWidth
   ::height := nHeight
   ::weight := fnWeight
   ::CharSet := fdwCharSet
   ::Italic := fdwItalic
   ::Underline := fdwUnderline
   ::StrikeOut := fdwStrikeOut

   AAdd(::aFonts, Self)

   RETURN Self

METHOD HFont:SELECT(oFont, nCharSet)
   
   LOCAL af := hwg_Selectfont(oFont)

   IF af == NIL
      RETURN NIL
   ENDIF

   RETURN ::Add(af[2], af[3], af[4], af[5], iif(Empty(nCharSet), af[6], nCharSet), af[7], af[8], af[9], af[1])

METHOD HFont:SetFontStyle(lBold, nCharSet, lItalic, lUnder, lStrike, nHeight)
   
   LOCAL weight
   LOCAL Italic
   LOCAL Underline
   LOCAL StrikeOut

   IF lBold != NIL
      weight = iif(lBold, FW_BOLD, FW_REGULAR)
   ELSE
      weight := ::weight
   ENDIF
   Italic := iif(lItalic = NIL, ::Italic, iif(lItalic, 1, 0))
   Underline := iif(lUnder  = NIL, ::Underline, iif(lUnder, 1, 0))
   StrikeOut := iif(lStrike = NIL, ::StrikeOut, iif(lStrike, 1, 0))
   nheight := iif(nheight = NIL, ::height, nheight)
   nCharSet := iif(nCharSet = NIL, ::CharSet, nCharSet)

   RETURN HFont():Add(::name, ::width, nheight, weight, nCharSet, Italic, Underline, StrikeOut) // ::handle)

METHOD HFont:RELEASE()
   
   LOCAL i
   LOCAL nlen := Len(::aFonts)

   ::nCounter--
   IF ::nCounter == 0
      FOR i := 1 TO nlen // TODO: FOR EACH
         IF ::aFonts[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aFonts, i)
            ASize(::aFonts, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN NIL

/* DF7BE: For debugging purposes */
METHOD HFont:PrintFont()
//        fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut
// Type:  C         N       N         N         N           N          N             N
// - 9999 means NIL

   LOCAL fontName
   LOCAL nWidth
   LOCAL nHeight
   LOCAL fnWeight
   LOCAL fdwCharSet
   LOCAL fdwItalic
   LOCAL fdwUnderline
   LOCAL fdwStrikeOut

   fontName := iif(::name == NIL, "<Empty>", ::name)
   nWidth := iif(::width == NIL, - 9999, ::width)
   nHeight := iif(::height == NIL, - 9999, ::height)
   fnWeight := iif(::weight == NIL, - 9999, ::weight)
   fdwCharSet := iif(::CharSet == NIL, - 9999, ::CharSet)
   fdwItalic := iif(::Italic == NIL, - 9999, ::Italic)
   fdwUnderline := iif(::Underline == NIL, - 9999, ::Underline)
   fdwStrikeOut := iif(::StrikeOut == NIL, - 9999, ::StrikeOut)

RETURN "Font Name=" + fontName + " Width=" + ALLTRIM(STR(nWidth)) + " Height=" + ALLTRIM(STR(nHeight)) + ;
       " Weight=" + ALLTRIM(STR(fnWeight)) + " CharSet=" + ALLTRIM(STR(fdwCharSet)) + ;
       " Italic=" + ALLTRIM(STR(fdwItalic)) + " Underline=" + ALLTRIM(STR(fdwUnderline)) + ;
       " StrikeOut=" + ALLTRIM(STR(fdwStrikeOut))


/*
  Returns an array with font properties (for creating a copy of a font entry)
  Copy sample
   apffrarr := oFont1:Props2Arr()
   oFont2 := HFont():Add(apffrarr[1], apffrarr[2], apffrarr[3], apffrarr[4], apffrarr[5], apffrarr[6], apffrarr[7], apffrarr[8])
 */
METHOD HFont:Props2Arr()
//        fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut
//        1         2       3         4         5           6          7             8
   LOCAL fontName
   LOCAL nWidth
   LOCAL nHeight
   LOCAL fnWeight
   LOCAL fdwCharSet
   LOCAL fdwItalic
   LOCAL fdwUnderline
   LOCAL fdwStrikeOut
   LOCAL aFontprops := {}

   fontName := iif(::name == NIL, "<Empty>", ::name)
   nWidth := iif(::width == NIL, - 9999, ::width)
   nHeight := iif(::height == NIL, - 9999, ::height)
   fnWeight := iif(::weight == NIL, - 9999, ::weight)
   fdwCharSet := iif(::CharSet == NIL, - 9999, ::CharSet)
   fdwItalic := iif(::Italic == NIL, - 9999, ::Italic)
   fdwUnderline := iif(::Underline == NIL, - 9999, ::Underline)
   fdwStrikeOut := iif(::StrikeOut == NIL, - 9999, ::StrikeOut)

   AADD(aFontprops, fontName)  // C
   AADD(aFontprops, nWidth)    // all other of type N
   AADD(aFontprops, nHeight)
   AADD(aFontprops, fnWeight)
   AADD(aFontprops, fdwCharSet)
   AADD(aFontprops, fdwItalic)
   AADD(aFontprops, fdwUnderline)
   AADD(aFontprops, fdwStrikeOut)

   RETURN aFontprops
