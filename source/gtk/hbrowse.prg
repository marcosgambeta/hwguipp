//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HBrowse class - browse databases and arrays
//
// Copyright 2005 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include <inkey.ch>
#include <dbinfo.ch>
#include <dbstruct.ch>
#include "hwguipp.ch"
#include "gtk.ch"

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

   STATIC s_crossCursor := NIL
   STATIC s_arrowCursor := NIL
   STATIC s_vCursor := NIL
   STATIC s_xDrag

CLASS HColumn INHERIT HObject

   DATA block, heading, footing, width, type
   DATA length INIT 0
   DATA dec
   DATA nJusHead, nJusLin        // Para poder Justificar los Encabezados de las columnas y lineas.
                                 // To be able to justfy the headings of the columns and lines
   // WHT. 27.07.2002
   DATA tcolor, bcolor, brush
   DATA oFont
   DATA lEditable INIT .F.      // Is the column editable
   DATA lResizable INIT .T.      // Is the column resizable
   DATA aList                    // Array of possible values for a column -
                                 // combobox will be used while editing the cell
   DATA oStyleHead               // An HStyle object to draw the header
   DATA oStyleFoot               // An HStyle object to draw the footer
   DATA oStyleCell               // An HStyle object to draw the cell
   DATA aPaintCB                 // An array with codeblocks to paint column items: { nId, cId, bDraw }
   DATA aBitmaps

   DATA bValid, bWhen            // When and Valid codeblocks for cell editing
   DATA bEdit                    // Codeblock, which performs cell editing, if defined
   DATA Picture

   DATA cGrid
   DATA lSpandHead INIT .F.
   DATA lSpandFoot INIT .F.

   DATA bHeadClick
   DATA bColorBlock              //   bColorBlock must return an array containing four colors values
   //   oBrowse:aColumns[1]:bColorBlock := {|| IF (nNumber < 0, ;
   //      {textColor, backColor, textColorSel, backColorSel} , ;
   //      {textColor, backColor, textColorSel, backColorSel} ) }
   METHOD New(cHeading, block, type, length, dec, lEditable, nJusHead, nJusLin, cPict, bValid, bWhen, aItem, bColorBlock, bHeadClick)
   METHOD SetPaintCB(nId, block, cId)

ENDCLASS

METHOD HColumn:New(cHeading, block, type, length, dec, lEditable, nJusHead, nJusLin, cPict, bValid, bWhen, aItem, bColorBlock, bHeadClick)

   ::heading := IIf(cHeading == NIL, "", cHeading)
   ::block := block
   ::type := type
   ::length := length
   ::dec := dec
   ::lEditable := IIf(lEditable != NIL, lEditable, .F.)
   ::nJusHead := IIf(nJusHead == NIL, DT_LEFT, nJusHead)  // Por default      / For default
   ::nJusLin := IIf(nJusLin == NIL, DT_LEFT, nJusLin)  // Justif.Izquierda / Justify left
   ::picture := cPict
   ::bValid := bValid
   ::bWhen := bWhen
   ::aList := aItem
   ::bColorBlock := bColorBlock
   ::bHeadClick := bHeadClick

   RETURN Self

METHOD HColumn:SetPaintCB(nId, block, cId)

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
   NEXT
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

   DATA winclass INIT "BROWSE"
   DATA active INIT .T.
   DATA lChanged INIT .F.
   DATA lDispHead INIT .T.                    // Should I display headers ?
   DATA lDispSep INIT .T.                    // Should I display separators ?

   DATA lRefrLinesOnly INIT .F.
   DATA lRefrHead INIT .T.

   DATA aColumns                               // HColumn's array
   DATA nRowHeight INIT 0                      // Predefined height of a row
   DATA nRowTextHeight                         // A max text height in a row
   DATA rowCount INIT 2                      // Number of visible data rows
   DATA rowPos INIT 1                      // Current row position
   DATA rowPosOld INIT 1                      // Current row position (after :Paint())
   DATA rowCurrCount INIT 0                    // Current number of rows
   DATA colPos INIT 1                      // Current column position
   DATA nColumns                               // Number of visible data columns
   DATA nLeftCol                               // Leftmost column
   DATA freeze                                 // Number of columns to freeze
   DATA nRecords                               // Number of records in browse
   DATA nCurrent INIT 1                      // Current record
   DATA aArray                                 // An array browsed if this is BROWSE ARRAY
   DATA recCurr INIT 0
   DATA oStyleHead                             // An HStyle object to draw the header
   DATA oStyleFoot                             // An HStyle object to draw the footer
   DATA oStyleCell                             // An HStyle object to draw the cell
   DATA headColor                              // Header text color
   DATA sepColor INIT 12632256               // Separators color
   DATA oPenSep, oPenHdr, oPen3d
   DATA lSep3d INIT .F.
   DATA aPadding INIT {4, 2, 4, 2}
   DATA aHeadPadding INIT {4, 0, 4, 0}
   DATA lInFocus INIT .F.                    // Set focus in :Paint()
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
   DATA lAppable INIT .F.
   DATA lAppMode INIT .F.
   DATA lAutoEdit INIT .F.
   DATA lUpdated INIT .F.
   DATA lAppended INIT .F.
   DATA lEditing INIT .F.                     // .T., if a field is edited now
   DATA lAdjRight INIT .T.                     // Adjust last column to right
   DATA nHeadRows INIT 1                       // Rows in header
   DATA nFootRows INIT 0                       // Rows in footer
   DATA nCtrlPress INIT 0                      // Left or Right Ctrl key code while Ctrl key is pressed
   DATA aSelected                              // An array of selected records numbers
   DATA nPaintRow, nPaintCol                   // Row/Col being painted

   DATA area
   DATA hScrollV INIT NIL
   DATA hScrollH INIT NIL
   DATA nScrollV INIT 0
   DATA nScrollH INIT 0
   DATA oGet, nGetRec
   DATA oEdit
   DATA lBtnDbl INIT .F.
   DATA nCursor INIT 0
   DATA lSetAdj INIT .F.
   DATA nHCCharset INIT -1                     // Charset for MEMO EDIT -1: set default value
                                               // For compatibiltity purposes, do not modify
                                               // with UTF-8
   // --- International Language Support for internal dialogs ---
   DATA cTextTitME INIT "Memo Edit"
   DATA cTextClose INIT "Close"   // Button
   DATA cTextSave INIT "Save"
   DATA cTextMod INIT "Memo was modified, save ?"
   DATA cTextLockRec INIT "Can't lock the record!"

   METHOD New(lType, oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, ;
      bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoVScroll, lNoBorder, ;
      lAppend, lAutoedit, bUpdate, bKeyDown, bPosChg, lMultiSelect, bRClick )
   METHOD InitBrw(nType)
   METHOD Rebuild(hDC)
   METHOD Activate()
   METHOD Init()
   METHOD DefaultLang()         // Reset of messages to default value English
   METHOD onEvent(msg, wParam, lParam)
   METHOD AddColumn(oColumn)
   METHOD InsColumn(oColumn, nPos)
   METHOD DelColumn(nPos)
   METHOD Paint()
   METHOD LineOut(nstroka, vybfld, hDC, lSelected, lClear)
   METHOD DrawHeader(hDC, nColumn, x1, y1, x2, y2)
   METHOD HeaderOut(hDC)
   METHOD FooterOut(hDC)
   METHOD SetColumn(nCol)
   METHOD DoHScroll(wParam)
   METHOD DoVScroll(wParam)
   METHOD LineDown(lMouse)
   METHOD LineUp(lMouse)
   METHOD PageUp(lMouse)
   METHOD PageDown(lMouse)
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
   METHOD APPEND() INLINE (::Bottom(.F.), ::LineDown())
   METHOD RefreshLine()
   METHOD Refresh(lFull)
   METHOD Setfocus() INLINE hwg_SetFocus(::area)
   METHOD Repaint()  // only internal usage on GTK
   METHOD End()

ENDCLASS

METHOD HBrowse:New(lType, oWndParent, nId, nStyle, nX, nY, nWidth, nHeight, oFont, ;
      bInit, bSize, bPaint, bEnter, bGfocus, bLfocus, lNoVScroll, ;
      lNoBorder, lAppend, lAutoedit, bUpdate, bKeyDown, bPosChg, lMultiSelect, bRClick)

   nStyle := hb_bitor(IIf(nStyle == NIL, 0,nStyle), WS_CHILD + WS_VISIBLE +  ;
      IIf(lNoBorder == NIL .OR. !lNoBorder, WS_BORDER, 0) +            ;
      IIf(lNoVScroll == NIL .OR. !lNoVScroll, WS_VSCROLL, 0))

   ::Super:New(oWndParent, nId, nStyle, nX, nY, IIf(nWidth == NIL, 0, nWidth), IIf(nHeight == NIL, 0, nHeight), oFont, bInit, bSize, bPaint)

   ::type := lType
   IF oFont == NIL
      ::oFont := ::oParent:oFont
   ENDIF
   ::bEnter := bEnter
   ::bRClick := bRClick
   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus

   ::lAppable := IIf(lAppend == NIL, .F., lAppend)
   ::lAutoEdit := IIf(lAutoedit == NIL, .F., lAutoedit)
   ::bUpdate := bUpdate
   ::bKeyDown := bKeyDown
   ::bPosChanged := bPosChg
   IF lMultiSelect != NIL .AND. lMultiSelect
      ::aSelected := {}
   ENDIF

   ::tcolor := 0
   ::bcolor := 0xFFFFFF
   ::tcolorSel := ::httColor := 0xFFFFFF
   ::bcolorSel := 0x808080
   ::htbColor := 2896388 // TODO: converter para hexadecimal

   ::InitBrw()
   ::Activate()

   RETURN Self


METHOD HBrowse:DefaultLang()
   ::cTextTitME := "Memo Edit"
   ::cTextClose := "Close"   // Button
   ::cTextSave := "Save"
   ::cTextMod := "Memo was modified, save ?"
   ::cTextLockRec := "Can't lock the record!"
   RETURN Self

METHOD HBrowse:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbrowse(Self)
      ::Init()
   ENDIF

   RETURN Self

/* Event handler */
METHOD HBrowse:onEvent(msg, wParam, lParam)

   LOCAL aCoors
   LOCAL retValue := -1

   // hwg_WriteLog("Brw: "+Str(msg, 6)+"|"+Str(wParam, 10)+"|"+Str(lParam, 10))
   IF ::active .AND. !Empty(::aColumns)

      IF hb_IsBlock(::bOther)
         Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF

      IF msg == WM_PAINT
         ::Paint()
         retValue := 1

      ELSEIF msg == WM_ERASEBKGND
         IF ::brush != NIL

            aCoors := hwg_Getclientrect(::handle)
            hwg_Fillrect(wParam, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, ::brush:handle)
            retValue := 1
         ENDIF

      ELSEIF msg == WM_SETFOCUS
         IF hb_IsBlock(::bGetFocus)
            Eval(::bGetFocus, Self)
         ENDIF

      ELSEIF msg == WM_KILLFOCUS
         IF hb_IsBlock(::bLostFocus)
            Eval(::bLostFocus, Self)
         ENDIF

      ELSEIF msg == WM_HSCROLL
         ::DoHScroll()

      ELSEIF msg == WM_VSCROLL
         ::DoVScroll(wParam)

      ELSEIF msg == WM_COMMAND
         hwg_DlgCommand(Self, wParam, lParam)


      ELSEIF msg == WM_KEYUP
         IF wParam == GDK_Control_L .OR. wParam == GDK_Control_R
            IF wParam == ::nCtrlPress
               ::nCtrlPress := 0
            ENDIF
         ENDIF
         retValue := 1
      ELSEIF msg == WM_KEYDOWN
         IF hb_IsBlock(::bKeyDown)
            IF !Eval(::bKeyDown, Self, wParam)
               RETURN 1
            ENDIF
         ENDIF
         IF wParam == GDK_Down        // Down
            ::LINEDOWN()
         ELSEIF wParam == GDK_Up    // Up
            ::LINEUP()
         ELSEIF wParam == GDK_Right    // Right
            LineRight(Self)
         ELSEIF wParam == GDK_Left    // Left
            LineLeft(Self)
         ELSEIF wParam == GDK_Home    // Home
            ::DoHScroll(SB_LEFT)
         ELSEIF wParam == GDK_End    // End
            ::DoHScroll(SB_RIGHT)
         ELSEIF wParam == GDK_Page_Down    // PageDown
            IF ::nCtrlPress != 0
               ::BOTTOM()
            ELSE
               ::PageDown()
            ENDIF
         ELSEIF wParam == GDK_Page_Up    // PageUp
            IF ::nCtrlPress != 0
               ::TOP()
            ELSE
               ::PageUp()
            ENDIF
         ELSEIF wParam == GDK_Return  // Enter
            ::Edit()
         ELSEIF wParam == GDK_Control_L .OR. wParam == GDK_Control_R
            IF ::nCtrlPress == 0
               ::nCtrlPress := wParam
            ENDIF
         ELSEIF (wParam >= 48 .AND. wParam <= 90 .OR. wParam >= 96 .AND. wParam <= 111) .AND. ::lAutoEdit
            ::Edit(wParam, lParam)
         ENDIF
         retValue := 1

      ELSEIF msg == WM_LBUTTONDOWN
         // hwg_WriteLog("Brw: WM_LBUTTONDOWN")
         ::ButtonDown(lParam)

      ELSEIF msg == WM_LBUTTONUP
         // hwg_WriteLog("Brw: WM_LBUTTONUP")
         ::ButtonUp(lParam)

      ELSEIF msg == WM_LBUTTONDBLCLK
         // hwg_WriteLog("Brw: WM_LBUTTONDBLCLK")
         ::ButtonDbl(lParam)

      ELSEIF msg == WM_RBUTTONDOWN
         // hwg_WriteLog("Brw: WM_RBUTTONDOWN")
         ::ButtonRDown(lParam)

      ELSEIF msg == WM_MOUSEMOVE
         // hwg_WriteLog("Brw: WM_MOUSEMOVE")
         ::MouseMove(wParam, lParam)

      ELSEIF msg == WM_MOUSEWHEEL
         // hwg_WriteLog("Brw: WM_MOUSEWHEEL")
         ::MouseWheel(hwg_Loword(wParam), If(hwg_Hiword(wParam) > 32768, hwg_Hiword(wParam) - 65535, hwg_Hiword(wParam)), hwg_Loword(lParam), hwg_Hiword(lParam))
      ELSEIF msg == WM_DESTROY
         ::End()
      ENDIF

   ENDIF

   RETURN retValue

METHOD HBrowse:Init()

   IF !::lInit
      ::Super:Init()
      // hwg_Setwindowobject(::handle, Self)
   ENDIF

   RETURN NIL

METHOD HBrowse:AddColumn(oColumn)

   LOCAL n
   LOCAL arr

   IF hb_IsArray(oColumn)
      arr := oColumn
      n := Len(arr)
      oColumn := HColumn():New(IIf(n > 0, arr[1], NIL), IIf(n > 1, arr[2], NIL), IIf(n > 2, arr[3], NIL), IIf(n > 3, arr[4], NIL), IIf(n > 4, arr[5], NIL), IIf(n > 5, arr[6], NIL))
   ENDIF
   AAdd(::aColumns, oColumn)
   ::lChanged := .T.
   InitColumn(Self, oColumn, Len(::aColumns))

   RETURN oColumn

METHOD HBrowse:InsColumn(oColumn, nPos)

   AAdd(::aColumns, NIL)
   AIns(::aColumns, nPos)
   ::aColumns[nPos] := oColumn
   ::lChanged := .T.
   InitColumn(Self, oColumn, nPos)

   RETURN oColumn

STATIC FUNCTION InitColumn(oBrw, oColumn, n)

   IF oColumn:type == NIL
      oColumn:type := ValType(Eval(oColumn:block, , oBrw, n))
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
         oColumn:length := Len(Transform(Eval(oColumn:block, , oBrw, n), oColumn:picture))
      ELSE
         oColumn:length := 10
      ENDIF
      oColumn:length := Max(oColumn:length, Len(oColumn:heading))
   ENDIF
   // DF7BE: If century is on, the length of date field must set to 10
   IF oColumn:type == "D"
     IF hwg_getCentury()
      oColumn:length := Max(oColumn:length, 10)
     ENDIF
   ENDIF
   RETURN NIL

METHOD HBrowse:DelColumn(nPos)

   ADel(::aColumns, nPos)
   ASize(::aColumns, Len(::aColumns) - 1)
   ::lChanged := .T.

   RETURN NIL

METHOD HBrowse:End()

   hwg_ReleaseObject(::area)
   IF ::hScrollV != NIL
      hwg_ReleaseObject(::hScrollV)
   ENDIF
   IF ::hScrollH != NIL
      hwg_ReleaseObject(::hScrollH)
   ENDIF

   ::Super:End()
   IF ::brush != NIL
      ::brush:Release()
      ::brush := NIL
   ENDIF
   IF ::brushSel != NIL
      ::brushSel:Release()
      ::brushSel := NIL
   ENDIF

   RETURN NIL

METHOD HBrowse:InitBrw(nType)

   IF nType != NIL
      ::type := nType
   ELSE
      ::aColumns := {}
      ::nRecords := 0
      ::nLeftCol := 1
      ::lRefrLinesOnly := .F.
      ::lRefrHead := .T.
      ::aArray := NIL
      ::freeze := ::height := 0

      IF Empty(s_crossCursor)
         s_crossCursor := hwg_Loadcursor(GDK_CROSS)
         s_arrowCursor := hwg_Loadcursor(GDK_LEFT_PTR)
         s_vCursor := hwg_Loadcursor(GDK_SB_V_DOUBLE_ARROW)
      ENDIF
   ENDIF
   ::rowPos := ::rowPosOld := ::nCurrent := ::colpos := 1

   IF ::type == BRW_DATABASE
      ::alias := Alias()
      ::bSkip :=  {|o, n|HB_SYMBOL_UNUSED(o), (::alias)->(dbSkip(n))}
      ::bGoTop :=  {||(::alias)->(DBGOTOP())}
      ::bGoBot :=  {||(::alias)->(dbGoBottom())}
      ::bEof :=  {||(::alias)->(Eof())}
      ::bBof :=  {||(::alias)->(Bof())}
      ::bRcou :=  {||(::alias)->(RecCount())}
      ::bRecnoLog := ::bRecno := {||(::alias)->(RecNo())}
      ::bGoTo :=  {|o, n|HB_SYMBOL_UNUSED(o), (::alias)->(dbGoto(n))}

   ELSEIF ::type == BRW_ARRAY
      ::bSKip := {|o, x|ARSKIP(o, x)}
      ::bGoTop := {|o|o:nCurrent := 1}
      ::bGoBot := {|o|o:nCurrent := o:nRecords}
      ::bEof := {|o|o:nCurrent > o:nRecords}
      ::bBof := {|o|o:nCurrent == 0}
      ::bRcou := {|o|Len(o:aArray)}
      ::bRecnoLog := ::bRecno := {|o|o:nCurrent}
      ::bGoTo := {|o, n|o:nCurrent := n}
      ::bScrollPos := {|o, n, lEof, nPos|hwg_VScrollPos(o, n, lEof, nPos)}

   ENDIF

   RETURN NIL

/* Added: hDC */
METHOD HBrowse:Rebuild(hDC)

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
   ENDIF
   IF ::bcolorSel != NIL
      ::brushSel := HBrush():Add(::bcolorSel)
   ENDIF
   ::nLeftCol := ::freeze + 1
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
            IF hb_IsObject(oColumn:aBitmaps[j, 2])
               xSize := Max(xSize, oColumn:aBitmaps[j, 2]:nWidth + 2)
               ::minHeight := Max(::minHeight, oColumn:aBitmaps[j, 2]:nHeight)
            ENDIF
         NEXT
      ELSE
         xSize := Round((nColLen) * arr[2], 0)
      ENDIF

      IF oColumn:length < 0
         oColumn:width := Abs(oColumn:length)
      ELSE
         oColumn:width := xSize + ::aPadding[1] + ::aPadding[3]
      ENDIF

   NEXT

   ::lChanged := .F.

   RETURN NIL

METHOD HBrowse:Paint()

   LOCAL aCoors
   LOCAL i
   LOCAL l
   LOCAL tmp
   LOCAL nRows
   LOCAL hDC
 
   // Variables not used
   // LOCAL oldAlias, pps
   // LOCAL oldBkColor, oldTColor

   IF !::active .OR. Empty(::aColumns)
      RETURN NIL
   ENDIF

   hDC := hwg_Getdc(::area)

   if ::oFont != NIL
      hwg_Selectobject(hDC, ::oFont:handle)
   ENDIF
   IF ::brush == NIL .OR. ::lChanged
      ::Rebuild(hDC)
   ENDIF
   IF ::oPenSep:color != ::sepColor
      ::oPenSep:Release()
      ::oPenSep := HPen():Add(PS_SOLID, 1, ::sepColor)
   ENDIF
   aCoors := hwg_Getclientrect(::handle)

   IF hb_bitand(::style, WS_BORDER) != 0
      hwg_gtk_drawedge(hDC, aCoors[1], aCoors[2], aCoors[3] - 1, aCoors[4] - 1, 6)
      i := 1
   ELSE
      i := 0
   ENDIF

   ::height := IIf(::nRowHeight > 0, ::nRowHeight, Max(::nRowTextHeight, ::minHeight) + 1 + ::aPadding[2] + ::aPadding[4])
   ::x1 := aCoors[1] + i
   ::y1 := aCoors[2] + IIf(::lDispHead, ::nRowTextHeight * ::nHeadRows + ::aHeadPadding[2] + ::aHeadPadding[4], 0) + i
   ::x2 := aCoors[3] - i
   ::y2 := aCoors[4] - i
   ::nRecords := Eval(::bRcou, Self)
   IF ::nCurrent > ::nRecords .AND. ::nRecords > 0
      ::nCurrent := ::nRecords
   ENDIF

   ::nColumns := FldCount(Self, ::x1 + 2, ::x2 - 2, ::nLeftCol)
   ::rowCount := Int((::y2 - ::y1) / (::height + 1)) - ::nFootRows
   nRows := Min(::nRecords, ::rowCount)

   IF ::hScrollV != NIL
      tmp := IIf(::nRecords < 100, ::nRecords, 100)
      i := IIf(::nRecords < 100, 1, ::nRecords / 100)
      IF hwg_SetAdjOptions(::hScrollV, NIL, tmp + nRows, i, nRows, nRows)
         ::lSetAdj := .T.
      ENDIF
   ENDIF
   IF ::hScrollH != NIL
      tmp := Len(::aColumns)
      hwg_SetAdjOptions(::hScrollH, NIL, tmp + 1, 1, 1, 1)
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
         Eval(::bSkip, Self, - (::rowPos - 1))
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
         i ++
         Eval(::bSkip, Self, 1)
      ENDDO
      ::rowCurrCount := i - 1

         IF ::rowPos >= i
            ::rowPos := IIf(i > 1, i - 1, 1)
         ENDIF
         DO WHILE i <= nRows
            ::LineOut(i, 0, hDC, .F., .T.)
            i ++
         ENDDO

         Eval(::bGoTo, Self, tmp)

         hwg_Fillrect(hDC, ::x1, ::y1 + (::height + 1) * nRows, ::x2, ::y2, ::brush:handle)
      ENDIF
      IF ::lAppMode
         ::LineOut(nRows + 1, 0, hDC, .F., .T.)
      ENDIF

      ::LineOut(::rowPos, ::colpos, hDC, .T.)

   IF ::lRefrHead .OR. ::lAppMode
      ::HeaderOut(hDC)
      IF ::nFootRows > 0
         ::FooterOut(hDC)
      ENDIF
   ENDIF

   hwg_Releasedc(::area, hDC)
   ::lRefrHead := .T.
   ::lRefrLinesOnly := .F.
   ::rowPosOld := ::rowPos
   tmp := Eval(::bRecno, Self)
   IF ::recCurr != tmp
      ::recCurr := tmp
      IF hb_IsBlock(::bPosChanged)
         Eval(::bPosChanged, Self, ::nCurrent)
      ENDIF
   ENDIF

   IF ::lAppMode
      ::Edit()
   ENDIF

   IF ::lInFocus .AND. ::oGet == NIL .AND. ((tmp := hwg_Getfocus()) == ::oParent:handle .OR. ;
         ::oParent:FindControl(NIL, tmp) != NIL )
      hwg_Setfocus(::area)
   ENDIF

   ::lAppMode := .F.

   RETURN NIL

METHOD HBrowse:DrawHeader(hDC, nColumn, x1, y1, x2, y2)

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

   IF hb_IsBlock(block := hwg_getPaintCB(aCB, PAINT_HEAD_ALL))
      RETURN Eval(block, oColumn, hDC, x1, y1, x2, y2, nColumn)
   ENDIF

   IF hb_IsBlock(block := hwg_getPaintCB(aCB, PAINT_HEAD_BACK))
      Eval(block, oColumn, hDC, x1, y1, x2, y2, nColumn)
   ELSEIF oColumn:oStyleHead != NIL
      oColumn:oStyleHead:Draw(hDC, x1, y1, x2, y2)
   ELSEIF ::oStyleHead != NIL
      ::oStyleHead:Draw(hDC, x1, y1, x2, y2)
   ELSE
      hwg_Drawbutton(hDC, x1, y1, x2, y2, IIf(oColumn:cGrid == NIL, 5, 0))
   ENDIF

   IF oColumn:cGrid != NIL
      hwg_Selectobject(hDC, ::oPenHdr:handle)
      cStr := oColumn:cGrid + ";"
      FOR nLine := 1 TO ::nHeadRows
         cNWSE := hb_tokenGet(@cStr, nLine, ";")
         ya := y1 + nHeight * nLine + ::aHeadPadding[2] + IIf(nLine == ::nHeadRows, ::aHeadPadding[4], 0)
         yb := y1 + nHeight * (nLine - 1) + IIf(nLine == 1, 0, ::aHeadPadding[2])
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
      NEXT
   ENDIF

   IF hb_IsChar(oColumn:heading)
      hwg_Drawtext(hDC, oColumn:heading, x1 + 1 + ::aHeadPadding[1], y1 + 1 + ::aHeadPadding[2], x2 + 1 + ::aHeadPadding[3], y1 + nHeight + ::aHeadPadding[2], oColumn:nJusHead)
   ELSE
      FOR nLine := 1 TO Len(oColumn:heading)
         IF !Empty(oColumn:heading[nLine])
            hwg_Drawtext(hDC, oColumn:heading[nLine], x1 + 1 + ::aHeadPadding[1], ;
               y1 + nHeight * (nLine - 1) + 1 + ::aHeadPadding[2], x2 - ::aHeadPadding[3], ;
               y1 + nHeight * nLine + ::aHeadPadding[2], ;
               oColumn:nJusHead  + IIf(oColumn:lSpandHead, DT_NOCLIP, 0))
         ENDIF
      NEXT
   ENDIF

   IF !Empty(aCB := hwg_getPaintCB(aCB, PAINT_HEAD_ITEM))
      FOR i := 1 TO Len(aCB)
         Eval(aCB[i], oColumn, hDC, x1, y1, x2, y2, nColumn)
      NEXT
   ENDIF

   RETURN NIL

METHOD HBrowse:HeaderOut(hDC)

   LOCAL i
   LOCAL x
   LOCAL y1
   LOCAL oldc
   LOCAL fif
   LOCAL xSize
   LOCAL nRows := Min(::nRecords + IIf(::lAppMode, 1, 0), ::rowCount)

   IF ::lDispSep
      hwg_Selectobject(hDC, ::oPenSep:handle)
   ENDIF

   x := ::x1
   y1 := ::y1 - ::nRowTextHeight * ::nHeadRows - ::aHeadPadding[2] - ::aHeadPadding[4]
   IF ::headColor != NIL
      oldc := hwg_Settextcolor(hDC, ::headColor)
   ENDIF
   fif := IIf(::freeze > 0, 1, ::nLeftCol)

   DO WHILE x < ::x2 - 2
      xSize := ::aColumns[fif]:width
      IF ::lAdjRight .AND. fif == Len(::aColumns)
         xSize := Max(::x2 - x, xSize)
      ENDIF
      IF ::lDispHead .AND. !::lAppMode
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
      fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
      IF fif > Len(::aColumns)
         EXIT
      ENDIF
   ENDDO

   IF ::lDispSep
      FOR i := 1 TO nRows
         hwg_Drawline(hDC, ::x1, ::y1 + (::height + 1) * i, IIf(::lAdjRight, ::x2, x), ::y1 + (::height + 1) * i)
      NEXT
   ENDIF
   IF ::headColor != NIL
      hwg_Settextcolor(hDC, oldc)
   ENDIF

   RETURN NIL

METHOD HBrowse:FooterOut(hDC)

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
   fif := IIf(::freeze > 0, 1, ::nLeftCol)

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
      IF hb_IsBlock(block := hwg_getPaintCB(aCB, PAINT_FOOT_ALL))
         RETURN Eval(block, oColumn, hDC, x, y1, x2, y2, fif)
      ELSE
         IF hb_IsBlock(block := hwg_getPaintCB(aCB, PAINT_FOOT_BACK))
            Eval(block, oColumn, hDC, x, y1, x2, y2, fif)
         ELSEIF oColumn:oStyleFoot != NIL
            oColumn:oStyleFoot:Draw(hDC, x, y1, x2, y2)
         ELSEIF ::oStyleFoot != NIL
            ::oStyleFoot:Draw(hDC, x, y1, x2, y2)
         ELSE
            hwg_Drawbutton(hDC, x, y1, x2, y2, 5)
         ENDIF

         IF oColumn:footing != NIL
            hwg_Settransparentmode(hDC, .T.)
            IF hb_IsChar(oColumn:footing)
               hwg_Drawtext(hDC, oColumn:footing, ;
                  x + ::aHeadPadding[1], y1 + ::aHeadPadding[2], ;
                  x2 - ::aHeadPadding[3], y2 - ::aHeadPadding[4], oColumn:nJusLin + IIf(oColumn:lSpandFoot, DT_NOCLIP, 0))
            ELSE
               FOR nLine := 1 TO Len(oColumn:footing)
                  IF !Empty(oColumn:footing[nLine])
                     hwg_Drawtext(hDC, oColumn:footing[nLine], ;
                        x + ::aHeadPadding[1], y1 + (nLine - 1) * (::height + 1) + 1, ;
                        x2 - ::aHeadPadding[3], ::y1 + nLine * (::height + 1), ;
                        oColumn:nJusLin + IIf(oColumn:lSpandFoot, DT_NOCLIP, 0))
                  ENDIF
               NEXT
            ENDIF
            hwg_Settransparentmode(hDC, .F.)
         ENDIF
         IF !Empty(aCB := hwg_getPaintCB(aCB, PAINT_FOOT_ITEM))
            FOR i := 1 TO Len(aCB)
               Eval(aCB[i], oColumn, hDC, x, y1, x2, y2, fif)
            NEXT
         ENDIF
      ENDIF
      hwg_Selectobject(hDC, ::oPenSep:handle)
      IF ::lDispSep .AND. x > ::x1
         IF ::lSep3d
            hwg_Selectobject(hDC, ::oPen3d:handle)
            hwg_Drawline(hDC, x - 1, y1+1, x - 1, y2-1)
            hwg_Selectobject(hDC, ::oPenSep:handle)
            hwg_Drawline(hDC, x - 2, y1 + 1, x - 2, y2 - 1)
         ELSE
            hwg_Drawline(hDC, x - 1, y1 + 1, x - 1, y2 - 1)
         ENDIF
      ENDIF
      x += xSize
      fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
      IF fif > Len(::aColumns)
         EXIT
      ENDIF
   ENDDO

   IF ::lDispSep
      hwg_Drawline(hDC, ::x1, y1, IIf(::lAdjRight, ::x2, x), y1)
   ENDIF

   RETURN NIL

/* Added: nstroka, vybfld, hDC, lSelected, lClear */
METHOD HBrowse:LineOut(nstroka, vybfld, hDC, lSelected, lClear)

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
   LOCAL oBrushLine := IIf(lSelected, ::brushSel, ::brush)
   LOCAL oBrushSele := IIf(vybfld >= 1, HBrush():Add(::htbColor), NIL)
   LOCAL lColumnFont := .F.
   LOCAL aCores
   LOCAL oColumn
   LOCAL aCB
   LOCAL block

   // Variables not used
   // dx, shablon, fldname, slen
   x := ::x1
   IF lClear == NIL
      lClear := .F.
   ENDIF

   IF hb_IsBlock(::bLineOut)
      Eval(::bLineOut, Self, lSelected)
   ENDIF
   IF ::nRecords > 0
      oldBkColor := hwg_Setbkcolor(hDC, IIf(lSelected,::bcolorSel,::bcolor))
      oldTColor := hwg_Settextcolor(hDC, IIf(lSelected,::tcolorSel,::tcolor))
      // fldname := Space(8)
      nCol := ::nPaintCol := IIf(::freeze > 0, 1, ::nLeftCol)
      ::nPaintRow := nstroka

      WHILE x < ::x2 - 2
         oColumn := ::aColumns[nCol]
         IF hb_IsBlock(oColumn:bColorBlock)
            aCores := Eval(oColumn:bColorBlock, Self, nstroka, nCol)
            IF lSelected
               oColumn:tColor := IIf(vybfld == i .AND. Len(aCores) >= 5 .AND. aCores[5] != NIL, aCores[5], aCores[3])
               oColumn:bColor := IIf(vybfld == i .AND. Len(aCores) >= 6 .AND. aCores[6] != NIL, aCores[6], aCores[4])
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
            xSize := Max(::x2 - x, xSize)
         ENDIF

         aCB := oColumn:aPaintCB
         x2 := x + xSize - IIf(::lSep3d, 2, 1)
         y1 := ::y1 + (::height + 1) * (nstroka - 1) + 1
         y2 := ::y1 + (::height + 1) * nstroka
         IF hb_IsBlock(block := hwg_getPaintCB(aCB, PAINT_LINE_ALL))
            Eval(block, oColumn, hDC, x, y1, x2, y2, nCol)
         ELSE
            IF hb_IsBlock(block := hwg_getPaintCB(aCB, PAINT_LINE_BACK))
               Eval(block, oColumn, hDC, x, y1, x2, y2, nCol)
            ELSEIF oColumn:oStyleCell != NIL
               oColumn:oStyleCell:Draw(hDC, x, y1, x2, y2)
            ELSEIF ::oStyleCell != NIL
               ::oStyleCell:Draw(hDC, x, y1, x2, y2)
            ELSE
               hBReal := IIf(oColumn:brush != NIL, oColumn:brush:handle, IIf(vybfld == i, oBrushSele, oBrushLine):handle)
               hwg_Fillrect(hDC, x, y1, x2, y2, hBReal)
            ENDIF
            IF !lClear
               IF oColumn:aBitmaps != NIL .AND. !Empty(oColumn:aBitmaps)
                  FOR j := 1 TO Len(oColumn:aBitmaps)
                     IF Eval(oColumn:aBitmaps[j, 1], Eval(oColumn:block, , Self, nCol), lSelected)
                        IF !Empty(ob := oColumn:aBitmaps[j, 2])
                           bh := ::height
                           bw := Int(ob:nWidth * (ob:nHeight / ::height))
                           hwg_Drawbitmap(hDC, ob:handle, NIL, x + ::aPadding[1], y1 + ::aPadding[2], bw, bh)
                        ENDIF
                        EXIT
                     ENDIF
                  NEXT
               ELSE
                  hwg_Settextcolor(hDC, IIf(oColumn:tColor != NIL, oColumn:tColor, IIf(vybfld == i, ::httcolor, IIf(lSelected, ::tcolorSel, ::tcolor))))
                  hwg_Setbkcolor(hDC, IIf(oColumn:bColor != NIL, oColumn:bColor, IIf(vybfld == i, ::htbcolor, IIf(lSelected, ::bcolorSel, ::bcolor))))

                  IF oColumn:oFont != NIL
                     hwg_Selectobject(hDC, oColumn:oFont:handle)
                     lColumnFont := .T.
                  ELSEIF lColumnFont
                     IF ::oFont != NIL
                        hwg_Selectobject(hDC, ::oFont:handle)
                     ENDIF
                     lColumnFont := .F.
                  ENDIF

                  IF !Empty(sviv := AllTrim(FLDSTR(Self, nCol)))
                     hwg_Drawtext(hDC, sviv, x + ::aPadding[1], y1 + ::aPadding[2], x2 + 1 + ::aPadding[3], y2 - 1 - ::aPadding[4], oColumn:nJusLin, .T.)
                  ENDIF
                  IF !Empty(aCB := hwg_getPaintCB(aCB, PAINT_LINE_ITEM))
                     FOR j := 1 TO Len(aCB)
                        Eval(aCB[j], oColumn, hDC, x, y1, x2, y2, nCol)
                     NEXT
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
         x += xSize
         nCol := ::nPaintCol := IIf(nCol == ::freeze, ::nLeftCol, nCol + 1)
         i ++
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

METHOD HBrowse:SetColumn(nCol)

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
//         ::lRefrBmp := .T.
         IF !lPaint
            ::RefreshLine()
         ELSE
            /* hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE) */
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

STATIC FUNCTION LINERIGHT(oBrw, lRefresh)

   LOCAL maxPos
   LOCAL nPos
   LOCAL oldLeft := oBrw:nLeftCol
   LOCAL oldPos := oBrw:colpos
   LOCAL fif
   LOCAL i
   LOCAL nColumns := Len(oBrw:aColumns)

   IF oBrw:lEditable .AND. oBrw:colpos < oBrw:nColumns
      oBrw:colpos ++
   ELSEIF oBrw:nColumns + oBrw:nLeftCol - oBrw:freeze - 1 < nColumns ;
         .AND. oBrw:nLeftCol < nColumns
      i := oBrw:nLeftCol + oBrw:nColumns
      DO WHILE oBrw:nColumns + oBrw:nLeftCol - oBrw:freeze - 1 < nColumns .AND. oBrw:nLeftCol + oBrw:nColumns == i
         oBrw:nLeftCol ++
      ENDDO
      oBrw:colpos := i - oBrw:nLeftCol + 1
   ENDIF

   IF oBrw:nLeftCol != oldLeft .OR. oBrw:colpos != oldpos
      IF oBrw:hScrollH != NIL
         maxPos := hwg_getAdjValue(oBrw:hScrollH, 1) - hwg_getAdjValue(oBrw:hScrollH, 4)
         fif := IIf(oBrw:lEditable, oBrw:colpos + oBrw:nLeftCol - 1, oBrw:nLeftCol)
         nPos := IIf(fif == 1, 0, IIf(fif == nColumns, maxpos, Int((maxPos + 1) * fif / nColumns)))
         hwg_SetAdjOptions(oBrw:hScrollH, nPos)
         oBrw:nScrollH := nPos
      ENDIF
      IF lRefresh == NIL .OR. lRefresh
         IF oBrw:nLeftCol == oldLeft
            oBrw:lRefrLinesOnly := .T.
            hwg_Invalidaterect(oBrw:area, 0, oBrw:x1, oBrw:y1 + (oBrw:height + 1) * oBrw:rowPosOld - oBrw:height, oBrw:x2, oBrw:y1 + (oBrw:height + 1) * (oBrw:rowPos))
         ELSE
            hwg_Invalidaterect(oBrw:area, 0)
         ENDIF
      ENDIF
   ENDIF
   hwg_Setfocus(oBrw:area)

   RETURN NIL

STATIC FUNCTION LINELEFT(oBrw, lRefresh)

   LOCAL maxPos
   LOCAL nPos
   LOCAL oldLeft := oBrw:nLeftCol
   LOCAL oldPos := oBrw:colpos
   LOCAL fif
   LOCAL nColumns := Len(oBrw:aColumns)

   IF oBrw:lEditable
      oBrw:colpos --
   ENDIF
   IF oBrw:nLeftCol > oBrw:freeze + 1 .AND. (!oBrw:lEditable .OR. oBrw:colpos < oBrw:freeze + 1)
      oBrw:nLeftCol --
      IF !oBrw:lEditable .OR. oBrw:colpos < oBrw:freeze + 1
         oBrw:colpos := oBrw:freeze + 1
      ENDIF
   ENDIF
   IF oBrw:colpos < 1
      oBrw:colpos := 1
   ENDIF
   IF oBrw:nLeftCol != oldLeft .OR. oBrw:colpos != oldpos
      IF oBrw:hScrollH != NIL
         maxPos := hwg_getAdjValue(oBrw:hScrollH, 1) - hwg_getAdjValue(oBrw:hScrollH, 4)
         fif := IIf(oBrw:lEditable, oBrw:colpos + oBrw:nLeftCol - 1, oBrw:nLeftCol)
         nPos := IIf(fif == 1, 0, IIf(fif == nColumns, maxpos, Int((maxPos + 1) * fif / nColumns)))
         hwg_SetAdjOptions(oBrw:hScrollH, nPos)
         oBrw:nScrollH := nPos
      ENDIF
      IF lRefresh == NIL .OR. lRefresh
         IF oBrw:nLeftCol == oldLeft
            oBrw:lRefrLinesOnly := .T.
            hwg_Invalidaterect(oBrw:area, 0, oBrw:x1, oBrw:y1 + (oBrw:height + 1) * oBrw:rowPosOld - oBrw:height, oBrw:x2, oBrw:y1 + (oBrw:height + 1) * (oBrw:rowPos))
         ELSE
            hwg_Invalidaterect(oBrw:area, 0)
         ENDIF
      ENDIF
   ENDIF
   hwg_Setfocus(oBrw:area)

   RETURN NIL

METHOD HBrowse:DoVScroll(wParam)

   LOCAL nScrollV := hwg_getAdjValue(::hScrollV)
   
   HB_SYMBOL_UNUSED(wParam)

   IF ::lSetAdj
      ::lSetAdj := .F.
      RETURN 0
   ENDIF
   IF nScrollV - ::nScrollV == 1
      ::LINEDOWN(.T.)
   ELSEIF nScrollV - ::nScrollV == - 1 // SB_LINEUP
      ::LINEUP(.T.)
   ELSEIF nScrollV - ::nScrollV == 10  // SB_PAGEDOWN
      ::PAGEDOWN(.T.)
   ELSEIF nScrollV - ::nScrollV == - 10 // SB_PAGEUP
      ::PAGEUP(.T.)
   ELSE
      IF hb_IsBlock(::bScrollPos)
         Eval(::bScrollPos, Self, SB_THUMBTRACK, .F., nScrollV)
      ENDIF
   ENDIF
   ::nScrollV := nScrollV
   // hwg_WriteLog("DoVScroll " + Ltrim(Str(::nScrollV)) + " " + Ltrim(Str(::nCurrent)) + "( " + Ltrim(Str(::nRecords)) + " )")

   RETURN 0

METHOD HBrowse:DoHScroll(wParam)

   LOCAL nScrollH
   LOCAL nLeftCol
   LOCAL colpos

   IF wParam == NIL
      nScrollH := hwg_getAdjValue(::hScrollH)
      IF nScrollH - ::nScrollH < 0
         LineLeft(Self)
      ELSEIF nScrollH - ::nScrollH > 0
         LineRight(Self)
      ENDIF
   ELSE
      IF wParam == SB_LEFT
         nLeftCol := colPos := 0
         DO WHILE nLeftCol != ::nLeftCol .OR. colPos != ::colPos
            nLeftCol := ::nLeftCol
            colPos := ::colPos
            LineLeft(Self, .F.)
         ENDDO
      ELSE
         nLeftCol := colPos := 0
         DO WHILE nLeftCol != ::nLeftCol .OR. colPos != ::colPos
            nLeftCol := ::nLeftCol
            colPos := ::colPos
            LineRight(Self, .F.)
         ENDDO
      ENDIF
      hwg_Invalidaterect(::area, 0)
   ENDIF

   RETURN NIL

METHOD HBrowse:LINEDOWN(lMouse)

   LOCAL maxPos
   LOCAL nPos
   LOCAL colpos

   lMouse := IIf(lMouse == NIL, .F. , lMouse)
   Eval(::bSkip, Self, 1)
   IF Eval(::bEof, Self)
      Eval(::bSkip, Self, -1)
      IF ::lAppable .AND. ::lEditable .AND. !lMouse .AND. (::type != BRW_DATABASE .OR. !Dbinfo(DBI_ISREADONLY))
         colpos := 1
         DO WHILE colpos <= Len(::aColumns) .AND. !::aColumns[colpos]:lEditable
            colpos ++
         ENDDO
         IF colpos <= Len(::aColumns)
            ::lAppMode := .T.
         ENDIF
      ELSE
         hwg_Setfocus(::area)
         RETURN NIL
      ENDIF
   ENDIF
   ::rowPos ++
//   ::lRefrBmp := .T.
   IF ::rowPos > ::rowCount
      ::rowPos := ::rowCount
      hwg_Invalidaterect(::area, 0)
   ELSE
      ::lRefrLinesOnly := .T.
      hwg_Invalidaterect(::area, 0, ::x1, ::y1 + (::height + 1) * ::rowPosOld - ::height, ::x2, ::y1 + (::height + 1) * (::rowPos))
   ENDIF
   IF ::lAppMode
      IF ::rowPos > 1
         ::rowPos --
      ENDIF
      ::colPos := ::nLeftCol := colpos
   ENDIF
   IF !lMouse .AND. ::hScrollV != NIL
   IF hb_IsBlock(::bScrollPos)
      Eval(::bScrollPos, Self, 1, .F.)
   ELSEIF !Empty(::hScrollV)
      maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
      nPos := hwg_getAdjValue(::hScrollV)
      nPos += Int(maxPos/ (::nRecords - 1))
         IF hwg_SetAdjOptions(::hScrollV, nPos)
            ::lSetAdj := .T.
         ENDIF
         ::nScrollV := nPos
      ENDIF
   ENDIF

   hwg_Setfocus(::area)

   RETURN NIL

/* Added: lMouse */
METHOD HBrowse:LINEUP(lMouse)

   LOCAL maxPos
   LOCAL nPos

   lMouse := IIf(lMouse == NIL, .F. , lMouse)
   Eval(::bSkip, Self, -1)
   IF Eval(::bBof, Self)
      Eval(::bGoTop, Self)
   ELSE
      ::rowPos --
      IF ::rowPos == 0
         ::rowPos := 1
         hwg_Invalidaterect(::area, 0)
      ELSE
         ::lRefrLinesOnly := .T.
         hwg_Invalidaterect(::area, 0, ::x1, ::y1 + (::height + 1) * ::rowPosOld - ::height, ::x2, ::y1 + (::height + 1) * ::rowPosOld)
         hwg_Invalidaterect(::area, 0, ::x1, ::y1 + (::height + 1) * ::rowPos - ::height, ::x2, ::y1 + (::height + 1) * ::rowPos)
      ENDIF

      IF !lMouse .AND. ::hScrollV != NIL
         IF hb_IsBlock(::bScrollPos)
            Eval(::bScrollPos, Self, -1, .F.)
         ELSEIF !Empty(::hScrollV)
            maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
            nPos := hwg_getAdjValue(::hScrollV)
            nPos -= Int(maxPos/ (::nRecords - 1))
            IF hwg_SetAdjOptions(::hScrollV, nPos)
               ::lSetAdj := .T.
            ENDIF
            ::nScrollV := nPos
         ENDIF
      ENDIF

   ENDIF
   hwg_Setfocus(::area)

   RETURN NIL

/* Added: lMouse */
METHOD HBrowse:PAGEUP(lMouse)

   LOCAL maxPos
   LOCAL nPos
   LOCAL step
   LOCAL lBof := .F.

   lMouse := IIf(lMouse == NIL, .F. , lMouse)
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

   IF !lMouse .AND. ::hScrollV != NIL
      IF hb_IsBlock(::bScrollPos)
         Eval(::bScrollPos, Self, -step, lBof)
      ELSEIF !Empty(::hScrollV)
         maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
         nPos := hwg_getAdjValue(::hScrollV)
         nPos -= Int(maxPos/ (::nRecords - 1))
         nPos := Max(nPos - Int(maxPos * step / (::nRecords - 1)), 0)
         IF hwg_SetAdjOptions(::hScrollV, nPos)
            ::lSetAdj := .T.
         ENDIF
         ::nScrollV := nPos
      ENDIF
   ENDIF

   hwg_Invalidaterect(::area, 0)
   hwg_Setfocus(::area)

   RETURN NIL

/* Added: lMouse */
METHOD HBrowse:PAGEDOWN(lMouse)

   LOCAL maxPos
   LOCAL nPos
   LOCAL nRows := ::rowCurrCount
   LOCAL step := IIf(nRows > ::rowPos, nRows - ::rowPos + 1, nRows)
   LOCAL lEof

   lMouse := IIf(lMouse == NIL, .F. , lMouse)
   Eval(::bSkip, Self, step)
   ::rowPos := Min(::nRecords, nRows)
   lEof := Eval(::bEof, Self)
   IF lEof .AND. ::bScrollPos == NIL
      Eval(::bSkip, Self, -1)
   ENDIF

   IF !lMouse .AND. ::hScrollV != NIL
      IF hb_IsBlock(::bScrollPos)
         Eval(::bScrollPos, Self, step, lEof)
      ELSE
         maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
         nPos := hwg_getAdjValue(::hScrollV)
         IF lEof
            nPos := maxPos
         ELSE
            nPos := Min(nPos + Int(maxPos * step/(::nRecords - 1)), maxPos)
         ENDIF
         IF hwg_SetAdjOptions(::hScrollV, nPos)
            ::lSetAdj := .T.
         ENDIF
         ::nScrollV := nPos
      ENDIF
   ENDIF

   hwg_Invalidaterect(::area, 0)
   hwg_Setfocus(::area)

   RETURN NIL

METHOD HBrowse:BOTTOM(lPaint)

   LOCAL nPos

   ::rowPos := LastRec()
   Eval(::bGoBot, Self)
   ::rowPos := Min(::nRecords, ::rowCount)

   IF ::hScrollV != NIL
      nPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
      IF hwg_SetAdjOptions(::hScrollV, nPos)
         ::lSetAdj := .T.
      ENDIF
      ::nScrollV := nPos
   ENDIF

   hwg_Invalidaterect(::area, 0)

   IF lPaint == NIL .OR. lPaint
      hwg_Setfocus(::area)
   ENDIF

   RETURN NIL

METHOD HBrowse:TOP()

   LOCAL nPos

   ::rowPos := 1
   Eval(::bGoTop, Self)

   IF ::hScrollV != NIL
      nPos := 0
      IF hwg_SetAdjOptions(::hScrollV, nPos)
         ::lSetAdj := .T.
      ENDIF
      ::nScrollV := nPos
   ENDIF

   hwg_Invalidaterect(::area, 0)
   hwg_Setfocus(::area)

   RETURN NIL

METHOD HBrowse:ButtonDown(lParam)

   LOCAL nLine
   LOCAL step
   LOCAL res := .F.
   LOCAL nrec
   LOCAL maxPos
   LOCAL nPos
   LOCAL ym := hwg_Hiword(lParam)
   LOCAL xm := hwg_Loword(lParam)
   LOCAL x1
   LOCAL fif
   // Variables not used
   // LOCAL hBrw := ::handle

   nLine := IIf(ym < ::y1, 0, Int((ym - ::y1) / (::height + 1)) + 1)
   step := nLine - ::rowPos

   ::lBtnDbl := .F.
   x1 := ::x1
   fif := IIf(::freeze > 0, 1, ::nLeftCol)

   DO WHILE fif < (::nLeftCol + ::nColumns) .AND. fif <= Len(::aColumns) .AND. x1 + ::aColumns[fif]:width < xm
      x1 += ::aColumns[fif]:width
      fif := IIf(fif == ::freeze, ::nLeftCol, fif + 1)
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
            IF ::hScrollV != NIL
               IF hb_IsBlock(::bScrollPos)
                  Eval(::bScrollPos, Self, step, .F.)
               ELSE
                  nPos := hwg_getAdjValue(::hScrollV)
                  maxPos := hwg_getAdjValue(::hScrollV, 1) - hwg_getAdjValue(::hScrollV, 4)
                  nPos := Min(nPos + Int(maxPos * step/(::nRecords - 1)), maxPos)
                  IF hwg_SetAdjOptions(::hScrollV, nPos)
                     ::lSetAdj := .T.
                  ENDIF
               ENDIF
            ENDIF
            res := .T.
         ELSE
            Eval(::bGoTo, Self, nrec)
         ENDIF
      ENDIF
      IF ::lEditable
         IF ::colpos != fif - ::nLeftCol + 1 + :: freeze
            ::colpos := fif - ::nLeftCol + 1 + :: freeze
            IF ::hScrollH != NIL
               maxPos := hwg_getAdjValue(::hScrollH, 1) - hwg_getAdjValue(::hScrollH, 4)
               nPos := IIf(fif == 1, 0, IIf(fif == Len(::aColumns), maxpos, Int((maxPos + 1) * fif / Len(::aColumns))))
               hwg_SetAdjOptions(::hScrollH, nPos)
            ENDIF
            res := .T.
         ENDIF
      ENDIF
      IF res
         hwg_Invalidaterect(::area, 0, ::x1, ::y1 + (::height + 1) * ::rowPosOld - ::height, ::x2, ::y1 + (::height + 1) * ::rowPosOld)
         hwg_Invalidaterect(::area, 0, ::x1, ::y1 + (::height + 1) * ::rowPos - ::height, ::x2, ::y1 + (::height + 1) * ::rowPos)
      ENDIF

   ELSEIF nLine == 0 .AND. ::nCursor == 1
      ::nCursor := 2
      Hwg_SetCursor(s_vCursor, ::area)
      s_xDrag := hwg_Loword(lParam)

   ELSEIF ::lDispHead .AND. ;
         nLine >= - ::nHeadRows .AND. ;
         fif <= Len(::aColumns) .AND. ;
         ::aColumns[fif]:bHeadClick != NIL

      Eval(::aColumns[fif]:bHeadClick, Self, fif, xm, ym)

   ENDIF
   hwg_Setfocus(::area)
   RETURN NIL

METHOD HBrowse:ButtonRDown(lParam)

   LOCAL nLine
   LOCAL ym := hwg_Hiword(lParam)
   LOCAL xm := hwg_Loword(lParam)
   LOCAL x1
   LOCAL fif

   IF ::bRClick == NIL
      RETURN NIL
   ENDIF

   nLine := IIf(ym < ::y1, 0, Int((ym - ::y1) / (::height + 1)) + 1)
   x1 := ::x1
   fif := IIf(::freeze > 0, 1, ::nLeftCol)

   DO WHILE fif < (::nLeftCol + ::nColumns) .AND. x1 + ::aColumns[fif]:width < xm
      x1 += ::aColumns[fif]:width
      fif := IIf(fif == ::freeze, ::nLeftCol, fif + 1)
   ENDDO

   Eval(::bRClick, Self, fif, nLine - ::rowPos + ::nCurrent)

   RETURN NIL

METHOD HBrowse:ButtonUp(lParam)

   LOCAL hBrw := ::handle
   LOCAL xPos := hwg_Loword(lParam)
   LOCAL x := ::x1
   LOCAL x1 := xPos
   LOCAL i

   IF ::lBtnDbl
      ::lBtnDbl := .F.
      RETURN NIL
   ENDIF
   IF ::nCursor == 2
      i := IIf(::freeze > 0, 1, ::nLeftCol)
      DO WHILE x < s_xDrag
         x += ::aColumns[i]:width
         IF Abs(x - s_xDrag) < 10
            x1 := x - ::aColumns[i]:width
            EXIT
         ENDIF
         i := IIf(i == ::freeze, ::nLeftCol, i + 1)
      ENDDO
      IF xPos > x1
         ::aColumns[i]:width := xPos - x1
         Hwg_SetCursor(s_arrowCursor, ::area)
         ::nCursor := 0
         hwg_Invalidaterect(hBrw, 0)
      ENDIF
   ELSEIF ::aSelected != NIL
      IF ::nCtrlPress == GDK_Control_L
         IF (i := Ascan(::aSelected, Eval(::bRecno, Self))) > 0
            ADel(::aSelected, i)
            ASize(::aSelected, Len(::aSelected) - 1)
         ELSE
            AAdd(::aSelected, Eval(::bRecno,Self))
         ENDIF
      ELSE
         IF Len(::aSelected) > 0
            ::aSelected := {}
            ::Refresh()
         ENDIF
      ENDIF
   ENDIF

   /* DF7BE : Ticket #33, blank lines repainted here, if lost */
    ::Refresh()
   hwg_Setfocus(::area)

   RETURN NIL

METHOD HBrowse:ButtonDbl(lParam)

   LOCAL nLine
   LOCAL ym := hwg_Hiword(lParam)
   // Variables not used
   // hBrw := ::handle

   nLine := IIf(ym < ::y1, 0, Int((ym - ::y1) / (::height + 1)) + 1)
   IF nLine <= ::rowCurrCount
      ::ButtonDown(lParam)
      ::Edit()
   ENDIF
   ::lBtnDbl := .T.

   RETURN NIL

METHOD HBrowse:MouseMove(wParam, lParam)

   LOCAL xPos := hwg_Loword(lParam)
   LOCAL yPos := hwg_Hiword(lParam)
   LOCAL x := ::x1
   LOCAL i
   LOCAL res := .F.
   LOCAL nLen

   IF !::active .OR. Empty(::aColumns) .OR. ::x1 == NIL
      RETURN NIL
   ENDIF

   IF ::lDispSep .AND. yPos <= ::height + 1
      IF wParam == 1 .AND. ::nCursor == 2
         Hwg_SetCursor(s_vCursor, ::area)
         res := .T.
      ELSE
         nLen := Len(::aColumns) - IIf(::lAdjRight, 1, 0)
         i := IIf(::freeze > 0, 1, ::nLeftCol)
         DO WHILE x < ::x2 - 2 .AND. i <= nLen
            x += ::aColumns[i]:width
            IF Abs(x - xPos) < 8
               IF ::aColumns[i]:lResizable
                  IF ::nCursor != 2
                     ::nCursor := 1
                  ENDIF
                  // hwg_WriteLog("Brw: Hwg_SetCursor 1")
                  Hwg_SetCursor(IIf(::nCursor == 1, s_crossCursor, s_vCursor), ::area)
                  res := .T.
               ENDIF
               EXIT
            ENDIF
            i := IIf(i == ::freeze, ::nLeftCol, i + 1)
         ENDDO
      ENDIF
      IF !res .AND. ::nCursor != 0
         // hwg_WriteLog("Brw: Hwg_SetCursor 2")
         Hwg_SetCursor(s_arrowCursor, ::area)
         ::nCursor := 0
      ENDIF
   ENDIF

   ::Repaint()

   RETURN NIL

METHOD HBrowse:MouseWheel(nKeys, nDelta, nXPos, nYPos)

   HB_SYMBOL_UNUSED(nXPos)
   HB_SYMBOL_UNUSED(nYPos)

   // hwg_WriteLog("Brw: MouseWheel")
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
   /* DF7BE : blank lines repainted here, if lost */
   ::Refresh()
   hwg_Setfocus(::area)
   RETURN NIL

METHOD HBrowse:Edit(wParam, lParam)

   LOCAL fipos
   LOCAL lRes
   LOCAL x1
   LOCAL y1
   LOCAL fif
   LOCAL nWidth
   LOCAL rowPos
   LOCAL oColumn
   LOCAL type
   LOCAL mvarbuff
   LOCAL bMemoMod
   LOCAL owb1
   LOCAL owb2
   LOCAL oModDlg
   LOCAL bclsbutt
   LOCAL lSaveMem // DF7BE

   lSaveMem := .T.

   // Variables not used
   // lReadExit
   
   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   bclsbutt := .T. 
   
   fipos := ::colpos + ::nLeftCol - 1 - ::freeze

   oColumn := ::aColumns[fipos]
   IF ::bEnter == NIL .OR. (hb_IsLogical(lRes := Eval(::bEnter, Self, fipos, ::nCurrent)) .AND. !lRes)
      IF !oColumn:lEditable
         RETURN NIL
      ENDIF
      IF ::type == BRW_DATABASE
         IF Dbinfo(DBI_ISREADONLY)
            RETURN NIL
         ENDIF
         ::varbuf := (::alias)->(Eval(oColumn:block, , Self, fipos))
      ELSE
         ::varbuf := Eval(oColumn:block, , Self, fipos)
      ENDIF
      type := IIf(oColumn:type == "U" .AND. ::varbuf != NIL, ValType(::varbuf), oColumn:type)
      IF type != "O"
         IF oColumn:bWhen == NIL .OR. Eval(oColumn:bWhen)
            IF ::lAppMode
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
         x1 := ::x1
         fif := IIf(::freeze > 0, 1, ::nLeftCol)
         DO WHILE fif < fipos
            x1 += ::aColumns[fif]:width
            fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
         ENDDO
         nWidth := IIf(::lAdjRight .AND. fif == Len(::aColumns), ::x2 - x1 - 1, Min(::aColumns[fif]:width, ::x2 - x1 - 1))
         rowPos := ::rowPos - 1
         IF ::lAppMode .AND. ::nRecords != 0
            rowPos ++
         ENDIF
         y1 := ::y1 + (::height + 1) * rowPos
         ::nGetRec := Eval(::bRecno, Self)
         ::lEditing := .T.
         IF type != "M"
         @ x1+::nX, y1+::nY GET ::oGet VAR ::varbuf      ;
            OF ::oParent                   ;
            SIZE nWidth, ::height + 1      ;
            STYLE ES_AUTOHSCROLL           ;
            FONT ::oFont                   ;
            PICTURE oColumn:picture        ;
            VALID {||VldBrwEdit(Self, fipos)}
         ::oGet:Show()
         hwg_Setfocus(::oGet:handle)
         hwg_edit_SetPos(::oGet:handle, 0)
         ::oGet:bAnyEvent := {|o, msg, c|HB_SYMBOL_UNUSED(o), GetEventHandler(Self, msg, c)}
         ELSE  // memo edit
         // ===================================== *
         // Special dialog for memo edit (DF7BE)
         // ===================================== *
            INIT DIALOG oModDlg title ::cTextTitME AT 0, 0 SIZE 610, 410  ON INIT {|o|o:center()}
            mvarbuff := ::varbuf  // DF7BE: inter variable avoids crash at store
               // Debug: oModDlg:nWidth ==> set to 400
//               @ 10, 10 HCEDIT oEdit SIZE oModDlg:nWidth - 20, 240 ;
// DF7BE: The sizes of WinAPI are too small. Text was truncated at end of line.
               @ 0, 30 HCEDIT ::oEdit SIZE 600, 300 ;
                    FONT ::oFont
               // old 010, 252 - 100, 252 - sizes 80, 24 (too small)
               @ 010, 340 ownerbutton owb2 TEXT ::cTextSave SIZE 100, 24 ON Click {||bclsbutt := .F., mvarbuff := ::oEdit, omoddlg:close(), oModDlg:lResult := .T.}
               @ 100, 340 ownerbutton owb1 TEXT ::cTextClose SIZE 100, 24 ON CLICK {||mvarbuff := ::oEdit, omoddlg:close(), oModDlg:lResult := .T.}
//               @ 100, 340 ownerbutton owb1 TEXT ::cTextClose size 100, 24 ON CLICK {||oModDlg:close()}
                 // serve memo field for editing
                ::oEdit:SetText(mvarbuff)
            ACTIVATE DIALOG oModDlg
          / is modified ? (.T.)
          bMemoMod := ::oEdit:lUpdated // on GTK forever .T.
          IF bMemoMod
          // Close button pressed ? (Dismiss modification)
            IF bclsbutt
//         "Close" Button should be handled like "Cancel".
//          Ask for saving, if  "Close" is pressed and the memo is modified
//
//            Ask and mark vor saving
             lSaveMem := hwg_MsgYesNo(::cTextMod, ::cTextTitME)
            ENDIF
            IF lSaveMem
             // write out edited memo field
             ::varbuf := ::oEdit:GetText()
             // Store new memo contents
             VldBrwEdit(Self, fipos , .T.)
             // hwg_MsgInfo("Memo saved")  // Debug
            ENDIF  // lSaveMem
           ENDIF   // bMemoMod
//          ENDIF
          // ::lEditing := .F.
          // ===================================== *
         ENDIF // memo edit
      ENDIF
   ENDIF

   RETURN NIL


METHOD HBrowse:Repaint()
   /*
     only internal usage:
     DF7BE : blank lines repainted, if lost.
     Reference: Bug Ticket #33
   */
   ::Refresh()
   hwg_Setfocus(::area)
   RETURN NIL


STATIC FUNCTION GetEventHandler(oBrw, msg, cod)

   IF msg == WM_KEYDOWN .AND. cod == GDK_Escape
      oBrw:oGet:nLastKey := GDK_Escape
      hwg_Setfocus(oBrw:area)
      oBrw:lEditing := .F.
      RETURN 1
   ENDIF

   RETURN 0

STATIC FUNCTION VldBrwEdit(oBrw, fipos , bmemo)
// Purpose: Store edited contents
// Parameter oEdit only used, if memo edit is used.

   LOCAL oColumn := oBrw:aColumns[fipos]
   LOCAL nRec
   LOCAL fif
   LOCAL cErrMsgRecLock
   LOCAL bESCkey
   LOCAL nChoic := NIL

   /* Mysterious behavior of Harbour on Ubuntu and LinuxMINT:
      Not ever found, that  ::cTextLockRec is not here
      reachable, this function not member of HBROWSE class */
     cErrMsgRecLock := oBrw:cTextLockRec

   // Added case for memo edit (bmemo = .T.), because HCEDIT used
   IF bmemo == NIL
    bmemo := .F.
   ENDIF

   // ESC key pressed ?
   IF bmemo
    bESCkey := IIf(oBrw:oEdit:nLastKey != GDK_Escape , .F. , .T.) /* Memo edit */
   ELSE
    bESCkey := IIf(oBrw:oGet:nLastKey  != GDK_Escape , .F. , .T.) /* GET */
   ENDIF

   IF !bESCkey
      IF oColumn:aList != NIL
         IF hb_IsNumeric(oBrw:varbuf)
            oBrw:varbuf := nChoic
         ELSE
            oBrw:varbuf := oColumn:aList[nChoic]
         ENDIF
      ENDIF
      IF oBrw:lAppMode
         oBrw:lAppMode := .F.
         IF oBrw:type == BRW_DATABASE
            (oBrw:alias)->(dbAppend())
            (oBrw:alias)->(Eval(oColumn:block, oBrw:varbuf, oBrw, fipos))
            UNLOCK
         ELSE
            IF hb_IsArray(oBrw:aArray[1])
               AAdd(oBrw:aArray, Array(Len(oBrw:aArray[1])))
               FOR fif := 2 TO Len(oBrw:aArray[1])
                  oBrw:aArray[Len(oBrw:aArray),fif] := IIf(oBrw:aColumns[fif]:type == "D", CToD(Space(8)), IIf(oBrw:aColumns[fif]:type == "N", 0, ""))
               NEXT
            ELSE
               AAdd(oBrw:aArray, NIL)
            ENDIF
            oBrw:nCurrent := Len(oBrw:aArray)
            Eval(oColumn:block, oBrw:varbuf, oBrw, fipos)
         ENDIF
         IF oBrw:nRecords > 0
            oBrw:rowPos ++
         ENDIF
         oBrw:lAppended := .T.
         oBrw:Refresh()
      ELSE
         IF (nRec := Eval(oBrw:bRecno, oBrw)) != oBrw:nGetRec
            Eval(oBrw:bGoTo, oBrw, oBrw:nGetRec)
         ENDIF
         IF oBrw:type == BRW_DATABASE
            IF (oBrw:alias)->(RLock())
               (oBrw:alias)->(Eval(oColumn:block, oBrw:varbuf, oBrw, fipos))
            ELSE
            /* Can't lock the record! */
               hwg_MsgStop(cErrMsgRecLock)
            ENDIF
         ELSE
            Eval(oColumn:block, oBrw:varbuf, oBrw, fipos)
         ENDIF
         IF nRec != oBrw:nGetRec
            Eval(oBrw:bGoTo, oBrw, nRec)
         ENDIF
         oBrw:lUpdated := .T.
      ENDIF
   ENDIF  /* GDK_Escape key */

   oBrw:Refresh()
   // Execute block after changes are made
   IF (!bESCkey) .AND. hb_IsBlock(oBrw:bUpdate)
      Eval(oBrw:bUpdate, oBrw, fipos)
   ENDIF
   IF bmemo
     oBrw:oParent:DelControl(oBrw:oEdit)
     oBrw:oEdit := NIL
   ELSE
     oBrw:oParent:DelControl(oBrw:oGet)
     oBrw:oGet := NIL
   ENDIF
   hwg_Setfocus(oBrw:area)

   RETURN .T.

METHOD HBrowse:RefreshLine()

   ::lRefrLinesOnly := .T.
   hwg_Invalidaterect(::area, 0, ::x1, ::y1 + (::height + 1) * ::rowPos - ::height, ::x2, ::y1 + (::height + 1) * ::rowPos)

   RETURN NIL

METHOD HBrowse:Refresh(lFull)

   IF lFull == NIL .OR. lFull
      ::lRefrHead := .T.
      ::lRefrLinesOnly := .F.
      hwg_Redrawwindow(::area, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)
   ELSE
      ::lRefrHead := .F.
      hwg_Invalidaterect(::area, 0)
   ENDIF

   RETURN NIL

STATIC FUNCTION FldStr(oBrw, numf)

   LOCAL cRes
   LOCAL vartmp
   LOCAL type
   LOCAL pict

   IF numf <= Len(oBrw:aColumns)

      // pict := oBrw:aColumns[numf]:picture  // Double assigned

      IF oBrw:type == BRW_DATABASE
         vartmp := (oBrw:alias)->(Eval(oBrw:aColumns[numf]:block, , oBrw, numf))
      ELSE
         vartmp := Eval(oBrw:aColumns[numf]:block, , oBrw, numf)
      ENDIF

      pict := oBrw:aColumns[numf]:picture
      IF pict != NIL
         cRes := Transform(vartmp, pict)
      ELSE
         type := (oBrw:aColumns[numf]):type
         IF type == "U" .AND. vartmp != NIL
            type := ValType(vartmp)
         ENDIF
         IF type == "C"
            //cRes := PadR(vartmp, oBrw:aColumns[numf]:length)
            cRes := vartmp
         ELSEIF type == "N"
            //cRes := PadL(Str(vartmp, oBrw:aColumns[numf]:length, oBrw:aColumns[numf]:dec), oBrw:aColumns[numf]:length)
            cRes := Ltrim(Str(vartmp, 24, oBrw:aColumns[numf]:dec))
         ELSEIF type == "D"
            //cRes := PadR(Dtoc(vartmp), oBrw:aColumns[numf]:length)
            cRes := Dtoc(vartmp)

         ELSEIF type == "L"
            //cRes := PadR(IIf(vartmp, "T", "F"), oBrw:aColumns[numf]:length)
            cRes := IIf(vartmp, "T", "F")

         ELSEIF type == "M"
            cRes := IIf(Empty(vartmp), "<memo>", "<MEMO>")

         ELSEIF type == "O"
            cRes := "<" + vartmp:Classname() + ">"

         ELSEIF type == "A"
            cRes := "<Array>"

         ELSE
            //cRes := Space(oBrw:aColumns[numf]:length)
            cRes := " "
         ENDIF
      ENDIF
   ENDIF

   RETURN cRes

STATIC FUNCTION FLDCOUNT(oBrw, xstrt, xend, fld1)

   LOCAL klf := 0
   LOCAL i := IIf(oBrw:freeze > 0, 1, fld1)

   WHILE .T.
      xstrt += oBrw:aColumns[i]:width
      IF xstrt > xend
         EXIT
      ENDIF
      klf ++
      i := IIf(i = oBrw:freeze, fld1, i + 1)
      IF i > Len(oBrw:aColumns)
         EXIT
      ENDIF
   ENDDO

   RETURN IIf(klf == 0, 1, klf)

FUNCTION hwg_CREATEARLIST(oBrw, arr)

   LOCAL i

   oBrw:type := BRW_ARRAY
   oBrw:aArray := arr
   IF Len(oBrw:aColumns) == 0
      // oBrw:aColumns := {}
      IF hb_IsArray(arr[1])
         FOR i := 1 TO Len(arr[1])
            oBrw:AddColumn(HColumn():New(NIL, hwg_ColumnArBlock()))
         NEXT
      ELSE
         oBrw:AddColumn(HColumn():New(NIL, {|value, o|HB_SYMBOL_UNUSED(value), o:aArray[o:nCurrent]}))
      ENDIF
   ENDIF
   Eval(oBrw:bGoTop, oBrw)
   oBrw:Refresh()

   RETURN NIL

PROCEDURE ARSKIP(oBrw, kolskip)

   LOCAL tekzp1

   IF oBrw:nRecords != 0
      tekzp1 := oBrw:nCurrent
      oBrw:nCurrent += kolskip + IIf(tekzp1 == 0, 1, 0)
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

   oBrw:alias := Alias()

   oBrw:aColumns := {}
   FOR i := 1 TO kolf
      oBrw:AddColumn(HColumn():New(FieldName(i), FieldWBlock(FieldName(i), nArea), dbFieldInfo(DBS_TYPE, i), dbFieldInfo(DBS_LEN, i), dbFieldInfo(DBS_DEC, i), lEditable))
   NEXT

   oBrw:Refresh()

   RETURN NIL

FUNCTION hwg_VScrollPos(oBrw, nType, lEof, nPos)

   LOCAL maxPos := hwg_getAdjValue(oBrw:hScrollV, 1) - hwg_getAdjValue(oBrw:hScrollV, 4)
   LOCAL oldRecno
   LOCAL newRecno

   IF nPos == NIL
      IF nType > 0 .AND. lEof
         Eval(oBrw:bSkip, oBrw, -1)
      ENDIF
      nPos := Round((maxPos/(oBrw:nRecords - 1)) * (Eval(oBrw:bRecnoLog, oBrw) - 1), 0)
      IF hwg_SetAdjOptions(oBrw:hScrollV, nPos)
          obrw:lSetAdj := .T.
      ENDIF

      oBrw:nScrollV := nPos
   ELSE
      oldRecno := Eval(oBrw:bRecnoLog, oBrw)
      newRecno := Round((oBrw:nRecords - 1) * nPos/ maxPos + 1, 0)
      IF newRecno <= 0
         newRecno := 1
      ELSEIF newRecno > oBrw:nRecords
         newRecno := oBrw:nRecords
      ENDIF
      IF newRecno != oldRecno
         Eval(oBrw:bSkip, oBrw, newRecno - oldRecno)
         IF oBrw:rowCount - oBrw:rowPos > oBrw:nRecords - newRecno
            oBrw:rowPos := oBrw:rowCount - (oBrw:nRecords - newRecno)
         ENDIF
         IF oBrw:rowPos > newRecno
            oBrw:rowPos := newRecno
         ENDIF
         oBrw:Refresh()
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_ColumnArBlock()

   RETURN {|value, o, n|IIf(value == NIL, o:aArray[o:nCurrent,n], o:aArray[o:nCurrent,n] := value)}

STATIC FUNCTION CountToken(cStr, nMaxLen, nCount)

   nMaxLen := nCount := 0
   IF hb_IsChar(cStr)
      IF (";" $ cStr)
         cStr := hb_aTokens(cStr, ";")
      ELSE
         nMaxLen := Len(cStr)
         nCount := 1
      ENDIF
   ENDIF
   IF hb_IsArray(cStr)
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
      NEXT
   ENDIF

   RETURN aRes
