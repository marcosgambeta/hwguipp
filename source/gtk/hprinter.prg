//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HPrinter class
//
// Copyright 2005 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

STATIC s_crlf := e"\r\n"
#define SCREEN_PRINTER ".buffer"

CLASS HPrinter INHERIT HObject

#if defined(__GTK__) .AND. defined(__RUSSIAN__)
   CLASS VAR cdp SHARED INIT "RUKOI8"
#else
   CLASS VAR cdp SHARED
#endif
   CLASS VAR aPaper INIT {{"A3", 297, 420}, {"A4", 210, 297}, {"A5", 148, 210}, {"A6", 105, 148}}

   DATA hDC INIT 0
   DATA cPrinterName INIT "DEFAULT"
   DATA cdpIn
   DATA lPreview
   DATA lBuffPrn INIT .F.
   DATA nWidth
   DATA nHeight
   DATA nOrient INIT 1
   DATA nFormType INIT 0
   DATA nHRes, nVRes                     // Resolution ( pixels/mm )
   DATA nPage
   DATA oPen
   DATA oFont
   DATA lastPen
   DATA lastFont
   DATA aPages
   DATA aJob
   DATA lmm INIT .F.
   DATA cScriptFile
   DATA nZoom
   DATA nCurrPage
   DATA hMeta
   DATA x1
   DATA y1
   DATA x2
   DATa y2
   DATA oBrush1
   DATA oBrush2
   DATA lprbutton INIT .T.
   // --- International Language Support for internal dialogs --
   DATA aLangTexts
   // Print Preview Dialog with sub dialog:
   // The messages and control text's are delivered by other classes, calling
   // the method Preview() in Parameter aTooltips as an array.
   // After call of Init method, you can update the array with messages in your
   // desired language.
   // Sample: Preview(NIL, NIL, aTooltips, NIL)
   // Structure of array look at
   // METHOD SetLanguage(apTooltips) CLASS HWinPrn
   // in file hwinprn.prg.
   // List of classes calling print preview
   // HWINPRN, HRepTmpl , ...
   // For more details see inline comments in sample program "nlsdemo.prg"

   METHOD New(cPrinter, lmm, nFormType)
   // FUNCTION hwg_HPrinter_LangArray_EN()
   METHOD DefaultLang()
   METHOD SetMode(nOrientation, nDuplex)
   METHOD Recalc(x1, y1, x2, y2)
   METHOD AddFont(fontName, nHeight , lBold, lItalic, lUnderline, nCharset)
   METHOD SetFont(oFont)
   METHOD AddPen(nWidth, style, color)
   METHOD SetPen(nWidth, style, color)
   METHOD StartDoc(lPreview, cScriptFile, lprbutton)
   METHOD EndDoc()
   METHOD StartPage()
   METHOD EndPage()
   METHOD End()
   METHOD Box(x1, y1, x2, y2, oPen)
   METHOD Line(x1, y1, x2, y2, oPen)
   METHOD Say(cString, x1, y1, x2, y2, nOpt, oFont)
   METHOD Bitmap(x1, y1, x2, y2, nOpt, hBitmap, cImageName)
   METHOD LoadScript(cScriptFile)
   METHOD SaveScript(cScriptFile)
   METHOD Preview(cTitle, aBitmaps, aTooltips, aBootUser)
   METHOD PaintDoc(oCanvas)
   METHOD PrintDoc()
   METHOD ChangePage(oCanvas, oSayPage, n, nPage)
   METHOD GetTextWidth(cString, oFont) INLINE hwg_gp_GetTextSize(::hDC, cString, oFont:name, oFont:height)

ENDCLASS

FUNCTION hwg_HPrinter_LangArray_EN()
/* Returns array with captions for titles and controls of print preview dialog
  in default language english.
  Use this code snippet as template to set to your own desired language. */

  LOCAL aTooltips
  
  aTooltips := {}

  /* 1  */ AAdd(aTooltips,"Exit Preview")
  /* 2  */ AAdd(aTooltips,"Print file")
  /* 3  */ AAdd(aTooltips,"First page")
  /* 4  */ AAdd(aTooltips,"Next page")
  /* 5  */ AAdd(aTooltips,"Previous page")
  /* 6  */ AAdd(aTooltips,"Last page")
  /* 7  */ AAdd(aTooltips,"Zoom out")
  /* 8  */ AAdd(aTooltips,"Zoom in")
  /* 9  */ AAdd(aTooltips,"Print dialog")
  // added (Titles and other Buttons)
  /* 10 */ AAdd(aTooltips,"Print preview -") // Title
  /* 11 */ AAdd(aTooltips,"Print")           // Button
  /* 12 */ AAdd(aTooltips,"Exit")            // Button
  /* 13 */ AAdd(aTooltips,"Dialog")          // Button
  /* 14 */ AAdd(aTooltips,"User Button")     // aBootUser[3], Tooltip
  /* 15 */ AAdd(aTooltips,"User Button")     // aBootUser[4]
  // Subdialog "Printer Dialog"
  /* 16 */ AAdd(aTooltips,"All")             // Radio Button              "All"
  /* 17 */ AAdd(aTooltips,"Current")         // Radio Button              "Current"
  /* 18 */ AAdd(aTooltips,"Pages")           // Radio Button              "Pages"
  /* 19 */ AAdd(aTooltips,"Print")           // Button                    "Print"
  /* 20 */ AAdd(aTooltips,"Cancel")          // Button                    "Cancel"
  /* 21 */ AAdd(aTooltips,"Enter range of pages") // Tooltip              "Enter range of pages"

RETURN aTooltips

METHOD HPrinter:New(cPrinter, lmm, nFormType)

   LOCAL aPrnCoors

   ::DefaultLang()

   IF lmm != NIL
      ::lmm := lmm
   ENDIF
   IF nFormType != NIL
      ::nFormType := nFormType
   ELSE
      nFormType := DMPAPER_A4
   ENDIF

   ::cdpIn := IIf(Empty(::cdp), hb_cdpSelect(), ::cdp)

   IF cPrinter != NIL .AND. cPrinter == SCREEN_PRINTER
      ::lBuffPrn := .T.
      ::hDC := hwg_Getdc(hwg_Getactivewindow())
      ::cPrinterName := ""
   ELSE
      ::hDC := Hwg_OpenPrinter(cPrinter, nFormType)
      ::cPrinterName := cPrinter
   ENDIF

   IF Empty(::hDC)
      RETURN NIL
   ELSEIF ::lBuffPrn
      aPrnCoors := hwg_Getdevicearea()
      ::nHRes := aPrnCoors[1] / aPrnCoors[3]
      ::nVRes := aPrnCoors[2] / aPrnCoors[4]
      ::nWidth := IIf(nFormType == DMPAPER_A3, 297, 210)
      ::nHeight := IIf(nFormType == DMPAPER_A3, 420, 297)
      IF !::lmm
         ::nWidth := Round(::nHRes * ::nWidth, 0)
         ::nHeight := Round(::nVRes * ::nHeight, 0)
      ENDIF
   ELSE
      aPrnCoors := hwg_gp_GetDeviceArea(::hDC)
      ::nWidth := IIf(::lmm, aPrnCoors[3], aPrnCoors[1])
      ::nHeight := IIf(::lmm, aPrnCoors[4], aPrnCoors[2])
      ::nHRes := aPrnCoors[1] / aPrnCoors[3]
      ::nVRes := aPrnCoors[2] / aPrnCoors[4]
      //hwg_WriteLog("Printer:" + str(aPrnCoors[1])+str(aPrnCoors[2])+str(aPrnCoors[3])+str(aPrnCoors[4])+"/"+str(::nWidth)+"/"+str(::nHeight))
   ENDIF

   RETURN Self

METHOD HPrinter:DefaultLang()
  ::aLangTexts := hwg_HPrinter_LangArray_EN()
RETURN NIL  

METHOD HPrinter:SetMode(nOrientation, nDuplex)
   
   LOCAL x

   IF (nOrientation == 1 .OR. nOrientation == 2) .AND. nOrientation != ::nOrient
      IF !::lBuffPrn
         hwg_Setprintermode(::hDC, nOrientation, IIf(Empty(nDuplex ), 0, nDuplex))
      ENDIF
      ::nOrient := nOrientation
      x := ::nHRes
      ::nHRes := ::nVRes
      ::nVRes := x
      x := ::nWidth
      ::nWidth := ::nHeight
      ::nHeight := x
   ENDIF

   RETURN .T.

METHOD HPrinter:Recalc(x1, y1, x2, y2)

   IF ::lmm
      x1 := Round(x1 * ::nHRes, 1)
      x2 := Round(x2 * ::nHRes, 1)
      y1 := Round(y1 * ::nVRes, 1)
      y2 := Round(y2 * ::nVRes, 1)
   ENDIF

   RETURN NIL

/* Added: , nCharset */   
METHOD HPrinter:AddFont(fontName, nHeight , lBold, lItalic, lUnderline, nCharset)
   
   LOCAL oFont
   
   HB_SYMBOL_UNUSED(nCharset)

   IF ::lmm .AND. nHeight != NIL
      nHeight *= ::nVRes
   ENDIF
   oFont := HGP_Font():Add(fontName, nHeight, ;
      IIf(lBold != NIL .AND. lBold, 700, 400),    ;
      IIf(lItalic != NIL .AND. lItalic, 255, 0), IIf(lUnderline != NIL .AND. lUnderline, 1, 0))

   RETURN oFont

METHOD HPrinter:SetFont(oFont)
   
   LOCAL oFontOld := ::oFont

   ::oFont := oFont

   RETURN oFontOld

METHOD HPrinter:AddPen(nWidth, style, color)
   
   LOCAL oPen

   IF ::lmm .AND. nWidth != NIL
      nWidth *= ::nVRes
   ENDIF
   oPen := HGP_Pen():Add(nWidth, style, color)

   RETURN oPen

METHOD HPrinter:SetPen(nWidth, style, color)
   
   LOCAL oPenOld := ::oPen

   ::oPen := HGP_Pen():Add(nWidth, style, color)

   RETURN oPenOld

METHOD HPrinter:End()

   IF !Empty(::hDC)
      IF ::lBuffPrn
         hwg_Releasedc(hwg_Getactivewindow(), ::hDC)
      ELSE
         hwg_ClosePrinter(::hDC)
      ENDIF
      ::hDC := 0
   ENDIF

   RETURN NIL

METHOD HPrinter:Box(x1, y1, x2, y2, oPen)

   IF oPen == NIL
      oPen := ::oPen
   ENDIF
   IF oPen != NIL
      IF Empty(::lastPen) .OR. oPen:width != ::lastPen:width .OR. ;
            oPen:style != ::lastPen:style .OR. oPen:color != ::lastPen:color
         ::lastPen := oPen
         ::aPages[::nPage] += "pen," + LTrim(Str(oPen:width)) + "," + ;
            LTrim(Str(oPen:style)) + "," + LTrim(Str(oPen:color)) + "," + s_crlf
      ENDIF
   ENDIF

   IF y2 > ::nHeight
      RETURN NIL
   ENDIF

   ::Recalc(@x1, @y1, @x2, @y2)

   ::aPages[::nPage] += "box," + LTrim(Str(x1)) + "," + LTrim(Str(y1)) + "," + ;
      LTrim(Str(x2)) + "," + LTrim(Str(y2)) + s_crlf

   RETURN NIL

METHOD HPrinter:Line(x1, y1, x2, y2, oPen)

   IF oPen == NIL
      oPen := ::oPen
   ENDIF
   IF oPen != NIL
      IF Empty(::lastPen) .OR. oPen:width != ::lastPen:width .OR. ;
            oPen:style != ::lastPen:style .OR. oPen:color != ::lastPen:color
         ::lastPen := oPen
         ::aPages[::nPage] += "pen," + LTrim(Str(oPen:width)) + "," + ;
            LTrim(Str(oPen:style)) + "," + LTrim(Str(oPen:color)) + "," + s_crlf
      ENDIF
   ENDIF

   IF y2 > ::nHeight
      RETURN NIL
   ENDIF

   ::Recalc(@x1, @y1, @x2, @y2)

   ::aPages[::nPage] += "lin," + LTrim(Str(x1)) + "," + LTrim(Str(y1)) + "," + ;
      LTrim(Str(x2)) + "," + LTrim(Str(y2)) + "," + s_crlf

   RETURN NIL

METHOD HPrinter:Say(cString, x1, y1, x2, y2, nOpt, oFont)

   IF y2 > ::nHeight
      RETURN NIL
   ENDIF

   ::Recalc(@x1, @y1, @x2, @y2)

   IF oFont == NIL
      oFont := ::oFont
   ENDIF

   IF oFont != NIL .AND. (::lastFont == NIL .OR. !::lastFont:Equal(oFont:name, oFont:height, oFont:weight, oFont:Italic, oFont:Underline))
      ::lastFont := oFont
      ::aPages[::nPage] += "fnt," + oFont:name + "," + LTrim(Str(oFont:height)) + "," + ;
         LTrim(Str(oFont:weight)) + "," + LTrim(Str(oFont:Italic)) + "," + ;
         LTrim(Str(oFont:Underline)) + "," + s_crlf
   ENDIF

   IF !Empty(nOpt) .AND. (Hb_BitAnd(nOpt, DT_RIGHT) != 0 .OR. Hb_BitAnd(nOpt, DT_CENTER) != 0) .AND. Left(cString, 1) == " "
      cString := LTrim(cString)
   ENDIF
   ::aPages[::nPage] += "txt," + LTrim(Str(x1)) + "," + LTrim(Str(y1)) + "," + ;
      LTrim(Str(x2)) + "," + LTrim(Str(y2)) + "," + ;
      IIf(nOpt == NIL, ",", LTrim(Str(nOpt )) + ",") + hb_StrToUtf8(cString, ::cdpIn) + s_crlf

    // hwg_WriteLog("Printer:Txt " + "txt," + LTrim(Str(x1)) + "," + LTrim(Str(y1)) + "," + ;
    //  LTrim(Str(x2)) + "," + LTrim(Str(y2)) + "," + ;
    //  IIf(nOpt == NIL, ",", LTrim(Str(nOpt)) + ",") + hb_StrToUtf8(cString, ::cdpIn) + s_crlf)
  
   RETURN NIL

METHOD HPrinter:Bitmap(x1, y1, x2, y2, nOpt, hBitmap, cImageName)

   HB_SYMBOL_UNUSED(hBitmap)

   IF y2 > ::nHeight
      RETURN NIL
   ENDIF

   ::Recalc(@x1, @y1, @x2, @y2)

   ::aPages[::nPage] += "img," + LTrim(Str(x1)) + "," + LTrim(Str(y1)) + "," + ;
      LTrim(Str(x2)) + "," + LTrim(Str(y2)) + "," + ;
      IIf(nOpt == NIL, ",", LTrim(Str(nOpt )) + ",") + cImageName + s_crlf

    // hwg_WriteLog("Printer:Bitmap " + "img," + LTrim(Str(x1)) + "," + LTrim(Str(y1)) + "," + ;
    //    LTrim(Str(x2)) + "," + LTrim(Str(y2)) + "," + ;
    //  IIf(nOpt == NIL, ",", LTrim(Str(nOpt)) + ",") + cImageName + s_crlf)

   RETURN NIL

METHOD HPrinter:StartDoc(lPreview, cScriptFile , lprbutton)

   IF lprbutton == NIL
      ::lprbutton := .T.
   ELSE
      ::lprbutton := lprbutton
   ENDIF 

   ::nPage := 0
   ::aPages := {}
   ::lPreview := lPreview
   IF !Empty(cScriptFile)
      ::cScriptFile := cScriptFile
   ENDIF

   RETURN NIL

METHOD HPrinter:EndDoc()

   IF !Empty(::cScriptFile)
      ::SaveScript()
   ENDIF

   IF Empty(::lPreview) .AND. !::lBuffPrn
      ::PrintDoc()
   ENDIF

   RETURN NIL

METHOD HPrinter:StartPage()

   ::nPage ++
   AAdd(::aPages, "page," + LTrim(Str(::nPage)) + "," + IIf(::lmm, "mm,", "px,") + IIf(::nOrient == 1, "p", "l") + s_crlf)

   RETURN NIL

METHOD HPrinter:EndPage()

   ::lastFont := ::lastPen := NIL
   hb_gcStep()

   RETURN NIL

METHOD HPrinter:LoadScript(cScriptFile)
   
   LOCAL arr
   LOCAL i
   LOCAL s

   IF Empty(cScriptFile) .OR. Empty(arr := hb_aTokens(MemoRead(cScriptFile), s_crlf))
      RETURN .F.
   ENDIF
   ::cScriptFile := cScriptFile
   ::aPages := {}

   ::aJob := hb_aTokens(arr[1], ",")

   FOR i := 1 TO Len(arr)
      IF Left(arr[i], 4) == "page"
         IF !Empty(s)
            AAdd(::aPages, s)
         ENDIF
         s := arr[i] + s_crlf
      ELSEIF !Empty(arr[i]) .AND. !Empty(s)
         s += arr[i] + s_crlf
      ENDIF
   NEXT
   IF !Empty(s)
      AAdd(::aPages, s)
   ENDIF

   RETURN !Empty(::aPages)

METHOD HPrinter:SaveScript(cScriptFile)

   LOCAL han
   LOCAL i

   IF Empty(cScriptFile)
      IF Empty(::cScriptFile)
         cScriptFile := ::cScriptFile := hwg_SelectfileEx(NIL, NIL, {{"All files", "*"}})
      ELSE
         cScriptFile := ::cScriptFile
      ENDIF
   ENDIF

   IF !Empty(cScriptFile)
      // hwg_MsgInfo("Scriptfile=" + cScriptFile)
      // Default scriptfile is "temp_a2.ps"
      han := FCreate(cScriptFile)
      FWrite(han, "job," + ;
            LTrim(Str(IIf(::lmm,::nWidth*::nHRes,::nWidth) )) + "," + ;
            LTrim(Str(IIf(::lmm,::nHeight*::nVRes,::nHeight) )) + "," + ;
            LTrim(Str(::nHRes, 11, 4 )) + "," + LTrim(Str(::nVRes, 11, 4 )) + ",utf8" + s_crlf)

      FOR i := 1 TO Len(::aPages)
         FWrite(han, ::aPages[i] + s_crlf)
      NEXT
      FClose(han)
   ENDIF

   RETURN NIL

#define TOOL_SIDE_WIDTH  88

METHOD HPrinter:Preview(cTitle, aBitmaps, aTooltips, aBootUser)

/*
aBootUser[1] : oBtn:bClick
aBootUser[2] : AddResource(Bitmap)
aBootUser[3] : "User Button", Tooltip ==> cBootUser3
aBootUser[4] : "User Button"          ==> cBootUser4

Default values in array aTooltips see 
FUNCTION hwg_HPrinter_LangArray_EN()
*/

   LOCAL cmExit
   LOCAL cmPrint
   LOCAL cmTitle
   LOCAL oDlg
   LOCAL oSayPage
   LOCAL oBtn
   LOCAL oCanvas
   LOCAL i
   LOCAL nLastPage := Len(::aPages)
   LOCAL aPage := {}
   LOCAL oFont := HFont():Add("Times New Roman", 0, -13, 700)
   LOCAL lTransp := (aBitmaps != NIL .AND. Len(aBitmaps) > 9 .AND. aBitmaps[10] != NIL .AND. aBitmaps[10])
   // Variables not used
   // LOCAL oTimer
   // LOCAL cmDialog, cBootUser3, cBootUser4
   
   // Button and title default captions
   // "Print preview -", see above
   cmExit := "Exit"
   cmPrint := "Print"
   // cmDialog := "Dialog"
   // cBootUser3 := "User Button"
   // cBootUser4 := "User Button"
   cmTitle := "Print preview"

   /* Parameter cTitle preferred */
   IF cTitle == NIL
    cTitle := cmTitle
    IF aTooltips != NIL
      cTitle := aTooltips[10]
    ENDIF
   ELSE
    cTitle := cmTitle
   ENDIF
   IF aTooltips != NIL
      cmPrint := aTooltips[11]
      cmExit := aTooltips[12]
      // cmDialog := aTooltips[13]
      // cBootUser3 := aTooltips[14]
      // cBootUser4 := aTooltips[15]
   ENDIF
   FOR i := 1 TO nLastPage
      AAdd(aPage, Str(i, 4) + ":" + Str(nLastPage, 4))
   NEXT


   ::nZoom := 0
   ::ChangePage(NIL, NIL, NIL, 1)

   ::oBrush1 := HBrush():Add(8421504)
   ::oBrush2 := HBrush():Add(16777215)

   INIT DIALOG oDlg TITLE cTitle AT 0, 0 ;
         SIZE hwg_Getdesktopwidth()-12, hwg_Getdesktopheight()-12 ON INIT {||hwg_SetAdjOptions(oCanvas:hScrollV,, 11, 1, 1, 1),hwg_SetAdjOptions(oCanvas:hScrollH,, 11, 1, 1, 1)}

   @ TOOL_SIDE_WIDTH, 0 PANEL oCanvas SIZE oDlg:nWidth - TOOL_SIDE_WIDTH, oDlg:nHeight ;
      ON SIZE {|o, x, y|o:Move(, , x - TOOL_SIDE_WIDTH, y)} ;
      ON PAINT {||::PaintDoc(oCanvas)} STYLE SS_OWNERDRAW + WS_VSCROLL + WS_HSCROLL

   oCanvas:bVScroll := {||FScrollV(oCanvas)}
   oCanvas:bHScroll := {||FScrollH(oCanvas)}
   oCanvas:bOther := {|o, m, wp, lp|HB_SYMBOL_UNUSED(wp), IIf(m == WM_LBUTTONDBLCLK, MessProc(Self, o, lp), -1)}
   SET KEY FCONTROL, Asc("S") TO ::SaveScript()

   @ 3, 2 OWNERBUTTON oBtn ON CLICK {||hwg_EndDialog()} ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 TEXT cmExit FONT oFont  ;  // "Exit"
      TOOLTIP IIf(aTooltips != NIL, aTooltips[1], "Exit Preview")
   IF aBitmaps != NIL .AND. Len(aBitmaps) > 1 .AND. aBitmaps[2] != NIL
      oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBitmaps[2]), HBitmap():AddFile(aBitmaps[2]))
      oBtn:title := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 1, 31 LINE LENGTH TOOL_SIDE_WIDTH - 1

  IF ::lprbutton
   @ 3, 36 OWNERBUTTON oBtn  ON CLICK {||::PrintDoc()} ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 TEXT cmPrint FONT oFont         ;  // "Print"
      TOOLTIP IIf(aTooltips != NIL, aTooltips[2], "Print file")
  ENDIF

   IF aBitmaps != NIL .AND. Len(aBitmaps) > 2 .AND. aBitmaps[3] != NIL
      oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBitmaps[3]), HBitmap():AddFile(aBitmaps[3]))
      oBtn:title := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 62 COMBOBOX oSayPage ITEMS aPage ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 COLOR "fff000" backcolor 12507070 ;
      ON CHANGE {||::ChangePage(oCanvas, oSayPage, , oSayPage:GetValue()) } STYLE WS_VSCROLL

   @ 3, 86 OWNERBUTTON oBtn ON CLICK {||::ChangePage(oCanvas, oSayPage, 0)} ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 TEXT "|<<" FONT oFont                 ;
      TOOLTIP IIf(aTooltips != NIL, aTooltips[3], "First page")
   IF aBitmaps != NIL .AND. Len(aBitmaps) > 3 .AND. aBitmaps[4] != NIL
      oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBitmaps[4]), HBitmap():AddFile(aBitmaps[4]))
      oBtn:title := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 110 OWNERBUTTON oBtn ON CLICK {||::ChangePage(oCanvas, oSayPage, 1)} ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 TEXT ">" FONT oFont                  ;
      TOOLTIP IIf(aTooltips != NIL, aTooltips[4], "Next page")
   IF aBitmaps != NIL .AND. Len(aBitmaps) > 4 .AND. aBitmaps[5] != NIL
      oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBitmaps[5]), HBitmap():AddFile(aBitmaps[5]))
      oBtn:title := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 134 OWNERBUTTON oBtn ON CLICK {||::ChangePage(oCanvas, oSayPage, -1)} ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 TEXT "<" FONT oFont    ;
      TOOLTIP IIf(aTooltips != NIL, aTooltips[5], "Previous page")
   IF aBitmaps != NIL .AND. Len(aBitmaps) > 5 .AND. aBitmaps[6] != NIL
      oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBitmaps[6]), HBitmap():AddFile(aBitmaps[6]))
      oBtn:title := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 158 OWNERBUTTON oBtn ON CLICK {||::ChangePage(oCanvas, oSayPage, 2)} ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 TEXT ">>|" FONT oFont   ;
      TOOLTIP IIf(aTooltips != NIL, aTooltips[6], "Last page")
   IF aBitmaps != NIL .AND. Len(aBitmaps) > 6 .AND. aBitmaps[7] != NIL
      oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBitmaps[7]), HBitmap():AddFile(aBitmaps[7]))
      oBtn:title := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 1, 189 LINE LENGTH TOOL_SIDE_WIDTH - 1

   @ 3, 192 OWNERBUTTON oBtn ON CLICK {||IIf(::nZoom > 0, (::nZoom--, hwg_Redrawwindow(oCanvas:handle)), .T.)} ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 TEXT "(-)" FONT oFont   ;
      TOOLTIP IIf(aTooltips != NIL, aTooltips[7], "Zoom out")
   IF aBitmaps != NIL .AND. Len(aBitmaps) > 7 .AND. aBitmaps[8] != NIL
      oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBitmaps[8]), HBitmap():AddFile(aBitmaps[8]))
      oBtn:title := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 216 OWNERBUTTON oBtn ON CLICK {||::nZoom++, hwg_Redrawwindow(oCanvas:handle)} ;
      SIZE TOOL_SIDE_WIDTH - 6, 24 TEXT "(+)" FONT oFont   ;
      TOOLTIP IIf(aTooltips != NIL, aTooltips[8], "Zoom in")
   IF aBitmaps != NIL .AND. Len(aBitmaps) > 8 .AND. aBitmaps[9] != NIL
      oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBitmaps[9]), HBitmap():AddFile(aBitmaps[9]))
      oBtn:title := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 1, 243 LINE LENGTH TOOL_SIDE_WIDTH - 1

   IF aBootUser != NIL

      @ 1, 313 LINE LENGTH TOOL_SIDE_WIDTH - 1

      @ 3, 316 OWNERBUTTON oBtn ;
         SIZE TOOL_SIDE_WIDTH - 6, 24        ;
         TEXT IIf(Len(aBootUser) == 4, aBootUser[4], "User Button") ;
         FONT oFont                   ;
         TOOLTIP IIf(aBootUser[3] != NIL, aBootUser[3], "User Button")

      oBtn:bClick := aBootUser[1]

      IF aBootUser[2] != NIL
         oBtn:oBitmap := IIf(aBitmaps[1], HBitmap():AddResource(aBootUser[2]), HBitmap():AddFile(aBootUser[2]))
         oBtn:title := NIL
         oBtn:lTransp := lTransp
      ENDIF

   ENDIF

   oDlg:Activate()

   oFont:Release()
   IF !Empty(::hMeta)
      hwg_Deleteobject(::hMeta)
   ENDIF

   RETURN NIL

METHOD HPrinter:PaintDoc(oCanvas)

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors
   LOCAL nWidth
   LOCAL nHeight
   LOCAL nZoom
   LOCAL nShiftV := 0
   LOCAL nShiftH := 0

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint(oCanvas:handle, pps)
   aCoors := hwg_Getclientrect(oCanvas:handle)

   hwg_Fillrect(hDC, 0, 0, aCoors[3], aCoors[4], ::oBrush1:handle)
   IF !Empty(::hMeta)
      nWidth := aCoors[3] - 20
      IF (nHeight := Int(nWidth * (::nHeight / ::nWidth))) > aCoors[4] - 20
         nHeight := aCoors[4] - 20
         nWidth := Int(nHeight * (::nWidth / ::nHeight))
      ENDIF
      IF ::nZoom > 0
         nZoom := 1 + 0.25 * ::nZoom
         nWidth *= nZoom
         nHeight *= nZoom
      ELSE
         IF oCanvas:nScrollV != 0
            oCanvas:nScrollV := 0
            hwg_SetAdjOptions(oCanvas:hScrollV,, 11, 1, 1, 1)
         ENDIF
         IF oCanvas:nScrollH != 0
            oCanvas:nScrollH := 0
            hwg_SetAdjOptions(oCanvas:hScrollH,, 11, 1, 1, 1)
         ENDIF
      ENDIF
      ::x1 := IIf(aCoors[3] > nWidth, Int((aCoors[3] - nWidth) / 2), 0)
      ::y1 := IIf(aCoors[4] > nHeight, Int((aCoors[4] - nHeight) / 2), 0)
      ::x2 := ::x1 + nWidth - 1
      ::y2 := ::y1 + nHeight - 1
      hwg_Fillrect(hDC, ::x1, ::y1, Min(::x1 + nWidth,aCoors[3]), Min(aCoors[4], ::y1 + nHeight), ::oBrush2:handle)

      IF oCanvas:nScrollV > 0 .AND. aCoors[4] < nHeight
         nShiftV := - ((nHeight-aCoors[4]) * oCanvas:nScrollV/10)
      ENDIF
      IF oCanvas:nScrollH > 0 .AND. aCoors[3] < nWidth
         nShiftH := - ((nWidth-aCoors[3]) * oCanvas:nScrollH/10)
      ENDIF
      IF nShiftH != 0 .OR. nShiftV != 0
         hwg_cairo_translate(hDC, nShiftH, nShiftV)
      ENDIF

      hwg_Drawbitmap(hDC, ::hMeta, NIL, ::x1, ::y1, nWidth, nHeight)
   ENDIF

   hwg_Endpaint(oCanvas:handle, pps)

   RETURN NIL

METHOD HPrinter:PrintDoc()

   LOCAL nOper := 0
   LOCAL cExt

   IF !Empty(::cPrinterName) .AND. (cExt := Lower(FilExten(::cPrinterName))) $ "pdf;ps;png;svg;"
      nOper := IIf(cExt == "pdf", 1, IIf(cExt == "ps", 2,IIf(cExt == "png", 3, 4)))
   ENDIF
   /*
     nOper:
     0 - printer, 1 - pdf, 2 - ps, 3 - png, 4 - svg
   */
   // hwg_MsgInfo("nOper=" + Str(nOper))
   hwg_gp_Print(::hDC, ::aPages, Len(::aPages), nOper, ::cPrinterName)

   RETURN NIL

METHOD HPrinter:ChangePage(oCanvas, oSayPage, n, nPage)

   LOCAL nCurrPage := ::nCurrPage
   LOCAL cMetaName

   IF nPage == NIL
      IF n == 0
         ::nCurrPage := 1
      ELSEIF n == 2
         ::nCurrPage := Len(::aPages)
      ELSEIF n == 1 .AND. ::nCurrPage < Len(::aPages)
         ::nCurrPage ++
      ELSEIF n == - 1 .AND. ::nCurrPage > 1
         ::nCurrPage --
      ENDIF
      oSayPage:SetItem(::nCurrPage)
   ELSE
      ::nCurrPage := nPage
   ENDIF
   IF !(nCurrPage == ::nCurrPage)
      IF !Empty(::hMeta)
         hwg_Deleteobject(::hMeta)
      ENDIF
      cMetaName := "/tmp/i" + LTrim(Str(Int(Seconds()))) + ".png"
      hwg_gp_Print(::hDC, ::aPages, Len(::aPages), 3, cMetaName, ::nCurrPage)
      ::hMeta := hwg_Openimage(cMetaName)
      FErase(cMetaName)
      IF !Empty(oCanvas)
         hwg_Redrawwindow(oCanvas:handle)
      ENDIF
   ENDIF

   RETURN NIL

/*
 *  CLASS HGP_Font
 */

CLASS HGP_Font INHERIT HObject

   CLASS VAR aFonts INIT {}

   DATA name
   DATA height
   DATA weight
   DATA italic
   DATA Underline
   DATA nCounter INIT 1

   METHOD Add(fontName, nHeight , fnWeight, fdwItalic, fdwUnderline)
   METHOD Equal(fontName, nHeight , fnWeight, fdwItalic, fdwUnderline)
   METHOD RELEASE(lAll)

ENDCLASS

METHOD HGP_Font:Add(fontName, nHeight , fnWeight, fdwItalic, fdwUnderline)

   LOCAL i
   LOCAL nlen := Len(::aFonts)

   nHeight := IIf(nHeight == NIL, 13, Abs(nHeight))
   nHeight -= 1
   fnWeight := IIf(fnWeight == NIL, 0, fnWeight)
   fdwItalic := IIf(fdwItalic == NIL, 0, fdwItalic)
   fdwUnderline := IIf(fdwUnderline == NIL, 0, fdwUnderline)

   For i := 1 TO nlen
      IF ::aFonts[i]:Equal(fontName, nHeight, fnWeight, fdwItalic, fdwUnderline)
         ::aFonts[i]:nCounter ++
         Return ::aFonts[i]
      ENDIF
   NEXT

   ::name := fontName
   ::height := nHeight
   ::weight := fnWeight
   ::Italic := fdwItalic
   ::Underline := fdwUnderline

   AAdd(::aFonts, Self)

   RETURN Self

METHOD HGP_Font:Equal(fontName, nHeight , fnWeight, fdwItalic, fdwUnderline)

   IF ::name == fontName .AND.          ;
         ::height == nHeight .AND.         ;
         ::weight == fnWeight .AND.        ;
         ::Italic == fdwItalic .AND.       ;
         ::Underline == fdwUnderline

      RETURN .T.
   ENDIF

   RETURN .F.

METHOD HGP_Font:RELEASE(lAll)

   LOCAL i
   LOCAL nlen := Len(::aFonts)

   IF lAll != NIL .AND. lAll
      ::aFonts := {}
      RETURN NIL
   ENDIF
   ::nCounter --
   IF ::nCounter == 0
      For i := 1 TO nlen
         IF ::aFonts[i]:Equal(::name, ::height, ::weight, ::Italic, ::Underline)
            ADel(::aFonts, i)
            ASize(::aFonts, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN NIL

CLASS HGP_Pen INHERIT HObject

   CLASS VAR aPens INIT {}

   DATA style
   DATA width
   DATA color
   DATA nCounter INIT 1

   METHOD Add(nWidth, style, color)
   METHOD RELEASE()

ENDCLASS

METHOD HGP_Pen:Add(nWidth, style, color)

   LOCAL i

   nWidth := IIf(nWidth == NIL, 1, nWidth)
   style := IIf(style == NIL, 0, style)
   color := IIf(color == NIL, 0, color)

   FOR i := 1 TO Len(::aPens)
      IF ::aPens[i]:width == nWidth .AND. ::aPens[i]:style == style .AND. ::aPens[i]:color == color
         ::aPens[i]:nCounter ++
         Return ::aPens[i]
      ENDIF
   NEXT

   ::width := nWidth
   ::style := style
   ::color := color
   AAdd(::aPens, Self)

   RETURN Self

METHOD HGP_Pen:RELEASE()

   LOCAL i
   LOCAL nlen := Len(::aPens)

   ::nCounter --
   IF ::nCounter == 0
      FOR i := 1 TO nlen
         IF ::aPens[i]:width == ::width .AND. ::aPens[i]:style == ::style .AND. ::aPens[i]:color == ::color
            ADel(::aPens, i)
            ASize(::aPens, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

   RETURN NIL

STATIC FUNCTION FScrollV(oCanvas)

   oCanvas:nScrollV := hwg_getAdjValue(oCanvas:hScrollV)
   hwg_Redrawwindow(oCanvas:handle)

   RETURN NIL

STATIC FUNCTION FScrollH(oCanvas)

   oCanvas:nScrollH := hwg_getAdjValue(oCanvas:hScrollH)
   hwg_Redrawwindow(oCanvas:handle)

   RETURN NIL

STATIC FUNCTION MessProc(oPrinter, oPanel, lParam)

   LOCAL xPos
   LOCAL yPos
   LOCAL nPage := oPrinter:nCurrPage
   LOCAL arr
   LOCAL i
   LOCAL j
   LOCAL nPos
   LOCAL x1
   LOCAL y1
   LOCAL x2
   LOCAL y2
   LOCAL cTemp
   LOCAL cl
   LOCAL nHRes
   LOCAL nVRes

   xPos := hwg_Loword(lParam)
   yPos := hwg_Hiword(lParam)

   nHRes := (oPrinter:x2 - oPrinter:x1) / oPrinter:nWidth
   nVRes := (oPrinter:y2 - oPrinter:y1) / oPrinter:nHeight

   arr := hb_aTokens(oPrinter:aPages[nPage], s_crlf)
   FOR i := 1 TO Len(arr)
      nPos := 0
      IF hb_TokenPtr(arr[i], @nPos, ",") == "txt"
         x1 := Round(Val(hb_TokenPtr(arr[i], @nPos, ",")) * nHRes / IIf(oPrinter:lmm, oPrinter:nHRes, 1), 0) + oPrinter:x1
         y1 := Round(Val(hb_TokenPtr(arr[i], @nPos, ",")) * nVRes / IIf(oPrinter:lmm, oPrinter:nVRes, 1), 0) + oPrinter:y1
         x2 := Round(Val(hb_TokenPtr(arr[i], @nPos, ",")) * nHRes / IIf(oPrinter:lmm, oPrinter:nHRes, 1), 0) + oPrinter:x1
         y2 := Round(Val(hb_TokenPtr(arr[i], @nPos, ",")) * nVRes / IIf(oPrinter:lmm, oPrinter:nVRes, 1), 0) + oPrinter:y1
         IF xPos >= x1 .AND. xPos <= x2 .AND. yPos >= y1 .AND. yPos <= y2
            EXIT
         ENDIF
      ENDIF
   NEXT
   IF i <= Len(arr)
      hb_TokenPtr(arr[i], @nPos, ",")

      cl := hwg_SetAppLocale("UTF-8")
      cTemp := hwg_MsgGet("", , ES_AUTOHSCROLL, , , DS_CENTER, SubStr(arr[i], nPos + 1))
      hwg_SetAppLocale(cl)
      IF !Empty(cTemp) .AND. !(cTemp == SubStr(arr[i], nPos + 1))
         oPrinter:aPages[nPage] := ""
         FOR j := 1 TO Len(arr)
            IF j != i
               oPrinter:aPages[nPage] += arr[j] + s_crlf
            ELSE
               oPrinter:aPages[nPage] += Left(arr[j], nPos) + cTemp + s_crlf
            ENDIF
         NEXT
         hwg_Redrawwindow(oPanel:handle)
      ENDIF
   ENDIF

Return 1
