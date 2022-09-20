/*
 * HWGUI - Harbour Win32 GUI library source code:
 * Main prg level functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "guilib.ch"

FUNCTION hwg_InitControls(oWnd, lNoActivate)

   LOCAL i
   LOCAL pArray := oWnd:aControls
   LOCAL lInit

   lNoActivate := iif(lNoActivate == NIL, .F., lNoActivate)
   IF pArray != NIL
      FOR i := 1 TO Len(pArray)
         // writelog("InitControl1" + str(pArray[i]:handle) + "/" + pArray[i]:classname + " " + str(pArray[i]:nWidth) + "/" + str(pArray[i]:nHeight))
         IF Empty(pArray[i]:handle) .AND. !lNoActivate
            lInit := pArray[i]:lInit
            pArray[i]:lInit := .T.
            pArray[i]:Activate()
            pArray[i]:lInit := lInit
         ENDIF
         IF IIF(HB_ISPOINTER(pArray[i]:handle), hwg_Ptrtoulong(pArray[i]:handle), pArray[i]:handle) <= 0
         //IF Empty(pArray[i]:handle) .OR. hwg_isPtrneg1(pArray[i]:handle)
            pArray[i]:handle := hwg_Getdlgitem(oWnd:handle, pArray[i]:id)
            // writelog("InitControl2" + str(pArray[i]:handle) + "/" + pArray[i]:classname)
         ENDIF
         IF !Empty(pArray[i]:aControls)
            hwg_InitControls(pArray[i])
         ENDIF
         pArray[i]:Init()
      NEXT
   ENDIF

RETURN .T.

FUNCTION hwg_FindParent(hCtrl, nLevel)

   LOCAL i
   LOCAL oParent
   LOCAL hParent := hwg_Getparent(hCtrl)

   IF !Empty(hParent)
      IF (i := Ascan(HDialog():aModalDialogs, {|o|o:handle == hParent})) != 0
         RETURN HDialog():aModalDialogs[i]
      ELSEIF ( oParent := HDialog():FindDialog(hParent) ) != NIL
         RETURN oParent
      ELSEIF ( oParent := HWindow():FindWindow(hParent) ) != NIL
         RETURN oParent
      ENDIF
   ENDIF
   IF nLevel == NIL
      nLevel := 0
   ENDIF
   IF nLevel < 2
      IF ( oParent := hwg_FindParent(hParent, nLevel + 1) ) != NIL
         RETURN oParent:FindControl(NIL, hParent)
      ENDIF
   ENDIF

RETURN NIL

FUNCTION hwg_FindSelf(hCtrl)

   LOCAL oParent

   oParent := hwg_FindParent(hCtrl)
   IF oParent != NIL
      RETURN oParent:FindControl(NIL, hCtrl)
   ENDIF

RETURN NIL

FUNCTION hwg_WriteStatus(oWnd, nPart, cText, lRedraw)

   LOCAL aControls
   LOCAL i

   IF oWnd == NIL
      oWnd := HWindow():GetMain()
   ENDIF
   aControls := oWnd:aControls
   IF (i := Ascan(aControls, {|o|o:ClassName() = "HSTATUS"})) > 0
      hwg_SendMessage(aControls[i]:handle, SB_SETTEXT, Iif(nPart == NIL, 0, nPart - 1), cText)
      IF lRedraw != NIL .AND. lRedraw
         hwg_Redrawwindow(aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE)
      ENDIF
   ELSEIF (i := Ascan(aControls, {|o|o:ClassName() = "HPANELSTS"})) > 0
      aControls[i]:Write(cText, nPart, lRedraw)
   ENDIF

RETURN NIL

FUNCTION hwg_ColorC2N(cColor)

   LOCAL i
   LOCAL res := 0
   LOCAL n := 1
   LOCAL iValue

   IF Left(cColor, 1) == "#"
      cColor := Substr(cColor, 2)
   ENDIF
   cColor := Trim(cColor)
   FOR i := 1 TO Len(cColor)
      iValue := Asc(SubStr(cColor, i, 1))
      IF iValue < 58 .AND. iValue > 47
         iValue -= 48
      ELSEIF iValue >= 65 .AND. iValue <= 70
         iValue -= 55
      ELSEIF iValue >= 97 .AND. iValue <= 102
         iValue -= 87
      ELSE
         RETURN 0
      ENDIF
      iValue *= n
      IF i % 2 == 1
         iValue *= 16
      ELSE
         n *= 256
      ENDIF
      res += iValue
   NEXT

RETURN res

FUNCTION hwg_ColorN2C(nColor)

   LOCAL s := ""
   LOCAL n1
   LOCAL n2
   LOCAL i

   FOR i := 0 to 2
      n1 := hb_BitAnd(hb_BitShift(nColor, -i * 8 - 4), 15)
      n2 := hb_BitAnd(hb_BitShift(nColor, -i * 8), 15)
      s += Chr(Iif(n1 < 10, n1 + 48, n1 + 55)) + Chr(Iif(n2 < 10, n2 + 48, n2 + 55))
   NEXT

RETURN s

FUNCTION hwg_ColorN2RGB(nColor, nr, ng, nb)

   nr := nColor % 256
   ng := Int(nColor / 256) % 256
   nb := Int(nColor / 65536)

RETURN {nr, ng, nb}

FUNCTION hwg_MsgGet(cTitle, cText, nStyle, x, y, nDlgStyle, cRes)

   LOCAL oDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)

   IF Empty(cRes)
      cRes := ""
   ENDIF

   nStyle := iif(nStyle == NIL, 0, nStyle)
   x := iif(x == NIL, 210, x)
   y := iif(y == NIL, 10, y)
   nDlgStyle := iif(nDlgStyle == NIL, 0, nDlgStyle)

   INIT DIALOG oDlg TITLE cTitle AT x, y SIZE 300, 140 FONT oFont CLIPPER STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + nDlgStyle

   IF !Empty(cText)
      @ 20, 10 SAY cText SIZE 260, 22
   ENDIF
   @ 20, 35 GET cres SIZE 260, 26 STYLE WS_TABSTOP + nStyle MAXLENGTH 0
   Atail(oDlg:aControls):Anchor := ANCHOR_TOPABS + ANCHOR_LEFTABS + ANCHOR_RIGHTABS

   @ 20, 95 BUTTON "Ok" ID IDOK SIZE 100, 32 ON SIZE ANCHOR_BOTTOMABS
   @ 180, 95 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32 ON SIZE ANCHOR_RIGHTABS + ANCHOR_BOTTOMABS

   ACTIVATE DIALOG oDlg

   oFont:Release()
   IF oDlg:lResult
      RETURN Trim(cRes)
   ELSE
      cRes := ""
   ENDIF

RETURN cRes

FUNCTION hwg_WChoice(arr, cTitle, nLeft, nTop, oFont, clrT, clrB, clrTSel, clrBSel, cOk, cCancel)

   LOCAL oDlg
   LOCAL oBrw
   LOCAL nChoice := 0
   LOCAL lArray := .T.
   LOCAL nField
   LOCAL lNewFont := .F.
   LOCAL i
   LOCAL aLen
   LOCAL nLen := 0
   LOCAL addX := 20
   LOCAL addY := 20
   LOCAL minWidth := 0
   LOCAL x1
   LOCAL hDC
   LOCAL aMetr
   LOCAL width
   LOCAL height
   LOCAL aArea
   LOCAL aRect
   LOCAL nStyle := WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX

   IF cTitle == NIL
      cTitle := ""
   ENDIF
   IF nLeft == NIL .AND. nTop == NIL
      nStyle += DS_CENTER
   ENDIF
   IF nLeft == NIL
      nLeft := 0
   ENDIF
   IF nTop == NIL
      nTop := 0
   ENDIF
   IF oFont == NIL
      oFont := HFont():Add("MS Sans Serif", 0, -13)
      lNewFont := .T.
   ENDIF
   IF cOk != NIL
      minWidth += 120
      IF cCancel != NIL
         minWidth += 100
      ENDIF
      addY += 36
   ENDIF

   IF HB_ISCHAR(arr)
      lArray := .F.
      aLen := RecCount()
      IF ( nField := FieldPos(arr) ) == 0
         RETURN 0
      ENDIF
      nLen := dbFieldInfo(3, nField)
   ELSE
      aLen := Len(arr)
      IF HB_ISARRAY(arr[1])
         FOR i := 1 TO aLen
            nLen := Max(nLen, Len(arr[i, 1]))
         NEXT
      ELSE
         FOR i := 1 TO aLen
            nLen := Max(nLen, Len(arr[i]))
         NEXT
      ENDIF
   ENDIF

   hDC := hwg_Getdc(hwg_Getactivewindow())
   hwg_Selectobject(hDC, ofont:handle)
   aMetr := hwg_Gettextmetric(hDC)
   aArea := hwg_Getdevicearea(hDC)
   aRect := hwg_Getwindowrect(hwg_Getactivewindow())
   hwg_Releasedc(hwg_Getactivewindow(), hDC)
   height := ( aMetr[1] + 5 ) * aLen + 4 + addY + 8
   IF height > aArea[2] - aRect[2] - nTop - 60
      height := aArea[2] - aRect[2] - nTop - 60
   ENDIF
   width := Max(aMetr[2] * 2 * nLen + 8 + addX, minWidth)

   INIT DIALOG oDlg TITLE cTitle AT nLeft, nTop SIZE width, height STYLE nStyle FONT oFont ON INIT {|o|hwg_Resetwindowpos(o:handle), hwg_Setfocus(oBrw:handle)}

   IF lArray
      @ addX/2, 10 BROWSE oBrw ARRAY SIZE width - addX, height - addY
      oBrw:aArray := arr
      IF HB_ISARRAY(arr[1])
         oBrw:AddColumn(HColumn():New(NIL, {|value, o|(value), o:aArray[o:nCurrent, 1]}, "C", nLen))
      ELSE
         oBrw:AddColumn(HColumn():New(NIL, {|value, o|(value), o:aArray[o:nCurrent]}, "C", nLen))
      ENDIF
   ELSE
      @ addX/2, 10 BROWSE oBrw DATABASE SIZE width - addX, height - addY
      oBrw:AddColumn(HColumn():New(NIL, {|value, o|(value), (o:alias)->(FieldGet(nField))}, "C", nLen))
   ENDIF

   oBrw:oFont    := oFont
   oBrw:bSize    := {|o, x, y|o:Move(NIL, NIL, x - addX, y - addY)}
   oBrw:bEnter   := {|o|nChoice := o:nCurrent, hwg_EndDialog(o:oParent:handle)}
   oBrw:bKeyDown := {| o, key | ( o ), iif(key == 27, (hwg_EndDialog(oDlg:handle), .F.), .T.)}

   oBrw:lDispHead := .F.
   IF clrT != NIL
      oBrw:tcolor := clrT
   ENDIF
   IF clrB != NIL
      oBrw:bcolor := clrB
   ENDIF
   IF clrTSel != NIL
      oBrw:tcolorSel := clrTSel
   ENDIF
   IF clrBSel != NIL
      oBrw:htbColor := oBrw:bcolorSel := clrBSel
   ENDIF

   IF cOk != NIL
      x1 := Int(width / 2) - iif(cCancel != NIL, 90, 40)
      @ x1, height - 36 BUTTON cOk SIZE 80, 28 ON CLICK {||nChoice := oBrw:nCurrent, hwg_EndDialog(oDlg:handle)} ON SIZE {|o, x, y|(x), o:Move(NIL, y - 36)}
      IF cCancel != NIL
         @ x1 + 100, height - 36 BUTTON cCancel SIZE 80, 28 ON CLICK {||hwg_EndDialog(oDlg:handle)} ON SIZE {|o,x,y|o:Move(x - 100, y - 36) }
      ENDIF
   ENDIF

   oDlg:Activate()

   IF lNewFont
      oFont:Release()
   ENDIF

RETURN nChoice

FUNCTION hwg_ShowProgress(nStep, maxPos, nRange, cTitle, oWnd, x1, y1, width, height)

   STATIC oDlg
   STATIC hPBar
   STATIC iCou
   STATIC nLimit

   LOCAL nStyle := WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX

   SWITCH nStep
   CASE 0
      nLimit := iif(nRange != NIL, Int(nRange / maxPos), 1)
      iCou := 0
      x1 := iif(x1 == NIL, 0, x1)
      y1 := iif(x1 == NIL, 0, y1)
      width := iif(width == NIL, 220, width)
      height := iif(height == NIL, 55, height)
      IF x1 == 0
         nStyle += DS_CENTER
      ENDIF
      IF oWnd != NIL
         oDlg := NIL
         hPBar := hwg_Createprogressbar(oWnd:handle, maxPos, 20, 25, width - 40, 20)
      ELSE
         INIT DIALOG oDlg TITLE cTitle AT x1, y1 SIZE width, height STYLE nStyle ;
            ON INIT {|o|hPBar := hwg_Createprogressbar(o:handle, maxPos, 20, 25, width - 40, 20)}
         ACTIVATE DIALOG oDlg NOMODAL
      ENDIF
      EXIT
   CASE 1
      iCou++
      IF iCou == nLimit
         iCou := 0
         hwg_Updateprogressbar(hPBar)
      ENDIF
      EXIT
   CASE 2
      hwg_Updateprogressbar(hPBar)
      EXIT
   CASE 3
      hwg_Setwindowtext(oDlg:handle, cTitle)
      IF maxPos != NIL
         hwg_Setprogressbar(hPBar, maxPos)
      ENDIF
      EXIT
   OTHERWISE
      hwg_Destroywindow(hPBar)
      IF oDlg != NIL
         hwg_EndDialog(oDlg:handle)
      ENDIF
   ENDSWITCH

RETURN NIL

FUNCTION hwg_EndWindow()

   IF HWindow():GetMain() != NIL
      hwg_Sendmessage(HWindow():aWindows[1]:handle, WM_SYSCOMMAND, SC_CLOSE, 0)
   ENDIF

RETURN NIL

FUNCTION hwg_HdSerial(cDrive)

   LOCAL cHex := hb_Numtohex(hwg_Hdgetserial(cDrive))

RETURN SubStr(cHex, 1, 4) + "-" + SubStr(cHex, 5, 4)

FUNCTION Hwg_GetIni(cSection, cEntry, cDefault, cFile)

RETURN hwg_Getprivateprofilestring(cSection, cEntry, cDefault, cFile)

FUNCTION Hwg_WriteIni(cSection, cEntry, cValue, cFile)

RETURN (hwg_Writeprivateprofilestring(cSection, cEntry, cValue, cFile))

FUNCTION hwg_SetHelpFileName ( cNewName )

   STATIC cName := ""

   LOCAL cOldName := cName

   IF cNewName != NIL
      cName := cNewName
   ENDIF

RETURN cOldName

FUNCTION hwg_RefreshAllGets(oDlg)

   AEval(oDlg:GetList, {|o|o:Refresh()})

RETURN NIL

FUNCTION hwg_SelectMultipleFiles(cDescr, cTip, cIniDir, cTitle)

   LOCAL aFiles
   LOCAL cFile
   LOCAL x
   LOCAL cFilter := ""
   LOCAL cItem
   LOCAL nAt
   LOCAL cChar
   LOCAL i /* cRet */
   LOCAL hWnd := 0
   LOCAL nFlags := ""
   LOCAL cPath
   LOCAL nIndex := 1

   cFilter += cDescr + Chr(0) + cTip + Chr(0)

   cFile := Space(32000)

   /* cRet := */ hwg_getopenfilename(hWnd, @cFile, cTitle, cFilter, nFlags, cIniDir, NIL, @nIndex)

   nAt := At(Chr(0) + Chr(0), cFile)

   cFile := Left(cFile, nAt)

   aFiles := {}

   IF nAt == 0 // no double chr(0) user must have pressed cancel
      RETURN (aFiles)
   ENDIF

   x := At(Chr(0), cFile) // fist null
   cPath := Left(cFile, x)

   cFile := StrTran(cFile, cPath, "")

   IF !Empty(cFile) // user selected more than 1 file
      cItem := ""
      FOR i := 1 TO Len(cFile) //EACH cChar IN cFile
         cChar := cFile[i]
         IF cChar == 0
            AAdd(aFiles, StrTran(cPath, Chr(0), "") + "\" + cItem)
            cItem := ""
            LOOP
         ENDIF
         cItem += cChar
      NEXT
   ELSE
      aFiles := {StrTran(cPath, Chr(0), "")}
   ENDIF

RETURN aFiles

FUNCTION hwg_Version(n)

   LOCAL s

   IF !Empty(n)
      SWITCH n
      CASE 1
         RETURN HWG_VERSION
      CASE 2
         RETURN HWG_BUILD
      CASE 3
#ifdef UNICODE
         RETURN Iif(hwg__isUnicode(), 1, 0)
#else
         RETURN 0
#endif
      CASE 4
         RETURN 0
      ENDSWITCH
   ENDIF
   s := "HWGUI++ " + HWG_VERSION // + " Build " + Ltrim(Str(HWG_BUILD))
#ifdef UNICODE
   IF hwg__isUnicode()
      s += " Unicode"
   ENDIF
#endif

RETURN s

FUNCTION hwg_getParentForm(o)

   DO WHILE o:oParent != NIL .AND. !__ObjHasMsg(o, "GETLIST")
      o := o:oParent
   ENDDO

RETURN o

FUNCTION hwg_TxtRect(cTxt, oWin, oFont)

   LOCAL hDC
   LOCAL aSize
   LOCAL hFont

   oFont := iif(oFont != NIL, oFont, oWin:oFont)

   hDC := hwg_Getdc(oWin:handle)
   IF oFont == NIL .AND. oWin:oParent != NIL
      oFont := oWin:oParent:oFont
   ENDIF
   IF oFont != NIL
      hFont := hwg_Selectobject(hDC, oFont:handle)
   ENDIF
   aSize := hwg_Gettextsize(hDC, cTxt)
   IF oFont != NIL
      hwg_Selectobject(hDC, hFont)
   ENDIF
   hwg_Releasedc(oWin:handle, hDC)

RETURN aSize

FUNCTION HWG_ScrollHV(oForm, msg, wParam, lParam)

   LOCAL nDelta
   LOCAL nSBCode
   LOCAL nPos
   LOCAL nInc

   HB_SYMBOL_UNUSED(lParam)

   nSBCode := hwg_Loword(wParam)

   SWITCH msg

   CASE WM_VSCROLL
   CASE WM_MOUSEWHEEL
      IF msg == WM_MOUSEWHEEL
         nSBCode = iif(hwg_Hiword(wParam) > 32768, hwg_Hiword(wParam) - 65535, hwg_Hiword(wParam))
         nSBCode = iif(nSBCode < 0, SB_LINEDOWN, SB_LINEUP)
      ENDIF
      // Handle vertical scrollbar messages
      SWITCH nSBCode
      CASE SB_TOP
         nInc := -oForm:nVscrollPos
         EXIT
      CASE SB_BOTTOM
         nInc := oForm:nVscrollMax - oForm:nVscrollPos
         EXIT
      CASE SB_LINEUP
         nInc := - Int(oForm:nVertInc * 0.05 + 0.49)
         EXIT
      CASE SB_LINEDOWN
         nInc := Int(oForm:nVertInc * 0.05 + 0.49)
         EXIT
      CASE SB_PAGEUP
         nInc := Min(-1, -oForm:nVertInc / 2)
         EXIT
      CASE SB_PAGEDOWN
         nInc := Max(1, oForm:nVertInc / 2)
         EXIT
      CASE SB_THUMBTRACK
         nPos := hwg_Hiword(wParam)
         nInc := nPos - oForm:nVscrollPos
         EXIT
      OTHERWISE
         nInc := 0
      ENDSWITCH
      nInc := Max(-oForm:nVscrollPos, Min(nInc, oForm:nVscrollMax - oForm:nVscrollPos))
      oForm:nVscrollPos += nInc
      nDelta := - VERT_PTS * nInc
      hwg_Scrollwindow(oForm:handle, 0, nDelta) //, NIL, NIL )
      hwg_Setscrollpos(oForm:Handle, SB_VERT, oForm:nVscrollPos, .T.)
      EXIT

   CASE WM_HSCROLL // .OR. msg == WM_MOUSEWHEEL
      // Handle vertical scrollbar messages
      SWITCH nSBCode
      CASE SB_TOP
         nInc := -oForm:nHscrollPos
         EXIT
      CASE SB_BOTTOM
         nInc := oForm:nHscrollMax - oForm:nHscrollPos
          EXIT
      CASE SB_LINEUP
         nInc := - 1
         EXIT
      CASE SB_LINEDOWN
         nInc := 1
         EXIT
      CASE SB_PAGEUP
         nInc := - HORZ_PTS
         EXIT
      CASE SB_PAGEDOWN
         nInc := HORZ_PTS
         EXIT
      CASE SB_THUMBTRACK
         nPos := hwg_Hiword(wParam)
         nInc := nPos - oForm:nHscrollPos
         EXIT
      OTHERWISE
         nInc := 0
      ENDSWITCH
      nInc := Max(-oForm:nHscrollPos, Min(nInc, oForm:nHscrollMax - oForm:nHscrollPos))
      oForm:nHscrollPos += nInc
      nDelta := -HORZ_PTS * nInc
      hwg_Scrollwindow(oForm:handle, nDelta, 0)
      hwg_Setscrollpos(oForm:Handle, SB_HORZ, oForm:nHscrollPos, .T.)

   ENDSWITCH

RETURN NIL
