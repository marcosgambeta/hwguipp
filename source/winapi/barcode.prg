//
// Create Barcode for HWGUI application
//
// see example at utils\designer\samples\barcode.xml
//
// Copyright 2006 Richard Roesnadi <roesnadi8@yahoo.co.id>
//

#include <hbclass.ch>
#include "hwguipp.ch"

//#define __DEVELOP__

#ifdef __DEVELOP__

   #define CODE39          1
   #define CODE39CHECK     2
   #define CODE128AUTO     3
   #define CODE128A        4
   #define CODE128B        5
   #define CODE128C        6
   #define EAN8            7
   #define EAN13           8
   #define UPCA            9
   #define CODABAR         10
   #define SUPLEMENTO5     11
   #define INDUST25        12
   #define INDUST25CHECK   13
   #define INTER25         14
   #define INTER25CHECK    15
   #define MATRIX25        16
   #define MATRIX25CHECK   17

   #xcommand DEFAULT < v1 > := < x1 >  => IF < v1 > == NIL ; < v1 > := < x1 > ; END

#xcommand @ < nTop >, < nLeft > BARCODE < oBC >   ;
[DEVICE <hDC>                ] ;
< label: PROMPT, VAR > < cText >   ;
Type < nBCodeType >              ;
[ SIZE <nWidth>, <nHeight>   ] ;
[ COLORTEXT <nColText>       ] ;
[ COLORPANE <nColPane>       ] ;
[ PINWIDTH <nPinWidth>       ] ;
[ VERTICAL <lVert>           ] ;
[ TRANSPARENT <lTransparent> ] ;
=> ;
< oBC > := Barcode():New([ <hDC> ], < cText >, < nTop >, < nLeft >, ;
                         [ <nWidth>       ], [ <nHeight>   ], [ <nBCodeType> ], ;
                         [ <nColText>     ], [ <nColPane>  ], [ !<lVert>     ], ;
                         [ <lTransparent> ], [ <nPinWidth> ])

//------------------------------------------------------------------------------
#xcommand SHOWBARCODE < oBC > => < oBC > :ShowBarcode()

FUNCTION Main()

   LOCAL oMainWindow
   LOCAL oFont
   LOCAL oEdit1
   LOCAL oEdit2
   LOCAL oBC
   LOCAL nTop
   LOCAL nLeft
   LOCAL nWidth
   LOCAL nHeight
   LOCAL nBCodeType
   LOCAL nColText
   LOCAL nColPane
   LOCAL lHorz
   LOCAL lTransparent
   LOCAL nPinWidth

   PREPARE FONT oFont NAME "MS Sans Serif" WIDTH 0 HEIGHT -13

   INIT WINDOW oMainWindow TITLE "Barcode" COLOR COLOR_3DLIGHT + 1 At 200, 0 SIZE 420, 300 FONT oFont ON PAINT {||oBC:showBarcode()}

   @ 20, 113 EDITBOX oEdit2 CAPTION "Example" SIZE 24, 130

   //@5, 5 BARCODE oBC VAR "000000000001" TYPE EAN13
   //SHOWBARCODE oBC

   nTop := 15
   nLeft := 5
   nBCodeType := 8
   lHorz := .T.
   lTransparent := .F.
   nPinWidth := 1

   nWidth := 200
   nHeight := 40

   oBC := Barcode():New(hwg_Getdc(oMainWindow:handle), "993198042124", nTop, nLeft, nWidth, nHeight, nBCodeType, nColText, nColPane, lHorz, lTransparent, nPinWidth)

   @ 163, 10 EDITBOX oEdit1 CAPTION oBC:InitEAN13() SIZE 100, 20

   ACTIVATE WINDOW oMainWindow

RETURN NIL

#endif

//-- CLASS DEFINITION ---------------------------------------------------------
//         Name: Barcode
//  Description:
//-----------------------------------------------------------------------------
CLASS Barcode

   DATA hDC           // handle of the window, dialog or printer object
   DATA cText         // barcode text
   DATA nTop          // top position
   DATA nLeft         // left position
   DATA nWidth        // barcode width
   DATA nHeight       // barcode height
   DATA nColText      // pin color
   DATA nColPane      // background color
   DATA lHorizontal   // horizontal (.T.) or vertical (.F.)
   DATA lTransparent  // transparent or not
   DATA nPinWidth     // barcode pin width
   DATA nBCodeType    // Barcode type:
   //  1  = Code 39
   //  2  = Code 39 check digit
   //  3  = Code 128 auto select
   //  4  = Code 128 mode A
   //  5  = Code 128 mode B
   //  6  = Code 128 mode C
   //  7  = EAN 8
   //  8  = EAN 13
   //  9  = UPC-A
   //  10 = Codabar
   //  11 = Suplemento 5
   //  12 = Industrial 2 of 5
   //  13 = Industrial 2 of 5 check digit
   //  14 = Interlaved 2 of 5
   //  15 = Interlaved 2 of 5 check digit
   //  16 = Matrix 2 of 5
   //  17 = Matrix 2 of 5 check digit

   METHOD New(hDC, cText, nTop, nLeft, nWidth, nHeight, nBCodeType, nColText, nColPane, lHorz, lTransparent, nPinWidth) CONSTRUCTOR
   METHOD ShowBarcode()
   METHOD CreateBarcode(cCode)
   METHOD InitCode39(lCheck)
   METHOD InitCode128(cMode)
   METHOD InitEAN13()
   METHOD InitUPC(nLen)
   METHOD InitE13BL(nLen)
   METHOD InitCodabar()
   METHOD InitSub5()
   METHOD InitIndustrial25(lCheck)
   METHOD InitInterleave25(lMode)
   METHOD InitMatrix25(lCheck)

ENDCLASS

//-- METHOD -------------------------------------------------------------------
//         Name: New
//  Description:
//-----------------------------------------------------------------------------

METHOD Barcode:New(hDC, cText, nTop, nLeft, nWidth, nHeight, nBCodeType, nColText, nColPane, lHorz, lTransparent, nPinWidth)

   DEFAULT nWidth := 200
   DEFAULT nHeight := 20
   DEFAULT nColText := 0
   DEFAULT nColPane := 0xFFFFFF // hwg_ColorRgb2N(255, 255, 255)
   DEFAULT lHorz := .T.
   DEFAULT lTransparent := .F.
   DEFAULT nPinWidth := 1
   // DEFAULT hDC := hwg_Getdc(hwg_Getactivewindow())

   ::hDC := hDC
   ::cText := cText
   ::nTop := nTop
   ::nLeft := nLeft
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::nBCodeType := nBCodeType
   ::nColText := nColText
   ::nColPane := nColPane
   ::lHorizontal := lHorz
   ::lTransparent := lTransparent
   ::nPinWidth := nPinWidth

RETURN Self


//-- METHOD -------------------------------------------------------------------
//         Name: ShowBarcode
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:ShowBarcode()

   LOCAL cCode
   LOCAL cCode2

   SWITCH ::nBCodeType
   CASE  1 ; cCode := ::InitCode39(.F.)                         ; EXIT
   CASE  2 ; cCode := ::InitCode39(.T.)                         ; EXIT
   CASE  3 ; cCode := ::InitCode128("")                         ; EXIT
   CASE  4 ; cCode := ::InitCode128("A")                        ; EXIT
   CASE  5 ; cCode := ::InitCode128("B")                        ; EXIT
   CASE  6 ; cCode := ::InitCode128("C")                        ; EXIT
   CASE  7 ; cCode := ::InitUPC(7)  ; cCode2 := ::InitE13BL(8)  ; EXIT
   CASE  8 ; cCode := ::InitEAN13()                             ; EXIT
   CASE  9 ; cCode := ::InitUPC(11) ; cCode2 := ::InitE13BL(12) ; EXIT
   CASE 10 ; cCode := ::InitCodabar()                           ; EXIT
   CASE 11 ; cCode := ::InitSub5()                              ; EXIT
   CASE 12 ; cCode := ::InitIndustrial25(.F.)                   ; EXIT
   CASE 13 ; cCode := ::InitIndustrial25(.T.)                   ; EXIT
   CASE 14 ; cCode := ::InitInterleave25(.F.)                   ; EXIT
   CASE 15 ; cCode := ::InitInterleave25(.T.)                   ; EXIT
   CASE 16 ; cCode := ::InitMatrix25(.F.)                       ; EXIT
   CASE 17 ; cCode := ::InitMatrix25(.T.)                       ; EXIT
   OTHERWISE
      cCode := ::InitCode39(.T.)
   ENDSWITCH

   ::CreateBarcode(cCode)

   IF ::nBCodeType == 7 .OR. ::nBCodeType == 9
      ::CreateBarcode(cCode2)
   ENDIF

RETURN NIL


//-- METHOD -------------------------------------------------------------------
//         Name: CreateBarcode
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:CreateBarcode(cCode)

   LOCAL i
   LOCAL hPen
   LOCAL hOldPen
   LOCAL hBrush
   LOCAL hOldBrush
   LOCAL nX := ::nTop
   LOCAL nY := ::nLeft

   //nX := ::nLeft
   //nY := ::nTop

   IF !::lTransparent .AND. ::nColPane != 0xFFFFFF // hwg_ColorRgb2N(255, 255, 255)

      IF !::lHorizontal
         RICH_Rectangle(::hDC, nX, nY, nX + ::nHeight, nY + Min(Len(cCode) * ::nPinWidth, ::nWidth))
      ELSE
         RICH_Rectangle(::hDC, nX, nY, nX + Min(Len(cCode) * ::nPinWidth, ::nWidth), nY + ::nHeight)
      ENDIF

   ENDIF

   hPen := Rich_CreatePen(NIL, NIL, ::nColText)
   hOldPen := Rich_SelectObject(::hDC, hPen)
   hBrush := Rich_CreateSolidBrush(::nColText)
   hOldBrush := Rich_SelectObject(::hDC, hBrush)

   IIf(::nPinWidth < 1, ::nPinWidth := 1, NIL)

   FOR EACH i IN cCode

      IF i == "1"
         IF !::lHorizontal
            RICH_Rectangle(::hDC, nX, nY, nX + ::nHeight, (nY += ::nPinWidth))
            // RICH_Rectangle(::hDC, nX, nY, nX + ::nWidth, (nY += ::nPinWidth))
         ELSE
            // RICH_Rectangle(::hDC, nX, nY, (nX += ::nPinWidth), nY + ::nWidth)
            RICH_Rectangle(::hDC, nX, nY, (nX += ::nPinWidth), nY + ::nHeight)
         ENDIF
      ELSE
         IF !::lHorizontal
            nY += ::nPinWidth
         ELSE
            nX += ::nPinWidth
         ENDIF
      ENDIF

   NEXT

   /*
   FOR i := 1 TO LEN(cCode)

      IF SUBSTR(cCode, i, 1) = "1"
         IF ::lHorizontal == .T.
            hwg_Rectangle(::hDC, nX, nY, nX + ::nHeight, (nY += ::nPinWidth))
         ELSE
            hwg_Rectangle(::hDC, nX, nY, (nX += ::nPinWidth), nY + ::nWidth)
         ENDIF
      ELSE
         IF ::lHorizontal == .T.
            nY += ::nPinWidth
         ELSE
            nX += ::nPinWidth
         ENDIF
      ENDIF

   NEXT
   */

   Rich_SelectObject(::hDC, hOldPen)
   hwg_Deleteobject(hPen)
   Rich_SelectObject(::hDC, hOldBrush)
   hwg_Deleteobject(hBrush)

RETURN NIL

//-- METHOD -------------------------------------------------------------------
//         Name: InitCode39
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitCode39(lCheck)

   LOCAL cCars := "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ-. *$/+%"
   LOCAL aBarras := { ;
      "1110100010101110", ; // 1
      "1011100010101110", ; // 2
      "1110111000101010", ; // 3
      "1010001110101110", ; // 4
      "1110100011101010", ; // 5
      "1011100011101010", ; // 6
      "1010001011101110", ; // 7
      "1110100010111010", ; // 8
      "1011100010111010", ; // 9
      "1010001110111010", ; // 0
      "1110101000101110", ; // A
      "1011101000101110", ; // B
      "1110111010001010", ; // C
      "1010111000101110", ; // D
      "1110101110001010", ; // E
      "1011101110001010", ; // F
      "1010100011101110", ; // G
      "1110101000111010", ; // H
      "1011101000111010", ; // I
      "1010111000111010", ; // J
      "1110101010001110", ; // K
      "1011101010001110", ; // L
      "1110111010100010", ; // M
      "1010111010001110", ; // N
      "1110101110100010", ; // O
      "1011101110100010", ; // p
      "1010101110001110", ; // Q
      "1110101011100010", ; // R
      "1011101011100010", ; // S
      "1010111011100010", ; // T
      "1110001010101110", ; // U
      "1000111010101110", ; // V
      "1110001110101010", ; // W
      "1000101110101110", ; // X
      "1110001011101010", ; // Y
      "1000111011101010", ; // Z
      "1000101011101110", ; // -
      "1110001010111010", ; // .
      "1000111010111010", ; // " "
      "1000101110111010", ; // *
      "1000100010100010", ; // $
      "1000100010100010", ; // /
      "1000101000100010", ; // +
      "1010001000100010" }  // %
   LOCAL cCar
   LOCAL m
   LOCAL n
   LOCAL cBarra := ""
   LOCAL cCode := ::cText
   LOCAL nCheck := 0

   DEFAULT lCheck := .F.

   cCode := Upper(cCode)

   IF Len(cCode) > 32
      cCode := Left(cCode, 32)
   ENDIF

   cCode := "*" + cCode + "*"

   FOR n := 1 TO Len(cCode)
      cCar := SubStr(cCode, n, 1)
      m := At(cCar, cCars)
      IF n > 0 // TODO: verificar
         cBarra := cBarra + aBarras[m]
         nCheck += (m - 1)
      END
   NEXT

   IF lCheck == .T.
      cBarra += aBarras[nCheck % 43 + 1]
   END

RETURN cBarra


//-- METHOD -------------------------------------------------------------------
//         Name: InitCode128
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitCode128(cMode)

   LOCAL aCode := { ;
         "212222", "222122", "222221", "121223", "121322", "131222", ;
         "122213", "122312", "132212", "221213", "221312", "231212", ;
         "112232", "122132", "122231", "113222", "123122", "123221", ;
         "223211", "221132", "221231", "213212", "223112", "312131", ;
         "311222", "321122", "321221", "312212", "322112", "322211", ;
         "212123", "212321", "232121", "111323", "131123", "131321", ;
         "112313", "132113", "132311", "211313", "231113", "231311", ;
         "112133", "112331", "132131", "113123", "113321", "133121", ;
         "313121", "211331", "231131", "213113", "213311", "213131", ;
         "311123", "311321", "331121", "312113", "312311", "332111", ;
         "314111", "221411", "431111", "111224", "111422", "121124", ;
         "121421", "141122", "141221", "112214", "112412", "122114", ;
         "122411", "142112", "142211", "241211", "221114", "213111", ;
         "241112", "134111", "111242", "121142", "121241", "114212", ;
         "124112", "124211", "411212", "421112", "421211", "212141", ;
         "214121", "412121", "111143", "111341", "131141", "114113", ;
         "114311", "411113", "411311", "113141", "114131", "311141", ;
         "411131", "211412", "211214", "211232", "2331112" }
   LOCAL cBarra
   LOCAL cCar
   LOCAL cTemp
   LOCAL n
   LOCAL nCar
   LOCAL cCode := ::cText
   LOCAL lCodeC := .F.
   LOCAL lCodeA := .F.
   LOCAL nSum := 0
   LOCAL nCount := 0

   // Errors
   IF !HB_ISCHAR(cCode)
      hwg_MsgInfo("Barcode Code 128 requires a character value.")
      RETURN NIL
   ENDIF

   IF !Empty(cMode)
      IF HB_ISCHAR(cMode) .AND. Upper(cMode) $ "ABC"
         cMode := Upper(cMode)
      ELSE
         hwg_MsgInfo("Code 128 modes are A, B o C. Character values.")
      ENDIF
   ENDIF

   IF Empty(cMode)
      // autodetect mode
      IF Str(Val(cCode), Len(cCode)) = cCode
         lCodeC := .T.
         cTemp := aCode[106]
         nSum := 105
      ELSE
         FOR EACH n IN cCode
            nCount += IIF(Asc(n) > 31, 1, 0) // no cars. de control
         NEXT
         IF nCount < Len(cCode) / 2
            lCodeA := .T.
            cTemp := aCode[104]
            nSum := 103
         ELSE
            cTemp := aCode[105]
            nSum := 104
         ENDIF
      ENDIF
   ELSE
      SWITCH cMode
      CASE "C"
         lCodeC := .T.
         cTemp := aCode[106]
         nSum := 105
         EXIT
      CASE "A"
         lCodeA := .T.
         cTemp := aCode[104]
         nSum := 103
         EXIT
      OTHERWISE
         cTemp := aCode[105]
         nSum := 104
      ENDSWITCH
   ENDIF

   // caracter registrado
   nCount := 0

   FOR n := 1 TO Len(cCode)

      nCount++
      cCar := SubStr(cCode, n, 1)

      IF lCodeC
         IF Len(cCode) == n                        // ultimo caracter
            cTemp += aCode[101]                 // SHIFT Code B
            nCar := Asc(cCar) - 31
         ELSE
            nCar := Val(SubStr(cCode, n, 2)) + 1
            n++
         ENDIF
      ELSEIF lCodeA
         IF cCar > "_"                           // Shift Code B
            cTemp += aCode[101]
            nCar := Asc(cCar) - 31
         ELSEIF cCar <= " "
            nCar := Asc(cCar) + 64
         ELSE
            nCar := Asc(cCar) - 31
         ENDIF
      ELSE                                      // code B standard
         IF cCar <= " "                         // shift code A
            cTemp += aCode[102]
            nCar := Asc(cCar) + 64
         ELSE
            nCar := Asc(cCar) - 31
         ENDIF
      ENDIF

      nSum += (nCar - 1) * nCount
      cTemp := cTemp + aCode[nCar]

   NEXT

   nSum := nSum % 103 + 1
   cTemp := cTemp + aCode[nSum] + aCode[107]
   cBarra := ""

   FOR n := 1 TO Len(cTemp) STEP 2
      cBarra += Replicate("1", Val(SubStr(cTemp, n, 1)))
      cBarra += Replicate("0", Val(SubStr(cTemp, n + 1, 1)))
   NEXT

RETURN cBarra


//-- METHOD -------------------------------------------------------------------
//         Name: InitEAN13
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitEAN13()

   LOCAL derecha := "1110010110011011011001000010101110010011101010000100010010010001110100"
   LOCAL izda1 := "0001101001100100100110111101010001101100010101111011101101101110001011"
   LOCAL izda2 := "0100111011001100110110100001001110101110010000101001000100010010010111"
   LOCAL primero := "ooooooooeoeeooeeoeooeeeooeooeeoeeooeoeeeoooeoeoeoeoeeooeeoeo"
   LOCAL l
   LOCAL s1
   LOCAL s2
   LOCAL control
   LOCAL n
   LOCAL cadena
   LOCAL Numero
   LOCAL Izda
   LOCAL Dcha
   LOCAL String
   LOCAL Mascara
   LOCAL k
   LOCAL cCode := ::cText

   k := Left(AllTrim(cCode) + "000000000000", 12) // padding with "0"

   // calculo del digito de control
   // suma de impares
   s1 := 0
   // suma de pares
   s2 := 0

   FOR n := 1 TO 6
      s1 := s1 + Val(SubStr(k, (n * 2) - 1, 1))
      s2 := s2 + Val(SubStr(k, (n * 2), 1))
   NEXT

   control := (s2 * 3) + s1
   l := 10
   DO WHILE control > l
      l := l + 10
   ENDDO

   control := l - control
   k := k + Str(control, 1, 0)

   // preparacion de la cadena de impresion

   Dcha := SubStr(k, 8, 6)
   Izda := SubStr(k, 2, 6)
   Mascara := SubStr(primero, (Val(SubStr(k, 1, 1)) * 6) + 1, 6)

   // barra de delimitacion
   cadena := [101]

   // parte izda
   FOR n := 1 TO 6
      Numero := Val(SubStr(Izda, n, 1))
      IF SubStr(Mascara, n, 1) = [o]
         String := SubStr(izda1, Numero * 7 + 1, 7)
      ELSE
         String := SubStr(izda2, Numero * 7 + 1, 7)
      ENDIF
      cadena := cadena + String
   NEXT

   cadena := cadena + [01010]

   // Lado derecho
   FOR n := 1 TO 6
      Numero := Val(SubStr(Dcha, n, 1))
      String := SubStr(derecha, Numero * 7 + 1, 7)
      cadena := cadena + String
   NEXT

   cadena := cadena + [101]

RETURN cadena


//-- METHOD -------------------------------------------------------------------
//         Name: InitUPC
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitUPC(nLen)

   LOCAL derecha := "1110010110011011011001000010101110010011101010000100010010010001110100"
   LOCAL izda1 := "0001101001100100100110111101010001101100010101111011101101101110001011"
   LOCAL l
   LOCAL s1
   LOCAL s2
   LOCAL control
   LOCAL n
   LOCAL cadena
   LOCAL Numero
   LOCAL Izda
   LOCAL Dcha
   LOCAL k
   LOCAL cCode := ::cText

   // valid values for nLen are 11,7
   k := Left(AllTrim(cCode) + "000000000000", nLen) // padding with "0"
   // calculo del digito de control
   // suma de impares
   s1 := 0
   // suma de pares
   s2 := 0

   FOR n := 1 TO nLen STEP 2
      s1 := s1 + Val(SubStr(k, n, 1))
      s2 := s2 + Val(SubStr(k, n + 1, 1))
   NEXT

   control := (s1 * 3) + s2
   l := 10
   DO WHILE control > l
      l := l + 10
   ENDDO

   control := l - control
   k := k + Str(control, 1, 0)
   nLen++

   // preparacion de la cadena de impresion
   cadena := []
   Dcha := Right(k, nLen / 2)
   Izda := Left(k, nLen / 2)

   // barra de delimitacion
   cadena := [101]
   // parte izda
   FOR n := 1 TO nLen / 2
      Numero := Val(SubStr(Izda, n, 1))
      cadena += SubStr(izda1, Numero * 7 + 1, 7)
   NEXT

   cadena := cadena + [01010]

   // Lado derecho
   FOR n := n TO Len(k)
      Numero := Val(SubStr(Dcha, n, 1))
      cadena += SubStr(derecha, Numero * 7 + 1, 7)
   NEXT

   cadena := cadena + [101]

RETURN cadena


//-- METHOD -------------------------------------------------------------------
//         Name: InitE13BL
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitE13BL(nLen)

   nLen := Int(nLen / 2)

RETURN "101" + Replicate("0", nLen * 7) + "01010" + Replicate("0", nLen * 7) + "101"


//-- METHOD -------------------------------------------------------------------
//         Name: InitCodabar
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitCodabar()

   //this system not test the start/end code

   LOCAL cChar := "0123456789-$:/.+ABCDTN*E"
   LOCAL abar := { ;
         "101010001110", "101011100010", "101000101110", "111000101010", ;
         "101110100010", "111010100010", "100010101110", "100010111010", ;
         "100011101010", "111010001010", "101000111010", "101110001010", ;
         "11101011101110", "11101110101110", "11101110111010", "10111011101110", ;
         "10111000100010", "10001000101110", "10100011100010", "10111000100010", ;
         "10001000101110", "10100010001110", "10100011100010" }
   LOCAL n
   LOCAL nCar
   LOCAL cBarra := ""
   LOCAL cCode := Upper(::cText)

   FOR n := 1 TO Len(cCode)
      IF (nCar := At(SubStr(cCode, n, 1), cChar)) > 0
         cBarra += abar[nCar]
      ENDIF
   NEXT

RETURN cBarra


//-- METHOD -------------------------------------------------------------------
//         Name: InitSup5
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitSub5()

   LOCAL izda1 := "0001101001100100100110111101010001101100010101111011101101101110001011"
   LOCAL izda2 := "0100111011001100110110100001001110101110010000101001000100010010010111"
   LOCAL primero := "ooooooooeoeeooeeoeooeeeooeooeeoeeooeoeeeoooeoeoeoeoeeooeeoeo"
   // LOCAL parity := "eeoooeoeooeooeoeoooeoeeooooeeooooeeoeoeooeooeooeoe"
   LOCAL k
   LOCAL control
   LOCAL n
   LOCAL nCar
   LOCAL cCode := ::cText
   LOCAL cBarras := "1011"

   k := Left(AllTrim(cCode) + "00000", 5) // padding with "0"

   control := Right(Str(Val(SubStr(k, 1, 1)) * 3 + Val(SubStr(k, 3, 1)) * 3 + ;
                        Val(SubStr(k, 5, 1)) * 3 + Val(SubStr(k, 2, 1)) * 9 + ;
                        Val(SubStr(k, 4, 1)) * 9, 5, 0), 1)
   control := SubStr(primero, Val(control) * 6 + 2, 5)

   FOR n := 1 TO 5
      nCar := Val(SubStr(k, n, 1))
      IF SubStr(control, n, 1) = "o"
         cBarras += SubStr(izda2, nCar * 7 + 1, 7)
      ELSE
         cBarras += SubStr(izda1, nCar * 7 + 1, 7)
      ENDIF
      IF n < 5
         cBarras += "01"
      ENDIF
   NEXT

RETURN cBarras


//-- METHOD -------------------------------------------------------------------
//         Name: InitIndustrial25
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitIndustrial25(lCheck)

   LOCAL n
   LOCAL aBar := {"00110", "10001", "01001", "11000", "00101", "10100", "01100", "00011", "10010", "01010"}
   LOCAL cInStart := "110" // industrial 2 of 5 start
   LOCAL cInStop := "101" // industrial 2 of 5 stop
   LOCAL cBar := ""
   LOCAL cBarra := ""
   LOCAL nCheck := 0
   LOCAL cCode := trans(::cText, "@9") // only digits

   DEFAULT lCheck := .F.

   IF lCheck
      FOR n := 1 TO Len(cCode) STEP 2
         nCheck += Val(SubStr(cCode, n, 1)) * 3 + Val(SubStr(cCode, n + 1, 1))
      NEXT
      cCode += Right(Str(nCheck, 10, 0), 1)
   ENDIF

   cBar := cInStart

   FOR n := 1 TO Len(cCode)
      cBar += aBar[Val(SubStr(cCode, n, 1)) + 1] + "0"
   NEXT

   cBar += cInStop

   FOR n := 1 TO Len(cBar)
      IF SubStr(cBar, n, 1) = "1"
         cBarra += "1110"
      ELSE
         cBarra += "10"
      ENDIF
   NEXT

RETURN cBarra


//-- METHOD -------------------------------------------------------------------
//         Name: InitInterleave25
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitInterleave25(lMode)

   LOCAL n
   LOCAL m
   LOCAL aBar := {"00110", "10001", "01001", "11000", "00101", "10100", "01100", "00011", "10010", "01010"}
   LOCAL cStart := "0000"
   LOCAL cStop := "100"
   LOCAL cBar := ""
   LOCAL cIz
   LOCAL cBarra := ""
   LOCAL cDer
   LOCAL nLen
   LOCAL nCheck := 0
   LOCAL cCode := trans(::cText, "@9") // only digits

   DEFAULT lMode := .F.

   nLen := Len(cCode)
   IF (nLen % 2 == 1 .AND. !lMode)
      nLen++
      cCode += "0"
   ENDIF
   IF lMode
      FOR n := 1 TO Len(cCode) STEP 2
         nCheck += Val(SubStr(cCode, n, 1)) * 3 + Val(SubStr(cCode, n + 1, 1))
      NEXT
      cCode += Right(Str(nCheck, 10, 0), 1)
   ENDIF

   cBarra := cStart

   // preencoding .. interlaving
   FOR n := 1 TO nLen STEP 2
      cIz := aBar[Val(SubStr(cCode, n, 1)) + 1]
      cDer := aBar[Val(SubStr(cCode, n + 1, 1)) + 1]
      FOR m := 1 TO 5
         cBarra += SubStr(cIz, m, 1) + SubStr(cDer, m, 1)
      NEXT
   NEXT

   cBarra += cStop

   FOR n := 1 TO Len(cBarra) STEP 2
      IF SubStr(cBarra, n, 1) = "1"
         cBar += "111"
      ELSE
         cBar += "1"
      ENDIF
      IF SubStr(cBarra, n + 1, 1) = "1"
         cBar += "000"
      ELSE
         cBar += "0"
      ENDIF
   NEXT

RETURN cBar


//-- METHOD -------------------------------------------------------------------
//         Name: InitIndust25
//  Description:
//-----------------------------------------------------------------------------
METHOD Barcode:InitMatrix25(lCheck)

   LOCAL n
   LOCAL aBar := {"00110", "10001", "01001", "11000", "00101", "10100", "01100", "00011", "10010", "01010"}
   LOCAL cMtSt := "10000" // matrix start/stop
   LOCAL cBar := ""
   LOCAL cBarra := ""
   LOCAL nCheck := 0
   LOCAL cCode := trans(::cText, "@9") // only digits

   DEFAULT lCheck := .F.

   IF lCheck
      FOR n := 1 TO Len(cCode) STEP 2
         nCheck += Val(SubStr(cCode, n, 1)) * 3 + Val(SubStr(cCode, n + 1, 1))
      NEXT
      cCode += Right(Str(nCheck, 10, 0), 1)
   ENDIF

   cBar := cMtSt

   FOR n := 1 TO Len(cCode)
      cBar += aBar[Val(SubStr(cCode, n, 1)) + 1] + "0"
   NEXT

   cBar += cMtSt

   FOR n := 1 TO Len(cBar) STEP 2
      IF SubStr(cBar, n, 1) = "1"
         cBarra += "111"
      ELSE
         cBarra += "1"
      ENDIF
      IF SubStr(cBar, n + 1, 1) = "1"
         cBarra += "000"
      ELSE
         cBarra += "0"
      ENDIF
   NEXT

RETURN cBarra

#pragma BEGINDUMP

#include "hwingui.hpp"

/*
RICH_RECTANGLE(hDC, nLeft, nTop, nRight, nBottom) --> .T.|.F.
*/
HB_FUNC_STATIC(RICH_RECTANGLE)
{
   hb_retl(Rectangle(hwg_par_HDC(1), hwg_par_int(2), hwg_par_int(3), hwg_par_int(4), hwg_par_int(5)));
}

/*
RICH_CREATEPEN(nStyle, nWidth, nColor) --> hPen
*/
HB_FUNC_STATIC(RICH_CREATEPEN)
{
   hb_retptr(CreatePen(hwg_par_int(1), hwg_par_int(2), hwg_par_COLORREF(3)));
}

/*
RICH_SELECTOBJECT(hDC, hGdiObj) --> hGdiObj
*/
HB_FUNC_STATIC(RICH_SELECTOBJECT)
{
   hb_retptr(SelectObject(hwg_par_HDC(1), hwg_par_HGDIOBJ(2)));
}

/*
RICH_CREATESOLIDBRUSH(nColor) --> hBrush
*/
HB_FUNC_STATIC(RICH_CREATESOLIDBRUSH)
{
   hb_retptr(CreateSolidBrush(hwg_par_COLORREF(1)));
}

#pragma ENDDUMP
