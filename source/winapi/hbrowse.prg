/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HBrowse class - browse databases and arrays
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

   // Modificaciones y Agregados. 27.07.2002, WHT.de la Argentina ///////////////
   // 1) En el metodo HColumn se agregaron las DATA: "nJusHead" y "nJustLin",  //
   //    para poder justificar los encabezados de columnas y tambien las       //
   //    lineas. Por default es DT_LEFT                                        //
   //    0-DT_LEFT, 1-DT_RIGHT y 2-DT_CENTER. 27.07.2002. WHT.                 //
   // 2) Ahora la variable "cargo" del metodo Hbrowse si es codeblock          //
   //    ejectuta el CB. 27.07.2002. WHT                                       //
   // 3) Se agreg¢ el Metodo "ShowSizes". Para poder ver la "width" de cada    //
   //    columna. 27.07.2002. WHT.                                             //
   //////////////////////////////////////////////////////////////////////////////
   // Translation from spanish to english by DF7BE
   //////////////////////////////////////////////////////////////////////////////
   // Modifications and additions. 27.07.2002, WHT.de la Argentina //////////////
   // 1) In the HColumn method, added the DATA "nJusHead" and "nJustLin",      //
   //    to be able to justify the column headings and also the lines.         //
   //    Default is DT_LEFT.                                                   //
   //    0-DT_LEFT, 1-DT_RIGHT y 2-DT_CENTER. 27.07.2002. WHT.                 //
   // 2) Variable "cargo" from the method Hbrowse:  Now it's codeblock is      //
   //    executed in the CB.  27.07.2002. WHT                                  //
   // 3) Method added "ShowSizes". In order to see the "width" of each         //
   //    column. 27.07.2002. WHT.                                              //
   //////////////////////////////////////////////////////////////////////////////

#include "hwgui.ch"
#include "inkey.ch"
#include "dbinfo.ch"
#include "dbstruct.ch"
#include "hbclass.ch"

#ifdef __XHARBOUR__
#xtranslate hb_tokenGet([<x>,<n>,<c>] ) =>  __StrToken(<x>,<n>,<c>)
#xtranslate hb_tokenPtr([<x>,<n>,<c>] ) =>  __StrTkPtr(<x>,<n>,<c>)
#endif

REQUEST DBGOTOP, DBGOTO, DBGOBOTTOM, DBSKIP, RECCOUNT, RECNO, EOF, BOF

/*
 * Scroll Bar Constants
 */
#ifndef SB_HORZ
#define SB_HORZ             0
#define SB_VERT             1
#define SB_CTL              2
#define SB_BOTH             3
#endif

 /* Moved to windows.ch */
 // #define HDM_GETITEMCOUNT    4608

   // #define DLGC_WANTALLKEYS    0x0004      /* Control wants all keys */

STATIC ColSizeCursor := 0
STATIC arrowCursor := 0
STATIC oCursor     := 0
STATIC xDrag

CLASS HColumn INHERIT HObject

   DATA block, heading, footing, width, type
   DATA length INIT 0
   DATA dec
   DATA nJusHead, nJusLin        // Para poder Justificar los Encabezados de las columnas y lineas.
                                 // To be able to justfy the headings of the columns and lines
   // WHT. 27.07.2002
   DATA tcolor, bcolor, brush
   DATA oFont
   DATA lEditable  INIT .F.      // Is the column editable
   DATA lResizable INIT .T.      // Is the column resizable
   DATA aList                    // Array of possible values for a column -
                                 // combobox will be used while editing the cell
   DATA oStyleHead               // An HStyle object to draw the header
   DATA oStyleFoot               // An HStyle object to draw the footer
   DATA oStyleCell               // An HStyle object to draw the cell
   DATA aPaintCB                 // An array with codeblocks to paint column items: {nId, cId, bDraw}
   DATA aBitmaps

   DATA bValid, bWhen            // When and Valid codeblocks for cell editing
   DATA bEdit                    // Codeblock, which performs cell editing, if defined
   DATA Picture

   DATA cGrid
   DATA lSpandHead INIT .F.
   DATA lSpandFoot INIT .F.

   DATA bHeadClick
   DATA bColorBlock              //   bColorBlock must return an array containing four colors values
   //   oBrowse:aColumns[1]:bColorBlock := {||IIF(nNumber < 0, ;
   //      {textColor, backColor, textColorSel, backColorSel}, ;
   //      {textColor, backColor, textColorSel, backColorSel})}
   METHOD New(cHeading, block, type, length, dec, lEditable, nJusHead, nJusLin, cPict, bValid, bWhen, aItem, bColorBlock, bHeadClick)
   METHOD SetPaintCB(nId, block, cId)

ENDCLASS

METHOD New(cHeading, block, type, length, dec, lEditable, nJusHead, nJusLin, cPict, bValid, bWhen, aItem, bColorBlock, bHeadClick) CLASS HColumn

   ::heading   := iif(cHeading == NIL, "", cHeading)
   ::block     := block
   ::type      := type
   ::length    := length
   ::dec       := dec
   ::lEditable := iif(lEditable != NIL, lEditable, .F.)
   ::nJusHead  := iif(nJusHead == NIL, DT_LEFT, nJusHead) // Por default      / For default
   ::nJusLin   := iif(nJusLin  == NIL, DT_LEFT, nJusLin ) // Justif.Izquierda / Justify left
   ::picture   := cPict
   ::bValid    := bValid
   ::bWhen     := bWhen
   ::aList     := aItem
   ::bColorBlock := bColorBlock
   ::bHeadClick  := bHeadClick

   RETURN Self

METHOD SetPaintCB(nId, block, cId) CLASS HColumn

   LOCAL i
   LOCAL nLen

   IF Empty(cId)
      cId := "_"
   ENDIF
   IF Empty(::aPaintCB)
      ::aPaintCB := {}
   ENDIF

   nLen := Len(::aPaintCB)
   FOR i := 1 TO nLen
      IF ::aPaintCB[i, 1] == nId .AND. ::aPaintCB[i, 2] == cId
         EXIT
      ENDIF
   NEXT i
   IF Empty(block)
      IF i <= nLen
         ADel(::aPaintCB, i)
         ::aPaintCB := ASize(::aPaintCB, nLen - 1)
      ENDIF
   ELSE
      IF i > nLen
         AAdd(::aPaintCB, {nId, cId, block})
      ELSE
         ::aPaintCB[i, 3] := block
      ENDIF
   ENDIF

   RETURN NIL

CLASS HBrowse INHERIT HControl

   DATA winclass   INIT "BROWSE"
   DATA active     INIT .T.
   DATA lChanged   INIT .F.
   DATA lDispHead  INIT .T.                    // Should I display headers ?
   DATA lDispSep   INIT .T.                    // Should I display separators ?

   DATA lRefrLinesOnly INIT .F.
   DATA lRefrHead  INIT .T.
   DATA lRefrBmp   INIT .F.
   DATA lBuffering INIT .F.
   DATA hBitmap

   DATA aColAlias  INIT {}
   DATA aRelation  INIT .F.
   DATA aColumns                               // HColumn's array
   DATA nRowHeight INIT 0                      // Predefined height of a row
   DATA nRowTextHeight                         // A max text height in a row
   DATA rowCount                               // Number of visible data rows
   DATA rowPos     INIT 1                      // Current row position
   DATA rowPosOld  INIT 1  HIDDEN              // Current row position (after :Paint())
   DATA rowCurrCount INIT 0                    // Current number of rows
   DATA colPos     INIT 1                      // Current column position
   DATA nColumns                               // Number of visible data columns
   DATA nLeftCol                               // Leftmost column
   DATA freeze                                 // Number of columns to freeze
   DATA nRecords                               // Number of records in browse
   DATA nCurrent   INIT 1                      // Current record
   DATA aArray                                 // An array browsed if this is BROWSE ARRAY
   DATA recCurr    INIT 0
   DATA oStyleHead                             // An HStyle object to draw the header
   DATA oStyleFoot                             // An HStyle object to draw the footer
   DATA oStyleCell                             // An HStyle object to draw the cell
   DATA headColor                              // Header text color
   DATA sepColor   INIT 12632256               // Separators color
   DATA oPenSep, oPenHdr, oPen3d
   DATA lSep3d     INIT .F.
   DATA aPadding   INIT {4, 2, 4, 2}
   DATA aHeadPadding   INIT {4, 0, 4, 0}
   DATA lInFocus   INIT .F.                    // Set focus in :Paint()
   DATA varbuf                                 // Used on Edit()
   DATA tcolorSel, bcolorSel, brushSel, htbColor, httColor // Hilite Text Back Color
   DATA bSkip, bGoTo, bGoTop, bGoBot, bEof, bBof
   DATA bRcou, bRecno, bRecnoLog
   DATA bPosChanged, bLineOut
   DATA bScrollPos                             // Called when user move browse through vertical scroll bar
   DATA bHScrollPos                            // Called when user move browse through horizontal scroll bar
   DATA bEnter, bKeyDown, bUpdate, bRClick
   DATA ALIAS                                  // Alias name of browsed database
   DATA x1, y1, x2, y2, width, height
   DATA minHeight INIT 0
   DATA lEditable INIT .T.
   DATA lAppable  INIT .F.
   DATA lAppMode  INIT .F.
   DATA lAutoEdit INIT .F.
   DATA lUpdated  INIT .F.
   DATA lAppended INIT .F.
   DATA lEditing  INIT .F.                     // .T., if a field is edited now
   DATA lAdjRight INIT .T.                     // Adjust last column to right
   DATA nHeadRows INIT 1                       // Rows in header
   DATA nFootRows INIT 0                       // Rows in footer
   DATA lResizing INIT .F.                     // .T. while a column resizing is undergoing
   DATA lCtrlPress INIT .F.                    // .T. while Ctrl key is pressed
   DATA aSelected                              // An array of selected records numbers
   DATA nPaintRow, nPaintCol                   // Row/Col being painted
   DATA nHCCharset INIT -1                     // Charset for MEMO EDIT -1: set default value = 0
                                               // 204: Russian
                                               // 15 : IBM 858 with Euro currency sign
   // --- International Language Support for internal dialogs ---
   DATA cTextTitME INIT "Memo Edit"
   DATA cTextClose INIT "Close"   // Button
   DATA cTextSave  INIT "Save"
   DATA cTextMod   INIT "Memo was modified, save ?"
   DATA cTextLockRec INIT "Can't lock the record!"

   METHOD New(lType, oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, ;
              lNoVScroll, lNoBorder, lAppend, lAutoedit, bUpdate, bKeyDown, bPosChg, lMultiSelect, bRClick)
   METHOD InitBrw(nType)
   METHOD Rebuild(hDC)
   METHOD Activate()
   METHOD Init()
   METHOD DefaultLang() // Reset of messages to default value English
   METHOD onEvent(msg, wParam, lParam)
   METHOD Redefine(lType, oWndParent, nId, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus)
   METHOD AddColumn(oColumn)
   METHOD InsColumn(oColumn, nPos)
   METHOD DelColumn(nPos)
   METHOD Paint(lLostFocus)
   METHOD LineOut(nstroka, vybfld, hDC, lSelected, lClear)
   METHOD DrawHeader(hDC, nColumn, x1, y1, x2, y2)
   METHOD HeaderOut(hDC)
   METHOD FooterOut(hDC)
   METHOD SetColumn(nCol)
   METHOD DoHScroll(wParam)
   METHOD DoVScroll(wParam)
   METHOD LineDown(lMouse)
   METHOD LineUp()
   METHOD PageUp()
   METHOD PageDown()
   METHOD Bottom(lPaint)
   METHOD Top()
   METHOD Home() INLINE ::DoHScroll(SB_LEFT)
   METHOD ButtonDown(lParam)
   METHOD ButtonRDown(lParam)
   METHOD ButtonUp(lParam)
   METHOD ButtonDbl(lParam)
   METHOD MouseMove(wParam, lParam)
   METHOD MouseWheel(nKeys, nDelta, nXPos, nYPos)
   METHOD Edit(wParam, lParam)
   METHOD APPEND() INLINE (::Bottom(.F.), ::LineDown() )
   METHOD RefreshLine()
   METHOD Refresh(lFull)
   METHOD ShowSizes()
   METHOD End()

ENDCLASS

METHOD New(lType, oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, ;
           lNoVScroll, lNoBorder, lAppend, lAutoedit, bUpdate, bKeyDown, bPosChg, lMultiSelect, bRClick) CLASS HBrowse

   IF pcount() == 0
      ::Super:New(NIL, NIL, WS_CHILD + WS_VISIBLE + WS_BORDER + WS_VSCROLL, 0, 0, 0, 0, NIL, NIL, NIL, NIL)
      ::oFont := ::oParent:oFont
      ::lAppable := .F.
      ::lAutoEdit := .F.
      hwg_RegBrowse()
      ::InitBrw()
      ::Activate()
      RETURN Self
   ENDIF

   nStyle := hb_bitor(iif(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + iif(lNoBorder = NIL .OR. !lNoBorder, WS_BORDER, 0) + iif(lNoVScroll = NIL .OR. !lNoVScroll, WS_VSCROLL, 0))

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, iif(nWidth == NIL, 0, nWidth), iif(nHeight == NIL, 0, nHeight), oFont, bInit, bSize, bPaint)

   ::type := lType
   IF oFont == NIL
      ::oFont := ::oParent:oFont
   ENDIF
   ::bEnter      := bEnter
   ::bRClick     := bRClick
   ::bGetFocus   := bGFocus
   ::bLostFocus  := bLFocus

   ::lAppable    := iif(lAppend == NIL, .F., lAppend)
   ::lAutoEdit   := iif(lAutoedit == NIL, .F., lAutoedit)
   ::bUpdate     := bUpdate
   ::bKeyDown    := bKeyDown
   ::bPosChanged := bPosChg
   IF lMultiSelect != NIL .AND. lMultiSelect
      ::aSelected := {}
   ENDIF

   hwg_RegBrowse()
   ::InitBrw()
   ::Activate()

   RETURN Self


METHOD DefaultLang() CLASS HBrowse
   ::cTextTitME := "Memo Edit"
   ::cTextClose := "Close"   // Button
   ::cTextSave  := "Save"
   ::cTextMod   := "Memo was modified, save ?"
   ::cTextLockRec := "Can't lock the record!"
   RETURN Self

METHOD Activate() CLASS HBrowse

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbrowse(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD onEvent(msg, wParam, lParam) CLASS HBrowse

   LOCAL nPos
   LOCAL iParHigh
   LOCAL iParLow

   // hwg_WriteLog("Brw: " + Str(msg, 6) + " " + Str(hwg_PtrToUlong(wParam), 10)  +" " + Str(hwg_PtrToUlong(lParam), 10))
   IF ::active .AND. !Empty(::aColumns)

      IF HB_ISBLOCK(::bOther)
         Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF

      SWITCH msg

      CASE WM_PAINT
         ::Paint()
         RETURN 1

      CASE WM_ERASEBKGND
         IF ::brush != NIL
            //aCoors := hwg_Getclientrect(::handle)
            //hwg_Fillrect(wParam, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, ::brush:handle)
            RETURN 1
         ENDIF
         EXIT

      CASE WM_SETFOCUS
         IF HB_ISBLOCK(::bGetFocus)
            Eval(::bGetFocus, Self)
         ENDIF
         EXIT

      CASE WM_KILLFOCUS
         IF HB_ISBLOCK(::bLostFocus)
            Eval(::bLostFocus, Self)
         ENDIF
         EXIT

      CASE WM_HSCROLL
         ::DoHScroll(wParam)
         EXIT

      CASE WM_VSCROLL
         ::DoVScroll(wParam)
         EXIT

      CASE WM_GETDLGCODE
         RETURN DLGC_WANTALLKEYS

      CASE WM_COMMAND
         IF ::aEvents != NIL
            iParHigh := hwg_Hiword(wParam)
            iParLow  := hwg_Loword(wParam)
            IF (nPos := Ascan(::aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
               Eval(::aEvents[nPos, 3], Self, iParLow)
            ENDIF
         ENDIF
         EXIT

      CASE WM_KEYUP
         wParam := hwg_PtrToUlong(wParam)
         // inicio bloco sauli
         IF wParam == 17
            ::lCtrlPress := .F.
         ENDIF
         // fim bloco sauli
         RETURN 1

      CASE WM_KEYDOWN
         wParam := hwg_PtrToUlong(wParam)
         IF HB_ISBLOCK(::bKeyDown)
            IF !Eval(::bKeyDown, Self, wParam)
               RETURN 1
            ENDIF
         ENDIF
         SWITCH wParam
         CASE 40       // Down
            ::LINEDOWN()
            EXIT
         CASE 38    // Up
            ::LINEUP()
            EXIT
         CASE 39    // Right
            ::DoHScroll(SB_LINERIGHT)
            EXIT
         CASE 37    // Left
            ::DoHScroll(SB_LINELEFT)
            EXIT
         CASE 36    // Home
            ::DoHScroll(SB_LEFT)
            EXIT
         CASE 35    // End
            ::DoHScroll(SB_RIGHT)
            EXIT
         CASE 34    // PageDown
            IF ::lCtrlPress
               ::BOTTOM()
            ELSE
               ::PageDown()
            ENDIF
            EXIT
         CASE 33    // PageUp
            IF ::lCtrlPress
               ::TOP()
            ELSE
               ::PageUp()
            ENDIF
            EXIT
         CASE 13    // Enter
            ::Edit()
            EXIT
            // inicio bloco sauli
         CASE 17
            ::lCtrlPress := .T.
            EXIT
            // fim bloco sauli
         OTHERWISE
            IF ::lAutoEdit .AND. (wParam >= 48 .AND. wParam <= 90 .OR. wParam >= 96 .AND. wParam <= 111)
               ::Edit(wParam, lParam)
            ENDIF
         ENDSWITCH
         RETURN 1

      CASE WM_LBUTTONDBLCLK
         ::ButtonDbl(lParam)
         EXIT

      CASE WM_LBUTTONDOWN
         ::ButtonDown(lParam)
         EXIT

      CASE WM_RBUTTONDOWN
         ::ButtonRDown(lParam)
         EXIT

      CASE WM_LBUTTONUP
         ::ButtonUp(lParam)
         EXIT

      CASE WM_MOUSEMOVE
         ::MouseMove(wParam, lParam)
         EXIT

      CASE WM_MOUSEWHEEL
         ::MouseWheel(hwg_Loword(wParam), IIf(hwg_Hiword(wParam) > 32768, hwg_Hiword(wParam) - 65535, hwg_Hiword(wParam)), hwg_Loword(lParam), hwg_Hiword(lParam))
         EXIT

      CASE WM_DESTROY
         ::End()
         EXIT

      CASE WM_SIZE
         ::lRefrBmp := .T.
         EXIT

      ENDSWITCH

   ENDIF

   RETURN - 1

METHOD Init() CLASS HBrowse

   IF !::lInit
      ::Super:Init()
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
   ENDIF

   RETURN NIL

METHOD Redefine(lType, oWndParent, nId, oFont, bInit, bSize, bPaint, bEnter, bGfocus, bLfocus) CLASS HBrowse

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint)

   ::type    := lType
   IF oFont == NIL
      ::oFont := ::oParent:oFont
   ENDIF
   ::bEnter  := bEnter
   ::bGetFocus  := bGFocus
   ::bLostFocus := bLFocus

   hwg_RegBrowse()
   ::InitBrw()

   RETURN Self

METHOD AddColumn(oColumn) CLASS HBrowse

   LOCAL n
   LOCAL arr

   IF ValType(oColumn) == "A"
      arr := oColumn
      n := Len(arr)
      oColumn := HColumn():New(iif(n > 0, arr[1], NIL), iif(n > 1, arr[2], NIL), ;
         iif(n > 2, arr[3], NIL), iif(n > 3, arr[4], NIL), iif(n > 4, arr[5], NIL), iif(n > 5, arr[6], NIL))
   ENDIF
   AAdd(::aColumns, oColumn)
   ::lChanged := .T.
   InitColumn(Self, oColumn, Len(::aColumns))

   RETURN oColumn

METHOD InsColumn(oColumn, nPos) CLASS HBrowse

   LOCAL n
   LOCAL arr

   IF ValType(oColumn) == "A"
      arr := oColumn
      n := Len(arr)
      oColumn := HColumn():New(iif(n > 0, arr[1], NIL), iif(n > 1, arr[2], NIL), ;
         iif(n > 2, arr[3], NIL), iif(n > 3, arr[4], NIL), iif(n > 4, arr[5], NIL), iif(n > 5, arr[6], NIL))
   ENDIF
   AAdd(::aColumns, NIL)
   AIns(::aColumns, nPos)
   ::aColumns[nPos] := oColumn
   ::lChanged := .T.
   InitColumn(Self, oColumn, nPos)

   RETURN oColumn

STATIC FUNCTION InitColumn(oBrw, oColumn, n)

   IF oColumn:type == NIL
      oColumn:type := ValType(Eval(oColumn:block, NIL, oBrw, n))
   ENDIF
   IF oColumn:dec == NIL
      IF oColumn:type == "N" .AND. At(".", Str(Eval(oColumn:block, NIL, oBrw, n))) != 0
         oColumn:dec := Len(SubStr(Str(Eval(oColumn:block, NIL, oBrw, n)), At(".", Str(Eval(oColumn:block, NIL, oBrw, n))) + 1))
      ELSE
         oColumn:dec := 0
      ENDIF
   ENDIF
   IF oColumn:length == NIL
      IF oColumn:picture != NIL
         oColumn:length := Len(Transform(Eval(oColumn:block, NIL, oBrw, n), oColumn:picture))
      ELSE
         oColumn:length := 10
      ENDIF
      oColumn:length := Max(oColumn:length, Len(oColumn:heading))
   ENDIF

   RETURN NIL

METHOD DelColumn(nPos) CLASS HBrowse

   ADel(::aColumns, nPos)
   ASize(::aColumns, Len(::aColumns) - 1)
   ::lChanged := .T.

   RETURN NIL

METHOD End() CLASS HBrowse

   ::Super:End()
   IF ::brush != NIL
      ::brush:Release()
      ::brush := NIL
   ENDIF
   IF ::brushSel != NIL
      ::brushSel:Release()
      ::brushSel := NIL
   ENDIF
   IF !Empty(::hBitmap)
      hwg_DeleteObject(::hBitmap)
      ::hBitmap := NIL
   ENDIF

   RETURN NIL

METHOD InitBrw(nType) CLASS HBrowse

   IF nType != NIL
      ::type := nType
   ELSE
      ::aColumns := {}
      ::nLeftCol := 1
      ::lRefrLinesOnly := .F.
      ::lRefrHead := .T.
      ::aArray   := NIL
      ::freeze := ::height := 0

      IF Empty(ColSizeCursor)
         ColSizeCursor := hwg_Loadcursor(IDC_SIZEWE)
         arrowCursor := hwg_Loadcursor(IDC_ARROW)
      ENDIF
   ENDIF
   ::rowPos := ::rowPosOld := ::nCurrent := ::colpos := 1

   IF ::type == BRW_DATABASE
      ::alias     := Alias()
      ::bSkip     := {|o, n|(o), (::alias)->(dbSkip(n))}
      ::bGoTop    := {||(::alias)->(DBGOTOP())}
      ::bGoBot    := {||(::alias)->(dbGoBottom())}
      ::bEof      := {||(::alias)->(Eof())}
      ::bBof      := {||(::alias)->(Bof())}
      ::bRcou     := {||(::alias)->(RecCount())}
      ::bRecnoLog := ::bRecno := {||(::alias)->(RecNo())}
      ::bGoTo     := {|o, n|(o), (::alias)->(dbGoto(n))}

   ELSEIF ::type == BRW_ARRAY
      ::bSkip      := {|o, n|ARSKIP(o, n)}
      ::bGoTop     := {|o|o:nCurrent := 1}
      ::bGoBot     := {|o|o:nCurrent := o:nRecords}
      ::bEof       := {|o|o:nCurrent > o:nRecords}
      ::bBof       := {|o|o:nCurrent == 0}
      ::bRcou      := {|o|Len(o:aArray)}
      ::bRecnoLog  := ::bRecno := {|o|o:nCurrent}
      ::bGoTo      := {|o, n|o:nCurrent := n}
      ::bScrollPos := {|o, n, lEof, nPos|hwg_VScrollPos(o, n, lEof, nPos)}

   ENDIF

   RETURN NIL

METHOD Rebuild(hDC) CLASS HBrowse

   LOCAL i
   LOCAL j
   LOCAL oColumn
   LOCAL xSize
   LOCAL nColLen
   LOCAL nHdrLen
   LOCAL nCount
   LOCAL arr

   IF ::oPenSep == NIL
      ::oPenSep := HPen():Add(PS_SOLID, 1, ::sepColor)
   ENDIF
   IF ::oPen3d == NIL
      ::oPen3d := HPen():Add(PS_SOLID, 1, hwg_Getsyscolor(COLOR_3DHILIGHT))
   ENDIF
   IF ::oPenHdr == NIL
      ::oPenHdr := HPen():Add(BS_SOLID, 1, 0)
   ENDIF
   IF ::brush != NIL
      ::brush:Release()
   ENDIF
   IF ::brushSel != NIL
      ::brushSel:Release()
   ENDIF
   IF ::bcolor != NIL
      ::brush := HBrush():Add(::bcolor)
      IF hDC != NIL
         hwg_Sendmessage(::handle, WM_ERASEBKGND, hDC, 0)
      ENDIF
   ENDIF
   IF ::bcolorSel != NIL
      ::brushSel  := HBrush():Add(::bcolorSel)
   ENDIF
   ::nLeftCol  := ::freeze + 1
   ::lEditable := .F.
   ::minHeight := ::nRowTextHeight := ::width := 0

   FOR i := 1 TO Len(::aColumns)

      oColumn := ::aColumns[i]

      IF oColumn:lEditable
         ::lEditable := .T.
      ENDIF

      IF oColumn:oFont != NIL
         hwg_Selectobject(hDC, oColumn:oFont:handle)
      ELSEIF ::oFont != NIL
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      arr := hwg_GetTextMetric(hDC)
      ::nRowTextHeight := Max(::nRowTextHeight, arr[1])
      ::width := Max(::width, Round((arr[3] + arr[2]) / 2 - 1, 0))

      nColLen := oColumn:length
      IF oColumn:heading != NIL
         oColumn:heading := CountToken(oColumn:heading, @nHdrLen, @nCount)
         IF !oColumn:lSpandHead
            nColLen := Max(nColLen, nHdrLen)
         ENDIF
         ::nHeadRows := Max(::nHeadRows, nCount)
      ENDIF
      IF oColumn:footing != NIL
         oColumn:footing := CountToken(oColumn:footing, @nHdrLen, @nCount)
         IF !oColumn:lSpandFoot
            nColLen := Max(nColLen, nHdrLen)
         ENDIF
         ::nFootRows := Max(::nFootRows, nCount)
      ENDIF

      IF oColumn:aBitmaps != NIL
         xSize := 0
         FOR j := 1 TO Len(oColumn:aBitmaps)
            IF ValType(oColumn:aBitmaps[j, 2]) == "O"
               xSize := Max(xSize, oColumn:aBitmaps[j, 2]:nWidth + 2)
               ::minHeight := Max(::minHeight, oColumn:aBitmaps[j, 2]:nHeight)
            ENDIF
         NEXT j
      ELSE
         xSize := Round((nColLen) * arr[2], 0)
      ENDIF

      IF oColumn:length < 0
         oColumn:width := Abs(oColumn:length)
      ELSE
         oColumn:width := xSize + ::aPadding[1] + ::aPadding[3]
      ENDIF

   NEXT i

   ::lChanged := .F.

   RETURN NIL

METHOD Paint(lLostFocus) CLASS HBrowse

   LOCAL aCoors
   LOCAL i
   LOCAL l
   LOCAL tmp
   LOCAL nRows
   LOCAL x1
   LOCAL pps
   LOCAL hDC
   LOCAL hDCReal

   HB_SYMBOL_UNUSED(lLostFocus)

   IF ::tcolor == NIL
      ::tcolor := 0
   ENDIF
   IF ::bcolor == NIL
      ::bcolor := 0xFFFFFF
   ENDIF

   IF ::httcolor == NIL
      ::httcolor := 0xFFFFFF
   ENDIF
   IF ::htbcolor == NIL
      ::htbcolor := 2896388 // TODO: converter para hexadecimal
   ENDIF

   IF ::tcolorSel == NIL
      ::tcolorSel := 0xFFFFFF
   ENDIF
   IF ::bcolorSel == NIL
      ::bcolorSel := 0x808080
   ENDIF

   pps := hwg_Definepaintstru()
   hDCReal := hwg_Beginpaint(::handle, pps)
   IF !::active .OR. Empty(::aColumns)
      hwg_Endpaint(::handle, pps)
      RETURN NIL
   ENDIF

   IF ::brush == NIL .OR. ::lChanged
      ::Rebuild(hDCReal)
   ENDIF
   IF ::oPenSep:color != ::sepColor
      ::oPenSep:Release()
      ::oPenSep := HPen():Add(PS_SOLID, 1, ::sepColor)
   ENDIF
   aCoors := hwg_Getclientrect(::handle)

   ::height := iif(::nRowHeight > 0, ::nRowHeight, Max(::nRowTextHeight, ::minHeight) + 1 + ::aPadding[2] + ::aPadding[4])
   ::x1 := aCoors[1]
   ::y1 := aCoors[2] + iif(::lDispHead, ::nRowTextHeight * ::nHeadRows + ::aHeadPadding[2] + ::aHeadPadding[4], 0)
   ::x2 := aCoors[3]
   ::y2 := aCoors[4]

   ::nRecords := Eval(::bRcou, Self)
   IF ::nCurrent > ::nRecords .AND. ::nRecords > 0
      ::nCurrent := ::nRecords
   ENDIF

   ::nColumns := FldCount(Self, ::x1 + 2, ::x2 - 2, ::nLeftCol)
   ::rowCount := Int((::y2 - ::y1) / (::height + 1)) - ::nFootRows
   nRows := Min(::nRecords, ::rowCount)

   IF ::lRefrBmp .AND. !Empty(::hBitmap)
      hwg_DeleteObject(::hBitmap)
      ::hBitmap := NIL
   ENDIF
   IF ::lBuffering .AND. !Empty(::hBitmap)
      hwg_DrawBitmap(hDCReal, ::hBitmap, NIL, aCoors[1], aCoors[2], aCoors[3] - aCoors[1], aCoors[4] - aCoors[2])
      hwg_Endpaint(::handle, pps)
   ELSE
      IF ::lBuffering
         hDC := hwg_CreateCompatibleDC(hDCReal)
         ::hBitmap := hwg_CreateCompatibleBitmap(hDCReal, aCoors[3] - aCoors[1], aCoors[4] - aCoors[2])
         hwg_Selectobject(hDC, ::hBitmap)
      ELSE
         hDC := hDCReal
      ENDIF
      IF ::oFont != NIL
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF

      IF ::lRefrLinesOnly
         IF ::rowPos != ::rowPosOld .AND. !::lAppMode
            Eval(::bSkip, Self, ::rowPosOld - ::rowPos)
            IF ::aSelected != NIL .AND. Ascan(::aSelected, {|x|x = Eval(::bRecno, Self)}) > 0
               ::LineOut(::rowPosOld, 0, hDC, .T.)
            ELSE
               ::LineOut(::rowPosOld, 0, hDC, .F.)
            ENDIF
            Eval(::bSkip, Self, ::rowPos - ::rowPosOld)
         ENDIF
      ELSE
         // Modified by Luiz Henrique dos Santos (luizhsantos@gmail.com)
         IF Eval(::bEof, Self) .OR. Eval(::bBof, Self)
            Eval(::bGoTop, Self)
            ::rowPos := 1
         ENDIF
         IF ::rowPos > nRows .AND. nRows > 0
            ::rowPos := nRows
         ENDIF
         tmp := Eval(::bRecno, Self)
         IF ::rowPos > 1
            Eval(::bSkip, Self, -(::rowPos - 1))
         ENDIF
         i := 1
         l := .F.
         DO WHILE .T.
            IF Eval(::bRecno, Self) == tmp
               ::rowPos := i
               l := .T.
            ENDIF
            IF i > nRows .OR. Eval(::bEof, Self)
               EXIT
            ENDIF
            IF l
               l := .F.
            ELSE
               IF ::aSelected != NIL .AND. Ascan(::aSelected, {|x|x = Eval(::bRecno, Self)}) > 0
                  ::LineOut(i, 0, hDC, .T.)
               ELSE
                  ::LineOut(i, 0, hDC, .F.)
               ENDIF
            ENDIF
            i++
            Eval(::bSkip, Self, 1)
         ENDDO
         ::rowCurrCount := i - 1

         IF ::rowPos >= i
            ::rowPos := iif(i > 1, i - 1, 1)
         ENDIF
         DO WHILE i <= nRows
            ::LineOut(i, 0, hDC, .F., .T.)
            i++
         ENDDO

         Eval(::bGoTo, Self, tmp)

         hwg_Fillrect(hDC, ::x1, ::y1 + (::height + 1) * nRows, ::x2, ::y2, ::brush:handle)
      ENDIF
      IF ::lAppMode
         ::LineOut(nRows + 1, 0, hDC, .F., .T.)
      ENDIF

      ::LineOut(::rowPos, ::colpos, hDC, .T.)

      ::HeaderOut(hDC)
      IF ::nFootRows > 0
         ::FooterOut(hDC)
      ENDIF

      IF !::lAdjRight
         x1 := ::x1
         i := iif(::freeze > 0, 1, ::nLeftCol)
         DO WHILE i < (::nLeftCol + ::nColumns) .AND. i <= Len(::aColumns)
            x1 += ::aColumns[i]:width
            i := iif(i == ::freeze, ::nLeftCol, i + 1)
         ENDDO
         IF i > Len(::aColumns)
            hwg_Fillrect(hDC, x1, aCoors[2], ::x2, ::y2, ::brush:handle)
         ENDIF
      ENDIF

      IF ::lBuffering
         hwg_BitBlt(hDCReal, 0, 0, aCoors[3] - aCoors[1], aCoors[4] - aCoors[2], hDC, 0, 0, SRCCOPY)
         hwg_DeleteDC(hDC)
      ENDIF
      hwg_Endpaint(::handle, pps)
   ENDIF

   ::lRefrBmp  := .F.
   ::lRefrHead := .T.
   ::lRefrLinesOnly := .F.
   ::rowPosOld := ::rowPos
   tmp := Eval(::bRecno, Self)
   IF ::recCurr != tmp
      ::recCurr := tmp
      IF HB_ISBLOCK(::bPosChanged)
         Eval(::bPosChanged, Self, ::nCurrent)
      ENDIF
   ENDIF

   IF ::lAppMode
      ::Edit()
   ENDIF

   IF ::lInFocus .AND. ((tmp := hwg_Getfocus()) == ::oParent:handle .OR. ::oParent:FindControl(NIL, tmp) != NIL)
      hwg_Setfocus(::handle)
   ENDIF

   ::lAppMode := .F.

   RETURN NIL

METHOD DrawHeader(hDC, nColumn, x1, y1, x2, y2) CLASS HBrowse

   LOCAL cStr
   LOCAL oColumn := ::aColumns[nColumn]
   LOCAL cNWSE
   LOCAL nLine
   LOCAL ya
   LOCAL yb
   LOCAL nHeight := ::nRowTextHeight
   LOCAL aCB := oColumn:aPaintCB
   LOCAL block
   LOCAL i

   IF !Empty(block := hwg_getPaintCB(aCB, PAINT_HEAD_ALL))
      RETURN Eval(block, oColumn, hDC, x1, y1, x2, y2, nColumn)
   ENDIF

   IF !Empty(block := hwg_getPaintCB(aCB, PAINT_HEAD_BACK))
      Eval(block, oColumn, hDC, x1, y1, x2, y2, nColumn)
   ELSEIF oColumn:oStyleHead != NIL
      oColumn:oStyleHead:Draw(hDC, x1, y1, x2, y2)
   ELSEIF ::oStyleHead != NIL
      ::oStyleHead:Draw(hDC, x1, y1, x2, y2)
   ELSE
      hwg_Drawbutton(hDC, x1, y1, x2, y2, iif(oColumn:cGrid == NIL, 1, 0))
   ENDIF

   IF oColumn:cGrid != NIL
      hwg_Selectobject(hDC, ::oPenHdr:handle)
      cStr := oColumn:cGrid + ";"
      FOR nLine := 1 TO ::nHeadRows
         cNWSE := hb_tokenGet(@cStr, nLine, ";")
         ya := y1 + nHeight * nLine + ::aHeadPadding[2] + iif(nLine == ::nHeadRows, ::aHeadPadding[4], 0)
         yb := y1 + nHeight * (nLine - 1) + iif(nLine == 1, 0, ::aHeadPadding[2])
         IF At("S", cNWSE) != 0
            hwg_Drawline(hDC, x1, ya, x2, ya)
         ENDIF
         IF At("N", cNWSE) != 0
            hwg_Drawline(hDC, x1, yb, x2, yb)
         ENDIF
         IF At("E", cNWSE) != 0
            hwg_Drawline(hDC, x2 - 1, yb + 1, x2 - 1, ya)
         ENDIF
         IF At("W", cNWSE) != 0
            hwg_Drawline(hDC, x1, yb + 1, x1, ya)
         ENDIF
      NEXT nLine
   ENDIF
   hwg_Settransparentmode(hDC, .T.)
   IF HB_ISCHAR(oColumn:heading)
      hwg_Drawtext(hDC, oColumn:heading, x1 + 1 + ::aHeadPadding[1], ;
         y1 + 1 + ::aHeadPadding[2], x2 - ::aHeadPadding[3], ;
         y1 + nHeight + ::aHeadPadding[2], oColumn:nJusHead)
   ELSE
      FOR nLine := 1 TO Len(oColumn:heading)
         IF !Empty(oColumn:heading[nLine])
            hwg_Drawtext(hDC, oColumn:heading[nLine], x1 + 1 + ::aHeadPadding[1], ;
               y1 + nHeight * (nLine - 1) + 1 + ::aHeadPadding[2], x2 - ::aHeadPadding[3], ;
               y1 + nHeight * nLine + ::aHeadPadding[2], ;
               oColumn:nJusHead  + iif(oColumn:lSpandHead, DT_NOCLIP, 0))
         ENDIF
      NEXT nLine
   ENDIF
   hwg_Settransparentmode(hDC, .F.)

   IF !Empty(aCB := hwg_getPaintCB(aCB, PAINT_HEAD_ITEM))
      FOR i := 1 TO Len(aCB)
         Eval(aCB[i], oColumn, hDC, x1, y1, x2, y2, nColumn)
      NEXT i
   ENDIF

   RETURN NIL

METHOD HeaderOut(hDC) CLASS HBrowse

   LOCAL i
   LOCAL x
   LOCAL y1
   LOCAL oldc
   LOCAL fif
   LOCAL xSize
   LOCAL nRows := Min(::nRecords + iif(::lAppMode, 1, 0), ::rowCount)
   LOCAL oldBkColor := hwg_Setbkcolor(hDC, hwg_Getsyscolor(COLOR_3DFACE))

   IF ::lDispSep
      hwg_Selectobject(hDC, ::oPenSep:handle)
   ENDIF

   x := ::x1
   y1 := ::y1 - ::nRowTextHeight * ::nHeadRows - ::aHeadPadding[2] - ::aHeadPadding[4]
   IF ::headColor != NIL
      oldc := hwg_Settextcolor(hDC, ::headColor)
   ENDIF
   fif := iif(::freeze > 0, 1, ::nLeftCol)

   DO WHILE x < ::x2 - 2
      xSize := ::aColumns[fif]:width
      IF ::lAdjRight .AND. fif == Len(::aColumns)
         xSize := Max(::x2 - x, xSize)
      ENDIF
      IF ::lRefrHead .AND. ::lDispHead .AND. !::lAppMode
         ::DrawHeader(hDC, fif, x - 1, y1, x + xSize - 1, ::y1 + 1)
      ENDIF
      hwg_Selectobject(hDC, ::oPenSep:handle)
      IF ::lDispSep .AND. x > ::x1
         IF ::lSep3d
            hwg_Selectobject(hDC, ::oPen3d:handle)
            hwg_Drawline(hDC, x - 1, ::y1 + 1, x - 1, ::y1 + (::height + 1) * nRows)
            hwg_Selectobject(hDC, ::oPenSep:handle)
            hwg_Drawline(hDC, x - 2, ::y1 + 1, x - 2, ::y1 + (::height + 1) * nRows)
         ELSE
            hwg_Drawline(hDC, x - 1, ::y1 + 1, x - 1, ::y1 + (::height + 1) * nRows)
         ENDIF
      ENDIF
      x += xSize
      IF !::lAdjRight .AND. fif == Len(::aColumns)
         hwg_Drawline(hDC, x - 1, y1, x - 1, ::y1 + (::height + 1) * nRows)
      ENDIF
      fif := iif(fif = ::freeze, ::nLeftCol, fif + 1)
      IF fif > Len(::aColumns)
         EXIT
      ENDIF
   ENDDO

   IF ::lDispSep
      FOR i := 1 TO nRows
         hwg_Drawline(hDC, ::x1, ::y1 + (::height + 1) * i, iif(::lAdjRight, ::x2, x), ::y1 + (::height + 1) * i)
      NEXT i
   ENDIF

   hwg_Setbkcolor(hDC, oldBkColor)
   IF ::headColor != NIL
      hwg_Settextcolor(hDC, oldc)
   ENDIF

   RETURN NIL

METHOD FooterOut(hDC) CLASS HBrowse

   LOCAL i
   LOCAL x
   LOCAL x2
   LOCAL y1
   LOCAL y2
   LOCAL fif
   LOCAL xSize
   LOCAL nLine
   LOCAL oColumn
   LOCAL aCB
   LOCAL block

   IF ::lDispSep
      hwg_Selectobject(hDC, ::oPenSep:handle)
   ENDIF

   x := ::x1
   fif := iif(::freeze > 0, 1, ::nLeftCol)

   //y1 := ::y1 + (::rowCount) * (::height + 1) + 1
   //y2 := ::y1 + (::rowCount + 1) * (::height + 1)
   y1 := ::y2 - ::height
   y2 := ::y2
   DO WHILE x < ::x2 - 2
      oColumn := ::aColumns[fif]
      xSize := oColumn:width
      IF ::lAdjRight .AND. fif == Len(::aColumns)
         xSize := Max(::x2 - x, xSize)
      ENDIF
      x2 := x + xSize - 1
      aCB := oColumn:aPaintCB
      IF !Empty(block := hwg_getPaintCB(aCB, PAINT_FOOT_ALL))
         RETURN Eval(block, oColumn, hDC, x, y1, x2, y2, fif)
      ELSE
         IF !Empty(block := hwg_getPaintCB(aCB, PAINT_FOOT_BACK))
            Eval(block, oColumn, hDC, x, y1, x2, y2, fif)
         ELSEIF oColumn:oStyleFoot != NIL
            oColumn:oStyleFoot:Draw(hDC, x, y1, x2, y2)
         ELSEIF ::oStyleFoot != NIL
            ::oStyleFoot:Draw(hDC, x, y1, x2, y2)
         ELSE
            hwg_Drawbutton(hDC, x, y1, x2, y2, 0)
         ENDIF

         IF oColumn:footing != NIL
            hwg_Settransparentmode(hDC, .T.)
            IF HB_ISCHAR(oColumn:footing)
               hwg_Drawtext(hDC, oColumn:footing, ;
                  x + ::aHeadPadding[1], y1 + ::aHeadPadding[2], ;
                  x2 - ::aHeadPadding[3], y2 - ::aHeadPadding[4], oColumn:nJusHead + iif(oColumn:lSpandFoot, DT_NOCLIP, 0))
            ELSE
               FOR nLine := 1 TO Len(oColumn:footing)
                  IF !Empty(oColumn:footing[nLine])
                     hwg_Drawtext(hDC, oColumn:footing[nLine], ;
                        x + ::aHeadPadding[1], y1 + (nLine - 1) * (::height + 1) + 1, ;
                        x2 - ::aHeadPadding[3], ::y1 + nLine * (::height + 1), ;
                        oColumn:nJusHead + iif(oColumn:lSpandFoot, DT_NOCLIP, 0) )
                  ENDIF
               NEXT nLine
            ENDIF
            hwg_Settransparentmode(hDC, .F.)
         ENDIF
         IF !Empty(aCB := hwg_getPaintCB(aCB, PAINT_FOOT_ITEM))
            FOR i := 1 TO Len(aCB)
               Eval(aCB[i], oColumn, hDC, x, y1, x2, y2, fif)
            NEXT i
         ENDIF
      ENDIF
      hwg_Selectobject(hDC, ::oPenSep:handle)
      IF ::lDispSep .AND. x > ::x1
         IF ::lSep3d
            hwg_Selectobject(hDC, ::oPen3d:handle)
            hwg_Drawline(hDC, x - 1, y1 + 1, x - 1, y2 - 1)
            hwg_Selectobject(hDC, ::oPenSep:handle)
            hwg_Drawline(hDC, x - 2, y1 + 1, x - 2, y2 - 1)
         ELSE
            hwg_Drawline(hDC, x - 1, y1 + 1, x - 1, y2 - 1)
         ENDIF
      ENDIF
      x += xSize
      fif := iif(fif = ::freeze, ::nLeftCol, fif + 1)
      IF fif > Len(::aColumns)
         EXIT
      ENDIF
   ENDDO

   IF ::lDispSep
      hwg_Drawline(hDC, ::x1, y1, iif(::lAdjRight, ::x2, x), y1)
   ENDIF

   RETURN NIL

METHOD LineOut(nstroka, vybfld, hDC, lSelected, lClear) CLASS HBrowse

   LOCAL x
   LOCAL x2
   LOCAL y1
   LOCAL y2
   LOCAL i := 1
   LOCAL sviv
   LOCAL xSize
   LOCAL nCol
   LOCAL j
   LOCAL ob
   LOCAL bw
   LOCAL bh
   LOCAL hBReal
   LOCAL oldBkColor
   LOCAL oldTColor
   LOCAL oBrushLine := iif(lSelected, ::brushSel, ::brush)
   LOCAL oBrushSele := iif(vybfld >= 1, HBrush():Add(::htbColor), NIL)
   LOCAL lColumnFont := .F.
   LOCAL aCores
   LOCAL oColumn
   LOCAL aCB
   LOCAL block

   x := ::x1
   IF lClear == NIL
      lClear := .F.
   ENDIF

   IF HB_ISBLOCK(::bLineOut)
      Eval(::bLineOut, Self, lSelected)
   ENDIF
   IF ::nRecords > 0
      oldBkColor := hwg_Setbkcolor(hDC, iif(lSelected, ::bcolorSel, ::bcolor))
      oldTColor  := hwg_Settextcolor(hDC, iif(lSelected, ::tcolorSel, ::tcolor))
      //fldname := Space(8)
      nCol := ::nPaintCol := iif(::freeze > 0, 1, ::nLeftCol)
      ::nPaintRow := nstroka

      WHILE x < ::x2 - 2
         oColumn := ::aColumns[nCol]
         IF oColumn:bColorBlock != NIL
            aCores := Eval(oColumn:bColorBlock, Self, nstroka, nCol)
            IF lSelected
               oColumn:tColor := iif(vybfld == i .AND. Len(aCores) >= 5 .AND. aCores[5] != NIL, aCores[5], aCores[3])
               oColumn:bColor := iif(vybfld == i .AND. Len(aCores) >= 6 .AND. aCores[6] != NIL, aCores[6], aCores[4])
            ELSE
               oColumn:tColor := aCores[1]
               oColumn:bColor := aCores[2]
            ENDIF
            oColumn:brush := HBrush():Add(oColumn:bColor)
         ENDIF
         IF oColumn:bColor != NIL .AND. oColumn:brush == NIL
            oColumn:brush := HBrush():Add(oColumn:bColor)
         ENDIF

         xSize := oColumn:width
         IF ::lAdjRight .AND. nCol == Len(::aColumns)
            xSize := Max(::x2 - x + 1, xSize)
         ENDIF

         aCB := oColumn:aPaintCB
         x2 := x + xSize - iif(::lSep3d, 2, 1)
         y1 := ::y1 + (::height + 1) * (nstroka - 1) + 1
         y2 := ::y1 + (::height + 1) * nstroka
         IF !Empty(block := hwg_getPaintCB(aCB, PAINT_LINE_ALL))
            Eval(block, oColumn, hDC, x, y1, x2, y2, nCol)
         ELSE
            IF !Empty(block := hwg_getPaintCB(aCB, PAINT_LINE_BACK))
               Eval(block, oColumn, hDC, x, y1, x2, y2, nCol)
            ELSEIF oColumn:oStyleCell != NIL
               oColumn:oStyleCell:Draw(hDC, x, y1, x2, y2)
            ELSEIF ::oStyleCell != NIL
               ::oStyleCell:Draw(hDC, x, y1, x2, y2)
            ELSE
               hBReal := iif(oColumn:brush != NIL, oColumn:brush:handle, iif(vybfld == i, oBrushSele, oBrushLine):handle)
               hwg_Fillrect(hDC, x, y1, x2, y2, hBReal)
            ENDIF
            IF !lClear
               IF oColumn:aBitmaps != NIL .AND. !Empty(oColumn:aBitmaps)
                  FOR j := 1 TO Len(oColumn:aBitmaps)
                     IF Eval(oColumn:aBitmaps[j, 1], Eval(oColumn:block, NIL, Self, nCol), lSelected)
                        IF !Empty(ob := oColumn:aBitmaps[j, 2])
                           IF ob:nHeight > ::height
                              bh := ::height
                              bw := Int(ob:nWidth * (ob:nHeight / ::height))
                              hwg_Drawbitmap(hDC, ob:handle, NIL, x + ::aPadding[1], y1 + ::aPadding[2], bw, bh)
                           ELSE
                              //bh := ob:nHeight
                              //bw := ob:nWidth
                              hwg_Drawtransparentbitmap(hDC, ob:handle, x + ::aPadding[1], Int((::height - ob:nHeight) / 2) + y1 + ::aPadding[2])
                           ENDIF
                        ENDIF
                        EXIT
                     ENDIF
                  NEXT j
               ELSE
                  hwg_Settextcolor(hDC, iif(oColumn:tColor != NIL, oColumn:tColor, iif(vybfld == i, ::httcolor, iif(lSelected,::tcolorSel,::tcolor))))
                  hwg_Setbkcolor(hDC, iif(oColumn:bColor != NIL, oColumn:bColor, iif(vybfld == i, ::htbcolor, iif(lSelected,::bcolorSel,::bcolor))))

                  IF oColumn:oFont != NIL
                     hwg_Selectobject(hDC, oColumn:oFont:handle)
                     lColumnFont := .T.
                  ELSEIF lColumnFont
                     IF ::oFont != NIL
                        hwg_Selectobject(hDC, ::oFont:handle)
                     ENDIF
                     lColumnFont := .F.
                  ENDIF

                  IF !Empty(sviv := FLDSTR(Self, nCol))
                     hwg_Settransparentmode(hDC, .T.)
                     hwg_Drawtext(hDC, sviv, x + ::aPadding[1], y1 + ::aPadding[2], x2 - ::aPadding[3], y2 - 1 - ::aPadding[4], oColumn:nJusLin)
                     hwg_Settransparentmode(hDC, .F.)
                  ENDIF
                  IF !Empty(aCB := hwg_getPaintCB(aCB, PAINT_LINE_ITEM))
                     FOR j := 1 TO Len(aCB)
                        Eval(aCB[j], oColumn, hDC, x, y1, x2, y2, nCol)
                     NEXT j
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
         x += xSize
         nCol := ::nPaintCol := iif(nCol == ::freeze, ::nLeftCol, nCol + 1)
         i++
         IF !::lAdjRight .AND. nCol > Len(::aColumns)
            EXIT
         ENDIF
      ENDDO
      hwg_Settextcolor(hDC, oldTColor)
      hwg_Setbkcolor(hDC, oldBkColor)
      IF lColumnFont
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
   ENDIF

   RETURN NIL

METHOD SetColumn(nCol) CLASS HBrowse

   LOCAL nColPos
   LOCAL lPaint := .F.

   IF ::lEditable
      IF nCol != NIL .AND. nCol >= 1 .AND. nCol <= Len(::aColumns)
         IF nCol <= ::freeze
            ::colpos := nCol
         ELSEIF nCol >= ::nLeftCol .AND. nCol <= ::nLeftCol + ::nColumns - ::freeze - 1
            ::colpos := nCol - ::nLeftCol + ::freeze + 1
         ELSE
            ::nLeftCol := nCol
            ::colpos := ::freeze + 1
            lPaint := .T.
         ENDIF
         ::lRefrBmp := .T.
         IF !lPaint
            ::RefreshLine()
         ELSE
            hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
         ENDIF
      ENDIF

      IF ::colpos <= ::freeze
         nColPos := ::colpos
      ELSE
         nColPos := ::nLeftCol + ::colpos - ::freeze - 1
      ENDIF
      RETURN nColPos

   ENDIF

   RETURN 1

STATIC FUNCTION LINERIGHT(oBrw)

   LOCAL i

   IF oBrw:lEditable
      IF oBrw:colpos < oBrw:nColumns
         oBrw:colpos++
         RETURN NIL
      ENDIF
   ENDIF
   IF oBrw:nColumns + oBrw:nLeftCol - oBrw:freeze - 1 < Len(oBrw:aColumns) .AND. oBrw:nLeftCol < Len(oBrw:aColumns)
      i := oBrw:nLeftCol + oBrw:nColumns
      DO WHILE oBrw:nColumns + oBrw:nLeftCol - oBrw:freeze - 1 < Len(oBrw:aColumns) .AND. oBrw:nLeftCol + oBrw:nColumns = i
         oBrw:nLeftCol++
      ENDDO
      oBrw:colpos := i - oBrw:nLeftCol + 1
   ENDIF

   RETURN NIL

STATIC FUNCTION LINELEFT(oBrw)

   IF oBrw:lEditable
      oBrw:colpos--
   ENDIF
   IF oBrw:nLeftCol > oBrw:freeze + 1 .AND. (!oBrw:lEditable .OR. oBrw:colpos < oBrw:freeze + 1)
      oBrw:nLeftCol--
      IF !oBrw:lEditable .OR. oBrw:colpos < oBrw:freeze + 1
         oBrw:colpos := oBrw:freeze + 1
      ENDIF
   ENDIF
   IF oBrw:colpos < 1
      oBrw:colpos := 1
   ENDIF

   RETURN NIL

METHOD DoVScroll(wParam) CLASS HBrowse

   LOCAL nScrollCode := hwg_Loword(wParam)

   SWITCH nScrollCode
   CASE SB_LINEDOWN
      ::LINEDOWN(.T.)
      EXIT
   CASE SB_LINEUP
      ::LINEUP()
      EXIT
   CASE SB_BOTTOM
      ::BOTTOM()
      EXIT
   CASE SB_TOP
      ::TOP()
      EXIT
   CASE SB_PAGEDOWN
      ::PAGEDOWN()
      EXIT
   CASE SB_PAGEUP
      ::PAGEUP()
      EXIT
   CASE SB_THUMBPOSITION
      IF HB_ISBLOCK(::bScrollPos)
         Eval(::bScrollPos, Self, SB_THUMBPOSITION, .F., hwg_Hiword(wParam))
      ENDIF
      EXIT
   CASE SB_THUMBTRACK
      IF HB_ISBLOCK(::bScrollPos)
         Eval(::bScrollPos, Self, SB_THUMBTRACK, .F., hwg_Hiword(wParam))
      ENDIF
      EXIT
   ENDSWITCH

   RETURN 0

METHOD DoHScroll(wParam) CLASS HBrowse

   LOCAL nScrollCode := hwg_Loword(wParam)
   LOCAL minPos
   LOCAL maxPos
   LOCAL nPos
   LOCAL oldLeft := ::nLeftCol
   LOCAL nLeftCol
   LOCAL colpos
   LOCAL oldPos := ::colpos
   LOCAL fif
   LOCAL lMoveThumb := .T.

   hwg_Getscrollrange(::handle, SB_HORZ, @minPos, @maxPos)
   //nPos := hwg_Getscrollpos(::handle, SB_HORZ)

   SWITCH nScrollCode
   CASE SB_LINELEFT
   CASE SB_PAGELEFT
      LineLeft(Self)
      EXIT
   CASE SB_LINERIGHT
   CASE SB_PAGERIGHT
      LineRight(Self)
      EXIT
   CASE SB_LEFT
      nLeftCol := colPos := 0
      DO WHILE nLeftCol != ::nLeftCol .OR. colPos != ::colPos
         nLeftCol := ::nLeftCol
         colPos := ::colPos
         LineLeft(Self)
      ENDDO
      EXIT
   CASE SB_RIGHT
      nLeftCol := colPos := 0
      DO WHILE nLeftCol != ::nLeftCol .OR. colPos != ::colPos
         nLeftCol := ::nLeftCol
         colPos := ::colPos
         LineRight(Self)
      ENDDO
      EXIT
   CASE SB_THUMBPOSITION
      IF HB_ISBLOCK(::bHScrollPos)
         Eval(::bHScrollPos, Self, SB_THUMBPOSITION, .F., hwg_Hiword(wParam))
         lMoveThumb := .F.
      ENDIF
      EXIT
   CASE SB_THUMBTRACK
      IF HB_ISBLOCK(::bHScrollPos)
         Eval(::bHScrollPos, Self, SB_THUMBTRACK, .F., hwg_Hiword(wParam))
         lMoveThumb := .F.
      ENDIF
      EXIT
   ENDSWITCH

   IF ::nLeftCol != oldLeft .OR. ::colpos != oldpos

      /* Move scrollbar thumb if ::bHScrollPos has not been called, since, in this case,
         movement of scrollbar thumb is done by that codeblock
      */
      IF lMoveThumb

         fif := iif(::lEditable, ::colpos + ::nLeftCol - 1, ::nLeftCol)
         nPos := iif(fif == 1, minPos, iif(fif = Len(::aColumns), maxpos, Int((maxPos - minPos + 1) * fif / Len(::aColumns))))
         hwg_Setscrollpos(::handle, SB_HORZ, nPos)

      ENDIF

      ::lRefrBmp := .T.
      IF ::nLeftCol == oldLeft
         ::RefreshLine()
      ELSE
         hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ENDIF
   hwg_Setfocus(::handle)

   RETURN NIL

METHOD LINEDOWN(lMouse) CLASS HBrowse

   LOCAL minPos
   LOCAL maxPos
   LOCAL nPos
   LOCAL colpos
   LOCAL btemp

   IF ::type == BRW_ARRAY
       btemp := Eval(::bSkip, Self, 1) == 0 .OR. Eval(::bEof, Self)
   ELSE
       // DF7BE: Modification suggested by Itarmar M. Lins Jr.
       // (see sample program Testado.prg)
       //
       // Database (Default)
       // If BROWSE command without "DATABASE" term, the attribute ::type is set to 0 !
       Eval(::bSkip, Self, 1)
       btemp := Eval(::bEof, Self)
   ENDIF

   IF btemp
      IF ::type == BRW_ARRAY
         Eval(::bGoBot, Self)
      ELSE
         Eval(::bSkip, Self, -1)
      ENDIF

      IF ::lAppable .AND. ::lEditable .AND. (lMouse == NIL .OR. !lMouse) .AND. (::type != BRW_DATABASE .OR. !Dbinfo(DBI_ISREADONLY))
         colpos := 1
         DO WHILE colpos <= Len(::aColumns) .AND. !::aColumns[colpos]:lEditable
            colpos++
         ENDDO
         IF colpos <= Len(::aColumns)
            ::lAppMode := .T.
         ENDIF
      ELSE
         hwg_Setfocus(::handle)
         RETURN NIL
      ENDIF
   ENDIF
   ::rowPos++
   ::lRefrBmp := .T.
   IF ::rowPos > ::rowCount
      ::rowPos := ::rowCount
      hwg_Invalidaterect(::handle, 0)
   ELSE
      ::lRefrLinesOnly := .T.
      hwg_Invalidaterect(::handle, 0, ::x1, ::y1 + (::height + 1) * ::rowPosOld - ::height, ::x2, ::y1 + (::height + 1) * (::rowPos))
   ENDIF
   IF ::lAppMode
      IF ::rowPos > 1
         ::rowPos--
      ENDIF
      ::colPos := ::nLeftCol := colpos
   ENDIF

   IF HB_ISBLOCK(::bScrollPos)
      Eval(::bScrollPos, Self, 1, .F.)
   ELSEIF ::nRecords > 1
      hwg_Getscrollrange(::handle, SB_VERT, @minPos, @maxPos)
      nPos := hwg_Getscrollpos(::handle, SB_VERT)
      nPos += Int((maxPos - minPos) / (::nRecords - 1))
      hwg_Setscrollpos(::handle, SB_VERT, nPos)
   ENDIF

   hwg_Postmessage(::handle, WM_PAINT, 0, 0)
   hwg_Setfocus(::handle)

   RETURN NIL

METHOD LINEUP() CLASS HBrowse

   LOCAL minPos
   LOCAL maxPos
   LOCAL nPos
   LOCAL btemp

   IF ::type == BRW_ARRAY
      btemp := Eval(::bSkip, Self, -1) == 0
   ELSE
      Eval(::bSkip, Self, -1)
      btemp := Eval(::bBof, Self)
   ENDIF

   IF btemp
      //Eval(::bSkip, Self, -1)
      //IF Eval(::bBof, Self) itamar
      Eval(::bGoTop, Self)
   ELSE
      ::rowPos--
      ::lRefrBmp := .T.
      IF ::rowPos = 0
         ::rowPos := 1
         hwg_Invalidaterect(::handle, 0)
      ELSE
         ::lRefrLinesOnly := .T.
         hwg_Invalidaterect(::handle, 0, ::x1, ::y1 + (::height + 1) * ::rowPosOld - ::height, ::x2, ::y1 + (::height + 1) * ::rowPosOld)
         hwg_Invalidaterect(::handle, 0, ::x1, ::y1 + (::height + 1) * ::rowPos - ::height, ::x2, ::y1 + (::height + 1) * ::rowPos)
      ENDIF

      IF HB_ISBLOCK(::bScrollPos)
         Eval(::bScrollPos, Self, -1, .F.)
      ELSEIF ::nRecords > 1
         hwg_Getscrollrange(::handle, SB_VERT, @minPos, @maxPos)
         nPos := hwg_Getscrollpos(::handle, SB_VERT)
         nPos -= Int((maxPos - minPos) / (::nRecords - 1))
         hwg_Setscrollpos(::handle, SB_VERT, nPos)
      ENDIF
      //::internal[1] := hwg_Setbit(::internal[1], 1, 0)
      hwg_Postmessage(::handle, WM_PAINT, 0, 0)
   ENDIF
   hwg_Setfocus(::handle)

   RETURN NIL

METHOD PAGEUP() CLASS HBrowse

   LOCAL minPos
   LOCAL maxPos
   LOCAL nPos
   LOCAL step
   LOCAL lBof := .F.

   IF ::rowPos > 1
      step := (::rowPos - 1)
      Eval(::bSKip, Self, -step)
      ::rowPos := 1
   ELSE
      step := ::rowCurrCount    // Min(::nRecords, ::rowCount)
      Eval(::bSkip, Self, -step)
      IF Eval(::bBof, Self)
         Eval(::bGoTop, Self)
         lBof := .T.
      ENDIF
   ENDIF

   IF HB_ISBLOCK(::bScrollPos)
      Eval(::bScrollPos, Self, -step, lBof)
   ELSEIF ::nRecords > 1
      hwg_Getscrollrange(::handle, SB_VERT, @minPos, @maxPos)
      nPos := hwg_Getscrollpos(::handle, SB_VERT)
      nPos := Max(nPos - Int((maxPos - minPos) * step / (::nRecords - 1)), minPos)
      hwg_Setscrollpos(::handle, SB_VERT, nPos)
   ENDIF

   ::Refresh(.F.)
   hwg_Setfocus(::handle)

   RETURN NIL

METHOD PAGEDOWN() CLASS HBrowse

   LOCAL minPos
   LOCAL maxPos
   LOCAL nPos
   LOCAL nRows := ::rowCurrCount
   LOCAL step := iif(nRows > ::rowPos, nRows - ::rowPos + 1, nRows)

   Eval(::bSkip, Self, step)
   ::rowPos := Min(::nRecords, nRows)

   IF HB_ISBLOCK(::bScrollPos)
      Eval(::bScrollPos, Self, step, Eval(::bEof, Self))
   ELSE
      hwg_Getscrollrange(::handle, SB_VERT, @minPos, @maxPos)
      nPos := hwg_Getscrollpos(::handle, SB_VERT)
      IF Eval(::bEof, Self)
         Eval(::bSkip, Self, -1)
         nPos := maxPos
         hwg_Setscrollpos(::handle, SB_VERT, nPos)
      ELSEIF ::nRecords > 1
         nPos := Min(nPos + Int((maxPos - minPos) * step / (::nRecords - 1)), maxPos)
         hwg_Setscrollpos(::handle, SB_VERT, nPos)
      ENDIF

   ENDIF

   ::Refresh(.F.)
   hwg_Setfocus(::handle)

   RETURN NIL

METHOD BOTTOM(lPaint) CLASS HBrowse

   LOCAL minPos
   LOCAL maxPos

   hwg_Getscrollrange(::handle, SB_VERT, @minPos, @maxPos)

   Eval(::bGoBot, Self)
   ::rowPos := iif(::rowCount == NIL, 9999, Min(::nRecords, ::rowCount))

   hwg_Setscrollpos(::handle, SB_VERT, maxPos)

   IF ::rowCount != NIL
      ::lRefrBmp := .T.
      hwg_Invalidaterect(::handle, 0)

      IF lPaint == NIL .OR. lPaint
         hwg_Postmessage(::handle, WM_PAINT, 0, 0)
         hwg_Setfocus(::handle)
      ENDIF
   ENDIF

   RETURN NIL

METHOD TOP() CLASS HBrowse

   LOCAL minPos
   LOCAL maxPos

   hwg_Getscrollrange(::handle, SB_VERT, @minPos, @maxPos)

   ::rowPos := 1
   Eval(::bGoTop, Self)

   hwg_Setscrollpos(::handle, SB_VERT, minPos)

   IF ::rowCount != NIL
      ::lRefrBmp := .T.
      hwg_Invalidaterect(::handle, 0)
      hwg_Postmessage(::handle, WM_PAINT, 0, 0)
      hwg_Setfocus(::handle)
   ENDIF

   RETURN NIL

METHOD ButtonDown(lParam) CLASS HBrowse

   LOCAL hBrw := ::handle
   LOCAL nLine
   LOCAL step
   LOCAL res := .F.
   LOCAL nrec
   LOCAL minPos
   LOCAL maxPos
   LOCAL nPos
   LOCAL ym := hwg_Hiword(lParam)
   LOCAL xm := hwg_Loword(lParam)
   LOCAL x1
   LOCAL fif

   nLine := iif(ym < ::y1, 0, Int((ym - ::y1) / (::height + 1)) + 1)
   step := nLine - ::rowPos

   x1  := ::x1
   fif := iif(::freeze > 0, 1, ::nLeftCol)

   DO WHILE fif < (::nLeftCol + ::nColumns) .AND. fif <= Len(::aColumns) .AND. x1 + ::aColumns[fif]:width < xm
      x1 += ::aColumns[fif]:width
      fif := iif(fif == ::freeze, ::nLeftCol, fif + 1)
   ENDDO
   IF fif > Len(::aColumns) .AND. ::lAdjRight
      fif := Len(::aColumns)
   ENDIF

   IF nLine > 0 .AND. nLine <= ::rowCurrCount
      IF step != 0
         nrec := Eval(::bRecno, Self)
         Eval(::bSkip, Self, step)
         IF !Eval(::bEof, Self)
            ::rowPos := nLine
            IF HB_ISBLOCK(::bScrollPos)
               Eval(::bScrollPos, Self, step, .F.)
            ELSEIF ::nRecords > 1
               hwg_Getscrollrange(hBrw, SB_VERT, @minPos, @maxPos)
               nPos := hwg_Getscrollpos(hBrw, SB_VERT)
               nPos := Min(nPos + Int((maxPos - minPos) * step / (::nRecords - 1)), maxPos)
               hwg_Setscrollpos(hBrw, SB_VERT, nPos)
            ENDIF
            res := .T.
         ELSE
            Eval(::bGoTo, Self, nrec)
         ENDIF
      ENDIF
      IF ::lEditable

         IF ::colpos != fif - ::nLeftCol + 1 + ::freeze

            // Colpos should not go beyond last column or I get bound errors on ::Edit()
            ::colpos := Min(::nColumns + 1, fif - ::nLeftCol + 1 + ::freeze)
            hwg_Getscrollrange(hBrw, SB_HORZ, @minPos, @maxPos)

            nPos := iif(fif == 1, minPos, iif(fif == Len(::aColumns), maxpos, Int((maxPos - minPos + 1) * fif / Len(::aColumns))))

            hwg_Setscrollpos(hBrw, SB_HORZ, nPos)
            res := .T.

         ENDIF

      ENDIF

      IF res
         ::lRefrBmp := .T.
         hwg_Invalidaterect(hBrw, 0, ::x1, ::y1 + (::height + 1) * ::rowPosOld - ::height, ::x2, ::y1 + (::height + 1) * ::rowPosOld)
         hwg_Invalidaterect(hBrw, 0, ::x1, ::y1 + (::height + 1) * ::rowPos - ::height, ::x2, ::y1 + (::height + 1) * ::rowPos)
         hwg_Sendmessage(hBrw, WM_PAINT, 0, 0)
      ENDIF

   ELSEIF nLine == 0 .AND. hwg_isPtrEq(oCursor, ColSizeCursor)

      ::lResizing := .T.
      Hwg_SetCursor(oCursor)
      xDrag := xm

   ELSEIF nLine == 0 .AND. ::lDispHead .AND. fif <= Len(::aColumns) .AND. ::aColumns[fif]:bHeadClick != NIL

      Eval(::aColumns[fif]:bHeadClick, Self, fif, xm, ym)

   ENDIF

   RETURN NIL

METHOD ButtonRDown(lParam) CLASS HBrowse

   LOCAL nLine
   LOCAL ym := hwg_Hiword(lParam)
   LOCAL xm := hwg_Loword(lParam)
   LOCAL x1
   LOCAL fif

   IF ::bRClick == NIL
      RETURN NIL
   ENDIF

   nLine := iif(ym < ::y1, 0, Int((ym - ::y1) / (::height + 1)) + 1)
   x1  := ::x1
   fif := iif(::freeze > 0, 1, ::nLeftCol)

   DO WHILE fif < (::nLeftCol + ::nColumns) .AND. x1 + ::aColumns[fif]:width < xm
      x1 += ::aColumns[fif]:width
      fif := iif(fif == ::freeze, ::nLeftCol, fif + 1)
   ENDDO

   Eval(::bRClick, Self, fif, nLine - ::rowPos + ::nCurrent)

   RETURN NIL

METHOD ButtonUp(lParam) CLASS HBrowse

   LOCAL hBrw := ::handle
   LOCAL xPos := hwg_Loword(lParam)
   LOCAL x
   LOCAL x1 := xPos
   LOCAL i

   IF ::lResizing
      x := ::x1
      i := iif(::freeze > 0, 1, ::nLeftCol)
      DO WHILE x < xDrag
         x += ::aColumns[i]:width
         IF Abs(x - xDrag) < 10
            x1 := x - ::aColumns[i]:width
            EXIT
         ENDIF
         i := iif(i == ::freeze, ::nLeftCol, i + 1)
      ENDDO
      IF xPos > x1
         ::aColumns[i]:width := xPos - x1
         Hwg_SetCursor(arrowCursor)
         oCursor := 0
         ::lResizing := .F.
         ::lRefrBmp := .T.
         hwg_Invalidaterect(hBrw, 0)
         hwg_Postmessage(hBrw, WM_PAINT, 0, 0)
      ENDIF
   ELSEIF ::aSelected != NIL
      IF ::lCtrlPress
         IF (i := Ascan(::aSelected, Eval(::bRecno, Self))) > 0
            ADel(::aSelected, i)
            ASize(::aSelected, Len(::aSelected) - 1)
         ELSE
            AAdd(::aSelected, Eval(::bRecno, Self))
         ENDIF
      ELSE
         IF Len(::aSelected) > 0
            ::aSelected := {}
            ::Refresh()
         ENDIF
      ENDIF
   ENDIF
   hwg_Setfocus(::handle)

   RETURN NIL

METHOD ButtonDbl(lParam) CLASS HBrowse

   LOCAL nLine
   LOCAL ym := hwg_Hiword(lParam)

   nLine := iif(ym < ::y1, 0, Int((ym - ::y1) / (::height + 1)) + 1)
   IF nLine > 0 .AND. nLine <= ::rowCurrCount
      ::ButtonDown(lParam)
      ::Edit()
   ENDIF

   RETURN NIL

METHOD MouseMove(wParam, lParam) CLASS HBrowse

   LOCAL xPos := hwg_Loword(lParam)
   LOCAL yPos := hwg_Hiword(lParam)
   LOCAL x := ::x1
   LOCAL i
   LOCAL res := .F.
   LOCAL nLen

   IF !::active .OR. Empty(::aColumns) .OR. ::x1 == NIL
      RETURN NIL
   ENDIF

   IF ::lDispSep .AND. yPos <= ::y1   //::height * ::nHeadRows + 1
      wParam := hwg_PtrToUlong(wParam)
      IF wParam == 1 .AND. ::lResizing
         Hwg_SetCursor(oCursor)
         res := .T.
      ELSE
         nLen := Len(::aColumns) - iif(::lAdjRight, 1, 0)
         i := iif(::freeze > 0, 1, ::nLeftCol)
         DO WHILE x < ::x2 - 2 .AND. i <= nLen
            x += ::aColumns[i]:width
            IF Abs(x - xPos) < 8
               IF ::aColumns[i]:lResizable
                  IF !hwg_isPtrEq(oCursor, ColSizeCursor)
                     oCursor := ColSizeCursor
                  ENDIF
                  Hwg_SetCursor(oCursor)
                  res := .T.
               ENDIF
               EXIT
            ENDIF
            i := iif(i == ::freeze, ::nLeftCol, i + 1)
         ENDDO
      ENDIF
      IF !res .AND. !Empty(oCursor)
         Hwg_SetCursor(arrowCursor)
         oCursor := 0
         ::lResizing := .F.
      ENDIF
   ENDIF

   RETURN NIL

METHOD MouseWheel(nKeys, nDelta, nXPos, nYPos) CLASS HBrowse

   HB_SYMBOL_UNUSED(nXPos)
   HB_SYMBOL_UNUSED(nYPos)

   IF hb_bitand(nKeys, MK_MBUTTON) != 0
      IF nDelta > 0
         ::PageUp()
      ELSE
         ::PageDown()
      ENDIF
   ELSE
      IF nDelta > 0
         ::LineUp()
      ELSE
         ::LineDown()
      ENDIF
   ENDIF

   RETURN NIL

METHOD Edit(wParam, lParam) CLASS HBrowse

   LOCAL fipos
   LOCAL lRes
   LOCAL x1
   LOCAL y1
   LOCAL fif
   LOCAL nWidth
   LOCAL lReadExit
   LOCAL rowPos
   LOCAL oModDlg
   LOCAL oColumn
   LOCAL aCoors
   LOCAL nChoic
   LOCAL bInit
   LOCAL oGet
   LOCAL type
   LOCAL oComboFont
   LOCAL oCombo
   LOCAL owb1
   LOCAL owb2
   LOCAL oEdit
   LOCAL mvarbuff
   LOCAL bMemoMod
   LOCAL oHCfont
   LOCAL apffrarr
   LOCAL nchrs
   LOCAL lCancel
   LOCAL lSaveMem    // DF7BE

   lCancel  := .T.
   lSaveMem := .T.

   fipos := ::colpos + ::nLeftCol - 1 - ::freeze

   IF ::oFont != NIL
      /* Preset charset for displaying special characters of other languages
         for example Russian ::nHCCharset = 204
         default is 0 */
     // ::nHCCharset := 15 // IBM 858 With Euro currency sign

     nchrs := ::nHCCharset
     apffrarr := ::oFont:Props2Arr()
     // hwg_Writelog(STR(::nHCCharset) )
     IF ::nHCCharset == -1
      nchrs := apffrarr[5]
     ENDIF
     oHCfont := HFont():Add(apffrarr[1], apffrarr[2], apffrarr[3], apffrarr[4], nchrs, apffrarr[6], apffrarr[7], apffrarr[8])
//        fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut
//        1         2       3         4         5           6          7             8
   ENDIF

   // hwg_WriteLog(oHCfont:PrintFont() )

   oColumn := ::aColumns[fipos]
   IF ::bEnter == NIL .OR. (ValType(lRes := Eval(::bEnter, Self, fipos, ::nCurrent)) == "L" .AND. !lRes)
      IF !oColumn:lEditable
         RETURN NIL
      ENDIF
      IF ::type == BRW_DATABASE
         IF Dbinfo(DBI_ISREADONLY)
            RETURN NIL
         ENDIF
         ::varbuf := (::alias) -> (Eval(oColumn:block, NIL, Self, fipos))
      ELSE
         ::varbuf := Eval(oColumn:block, NIL, Self, fipos)
      ENDIF
      type := iif(oColumn:type == "U" .AND. ::varbuf != NIL, ValType(::varbuf), oColumn:type)
      IF type != "O"
         IF oColumn:bWhen = NIL .OR. Eval(oColumn:bWhen)
            IF ::lAppMode
               // TODO: SWITCH
               IF type == "D"
                  ::varbuf := CToD("")
               ELSEIF type == "N"
                  ::varbuf := 0
               ELSEIF type == "L"
                  ::varbuf := .F.
               ELSE
                  ::varbuf := ""
               ENDIF
            ENDIF
         ELSE
            RETURN NIL
         ENDIF
         x1  := ::x1
         fif := iif(::freeze > 0, 1, ::nLeftCol)
         DO WHILE fif < fipos
            x1 += ::aColumns[fif]:width
            fif := iif(fif = ::freeze, ::nLeftCol, fif + 1)
         ENDDO
         nWidth := Iif(::lAdjRight .AND. fif == Len(::aColumns), ::x2 - x1 - 1, Min(::aColumns[fif]:width, ::x2 - x1 - 1))
         rowPos := ::rowPos - 1
         IF ::lAppMode .AND. ::nRecords != 0
            rowPos++
         ENDIF
         y1 := ::y1 + (::height + 1) * rowPos

         aCoors := hwg_Clienttoscreen(::handle, x1, y1)
         x1 := aCoors[1]
         y1 := aCoors[2]

         lReadExit := Set(_SET_EXIT, .T.)
         bInit := iif(wParam == NIL, {|o|hwg_Movewindow(o:handle, x1, y1, nWidth, o:nHeight + 1)}, ;
            {|o|hwg_Movewindow(o:handle, x1, y1, nWidth, o:nHeight + 1), hwg_Postmessage(o:aControls[1]:handle, WM_KEYDOWN, wParam, lParam)})

         IF type != "M"
            INIT DIALOG oModDlg STYLE WS_POPUP + 1 + iif(oColumn:aList == NIL, WS_BORDER, 0) ;
               AT x1, y1 - iif(oColumn:aList == NIL, 1, 0) SIZE nWidth, ::height + iif(oColumn:aList == NIL, 1, 0) ;
               ON INIT bInit
         ELSE
            INIT DIALOG oModDlg title ::cTextTitME AT 0, 0 SIZE 400, 300 ON INIT {|o|o:center()}
         ENDIF
         ::lEditing := .T.

         IF oColumn:aList != NIL
            oModDlg:brush := - 1
            oModDlg:nHeight := ::height * 5

            IF ValType(::varbuf) == "N"
               nChoic := ::varbuf
            ELSE
               ::varbuf := AllTrim(::varbuf)
               nChoic := Ascan(oColumn:aList, ::varbuf)
            ENDIF

            /* 21/09/2005 - <maurilio.longo@libero.it>
                            The combobox needs to use a font smaller than the one used
                            by the browser or it will be taller than the browse row that
                            has to contain it.
            */
            oComboFont := iif(ValType(::oFont) == "U", HFont():Add("MS Sans Serif", 0, -8), HFont():Add(::oFont:name, ::oFont:width, ::oFont:height + 2))

            @ 0, 0 GET COMBOBOX oCombo VAR nChoic ITEMS oColumn:aList SIZE nWidth, ::height * 5 FONT oComboFont

            IF oColumn:bValid != NIL
               oCombo:bValid := oColumn:bValid
            ENDIF

         ELSE
            IF type != "M"
               @ 0, 0 GET oGet VAR ::varbuf      ;
                  SIZE nWidth, ::height + 1      ;
                  NOBORDER                       ;
                  STYLE ES_AUTOHSCROLL           ;
                  FONT ::oFont                   ;
                  PICTURE oColumn:picture        ;
                  VALID oColumn:bValid
            ELSE

// =========================================================================
// GET not suitable for memo editing, danger of data loss, use HCEDIT (DF7BE)
// =========================================================================
//               oGet1 := ::varbuf  // DF7BE
                mvarbuff := ::varbuf  // DF7BE: inter variable avoids crash at store
//               @ 10, 10 GET oGet1 SIZE oModDlg:nWidth - 20, 240 FONT ::oFont Style WS_VSCROLL + WS_HSCROLL + ES_MULTILINE VALID oColumn:bValid

               /* DF7BE 2020-12-02:
                  Prepare for correct display of Euro currency sign in Memo edit
                  by using charset 0 (ISO8859-15)
                */
               @ 10, 10 HCEDIT oEdit SIZE oModDlg:nWidth - 20, 240 FONT oHCfont // ::oFont

               // ::varbuf ==> mvarbuff, oGet1 ==> oEdit (DF7BE)
               @ 010, 252 ownerbutton owb2 TEXT ::cTextSave size 80, 24 ON Click {||lCancel := .F., mvarbuff := oEdit, omoddlg:close(), oModDlg:lResult := .T.}
               @ 100, 252 ownerbutton owb1 TEXT ::cTextClose size 80, 24 ON CLICK {||mvarbuff := oEdit, omoddlg:close(), oModDlg:lResult := .T.}
//               @ 100, 252 ownerbutton owb1 TEXT ::cTextClose size 80, 24 ON CLICK {||oModDlg:close()}
                 // serve memo field for editing (DF7BE)
                oEdit:SetText(mvarbuff)       // DF7BE
// =========================================================================
            ENDIF
         ENDIF

         oModDlg:oParent := Self
         ACTIVATE DIALOG oModDlg
// =========================================================================
// DF7BE
         IF type == "M"
          // is modified ? (.T.)
          bMemoMod := oEdit:lUpdated
          IF bMemoMod
//         "Close" Button should be handled like "Cancel".
//          Ask for saving, if  "Close" is pressed and the memo is modified
           IF lCancel
//           Ask and mark vor saving
            lSaveMem := hwg_Msgyesno(::cTextMod, ::cTextTitME)
           ENDIF
           IF lSaveMem
            // write out edited memo field
            // hwg_MsgInfo("Memo saved")
            ::varbuf := oEdit:GetText()
           ENDIF
          ENDIF
         ENDIF
// =========================================================================
         ::lEditing := .F.

         IF oColumn:aList != NIL
            oComboFont:Release()
         ENDIF

         IF oModDlg:lResult
            IF oColumn:aList != NIL
               IF ValType(::varbuf) == "N"
                  ::varbuf := nChoic
               ELSE
                  ::varbuf := oColumn:aList[nChoic]
               ENDIF
            ENDIF
            IF ::lAppMode
               ::lAppMode := .F.
               IF ::type == BRW_DATABASE
                  (::alias) -> (dbAppend())
                  (::alias) -> (Eval(oColumn:block, ::varbuf, Self, fipos))
                  UNLOCK
               ELSE
                  IF ValType(::aArray[1]) == "A"
                     AAdd(::aArray, Array(Len(::aArray[1])))
                     FOR fif := 2 TO Len((::aArray[1]))
                        ::aArray[Len(::aArray),fif] := iif(::aColumns[fif]:type == "D", CToD(Space(8)), iif(::aColumns[fif]:type == "N", 0, ""))
                     NEXT fif
                  ELSE
                     AAdd(::aArray, NIL)
                  ENDIF
                  ::nCurrent := Len(::aArray)
                  Eval(oColumn:block, ::varbuf, Self, fipos)
               ENDIF
               IF ::nRecords > 0
                  ::rowPos++
               ENDIF
               ::lAppended := .T.
               ::Refresh()
            ELSE
               IF ::type == BRW_DATABASE
                  IF (::alias) -> (RLock())
                     (::alias) -> (Eval(oColumn:block, ::varbuf, Self, fipos))
                  ELSE
                     hwg_Msgstop(::cTextLockRec) /* Can't lock the record! */
                  ENDIF
               ELSE
                  Eval(oColumn:block, ::varbuf, Self, fipos)
               ENDIF

               ::lUpdated := .T.
               hwg_Invalidaterect(::handle, 0, ::x1, ::y1 + (::height + 1) * (::rowPos - 1), ::x2, ::y1 + (::height + 1) * ::rowPos)
               ::RefreshLine()
            ENDIF

            /* Execute block after changes are made */
            IF ::bUpdate != NIL
               Eval(::bUpdate, Self, fipos)
            END

         ELSEIF ::lAppMode
            ::lAppMode := .F.
            hwg_Invalidaterect(::handle, 0, ::x1, ::y1 + (::height + 1) * ::rowPos, ::x2, ::y1 + (::height + 1) * (::rowPos + 2))
            ::RefreshLine()
         ENDIF
         hwg_Setfocus(::handle)
         SET(_SET_EXIT, lReadExit)

      ENDIF
   ENDIF

   RETURN NIL

METHOD RefreshLine() CLASS HBrowse

   ::lRefrBmp := ::lRefrLinesOnly := .T.
   hwg_Invalidaterect(::handle, 0, ::x1, ::y1 + (::height + 1) * ::rowPos - ::height, ::x2, ::y1 + (::height + 1) * ::rowPos)
   hwg_Sendmessage(::handle, WM_PAINT, 0, 0)

   RETURN NIL

METHOD Refresh(lFull) CLASS HBrowse

   ::lRefrBmp := .T.
   IF lFull == NIL .OR. lFull
      ::lRefrHead := .T.
      ::lRefrLinesOnly := .F.
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
   ELSE
      hwg_Invalidaterect(::handle, 0, ::x1, ::y1 + 1, ::x2, ::y1 + (::rowCount) * (::height + 1))
      ::lRefrHead := .F.
      hwg_Postmessage(::handle, WM_PAINT, 0, 0)
   ENDIF

   RETURN NIL

STATIC FUNCTION FldStr(oBrw, numf)

   LOCAL cRes
   LOCAL vartmp
   LOCAL type
   LOCAL pict

   IF numf <= Len(oBrw:aColumns)

      IF oBrw:type == BRW_DATABASE
         IF oBrw:aRelation
            vartmp := (oBrw:aColAlias[numf]) -> (Eval(oBrw:aColumns[numf]:block, NIL, oBrw, numf))
         ELSE
            vartmp := (oBrw:alias) -> (Eval(oBrw:aColumns[numf]:block, NIL, oBrw, numf))
         ENDIF
      ELSE
         vartmp := Eval(oBrw:aColumns[numf]:block, NIL, oBrw, numf)
      ENDIF

      IF (pict := oBrw:aColumns[numf]:picture) != NIL
         cRes := Transform(vartmp, pict)
      ELSE
         type := (oBrw:aColumns[numf]):type
         IF type == "U" .AND. vartmp != NIL
            type := ValType(vartmp)
         ENDIF
         SWITCH type
         CASE "C"
            cRes := vartmp
            EXIT
         CASE "N"
            IF vartmp = NIL
               //cRes := PadL(Space(oBrw:aColumns[numf]:length + oBrw:aColumns[numf]:dec), oBrw:aColumns[numf]:length)
               cRes := " "
            ELSE
               //cRes := PadL(Str(vartmp, oBrw:aColumns[numf]:length, oBrw:aColumns[numf]:dec), oBrw:aColumns[numf]:length)
               cRes := Ltrim(Str(vartmp, 24, oBrw:aColumns[numf]:dec))
            ENDIF
            EXIT
         CASE "D"
            //cRes := PadR(Dtoc(vartmp), oBrw:aColumns[numf]:length)
            cRes := Dtoc(vartmp)
            EXIT
         CASE "T"
#ifdef __XHARBOUR__
            cRes := Space(23)
#else
            IF vartmp == NIL
               cRes := Space(23)
            ELSE
               //cRes := PadR(HB_TSTOSTR(vartmp, .T.), oBrw:aColumns[numf]:length)
               cRes := HB_TSTOSTR(vartmp, .T.)
            ENDIF
#endif
            EXIT
         CASE "L"
            //cRes := PadR(iif(vartmp, "T", "F"), oBrw:aColumns[numf]:length)
            cRes := iif(vartmp, "T", "F")
            EXIT
         CASE "M"
            cRes := iif(Empty(vartmp), "<memo>", "<MEMO>")
            EXIT
         CASE "O"
            cRes := "<" + vartmp:Classname() + ">"
            EXIT
         CASE "A"
            cRes := "<Array>"
            EXIT
         OTHERWISE
            //cRes := Space(oBrw:aColumns[numf]:length)
            cRes := " "
         ENDSWITCH
      ENDIF
   ENDIF

   RETURN cRes

STATIC FUNCTION FLDCOUNT(oBrw, xstrt, xend, fld1)

   LOCAL klf := 0
   LOCAL i := iif(oBrw:freeze > 0, 1, fld1)

   DO WHILE .T.
      xstrt += oBrw:aColumns[i]:width
      IF xstrt > xend
         EXIT
      ENDIF
      klf++
      i   := iif(i = oBrw:freeze, fld1, i + 1)
      IF i > Len(oBrw:aColumns)
         EXIT
      ENDIF
   ENDDO

   RETURN iif(klf = 0, 1, klf)

FUNCTION hwg_CREATEARLIST(oBrw, arr)

   LOCAL i

   oBrw:type  := BRW_ARRAY
   oBrw:aArray := arr
   IF Len(oBrw:aColumns) == 0
      // oBrw:aColumns := {}
      IF ValType(arr[1]) == "A"
         FOR i := 1 TO Len(arr[1])
            oBrw:AddColumn({, hwg_ColumnArBlock()})
         NEXT i
      ELSE
         oBrw:AddColumn({, {|value, o|(value), o:aArray[o:nCurrent]}})
      ENDIF
   ENDIF
   Eval(oBrw:bGoTop, oBrw)
   //oBrw:Refresh()

   RETURN NIL

PROCEDURE ARSKIP(oBrw, nSkip)

   LOCAL nCurrent1

   IF oBrw:nRecords != 0
      nCurrent1   := oBrw:nCurrent
      oBrw:nCurrent += nSkip + iif(nCurrent1 = 0, 1, 0)
      IF oBrw:nCurrent < 1
         oBrw:nCurrent := 0
      ELSEIF oBrw:nCurrent > oBrw:nRecords
         oBrw:nCurrent := oBrw:nRecords + 1
      ENDIF
   ENDIF

   RETURN

FUNCTION hwg_CreateList(oBrw, lEditable)

   LOCAL i
   LOCAL nArea := Select()
   LOCAL kolf := FCount()

   oBrw:alias   := Alias()

   oBrw:aColumns := {}
   FOR i := 1 TO kolf
      oBrw:AddColumn({FieldName(i), ;
         FieldWBlock(FieldName(i), nArea), ;
         dbFieldInfo(DBS_TYPE, i), ;
         iif(dbFieldInfo(DBS_TYPE, i) == "D" .AND. __SetCentury(), 10, dbFieldInfo(DBS_LEN, i)), ;
         dbFieldInfo(DBS_DEC, i), ;
         lEditable })
   NEXT i

   //oBrw:Refresh()

   RETURN NIL

FUNCTION hwg_VScrollPos(oBrw, nType, lEof, nPos)

   LOCAL minPos
   LOCAL maxPos
   LOCAL oldRecno
   LOCAL newRecno

   hwg_Getscrollrange(oBrw:handle, SB_VERT, @minPos, @maxPos)
   IF nPos == NIL
      IF nType > 0 .AND. lEof
         Eval(oBrw:bSkip, oBrw, -1)
      ENDIF
      nPos := iif(oBrw:nRecords > 1, Round(((maxPos - minPos) / (oBrw:nRecords - 1)) * (Eval(oBrw:bRecnoLog, oBrw) - 1), 0), minPos)
      hwg_Setscrollpos(oBrw:handle, SB_VERT, nPos)
   ELSE
      oldRecno := Eval(oBrw:bRecnoLog, oBrw)
      newRecno := Round((oBrw:nRecords - 1) * nPos / (maxPos - minPos) + 1, 0)
      IF newRecno <= 0
         newRecno := 1
      ELSEIF newRecno > oBrw:nRecords
         newRecno := oBrw:nRecords
      ENDIF
      IF nType == SB_THUMBPOSITION
         hwg_Setscrollpos(oBrw:handle, SB_VERT, nPos)
      ENDIF
      IF newRecno != oldRecno
         Eval(oBrw:bSkip, oBrw, newRecno - oldRecno)
         IF oBrw:rowCount - oBrw:rowPos > oBrw:nRecords - newRecno
            oBrw:rowPos := oBrw:rowCount - (oBrw:nRecords - newRecno)
         ENDIF
         IF oBrw:rowPos > newRecno
            oBrw:rowPos := newRecno
         ENDIF
         oBrw:Refresh(.F.)
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_HScrollPos(oBrw, nType, lEof, nPos)

   LOCAL minPos
   LOCAL maxPos
   LOCAL i
   LOCAL nSize := 0
   LOCAL nColPixel
   LOCAL nBWidth := oBrw:nWidth // :width is _not_ browse width

   HB_SYMBOL_UNUSED(lEof)

   hwg_Getscrollrange(oBrw:handle, SB_HORZ, @minPos, @maxPos)

   IF nType == SB_THUMBPOSITION

      nColPixel := Int((nPos * nBWidth) / ((maxPos - minPos) + 1))
      i := oBrw:nLeftCol - 1

      WHILE nColPixel > nSize .AND. i < Len(oBrw:aColumns)
         nSize += oBrw:aColumns[++i]:width
      ENDDO

      // colpos is relative to leftmost column, as it seems, so I subtract leftmost column number
      oBrw:colpos := Max(i, oBrw:nLeftCol) - oBrw:nLeftCol + 1
   ENDIF

   hwg_Setscrollpos(oBrw:handle, SB_HORZ, nPos)

   RETURN NIL

   //----------------------------------------------------//
   // Agregado x WHT. 27.07.02
   // Locus metodus.

METHOD ShowSizes() CLASS HBrowse

   LOCAL cText := ""

   AEval(::aColumns, {|v, e|(v), cText += ::aColumns[e]:heading + ": " + Str(Round(::aColumns[e]:width / 8, 0) - 2) + Chr(10) + Chr(13)})
   hwg_Msginfo(cText)

   RETURN NIL

FUNCTION hwg_ColumnArBlock()

   RETURN {|value, o, n|iif(value == NIL, o:aArray[o:nCurrent, n], o:aArray[o:nCurrent, n] := value)}

STATIC FUNCTION CountToken(cStr, nMaxLen, nCount)

   nMaxLen := nCount := 0
   IF HB_ISCHAR(cStr)
      IF (";" $ cStr)
         cStr := hb_aTokens(cStr, ";")
      ELSE
         nMaxLen := Len(cStr)
         nCount := 1
      ENDIF
   ENDIF
   IF ValType(cStr) == "A"
      AEval(cStr, {|s|nMaxLen := Max(nMaxLen, Len(s))})
      nCount := Len(cStr)
   ENDIF

   RETURN cStr

FUNCTION hwg_getPaintCB(arr, nId)

   LOCAL i
   LOCAL nLen
   LOCAL aRes

   IF !Empty(arr)
      nLen := Len(arr)
      FOR i := 1 TO nLen
         IF arr[i, 1] == nId
            IF nId < PAINT_LINE_ITEM
               RETURN arr[i, 3]
            ELSE
               IF aRes == NIL
                  aRes := {arr[i, 3]}
               ELSE
                  AAdd(aRes, arr[i, 3])
               ENDIF
            ENDIF
         ENDIF
      NEXT i
   ENDIF

   RETURN aRes
