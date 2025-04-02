//
// HWGUI - Harbour Win32 GUI library source code:
// HDialog class
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

#define  WM_PSPNOTIFY         WM_USER+1010

STATIC aSheet := NIL

#ifdef MT_EXPERIMENTAL
   THREAD STATIC aDialogs := {}
   THREAD STATIC aModalDialogs := {}

   FUNCTION aDialogs()

      RETURN aDialogs

   FUNCTION aModalDialogs()

      RETURN aModalDialogs
#endif

CLASS HDialog INHERIT HWindow

#ifdef MT_EXPERIMENTAL
   METHOD aDialogs INLINE aDialogs()
   METHOD aModalDialogs INLINE aModalDialogs()
#else
   CLASS VAR aDialogs SHARED INIT {}
   CLASS VAR aModalDialogs SHARED INIT {}
#endif

   DATA lModal INIT .T.
   DATA lResult INIT .F.     // Becomes TRUE if the OK button is pressed
   DATA lExitOnEnter INIT .T. // Set it to False, if dialog shouldn't be ended after pressing ENTER key,
   // Added by Sandro Freire
   DATA lExitOnEsc INIT .T. // Set it to False, if dialog shouldn't be ended after pressing ENTER key,
   // Added by Sandro Freire
   DATA lRouteCommand INIT .F.
   DATA xResourceID
   DATA lClosable INIT .T.
   DATA nInitState

   METHOD New(lType, nStyle, x, y, width, height, cTitle, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, lClipper, ;
              oBmp, oIcon, lExitOnEnter, nHelpId, xResourceID, lExitOnEsc, bColor, lNoClosable)
   METHOD Activate(lNoModal, lMaximized, lMinimized, lCentered, bActivate)
   METHOD onEvent(msg, wParam, lParam)
   METHOD AddItem() INLINE AAdd(Iif(::lModal, ::aModalDialogs, ::aDialogs), Self)
   METHOD DelItem()
   METHOD FindDialog(hWnd)
   METHOD GetActive()
   METHOD Close() INLINE hwg_EndDialog(::handle)

ENDCLASS

METHOD HDialog:New(lType, nStyle, x, y, width, height, cTitle, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, lClipper, ;
           oBmp, oIcon, lExitOnEnter, nHelpId, xResourceID, lExitOnEsc, bColor, lNoClosable)

   IF pcount() == 0
      ::style := WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX
      ::oDefaultParent := Self
      ::nY := 0
      ::nX := 0
      ::nWidth := 0
      ::nHeight := 0
      ::type := WND_DLG_NORESOURCE
      RETURN Self
   ENDIF

   IF nStyle == NIL
      ::style := WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX
   ELSEIF nStyle < 0 .AND. nStyle > -0x1000
      ::style := WS_POPUP + WS_VISIBLE
      IF hb_bitand(Abs(nStyle), Abs(WND_NOTITLE)) = 0
         ::style += WS_CAPTION
      ENDIF
      IF hb_bitand(Abs(nStyle), WND_NOSYSMENU) = 0
         ::style += WS_SYSMENU
      ENDIF
      IF hb_bitand(Abs(nStyle), WND_NOSIZEBOX) = 0
         ::style += WS_SIZEBOX
      ENDIF
   ELSE
      ::style := nStyle
   ENDIF
   ::oDefaultParent := Self
   ::xResourceID := xResourceID
   ::type := lType
   ::title := cTitle
   ::oBmp := oBmp
   ::oIcon := oIcon
   ::nY := Iif(y == NIL, 0, y)
   ::nX := Iif(x == NIL, 0, x)
   ::nWidth := Iif(width == NIL, 0, width)
   ::nWidth := Iif(width == NIL, 0, width)
   ::nHeight := Iif(height == NIL, 0, Abs(height))
   IF ::nWidth < 0
      ::nWidth := Abs(::nWidth)
      //::nAdjust := 1
   ENDIF
   ::oFont := oFont
   ::bInit := bInit
   ::bDestroy := bExit
   ::bSize := bSize
   ::bPaint := bPaint
   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus
   ::bOther := bOther
   ::lClipper := Iif(lClipper == NIL, .F., lClipper)
   ::lExitOnEnter := Iif(lExitOnEnter == NIL, .T., !lExitOnEnter)
   ::lExitOnEsc := Iif(lExitOnEsc == NIL, .T., !lExitOnEsc)
   ::lClosable := Iif(lNoClosable == NIL, .T., !lNoClosable)

   IF bColor != NIL
      ::brush := HBrush():Add(bColor)
   ENDIF
   IF nHelpId != NIL
      ::HelpId := nHelpId
   ENDIF
   IF hb_bitand(::style, WS_HSCROLL) > 0
      ::nScrollBars++
   ENDIF
   IF hb_bitand(::style, WS_VSCROLL) > 0
      ::nScrollBars += 2
   ENDIF

   RETURN Self

METHOD HDialog:Activate(lNoModal, lMaximized, lMinimized, lCentered, bActivate)

   LOCAL oWnd
   LOCAL hParent
   //LOCAL aCoors
   //LOCAL aRect

   IF bActivate != NIL
      ::bActivate := bActivate
   ENDIF

   IF ::oParent == NIL
      ::oParent := hwg_GetModalDlg()
   ENDIF
   hwg_CreateGetList(Self)
   hParent := Iif(::oParent != NIL .AND. __ObjHasMsg(::oParent, "HANDLE") .AND. !Empty(::oParent:handle), ;
      ::oParent:handle, Iif((oWnd := HWindow():GetMain()) != NIL, oWnd:handle, hwg_Getactivewindow()))

   ::nInitState := Iif(!Empty(lMaximized), SW_SHOWMAXIMIZED, Iif(!Empty(lMinimized), SW_SHOWMINIMIZED, Iif(!Empty(lCentered), 16, 0)))

   SWITCH ::type

   CASE WND_DLG_RESOURCE
      IF lNoModal == NIL .OR. !lNoModal
         ::lModal := .T.
         ::AddItem()
         Hwg_DialogBox(hParent, Self)
      ELSE
         ::lModal := .F.
         ::handle := 0
         ::lResult := .F.
         ::AddItem()
         Hwg_CreateDialog(hParent, Self)
      ENDIF
      EXIT

   CASE WND_DLG_NORESOURCE
      IF lNoModal == NIL .OR. !lNoModal
         ::lModal := .T.
         ::AddItem()
         Hwg_DlgBoxIndirect(hParent, Self, ::nX, ::nY, ::nWidth, ::nHeight, ::style)
      ELSE
         ::lModal := .F.
         ::handle := 0
         ::lResult := .F.
         ::AddItem()
         Hwg_CreateDlgIndirect(hParent, Self, ::nX, ::nY, ::nWidth, ::nHeight, ::style)
      ENDIF

   ENDSWITCH

   IF !::lModal
      SWITCH ::nInitState
      CASE SW_SHOWMINIMIZED ; ::Minimize() ; EXIT
      CASE SW_SHOWMAXIMIZED ; ::Maximize() ; EXIT
      CASE 16               ; ::Center()
      ENDSWITCH
      /*
      IF ::nAdjust == 1
         ::nAdjust := 2
         aCoors := hwg_Getwindowrect(::handle)
         aRect := hwg_GetClientRect(::handle)
         ::Move(NIL, NIL, ::nWidth + (aCoors[3] - aCoors[1] - (aRect[3] - aRect[1])), ::nHeight + (aCoors[4] - aCoors[2] - (aRect[4] - aRect[2])))
      ENDIF
      */
      IF hb_IsBlock(::bActivate)
         Eval(::bActivate, Self)
         ::bActivate := NIL
      ENDIF
   ENDIF

   RETURN NIL

METHOD HDialog:onEvent(msg, wParam, lParam)

   LOCAL nPos
   LOCAL oTab

   // hwg_writelog(str(msg) + str(hwg_PtrToUlong(wParam)) + str(hwg_PtrToUlong(lParam)))

   SWITCH msg

   CASE WM_COMMAND
      IF ::lRouteCommand
         nPos := ascan(::aControls, {|x|x:className() == "HTAB"})
         IF nPos > 0
            oTab := ::aControls[nPos]
            IF Len(oTab:aPages) > 0
               onDlgCommand(oTab:aPages[oTab:GetActivePage(), 1], wParam, lParam)
            ENDIF
         ENDIF
      ENDIF
      RETURN onDlgCommand(Self, wParam, lParam)

   CASE WM_SYSCOMMAND
      RETURN onSysCommand(Self, wParam)

   CASE WM_SIZE
      RETURN hwg_onWndSize(Self, wParam, lParam)

   CASE WM_ERASEBKGND
      RETURN onEraseBk(Self, wParam)

   CASE WM_PSPNOTIFY
      RETURN onPspNotify(Self, wParam, lParam)

   CASE WM_HELP
      RETURN onHelp(Self, wParam, lParam)

   CASE WM_ACTIVATE
      RETURN onActivate(Self, wParam, lParam)

   CASE WM_INITDIALOG
      RETURN InitModalDlg(Self, wParam, lParam)

   CASE WM_DESTROY
      RETURN hwg_onDestroy(Self)

   CASE WM_HSCROLL
   CASE WM_VSCROLL
   CASE WM_MOUSEWHEEL
      IF ::nScrollBars != -1 .AND. ::bScroll = NIL
         hwg_ScrollHV(Self, msg, wParam, lParam)
      ENDIF
      hwg_onTrackScroll(Self, msg, wParam, lParam)
      RETURN ::Super:onEvent(msg, wParam, lParam)

   OTHERWISE
      RETURN ::Super:onEvent(msg, wParam, lParam)

   ENDSWITCH

   RETURN 0

METHOD HDialog:DelItem()

   LOCAL i

   IF ::lModal
      IF (i := Ascan(::aModalDialogs, {|o|o == Self})) > 0
         ADel(::aModalDialogs, i)
         ASize(::aModalDialogs, Len(::aModalDialogs) - 1)
      ENDIF
   ELSE
      IF (i := Ascan(::aDialogs, {|o|o == Self})) > 0
         ADel(::aDialogs, i)
         ASize(::aDialogs, Len(::aDialogs) - 1)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HDialog:FindDialog(hWnd)

   LOCAL i := Ascan(::aDialogs, {|o|hwg_Isptreq(o:handle, hWnd)})

   RETURN Iif(i == 0, NIL, ::aDialogs[i])

METHOD HDialog:GetActive()

   LOCAL handle := hwg_Getfocus()
   LOCAL i := Ascan(::Getlist, {|o|hwg_Isptreq(o:handle, handle)})

   RETURN Iif(i == 0, NIL, ::Getlist[i])

STATIC FUNCTION InitModalDlg(oDlg, wParam, lParam)

   LOCAL nReturn := 1
   LOCAL aCoors
   //LOCAL aRect

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF HB_ISARRAY(oDlg:menu)
      hwg__SetMenu(oDlg:handle, oDlg:menu[5])
   ENDIF
   hwg_InitControls(oDlg, .T.)
   IF oDlg:oIcon != NIL
      hwg_Sendmessage(oDlg:handle, WM_SETICON, 1, oDlg:oIcon:handle)
   ENDIF
   IF oDlg:Title != NIL
      hwg_Setwindowtext(oDlg:Handle, oDlg:Title)
   ENDIF
   IF oDlg:oFont != NIL
      hwg_Sendmessage(oDlg:handle, WM_SETFONT, oDlg:oFont:handle, 0)
   ENDIF
   IF !oDlg:lClosable
      hwg_Enablemenusystemitem(oDlg:handle, SC_CLOSE, .F.)
   ENDIF

   SWITCH oDlg:nInitState
   CASE SW_SHOWMINIMIZED ; oDlg:Minimize() ; EXIT
   CASE SW_SHOWMAXIMIZED ; oDlg:Maximize() ; EXIT
   CASE 16               ; oDlg:Center()
   ENDSWITCH

   IF hb_IsBlock(oDlg:bInit)
      IF ValType(nReturn := Eval(oDlg:bInit, oDlg)) != "N"
         nReturn := 1
      ENDIF
   ENDIF

/*
   IF oDlg:nAdjust == 1
      oDlg:nAdjust := 2
      aCoors := hwg_Getwindowrect(oDlg:handle)
      aRect := hwg_GetClientRect(oDlg:handle)
      hwg_writelog(str(oDlg:nHeight) + "/" + str(aCoors[4] - aCoors[2]) + "/" + str(aRect[4]))
      oDlg:Move(NIL, NIL, oDlg:nWidth + (aCoors[3] - aCoors[1] - aRect[3]), oDlg:nHeight + (aCoors[4] - aCoors[2] - aRect[4]))
   ELSE
*/
      aCoors := hwg_Getwindowrect(oDlg:handle)
      oDlg:nWidth := aCoors[3] - aCoors[1]
      oDlg:nHeight := aCoors[4] - aCoors[2]
//   ENDIF

   RETURN nReturn

STATIC FUNCTION onEraseBk(oDlg, hDC)

   LOCAL aCoors

   IF __ObjHasMsg(oDlg, "OBMP")
      IF oDlg:oBmp != NIL
         hwg_Spreadbitmap(hDC, oDlg:oBmp:handle)
         RETURN 1
      ELSE
         aCoors := hwg_Getclientrect(oDlg:handle)
         IF oDlg:brush != NIL
            IF ValType(oDlg:brush) != "N"
               hwg_Fillrect(hDC, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, oDlg:brush:handle)
            ENDIF
         ELSE
            hwg_Fillrect(hDC, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, COLOR_3DFACE + 1)
         ENDIF
         RETURN 1
      ENDIF
   ENDIF

   RETURN 0

#define  FLAG_CHECK      2

FUNCTION onDlgCommand(oDlg, wParam, lParam)

   LOCAL iParHigh := hwg_Hiword(wParam)
   LOCAL iParLow := hwg_Loword(wParam)
   LOCAL aMenu
   LOCAL i
   LOCAL hCtrl

   HB_SYMBOL_UNUSED(lParam)

   // WriteLog(Str(iParHigh, 10) + "|" + Str(iParLow, 10) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10))
   IF iParHigh == 0
      IF iParLow == IDOK
         hCtrl := hwg_Getfocus()
         FOR i := Len(oDlg:GetList) TO 1 STEP -1
            IF !oDlg:GetList[i]:lHide .AND. hwg_Iswindowenabled(oDlg:Getlist[i]:Handle)
               EXIT
            ENDIF
         NEXT
         IF i != 0 .AND. oDlg:GetList[i]:handle == hCtrl
            IF __ObjHasMsg(oDlg:GetList[i], "BVALID")
               IF oDlg:lExitOnEnter .AND. Eval(oDlg:GetList[i]:bValid, oDlg:GetList[i])
                  oDlg:GetList[i]:bLostFocus := NIL
                  oDlg:lResult := .T.
                  hwg_EndDialog(oDlg:handle)
               ENDIF
               RETURN 1
            ENDIF
         ENDIF
         IF oDlg:lClipper
            IF !hwg_GetSkip(oDlg, hCtrl, 1)
               IF oDlg:lExitOnEnter
                  oDlg:lResult := .T.
                  hwg_EndDialog(oDlg:handle)
               ENDIF
            ENDIF
            RETURN 1
         ENDIF
      ELSEIF iParLow == IDCANCEL .AND. oDlg:lExitOnEsc
         oDlg:nLastKey := 27
      ENDIF
   ENDIF

   IF oDlg:aEvents != NIL .AND. (i := Ascan(oDlg:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
      Eval(oDlg:aEvents[i, 3], oDlg, iParLow)
   ELSEIF iParHigh == 0 .AND. ((iParLow == IDOK .AND. oDlg:FindControl(IDOK) != NIL) .OR. iParLow == IDCANCEL)
      IF iParLow == IDOK
         oDlg:lResult := .T.
      ENDIF
      //Replaced by Sandro
      IF oDlg:lExitOnEsc .OR. hwg_Getkeystate(VK_ESCAPE) >= 0
         hwg_EndDialog(oDlg:handle)
      ENDIF
   ELSEIF __ObjHasMsg(oDlg, "MENU") .AND. HB_ISARRAY(oDlg:menu) .AND. (aMenu := Hwg_FindMenuItem(oDlg:menu, iParLow, @i)) != NIL
      IF hb_bitand(aMenu[1, i, 4], FLAG_CHECK) > 0
         hwg_Checkmenuitem(NIL, aMenu[1, i, 3], !hwg_Ischeckedmenuitem(NIL, aMenu[1, i, 3]))
      ENDIF
      IF aMenu[1, i, 1] != NIL
         Eval(aMenu[1, i, 1])
      ENDIF
   ELSEIF __ObjHasMsg(oDlg, "OPOPUP") .AND. oDlg:oPopup != NIL .AND. (aMenu := Hwg_FindMenuItem(oDlg:oPopup:aMenu, iParLow, @i)) != NIL .AND. hb_IsBlock(aMenu[1, i, 1])
      Eval(aMenu[1, i, 1])
   ENDIF

   RETURN 1

STATIC FUNCTION onActivate(oDlg, wParam, lParam)

   LOCAL iParLow := hwg_Loword(wParam)
   LOCAL b

   HB_SYMBOL_UNUSED(lParam)

   IF hb_IsBlock(oDlg:bActivate)
      b := oDlg:bActivate
      oDlg:bActivate := NIL
      Eval(b, oDlg)
   ENDIF
   IF iParLow > 0 .AND. hb_IsBlock(oDlg:bGetFocus)
      Eval(oDlg:bGetFocus, oDlg)
   ELSEIF iParLow == 0 .AND. hb_IsBlock(oDlg:bLostFocus)
      Eval(oDlg:bLostFocus, oDlg)
   ENDIF

   RETURN 0

STATIC FUNCTION onHelp(oDlg, wParam, lParam)

   LOCAL oCtrl
   LOCAL nHelpId
   LOCAL oParent

   HB_SYMBOL_UNUSED(wParam)

   IF !Empty(hwg_SetHelpFileName())
      oCtrl := oDlg:FindControl(NIL, hwg_Gethelpdata(lParam))
      IF oCtrl != NIL
         nHelpId := oCtrl:HelpId
         IF Empty(nHelpId)
            oParent := oCtrl:oParent
            nHelpId := oParent:HelpId
         ENDIF
         hwg_Winhelp(oDlg:handle, hwg_SetHelpFileName(), Iif(Empty(nHelpId), 3, 1), nHelpId)
      ENDIF
   ENDIF

   RETURN 0

STATIC FUNCTION onPspNotify(oDlg, wParam, lParam)

   LOCAL nCode := hwg_Getnotifycode(lParam)
   LOCAL res := .T.

   HB_SYMBOL_UNUSED(wParam)

   SWITCH nCode
   CASE PSN_SETACTIVE
      IF hb_IsBlock(oDlg:bGetFocus)
         res := Eval(oDlg:bGetFocus, oDlg)
      ENDIF
      // 'res' should be 0(Ok) or -1
      Hwg_SetDlgResult(oDlg:handle, Iif(res, 0, -1))
      RETURN 1
   CASE PSN_KILLACTIVE
      IF hb_IsBlock(oDlg:bLostFocus)
         res := Eval(oDlg:bLostFocus, oDlg)
      ENDIF
      // 'res' should be 0(Ok) or 1
      Hwg_SetDlgResult(oDlg:handle, Iif(res, 0, 1))
      RETURN 1
   CASE PSN_RESET
      EXIT
   CASE PSN_APPLY
      IF hb_IsBlock(oDlg:bDestroy)
         res := Eval(oDlg:bDestroy, oDlg)
         res := Iif(HB_ISLOGICAL(res), res, .T.)
      ENDIF
      // 'res' should be 0(Ok) or 2
      Hwg_SetDlgResult(oDlg:handle, Iif(res, 0, 2))
      IF res
         oDlg:lResult := .T.
      ENDIF
      RETURN 1
   OTHERWISE
      IF hb_IsBlock(oDlg:bOther)
         res := Eval(oDlg:bOther, oDlg, WM_NOTIFY, 0, lParam)
         Hwg_SetDlgResult(oDlg:handle, Iif(res, 0, 1))
         RETURN 1
      ENDIF
   ENDSWITCH

   RETURN 0

FUNCTION hwg_PropertySheet(hParentWindow, aPages, cTitle, x1, y1, width, height, lModeless, lNoApply, lWizard)

   LOCAL hSheet
   LOCAL i
   LOCAL aHandles := Array(Len(aPages))
   LOCAL aTemplates := Array(Len(aPages))

   aSheet := Array(Len(aPages))
   FOR i := 1 TO Len(aPages)
      IF aPages[i]:type == WND_DLG_RESOURCE
         aHandles[i] := hwg__createpropertysheetpage(aPages[i])
      ELSE
         aTemplates[i] := hwg_Createdlgtemplate(aPages[i], x1, y1, width, height, WS_CHILD + WS_VISIBLE + WS_BORDER)
         aHandles[i] := hwg__createpropertysheetpage(aPages[i], aTemplates[i])
      ENDIF
      aSheet[i] := { aHandles[i], aPages[i] }
   NEXT
   hSheet := hwg__propertysheet(hParentWindow, aHandles, Len(aHandles), cTitle, lModeless, lNoApply, lWizard)
   FOR i := 1 TO Len(aPages)
      IF aPages[i]:type != WND_DLG_RESOURCE
         hwg_Releasedlgtemplate(aTemplates[i])
      ENDIF
   NEXT

   RETURN hSheet

FUNCTION hwg_GetModalDlg()

   LOCAL i := Len(HDialog():aModalDialogs)

   RETURN Iif(i > 0, HDialog():aModalDialogs[i], NIL)

FUNCTION hwg_GetModalHandle()

   LOCAL i := Len(HDialog():aModalDialogs)

   RETURN Iif(i > 0, HDialog():aModalDialogs[i]:handle, 0)

FUNCTION hwg_EndDialog(handle)

   LOCAL oDlg
   LOCAL lRes

   IF handle == NIL
      IF (oDlg := Atail(HDialog():aModalDialogs)) == NIL
         RETURN NIL
      ENDIF
   ELSE
      IF ((oDlg := Atail(HDialog():aModalDialogs)) == NIL .OR. oDlg:handle != handle) .AND. (oDlg := HDialog():FindDialog(handle)) == NIL
         RETURN NIL
      ENDIF
   ENDIF
   IF hb_IsBlock(oDlg:bDestroy)
      lRes := Eval(oDlg:bDestroy, oDlg)
      IF Valtype(lRes) != "L" .OR. lRes
         RETURN Iif(oDlg:lModal, Hwg__EndDialog(oDlg:handle), hwg_Destroywindow(oDlg:handle))
      ELSE
         RETURN NIL
      ENDIF
   ENDIF

   RETURN Iif(oDlg:lModal, Hwg__EndDialog(oDlg:handle), hwg_Destroywindow(oDlg:handle))

FUNCTION hwg_SetDlgKey(oDlg, nctrl, nkey, block, lGlobal)

   LOCAL i
   LOCAL aKeys

   IF oDlg == NIL
      oDlg := HCustomWindow():oDefaultParent
   ENDIF
   IF nctrl == NIL
      nctrl := 0
   ENDIF

   IF Empty(lGlobal)
      IF !__ObjHasMsg(oDlg, "KEYLIST")
         RETURN .F.
      ENDIF
      aKeys := oDlg:KeyList
   ELSE
      aKeys := HWindow():aKeysGlobal
   ENDIF

   IF block == NIL
      IF (i := Ascan(aKeys, {|a|a[1] == nctrl .AND. a[2] == nkey})) == 0
         RETURN .F.
      ELSE
         ADel(aKeys, i)
         ASize(aKeys, Len(aKeys) - 1)
      ENDIF
   ELSE
      IF (i := Ascan(aKeys, {|a|a[1] == nctrl .AND. a[2] == nkey})) == 0
         AAdd(aKeys, {nctrl, nkey, block})
      ELSE
         aKeys[i, 3] := block
      ENDIF
   ENDIF

   RETURN .T.

STATIC FUNCTION onSysCommand(oDlg, wParam)

   wParam := hwg_PtrToUlong(wParam)
   IF wParam == SC_CLOSE
      IF !oDlg:lClosable
         RETURN 1
      ENDIF
   ENDIF

   RETURN -1
