/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HWinPrn class
 *
 * Copyright 2005 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 *
 * Modifications by DF7BE:
 * - New parameter "nCharset" for
 *   selecting international charachter sets
 *   Data and methods for National Language Support
 *
 * - New method SetDefaultMode():
 *   should act like a "printer reset"
 *   (Set back to default values).
 *
 * - Recovered METHOD PrintBitmap
 *   (Ticket #64, TNX HKrzak)
*/

/*
  Some notes how to explain the work flow of the
  HWINPRN class:
  Every method adding lines or settings into the document to print  
  collect records in an Array aPages[] initialized by method New() of HPRINTER class.
  These methods are for example:
  SetMode(), PrintLine(), PrintBitmap(), NextPage().
  When running method End() of HWINPRN class to close the print job,
  all collected records in the array
  are written in a script file with default filename "temp_a2.ps". 
  This script builds the complete layout of the printing job in background.
  After this, the layout is diplayed in the print preview dialog, the last step
  is send the data to the printer device.

  Sample for the page 7 created by sample program "winprn.prg":
   page,7,px,p
   fnt,monospace,12.2410,400,0,0,
   txt,14.16,-0.3156,589,11.6812,,From file >hwgui.bmp<
   img,14.16,11.6812,315.16,171.6812,,../../image/hwgui.bmp
   txt,14.16,183.6780,589,195.6749,,astro from hex value via temporary file
   img,14.16,195.6749,121.16,285.6749,,/tmp/e5950039.bmp
   img,248.16,297.6717,355.16,387.6717,,/tmp/e5950039.bmp
   img,482.16,399.6685,589.16,489.6685,,/tmp/e5950039.bmp
   txt,14.16,501.6654,589,513.6622,,--------------------

   The record secription (not valid for all types):
   <type>,<x1>,<y1>,<x2>,<y2>,nOpt,<value> CRLF

   The layout is generated in function hwg_gp_Print() in hprinter.prg.
   This function is implemented in wprint.c using
   the features of the Cairo graphic library.
   Function draw_page() interprets the values of the array and
   builds the pixbuffer for one page.


*/

#include "hwgui.ch"
#include "hbclass.ch"


#define   STD_HEIGHT      4

#define   MODE_NORMAL     0
#define   MODE_ELITE      1
#define   MODE_COND       2
#define   MODE_ELITECOND  3
#define   MODE_USER      10

CLASS HWinPrn

   CLASS VAR nStdHeight SHARED  INIT NIL
   CLASS VAR cPrinterName SHARED  INIT NIL
   DATA   oPrinter
   DATA   nFormType INIT 9
   DATA   oFont
   DATA   nLineHeight, nLined
   DATA   nCharW
   DATA   x, y
   DATA   cPseudo   INIT "�ͳ����ֿ�������ټ�������������Ǵ�������"
   DATA   lElite    INIT .F.
   DATA   lCond     INIT .F.
   DATA   nLineInch INIT 6
   DATA   lBold     INIT .F.
   DATA   lItalic   INIT .F.
   DATA   lUnder    INIT .F.
   DATA   nLineMax  INIT 0
   DATA   lChanged  INIT .F.

   DATA   cpFrom, cpTo
   DATA   nTop      INIT 5
   DATA   nBottom   INIT 5
   DATA   nLeft     INIT 5
   DATA   nRight    INIT 5
   
   DATA   nCharset  INIT 0   //  Charset (N) Default: 0, 204 = Russian

   // --- International Language Support for internal dialogs --
   DATA aTooltips   INIT {}  // Array with tooltips messages for print preview dialog
   DATA aBootUser   INIT {}  // Array with control  messages for print preview dialog  (optional usage)


   METHOD New(cPrinter, cpFrom, cpTo, nFormType, nCharset)
   METHOD SetLanguage(apTooltips, apBootUser)
   METHOD InitValues(lElite, lCond, nLineInch, lBold, lItalic, lUnder, nLineMax, nCharset)
   METHOD SetMode(lElite, lCond, nLineInch, lBold, lItalic, lUnder, nLineMax, nCharset)
   METHOD SetDefaultMode()
   METHOD StartDoc(lPreview, cMetaName, lprbutton)
   METHOD NextPage()
   METHOD NewLine()
   METHOD PrintLine(cLine, lNewLine)
   METHOD PrintBitmap(xBitmap, nAlign, cBitmapName) // cImageName
   METHOD PrintText(cText)
   METHOD SetX(nYvalue)
   METHOD SetY(nYvalue)
   METHOD PutCode(cLine)   // cText
   METHOD EndDoc()
   METHOD END()

#ifdef __GTK__
   METHOD SetMetaFile(cMetafile)    INLINE ::oPrinter:cScriptFile := cMetafile
#endif

   HIDDEN:
   DATA lDocStart   INIT .F.
   DATA lPageStart  INIT .F.
   DATA lFirstLine

ENDCLASS

METHOD New(cPrinter, cpFrom, cpTo, nFormType, nCharset) CLASS HWinPrn

   ::SetLanguage() // Start with default english

   ::oPrinter := HPrinter():New(cPrinter, .F., nFormType)
   IF ::oPrinter == NIL
      RETURN NIL
   ENDIF
   ::cpFrom := cpFrom
   ::cpTo   := cpTo
#ifdef __GTK__
   IF !Empty(cpTo)
      ::oPrinter:cdpIn := cpTo
   ENDIF
#endif
   IF nFormType != NIL
      ::nFormType := nFormType
   ENDIF
   
   IF nCharset != NIL
      ::nCharset := nCharset
   ENDIF
 

   RETURN Self


METHOD SetLanguage(apTooltips, apBootUser) CLASS HWinPrn
// NLS: Sets the message and control texts to print preview dialog
// Are stored in arrays:   ::aTooltips[], ::aBootUser[]

   HB_SYMBOL_UNUSED(apBootUser)

// Default settings (English)
  ::aTooltips := hwg_HPrinter_LangArray_EN()
// Overwrite default, if array with own language served
   IF apTooltips != NIL
      ::aTooltips := apTooltips
   ENDIF
/* Activate, if necessary */
//   IF apBootUser != NIL
//      ::aBootUser := apBootUser
//   ENDIF
RETURN NIL

METHOD InitValues(lElite, lCond, nLineInch, lBold, lItalic, lUnder, nLineMax, nCharset) CLASS HWinPrn

   IF lElite != NIL
      ::lElite := lElite
   ENDIF
   IF lCond != NIL
      ::lCond := lCond
   ENDIF
   IF nLineInch != NIL
      ::nLineInch := nLineInch
   ENDIF
   IF lBold != NIL
      ::lBold := lBold
   ENDIF
   IF lItalic != NIL
      ::lItalic := lItalic
   ENDIF
   IF lUnder != NIL
      ::lUnder := lUnder
   ENDIF
   IF nLineMax != NIL
      ::nLineMax := nLineMax
   ENDIF
   IF nCharset != NIL
      ::nCharset := nCharset
   ENDIF
   ::lChanged := .T.

   RETURN NIL

METHOD SetMode(lElite, lCond, nLineInch, lBold, lItalic, lUnder, nLineMax, nCharset) CLASS HWinPrn

#ifdef __GTK__
   LOCAL cFont := "monospace"
#else
   LOCAL cFont := "Lucida Console"
#endif
   LOCAL aKoef := { 1, 1.22, 1.71, 2 }
   LOCAL nMode := 0
   LOCAL oFont
   LOCAL nWidth
   LOCAL nPWidth
   LOCAL nStdHeight
   LOCAL nStdLineW

   ::InitValues(lElite, lCond, nLineInch, lBold, lItalic, lUnder, nLineMax, nCharset)

   IF ::lPageStart

      IF ::nStdHeight == NIL .OR. ::cPrinterName != ::oPrinter:cPrinterName
         ::nStdHeight := STD_HEIGHT
         ::cPrinterName := ::oPrinter:cPrinterName
         nPWidth := ::oPrinter:nWidth / ::oPrinter:nHRes - 10

         IF ::nFormType == 9 .AND. ( nPWidth > 210 .OR. nPWidth < 190 )
            nPWidth := 200
         ELSEIF ::nFormType == 8 .AND. ( nPWidth > 300 .OR. nPWidth < 280 )
            nPWidth := 290
         ENDIF

         oFont := ::oPrinter:AddFont(cFont, ::nStdHeight * ::oPrinter:nVRes)

         nWidth := ::oPrinter:GetTextWidth(Replicate("A", Iif(::nFormType == 8, 113, 80)), oFont) / ::oPrinter:nHRes
         IF nWidth > nPWidth + 2 .OR. nWidth < nPWidth - 15
            ::nStdHeight := ::nStdHeight * ( nPWidth / nWidth )
         ENDIF
         oFont:Release()
      ENDIF

      nStdLineW  := Iif(::nFormType == 8, Iif(::oPrinter:nOrient == 2, 160, 113), Iif(::oPrinter:nOrient == 2, 113, 80))
      nStdHeight := Iif(!Empty(::nLineMax), ::nStdHeight / (::nLineMax / nStdLineW), ::nStdHeight)

      IF ::lElite
         nMode++
      ENDIF
      IF ::lCond
         nMode += 2
      ENDIF
      //hwg_writelog("nStdHeight: " + Ltrim(str(::nStdHeight)) + "/" + Ltrim(str(nStdHeight)) + " ::nLineMax: " + Ltrim(str(::nLineMax)) + "  nStdLineW: " + Ltrim(str(nStdLineW)))

      ::nLineHeight := ( nStdHeight / aKoef[nMode + 1] ) * ::oPrinter:nVRes
      ::nLined := ( 25.4 * ::oPrinter:nVRes ) / ::nLineInch - ::nLineHeight

      oFont := ::oPrinter:AddFont(cFont, ::nLineHeight, ::lBold, ::lItalic, ::lUnder, ::nCharset) // ::nCharset 204 = Russian

      IF ::oFont != NIL
         ::oFont:Release()
      ENDIF
      
      ::oFont := oFont

      ::oPrinter:SetFont(::oFont)
      ::nCharW := ::oPrinter:GetTextWidth("ABCDEFGHIJ", oFont) / 10
      ::lChanged := .F.

   ENDIF

   RETURN NIL

/*
  Added by DF7BE:
  Should act like a "printer reset"
  (Set back to default values).
*/
METHOD SetDefaultMode() CLASS HWinPrn

   ::SetMode(.F., .F., 6, .F., .F., .F., 0, 0)

   RETURN NIL


METHOD SetY(nYvalue) CLASS HWinPrn

  IF nYvalue == NIL
   nYvalue := 0
  ENDIF
  ::Y := nYvalue
  
 RETURN nYvalue
 
 METHOD SetX(nYvalue) CLASS HWinPrn

  IF nYvalue == NIL
   nYvalue := 0
  ENDIF
  ::X := nYvalue
  
 RETURN nYvalue


METHOD StartDoc(lPreview, cMetaName, lprbutton) CLASS HWinPrn
// Set lprbutton to .F., if preview dialog not shows the print button


   ::lDocStart := .T.
   ::oPrinter:StartDoc(lPreview, cMetaName, lprbutton)
   ::NextPage()

   RETURN NIL

METHOD NextPage() CLASS HWinPrn

   IF !::lDocStart
      RETURN NIL
   ENDIF
   IF ::lPageStart
      ::oPrinter:EndPage()
   ENDIF

   ::lPageStart := .T.
   ::oPrinter:StartPage()

   IF ::oFont == NIL
      ::SetMode()
   ELSE
      ::oPrinter:SetFont(::oFont)
   ENDIF

#ifdef __GTK__
   ::y := ::nTop * ::oPrinter:nVRes - ::nLineHeight + ::nLined
#else
   ::y := ::nTop * ::oPrinter:nVRes - ::nLineHeight - ::nLined
#endif
   ::lFirstLine := .T.

   RETURN NIL

   
/*
   DF7BE:
   Recovered from r2536 2016-06-16
   added support for bitmap object

   xBitmap     : Name and path to bitmap file
                 or bitmap object variable
   nAlign      : 0 - left, 1 - center, 2 - right, default = 0
   cBitmapName  : Name of resource, if xBitmap is bitmap object
 */
METHOD PrintBitmap(xBitmap, nAlign, cBitmapName) CLASS HWinPrn

   LOCAL i
   LOCAL cTmp
   LOCAL hBitmap
   LOCAL aBmpSize
   LOCAL cImageName
   
   IF !::lDocStart
      ::StartDoc()
   ENDIF
   
   IF nAlign == NIL
     nAlign := 0  // 0 - left, 1 - center, 2 - right
   ENDIF

   cTmp := hwg_CreateTempfileName(NIL, ".bmp")   
   
   IF HB_ISCHAR(xBitmap) // does not work on GTK
     // from file
     IF !hb_fileexists(xBitmap)
       RETURN NIL
     ENDIF
     hBitmap := hwg_Openbitmap(xBitmap, ::oPrinter:hDC)
     // hwg_msginfo(hb_valtostr(hBitmap))
     IF hb_ValToStr(hBitmap) == "0x00000000"
       RETURN NIL
     ENDIF  
     cImageName := IIF(EMPTY (cBitmapName), xBitmap, cBitmapName)
     aBmpSize  := hwg_Getbitmapsize(hBitmap)
   ELSE
     // xBitmap is a bitmap object
     cImageName := IIF(EMPTY (cBitmapName), "", cBitmapName)
     // Store into a temporary file
     xBitmap:OBMP2FILE(cTmp, cBitmapName)
     hBitmap := hwg_Openbitmap(cTmp, ::oPrinter:hDC)
     // hwg_msginfo(hb_valtostr(hBitmap))
     IF hb_ValToStr(hBitmap) == "0x00000000"
       RETURN NIL
     ENDIF
     aBmpSize  := hwg_Getbitmapsize(hBitmap)
     FERASE(cTmp)
   ENDIF
   
/* Page size overflow  ? ==> next page */
#ifdef __GTK__
   IF ::y + aBmpSize[2] + ::nLined > ::oPrinter:nHeight
#else
   IF ::y + aBmpSize[2] + ::nLined > ::oPrinter:nHeight
#endif
      ::NextPage()
   ENDIF
   
   ::x := ::nLeft * ::oPrinter:nHRes
   ::y += ::nLineHeight + ::nLined

   IF nAlign == 1 .AND. ::x + aBmpSize[2] < ::oPrinter:nWidth 
     ::x += ROUND((::oPrinter:nWidth - ::x - aBmpSize[1]) / 2, 0)
   // HKrzak 2020-10-27 
   ELSEIF nAlign == 2
     ::x += ROUND((::oPrinter:nWidth - ::x - aBmpSize[1]), 0)
   ENDIF
   IF ::lFirstLine
      ::lFirstLine := .F.
   ENDIF
   // Paint bitmap
   ::oPrinter:Bitmap(::x, ::y, ::x + aBmpSize[1], ::y + aBmpSize[2], NIL, hBitmap, cImageName)
        
   i := aBmpSize[2] - ::nLineHeight
   IF i > 0
      ::Y +=  i
   ENDIF

   // hwg_WriteLog(STR(::x) + CHR(10) + STR(::y) + CHR(10) ;
   // + STR(aBmpSize[1]) + CHR(10) +  STR(aBmpSize[2]) + CHR(10) +  STR(i) )

   RETURN NIL
   

METHOD NewLine()  CLASS HWinPrn
    ::PrintLine("", .T.)
    ::SetX()
    ::y += ::nLineHeight
     IF ::y < 0
       ::y := 0
     ENDIF
   RETURN NIL   

   
METHOD PrintLine(cLine, lNewLine) CLASS HWinPrn
   
   LOCAL i
   LOCAL i0
   LOCAL j
   LOCAL slen
   LOCAL c

   IF !::lDocStart
      ::StartDoc()
   ENDIF

// HKrzak.Start 2020-10-25
// Bug Ticket #64
IF cLine != NIL .AND. HB_ISNUMERIC(cLine)
     ::y += ::nLineHeight * cLine
     IF ::y < 0
       ::y := 0
     ENDIF
   ENDIF
// HKrzak.End   
   

#ifdef __GTK__
   IF ::y + 3 * (::nLineHeight + ::nLined) > ::oPrinter:nHeight
#else
   IF ::y + 2 * (::nLineHeight + ::nLined) > ::oPrinter:nHeight
#endif
      ::NextPage()
   ENDIF

// HKrzak.Start 2020-10-25
// Bug Ticket #64
   IF cLine != NIL .AND. HB_ISNUMERIC(cLine)
     RETURN NIL
   ENDIF
// HKrzak.End

   ::x := ::nLeft * ::oPrinter:nHRes
   IF ::lFirstLine
      ::lFirstLine := .F.
   ELSEIF lNewLine == NIL .OR. lNewLine
      ::y += ::nLineHeight + ::nLined
   ENDIF

   IF cLine != NIL .AND. !Empty(cLine)
      slen := Len(cLine)
      i := 1
      i0 := 0
      DO WHILE i <= slen
         IF ( c := SubStr(cLine, i, 1) ) < " "
            IF i0 != 0
               ::PrintText(SubStr(cLine, i0, i - i0))
               i0 := 0
            ENDIF
            i += ::PutCode(SubStr(cLine, i))
            LOOP
         ELSEIF ( j := At(c, ::cPseudo) ) != 0
            IF i0 != 0
               ::PrintText(SubStr(cLine, i0, i - i0))
               i0 := 0
            ENDIF
            IF j < 3            // Horisontal line ��
               i0 := i
               DO WHILE i <= slen .AND. SubStr(cLine, i, 1) == c
                  i++
               ENDDO
               ::oPrinter:Line(::x, ::y + (::nLineHeight / 2), ::x + (i - i0) * ::nCharW, ::y + (::nLineHeight / 2))
               ::x += ( i - i0 ) * ::nCharW
               i0 := 0
               LOOP
            ELSE
               IF j < 5         // Vertical Line ��
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y, ::x + (::nCharW / 2), ::y + ::nLineHeight + ::nLined)
               ELSEIF j < 9     // ����
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y + (::nLineHeight / 2), ::x + ::nCharW, ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y + (::nLineHeight / 2), ::x + (::nCharW / 2), ::y + ::nLineHeight + ::nLined)
               ELSEIF j < 13    // ����
                  ::oPrinter:Line(::x, ::y + (::nLineHeight / 2), ::x + (::nCharW / 2), ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y + (::nLineHeight / 2), ::x + (::nCharW / 2), ::y + ::nLineHeight + ::nLined)
               ELSEIF j < 17    // ����
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y + (::nLineHeight / 2), ::x + ::nCharW, ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y, ::x + (::nCharW / 2), ::y + (::nLineHeight / 2))
               ELSEIF j < 21    // ټ��
                  ::oPrinter:Line(::x, ::y + (::nLineHeight / 2), ::x + (::nCharW / 2), ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y, ::x + (::nCharW / 2), ::y + (::nLineHeight / 2))
               ELSEIF j < 25    // ����
                  ::oPrinter:Line(::x, ::y + (::nLineHeight / 2), ::x + ::nCharW, ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y + (::nLineHeight / 2), ::x + (::nCharW / 2), ::y + ::nLineHeight + ::nLined)
               ELSEIF j < 29    // ����
                  ::oPrinter:Line(::x, ::y + (::nLineHeight / 2), ::x + ::nCharW, ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y, ::x + (::nCharW / 2), ::y + (::nLineHeight / 2))
               ELSEIF j < 33    // ����
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y + (::nLineHeight / 2), ::x + ::nCharW, ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y, ::x + (::nCharW / 2), ::y + ::nLineHeight + ::nLined)
               ELSEIF j < 37    // ����
                  ::oPrinter:Line(::x, ::y + (::nLineHeight / 2), ::x + (::nCharW / 2), ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y, ::x + (::nCharW / 2), ::y + ::nLineHeight + ::nLined)
               ELSE    // ����
                  ::oPrinter:Line(::x, ::y + (::nLineHeight / 2), ::x + ::nCharW, ::y + (::nLineHeight / 2))
                  ::oPrinter:Line(::x + (::nCharW / 2), ::y, ::x + (::nCharW / 2), ::y + ::nLineHeight + ::nLined)
               ENDIF
               ::x += ::nCharW
            ENDIF
         ELSE
            IF i0 == 0
               i0 := i
            ENDIF
         ENDIF
         i++
      ENDDO
      IF i0 != 0
       // hwg_writelog(STR(::x) + CHR(10) + STR(::y) + CHR(10) + STR(i0) + CHR(10) + STR(i) + ;
       //  CHR(10) + STR(::nLineHeight) )
         ::PrintText(SubStr(cLine, i0, i - i0))
      ENDIF
   ENDIF

   RETURN NIL

METHOD PrintText(cText) CLASS HWinPrn

   IF ::lChanged
      ::SetMode()
   ENDIF
   ::oPrinter:Say(IIf(::cpFrom != ::cpTo, hb_Translate(cText, ::cpFrom, ::cpTo), cText), ::x, ::y, ::oPrinter:nWidth, ::y + ::nLineHeight + ::nLined)
   ::x += (::nCharW * Len(cText))


   RETURN NIL

METHOD PutCode(cLine) CLASS HWinPrn
   
   STATIC aCodes := {   ;
          { Chr(27) + "@", .F., .F., 6, .F., .F., .F. }, ;     /* Reset */
          { Chr(27) + "M", .T., NIL, NIL, NIL, NIL, NIL }, ;     /* Elite */
          { Chr(15), NIL, .T., NIL, NIL, NIL, NIL }, ;     /* Cond */
          { Chr(18), NIL, .F., NIL, NIL, NIL, NIL }, ;     /* Cancel Cond */
          { Chr(27) + "0", NIL, NIL, 8, NIL, NIL, NIL }, ;     /* 8 lines per inch */
          { Chr(27) + "2", NIL, NIL, 6, NIL, NIL, NIL }, ;     /* 6 lines per inch ( standard ) */
          { Chr(27) + "-1", NIL, NIL, NIL, NIL, NIL, .T. }, ;     /* underline */
          { Chr(27) + "-0", NIL, NIL, NIL, NIL, NIL, .F. }, ;     /* cancel underline */
          { Chr(27) + "4", NIL, NIL, NIL, NIL, .T., NIL }, ;     /* italic */
          { Chr(27) + "5", NIL, NIL, NIL, NIL, .F., NIL }, ;     /* cancel italic */
          { Chr(27) + "G", NIL, NIL, NIL, .T., NIL, NIL }, ;     /* bold */
          { Chr(27) + "H", NIL, NIL, NIL, .F., NIL, NIL } ;     /* cancel bold */
        }
   
   LOCAL i
   LOCAL sLen := Len(aCodes)
   LOCAL c := Left(cLine, 1)

   IF !Empty(c) .AND. c < " "
      IF Asc(c) == 31
         ::InitValues(NIL, NIL, NIL, NIL, NIL, NIL, Asc(Substr(cLine, 2, 1)))
         RETURN 2
      ELSE
         FOR i := 1 TO sLen
            IF Left(aCodes[i, 1], 1) == c .AND. At(aCodes[i, 1], Left(cLine, 3)) == 1
               ::InitValues(aCodes[i, 2], aCodes[i, 3], aCodes[i, 4], aCodes[i, 5], aCodes[i, 6], aCodes[i, 7])
               RETURN Len(aCodes[i, 1])
            ENDIF
         NEXT
      ENDIF
   ENDIF

   RETURN 1

METHOD EndDoc() CLASS HWinPrn

   IF ::lPageStart
      ::oPrinter:EndPage()
      ::lPageStart := .F.
   ENDIF
   IF ::lDocStart
      ::oPrinter:EndDoc()
      ::lDocStart := .F.
      IF __ObjHasMsg(::oPrinter, "PREVIEW") .AND. ::oPrinter:lPreview
         ::oPrinter:Preview(NIL, NIL, ::aTooltips, NIL)
      ENDIF
   ENDIF

   RETURN NIL

METHOD END() CLASS HWinPrn

   ::EndDoc()
   ::oFont:Release()
   ::oPrinter:END()

   RETURN NIL
