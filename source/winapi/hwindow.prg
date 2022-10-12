/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HWindow class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define FIRST_MDICHILD_ID      501
#define MAX_MDICHILD_WINDOWS   18
#define WM_NOTIFYICON          WM_USER + 1000
#define ID_NOTIFYICON          1
#define SIZE_MINIMIZED         1

#ifdef MT_EXPERIMENTAL
THREAD STATIC aWindows := {}

FUNCTION aWindows()
RETURN aWindows
#endif

FUNCTION hwg_onWndSize(oWnd, wParam, lParam)

   LOCAL aCoors := hwg_Getwindowrect(oWnd:handle)

   wParam := hwg_PtrToUlong(wParam)
   IF oWnd:oEmbedded != NIL
      oWnd:oEmbedded:Resize(hwg_Loword(lParam), hwg_Hiword(lParam))
   ENDIF

   IF wParam != SIZE_MINIMIZED
      IF oWnd:nScrollBars > - 1 .AND. oWnd:lAutoScroll .AND. !Empty(oWnd:Type)
         IF Empty(oWnd:rect)
            oWnd:rect := hwg_Getclientrect(oWnd:handle)
            AEval(oWnd:aControls, {|o|oWnd:ncurHeight := Max(o:nY + o:nHeight + VERT_PTS * 4, oWnd:ncurHeight)})
            AEval(oWnd:aControls, {|o|oWnd:ncurWidth := Max(o:nX + o:nWidth + HORZ_PTS * 4, oWnd:ncurWidth)})
         ENDIF
         oWnd:ResetScrollbars()
         oWnd:SetupScrollbars()
      ENDIF
      IF oWnd:nAdjust == 2
         oWnd:nAdjust := 0
      ELSE
         hwg_onAnchor(oWnd, oWnd:nWidth, oWnd:nHeight, aCoors[3] - aCoors[1], aCoors[4] - aCoors[2])
      ENDIF
   ENDIF
   oWnd:Super:onEvent(WM_SIZE, wParam, lParam)

   IF wParam != SIZE_MINIMIZED
      oWnd:nWidth  := aCoors[3] - aCoors[1]
      oWnd:nHeight := aCoors[4] - aCoors[2]
   ENDIF

   IF HB_ISBLOCK(oWnd:bSize)
      Eval(oWnd:bSize, oWnd, hwg_Loword(lParam), hwg_Hiword(lParam))
   ENDIF
   IF oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
      aCoors := hwg_GetClientRect(oWnd:handle)
      hwg_Movewindow(HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2], aCoors[3] - oWnd:aOffset[1] - oWnd:aOffset[3], aCoors[4] - oWnd:aOffset[2] - oWnd:aOffset[4])
      RETURN 0
   ENDIF

   RETURN Iif(!Empty(oWnd:type) .AND. oWnd:type >= WND_DLG_RESOURCE, 0, -1)

FUNCTION hwg_onAnchor(oWnd, wold, hold, wnew, hnew)

   LOCAL aControls := oWnd:aControls
   LOCAL oItem
   LOCAL w
   LOCAL h

   FOR EACH oItem IN aControls
      IF oItem:Anchor > 0
         w := oItem:nWidth
         h := oItem:nHeight
         oItem:onAnchor(wold, hold, wnew, hnew)
         hwg_onAnchor(oItem, w, h, oItem:nWidth, oItem:nHeight)
      ENDIF
   NEXT
   RETURN NIL

STATIC FUNCTION onActivate(oDlg, wParam, lParam)

   LOCAL iParLow := hwg_Loword(wParam)

   HB_SYMBOL_UNUSED(lParam)

   IF iParLow > 0 .AND. HB_ISBLOCK(oDlg:bGetFocus)
      Eval(oDlg:bGetFocus, oDlg)
   ELSEIF iParLow == 0 .AND. HB_ISBLOCK(oDlg:bLostFocus)
      Eval(oDlg:bLostFocus, oDlg)
   ENDIF

   RETURN 0

STATIC FUNCTION onEnterIdle(oDlg, wParam, lParam)

   LOCAL oItem
   LOCAL b
   LOCAL aCoors
   LOCAL aRect

   IF (Empty(wParam) .AND. (oItem := Atail(HDialog():aModalDialogs)) != NIL .AND. hwg_Isptreq(oItem:handle, lParam))
      oDlg := oItem
   ENDIF
   IF __ObjHasMsg(oDlg, "BACTIVATE")
      IF oDlg:nAdjust == 1
         oDlg:nAdjust := 2
         aCoors := hwg_Getwindowrect(oDlg:handle)
         aRect := hwg_GetClientRect(oDlg:handle)
         oDlg:Move(NIL, NIL, oDlg:nWidth + (aCoors[3] - aCoors[1] - aRect[3]), oDlg:nHeight + (aCoors[4] - aCoors[2] - aRect[4]))
      ENDIF
      IF HB_ISBLOCK(oDlg:bActivate)
         b := oDlg:bActivate
         oDlg:bActivate := NIL
         Eval(b, oDlg)
      ENDIF
   ENDIF

   RETURN 0

FUNCTION hwg_onDestroy(oWnd)

   LOCAL i
   LOCAL nHandle := oWnd:handle

   IF oWnd:oEmbedded != NIL
      oWnd:oEmbedded:End()
      oWnd:oEmbedded := NIL
   ENDIF

   IF (i := Ascan(HTimer():aTimers, {|o|hwg_Isptreq(o:oParent:handle, nHandle)})) != 0
      HTimer():aTimers[i]:End()
   ENDIF

   oWnd:Super:onEvent(WM_DESTROY)
   oWnd:DelItem(oWnd)

   RETURN 0

CLASS HWindow INHERIT HCustomWindow, HScrollArea

#ifdef MT_EXPERIMENTAL
   METHOD aWindows       INLINE aWindows()
#else
   CLASS VAR aWindows    SHARED INIT {}
#endif
   CLASS VAR szAppName   SHARED INIT "HwGUI_App"
   CLASS VAR aKeysGlobal SHARED INIT {}

   DATA menu
   DATA oPopup
   DATA hAccel
   DATA oIcon
   DATA oBmp
   DATA lUpdated      INIT .F.     // TRUE, if any GET is changed
   DATA lClipper      INIT .F.
   DATA GetList       INIT {}      // The array of GET items in the dialog
   DATA KeyList       INIT {}      // The array of keys ( as Clipper's SET KEY )
   DATA nLastKey      INIT 0
   DATA bCloseQuery
   DATA bActivate
   DATA nAdjust       INIT 0
   DATA tColorinFocus INIT -1
   DATA bColorinFocus INIT -1

   DATA aOffset
   DATA oEmbedded
   DATA bScroll

   METHOD New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
              cAppName, oBmp, cHelp, nHelpId, bColor)
   METHOD AddItem(oWnd)
   METHOD DelItem(oWnd)
   METHOD FindWindow(hWnd)
   METHOD GetMain()
   METHOD EvalKeyList(nKey, bPressed)
   METHOD Center()
   METHOD Restore()
   METHOD Maximize()
   METHOD Minimize()
   METHOD Close()
   METHOD SetTitle(cTitle) INLINE hwg_Setwindowtext(::handle, ::title := cTitle)

ENDCLASS


METHOD New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
           cAppName, oBmp, cHelp, nHelpId, bColor) CLASS HWindow

   HB_SYMBOL_UNUSED(clr)
   HB_SYMBOL_UNUSED(cMenu)
   HB_SYMBOL_UNUSED(cHelp)

   ::oDefaultParent := Self
   ::title    := cTitle
   ::style    := Iif(nStyle == NIL, 0, nStyle)
   ::oIcon    := oIcon
   ::oBmp     := oBmp
   ::nY       := Iif(y == NIL, 0, y)
   ::nX       := iif(x == NIL, 0, x)
   ::nWidth   := Iif(width == NIL, 0, width)
   ::nHeight  := Iif(height == NIL, 0, Abs(height))
   IF ::nWidth < 0
      ::nWidth   := Abs(::nWidth)
      ::nAdjust := 1
   ENDIF
   ::oFont    := oFont
   ::bInit    := bInit
   ::bDestroy := bExit
   ::bSize    := bSize
   ::bPaint   := bPaint
   ::bGetFocus  := bGFocus
   ::bLostFocus := bLFocus
   ::bOther     := bOther

   IF bColor != NIL
      ::brush := HBrush():Add(bColor)
   ENDIF
   IF cAppName != NIL
      ::szAppName := cAppName
   ENDIF
   IF nHelpId != NIL
      ::HelpId := nHelpId
   ENDIF

   ::aOffset := Array(4)
   AFill(::aOffset, 0)

   IF hb_bitand(::style, WS_HSCROLL) > 0
      ::nScrollBars++
   ENDIF
   IF hb_bitand(::style, WS_VSCROLL) > 0
      ::nScrollBars += 2
   ENDIF

   ::AddItem(Self)

   RETURN Self

METHOD AddItem(oWnd) CLASS HWindow

   AAdd(::aWindows, oWnd)

   RETURN NIL

METHOD DelItem(oWnd) CLASS HWindow

   LOCAL i
   LOCAL h := oWnd:handle

   IF (i := Ascan(::aWindows, {|o|hwg_Isptreq(o:handle,h)})) > 0
      ADel(::aWindows, i)
      ASize(::aWindows, Len(::aWindows) - 1)
   ENDIF

   RETURN NIL

METHOD FindWindow(hWnd) CLASS HWindow

   LOCAL i := Ascan(::aWindows, {|o|hwg_Isptreq(o:handle, hWnd)})

   RETURN Iif(i == 0, NIL, ::aWindows[i])

METHOD GetMain() CLASS HWindow

   RETURN Iif(Len(::aWindows) > 0, Iif(::aWindows[1]:type == WND_MAIN, ::aWindows[1], Iif(Len(::aWindows) > 1, ::aWindows[2], NIL)), NIL)

METHOD EvalKeyList(nKey, bPressed) CLASS HWindow

   LOCAL cKeyb
   LOCAL nctrl
   LOCAL nPos

   HB_SYMBOL_UNUSED(bPressed)

   cKeyb := hwg_Getkeyboardstate()
   nctrl := Iif(Asc(SubStr(cKeyb, VK_CONTROL + 1, 1)) >= 128, FCONTROL, Iif(Asc(SubStr(cKeyb, VK_SHIFT + 1, 1)) >= 128, FSHIFT, ;
      Iif(Asc(SubStr(cKeyb, VK_MENU + 1, 1)) >= 128, FALT, 0 )))

   IF !Empty(::KeyList)
      IF (nPos := Ascan(::KeyList, {|a|a[1] == nctrl .AND. a[2] == nKey})) > 0
         Eval(::KeyList[nPos, 3], ::FindControl(NIL, hwg_Getfocus()))
         RETURN .T.
      ENDIF
   ENDIF
   IF !Empty(::aKeysGlobal)
      IF (nPos := Ascan(::aKeysGlobal, {|a|a[1] == nctrl .AND. a[2] == nKey})) > 0
         Eval(::aKeysGlobal[nPos, 3], ::FindControl(NIL, hwg_Getfocus()))
      ENDIF
   ENDIF

   RETURN .T.

CLASS HMainWindow INHERIT HWindow

   DATA nMenuPos
   DATA oNotifyIcon
   DATA bNotify
   DATA oNotifyMenu
   DATA lTray INIT .F.

   METHOD New(lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
              cAppName, oBmp, cHelp, nHelpId, bColor, nExclude)
   METHOD Activate(lShow, lMaximized, lMinimized, lCentered, bActivate)
   METHOD onEvent(msg, wParam, lParam)
   METHOD InitTray(oNotifyIcon, bNotify, oNotifyMenu, cTooltip)
   METHOD GetMdiActive() INLINE ::FindWindow(hwg_Sendmessptr(::GetMain():handle, WM_MDIGETACTIVE, 0, 0))

ENDCLASS

METHOD New(lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
           cAppName, oBmp, cHelp, nHelpId, bColor, nExclude) CLASS HMainWindow

   LOCAL hbrush

   IF nStyle != NIL .AND. nStyle < 0
      nExclude := 0
      IF hb_bitand(Abs(nStyle), WND_NOSYSMENU) != 0
         nExclude := hb_bitor(nExclude, WS_SYSMENU)
      ENDIF
      IF hb_bitand(Abs(nStyle), WND_NOSIZEBOX) != 0
         nExclude := hb_bitor(nExclude, WS_THICKFRAME)
      ENDIF
      IF hb_bitand(Abs(nStyle), Abs(WND_NOTITLE)) != 0
         nExclude := hb_bitor(nExclude, WS_CAPTION)
         nStyle := WS_POPUP
      ELSE
         nStyle := 0
      ENDIF
   ENDIF

   ::Super:New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
               cAppName, oBmp, cHelp, nHelpId, bColor)
   ::type := lType

   hbrush := IIf(::brush != NIL, ::brush:handle, clr)

   IF lType == WND_MDI

      ::nMenuPos := nPos
      ::handle := Hwg_InitMdiWindow(Self, ::szAppName, cTitle, cMenu, Iif(oIcon != NIL, oIcon:handle, NIL), hbrush, nStyle, ::nX, ::nY, ::nWidth, ::nHeight)

   ELSEIF lType == WND_MAIN

      ::handle := Hwg_InitMainWindow(Self, ::szAppName, cTitle, cMenu, Iif(oIcon != NIL, oIcon:handle, NIL), Iif(oBmp != NIL, -1, hbrush), ;
         ::Style, Iif(nExclude == NIL, 0, nExclude), ::nX, ::nY, ::nWidth, ::nHeight)

      IF cHelp != NIL
         hwg_SetHelpFileName(cHelp)
      ENDIF

   ENDIF
   IF HB_ISBLOCK(::bInit)
      Eval(::bInit, Self)
   ENDIF

   RETURN Self

METHOD Activate(lShow, lMaximized, lMinimized, lCentered, bActivate) CLASS HMainWindow

   LOCAL oWndClient
   LOCAL handle

   IF HB_ISBLOCK(bActivate)
      ::bActivate := bActivate
   ENDIF

   hwg_CreateGetList(Self)

   IF ::type == WND_MDI

      oWndClient := HWindow():New(NIL, NIL, NIL, ::style, ::title, NIL, ::bInit, ::bDestroy, ::bSize, ::bPaint, ::bGetFocus, ::bLostFocus, ::bOther)
      handle := Hwg_InitClientWindow(oWndClient, ::nMenuPos, ::nX, ::nY + 60, ::nWidth, ::nHeight)
      oWndClient:handle = handle

      IF !Empty(lCentered)
         ::Center()
      ENDIF

      Hwg_ActivateMdiWindow((lShow == NIL .OR. lShow), ::hAccel, lMaximized, lMinimized)

   ELSEIF ::type == WND_MAIN

      IF !Empty(lCentered)
         ::Center()
      ENDIF

      Hwg_ActivateMainWindow((lShow == NIL .OR. lShow), ::hAccel, lMaximized, lMinimized)

   ENDIF

   RETURN NIL

METHOD onEvent(msg, wParam, lParam)  CLASS HMainWindow

   // hwg_writelog(str(msg) + str(wParam) + str(lParam))

   SWITCH msg

   CASE WM_COMMAND
      RETURN onCommand(Self, wParam, lParam)

   CASE WM_ERASEBKGND
      RETURN onEraseBk(Self, wParam)

   CASE WM_MOVE
      RETURN onMove(Self)

   CASE WM_SIZE
      RETURN hwg_onWndSize(Self, wParam, lParam)

   CASE WM_SYSCOMMAND
      RETURN onSysCommand(Self, wParam)

   CASE WM_NOTIFYICON
      RETURN onNotifyIcon(Self, wParam, lParam)

   CASE WM_ACTIVATE
      RETURN onActivate(Self, wParam, lParam)

   CASE WM_ENTERIDLE
      RETURN onEnterIdle(Self, wParam, lParam)

   CASE WM_ACTIVATEAPP
      RETURN onEnterIdle(Self, wParam, lParam)

   CASE WM_CLOSE
      RETURN onCloseQuery(Self)

   CASE WM_DESTROY
      RETURN hwg_onDestroy(Self)

   CASE WM_ENDSESSION
      RETURN onEndSession(Self, wParam)

   CASE WM_HSCROLL
   CASE WM_VSCROLL
   CASE WM_MOUSEWHEEL
      IF ::nScrollBars != -1
         hwg_ScrollHV(Self, msg, wParam, lParam)
      ENDIF
      hwg_onTrackScroll(Self, msg, wParam, lParam)
      RETURN ::Super:onEvent(msg, wParam, lParam)

   OTHERWISE
      RETURN ::Super:onEvent(msg, wParam, lParam)

   ENDSWITCH

   RETURN -1

METHOD InitTray(oNotifyIcon, bNotify, oNotifyMenu, cTooltip) CLASS HMainWindow

   ::bNotify     := bNotify
   ::oNotifyMenu := oNotifyMenu
   ::oNotifyIcon := oNotifyIcon
   hwg_Shellnotifyicon(.T., ::handle, oNotifyIcon:handle, cTooltip)
   ::lTray := .T.

   RETURN NIL

CLASS HMDIChildWindow INHERIT HWindow

   METHOD New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
              cAppName, oBmp, cHelp, nHelpId, bColor)
   METHOD Activate(lShow, lMaximized, lMinimized, lCentered, bActivate)
   METHOD onEvent(msg, wParam, lParam)

ENDCLASS

METHOD New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
           cAppName, oBmp, cHelp, nHelpId, bColor) CLASS HMDIChildWindow

   ::Super:New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
               cAppName, oBmp, cHelp, nHelpId, bColor)

   ::type := WND_MDICHILD

   RETURN Self

METHOD Activate(lShow, lMaximized, lMinimized, lCentered, bActivate) CLASS HMDIChildWindow

   HB_SYMBOL_UNUSED(lShow)
   HB_SYMBOL_UNUSED(lMaximized)
   HB_SYMBOL_UNUSED(lMinimized)

   hwg_CreateGetList(Self)
   // Hwg_CreateMdiChildWindow(Self)

   ::handle := Hwg_CreateMdiChildWindow(Self)
   ::RedefineScrollbars()

   IF HB_ISBLOCK(bActivate)
      Eval(bActivate)
   ENDIF

   hwg_InitControls(Self)
   IF HB_ISBLOCK(::bInit)
      Eval(::bInit, Self)
   ENDIF

   IF !Empty(lCentered)
      ::Center()
   ENDIF

   RETURN NIL

METHOD onEvent(msg, wParam, lParam)  CLASS HMDIChildWindow

   SWITCH msg

   CASE WM_ERASEBKGND
      RETURN onEraseBk(Self, wParam)

   CASE WM_COMMAND
      RETURN onMdiCommand(Self, wParam)

   CASE WM_MOVE
      RETURN onMove(Self)

   CASE WM_SIZE
      RETURN hwg_onWndSize(Self, wParam, lParam)

   CASE WM_NCACTIVATE
      RETURN onMdiNcActivate(Self, wParam)

   CASE WM_SYSCOMMAND
      RETURN onSysCommand(Self, wParam)

   CASE WM_CREATE
      RETURN onMdiCreate(Self, lParam)

   CASE WM_DESTROY
      RETURN hwg_onDestroy(Self)

   CASE WM_HSCROLL
   CASE WM_VSCROLL
      IF ::nScrollBars != -1
         hwg_ScrollHV(Self, msg, wParam, lParam)
      ENDIF
      hwg_onTrackScroll(Self, wParam, lParam)
      RETURN ::Super:onEvent(msg, wParam, lParam)

   OTHERWISE
      RETURN ::Super:onEvent(msg, wParam, lParam)

   ENDSWITCH

   RETURN -1

CLASS HChildWindow INHERIT HWindow

   DATA oNotifyMenu

   METHOD New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
              cAppName, oBmp, cHelp, nHelpId, bColor)
   METHOD Activate(lShow)
   METHOD onEvent(msg, wParam, lParam)

ENDCLASS

METHOD New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
           cAppName, oBmp, cHelp, nHelpId, bColor) CLASS HChildWindow

   ::Super:New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
               cAppName, oBmp, cHelp, nHelpId, bColor)
   ::oParent := HWindow():GetMain()

   IF HB_ISOBJECT(::oParent)
      ::handle := Hwg_InitChildWindow(Self, ::szAppName, cTitle, cMenu, Iif(oIcon != NIL, oIcon:handle, NIL), ;
         Iif(oBmp != NIL, -1, Iif(::brush != NIL, ::brush:handle, clr)), nStyle, ::nX, ::nY, ::nWidth, ::nHeight, ::oParent:handle)
   ELSE
      hwg_Msgstop("Create Main window first !", "HChildWindow():New()")
      RETURN NIL
   ENDIF
   IF HB_ISBLOCK(::bInit)
      Eval(::bInit, Self)
   ENDIF

   RETURN Self

METHOD Activate(lShow) CLASS HChildWindow

   hwg_CreateGetList(Self)
   Hwg_ActivateChildWindow((lShow == NIL .OR. lShow), ::handle)

   RETURN NIL

METHOD onEvent(msg, wParam, lParam)  CLASS HChildWindow

   SWITCH msg

   CASE WM_DESTROY
      RETURN hwg_onDestroy(Self)

   CASE WM_SIZE
      RETURN hwg_onWndSize(Self, wParam, lParam)

   CASE WM_COMMAND
      RETURN onCommand(Self, wParam, lParam)

   CASE WM_ERASEBKGND
      RETURN onEraseBk(Self, wParam)

   CASE WM_MOVE
      RETURN onMove(Self)

   CASE WM_SYSCOMMAND
      RETURN onSysCommand(Self, wParam)

   CASE WM_NOTIFYICON
      RETURN onNotifyIcon(Self, wParam, lParam)

   CASE WM_ACTIVATE
      RETURN onActivate(Self, wParam, lParam)

   CASE WM_ENTERIDLE
      RETURN onEnterIdle(Self, wParam, lParam)

   CASE WM_ACTIVATEAPP
      RETURN onEnterIdle(Self, wParam, lParam)

   CASE WM_CLOSE
      RETURN onCloseQuery(Self)

   CASE WM_ENDSESSION
      RETURN onEndSession(Self, wParam)

   CASE WM_HSCROLL
   CASE WM_VSCROLL
      hwg_onTrackScroll(Self, wParam, lParam)
      RETURN ::Super:onEvent(msg, wParam, lParam)

   OTHERWISE
      RETURN ::Super:onEvent(msg, wParam, lParam)

   ENDSWITCH

   RETURN -1

FUNCTION hwg_ReleaseAllWindows(hWnd)

   LOCAL iCont
   LOCAL nCont

   //  Vamos mandar destruir as filhas
   // Destroi as CHILD's desta MAIN
#ifdef __XHARBOUR__
   LOCAL oItem
   FOR EACH oItem IN HWindow():aWindows
      IF oItem:oParent != NIL .AND. oItem:oParent:handle == hWnd
         hwg_Sendmessage(oItem:handle, WM_CLOSE, 0, 0)
      ENDIF
   NEXT
#else
   nCont := Len(HWindow():aWindows)

   FOR iCont := nCont TO 1 STEP - 1

      IF HWindow():aWindows[iCont]:oParent != NIL .AND. HWindow():aWindows[iCont]:oParent:handle == hWnd
         hwg_Sendmessage(HWindow():aWindows[iCont]:handle, WM_CLOSE, 0, 0)
      ENDIF

   NEXT
#endif

   IF HWindow():aWindows[1]:handle == hWnd
      hwg_Postquitmessage(0)
   ENDIF

   RETURN -1

#define FLAG_CHECK 2

STATIC FUNCTION onCommand(oWnd, wParam, lParam)

   LOCAL iItem
   LOCAL iCont
   LOCAL aMenu
   LOCAL iParHigh
   LOCAL iParLow
   LOCAL nHandle

   HB_SYMBOL_UNUSED(lParam)

   wParam := hwg_PtrToUlong(wParam)
   SWITCH wParam
   CASE SC_CLOSE
      IF Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_Sendmessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
         hwg_Sendmessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0)
      ENDIF
      EXIT
   CASE SC_RESTORE
      IF Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_Sendmessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
         hwg_Sendmessage(HWindow():aWindows[2]:handle, WM_MDIRESTORE, nHandle, 0)
      ENDIF
      EXIT
   CASE SC_MAXIMIZE
      IF Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_Sendmessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
         hwg_Sendmessage(HWindow():aWindows[2]:handle, WM_MDIMAXIMIZE, nHandle, 0)
      ENDIF
      EXIT
   OTHERWISE
      IF wParam >= FIRST_MDICHILD_ID .AND. wparam < FIRST_MDICHILD_ID + MAX_MDICHILD_WINDOWS
         nHandle := HWindow():aWindows[wParam - FIRST_MDICHILD_ID + 3]:handle
         hwg_Sendmessage(HWindow():aWindows[2]:handle, WM_MDIACTIVATE, nHandle, 0)
      ENDIF
   ENDSWITCH
   iParHigh := hwg_Hiword(wParam)
   iParLow := hwg_Loword(wParam)
   IF oWnd:aEvents != NIL .AND. (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
      Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
   ELSEIF HB_ISARRAY(oWnd:menu) .AND. (aMenu := Hwg_FindMenuItem(oWnd:menu, iParLow, @iCont)) != NIL
      IF hb_bitand(aMenu[1, iCont, 4], FLAG_CHECK) > 0
         hwg_Checkmenuitem(NIL, aMenu[1, iCont, 3], !hwg_Ischeckedmenuitem(NIL, aMenu[1, iCont, 3]))
      ENDIF
      IF HB_ISBLOCK(aMenu[1, iCont, 1])
         Eval(aMenu[1, iCont, 1])
      ENDIF
   ELSEIF oWnd:oPopup != NIL .AND. (aMenu := Hwg_FindMenuItem(oWnd:oPopup:aMenu, wParam, @iCont)) != NIL .AND. HB_ISBLOCK(aMenu[1, iCont, 1])
      Eval(aMenu[1, iCont, 1])
   ELSEIF oWnd:oNotifyMenu != NIL .AND. (aMenu := Hwg_FindMenuItem(oWnd:oNotifyMenu:aMenu, wParam, @iCont)) != NIL .AND. HB_ISBLOCK(aMenu[1, iCont, 1])
      Eval(aMenu[1, iCont, 1])
   ENDIF

   RETURN 0

STATIC FUNCTION onMove(oWnd)

   LOCAL aControls := hwg_Getwindowrect(oWnd:handle)

   oWnd:nX := aControls[1]
   oWnd:nY := aControls[2]

   RETURN -1

STATIC FUNCTION onEraseBk(oWnd, hDC)

   LOCAL aCoors

   IF oWnd:oBmp != NIL
      hwg_Spreadbitmap(hDC, oWnd:oBmp:handle)
      RETURN 1
   ELSEIF oWnd:brush != NIL .AND. oWnd:type != WND_MAIN
      aCoors := hwg_Getclientrect(oWnd:handle)
      hwg_Fillrect(hDC, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, oWnd:brush:handle)
      RETURN 1
   ENDIF

   RETURN -1

STATIC FUNCTION onSysCommand(oWnd, wParam)

   LOCAL i

   wParam := hwg_PtrToUlong(wParam)
   SWITCH wParam
   CASE SC_CLOSE
      IF HB_ISBLOCK(oWnd:bDestroy)
         i := Eval(oWnd:bDestroy, oWnd)
         i := Iif(HB_ISLOGICAL(i), i, .T.)
         IF !i
            RETURN 0
         ENDIF
      ENDIF
      IF __ObjHasMsg(oWnd, "ONOTIFYICON") .AND. oWnd:oNotifyIcon != NIL
         hwg_Shellnotifyicon(.F., oWnd:handle, oWnd:oNotifyIcon:handle)
      ENDIF
      IF __ObjHasMsg(oWnd, "HACCEL") .AND. oWnd:hAccel != NIL
         hwg_Destroyacceleratortable(oWnd:hAccel)
      ENDIF
      EXIT
   CASE SC_MINIMIZE
      IF __ObjHasMsg(oWnd, "LTRAY") .AND. oWnd:lTray
         oWnd:Hide()
         RETURN 0
      ENDIF
   ENDSWITCH

   RETURN -1

STATIC FUNCTION onEndSession(oWnd)

   LOCAL i

   IF HB_ISBLOCK(oWnd:bDestroy)
      i := Eval(oWnd:bDestroy, oWnd)
      i := Iif(HB_ISLOGICAL(i), i, .T.)
      IF !i
         RETURN 0
      ENDIF
   ENDIF

   RETURN -1

STATIC FUNCTION onNotifyIcon(oWnd, wParam, lParam)

   LOCAL ar

   wParam := hwg_PtrToUlong(wParam)
   lParam := hwg_PtrToUlong(lParam)
   IF wParam == ID_NOTIFYICON
      IF lParam == WM_LBUTTONDOWN
         IF HB_ISBLOCK(oWnd:bNotify)
            Eval(oWnd:bNotify)
         ENDIF
      ELSEIF lParam == WM_RBUTTONDOWN
         IF oWnd:oNotifyMenu != NIL
            ar := hwg_GetCursorPos()
            oWnd:oNotifyMenu:Show(oWnd, ar[1], ar[2])
         ENDIF
      ENDIF
   ENDIF

   RETURN -1

STATIC FUNCTION onMdiCreate(oWnd, lParam)

   HB_SYMBOL_UNUSED(lParam)

   hwg_InitControls(oWnd)
   IF HB_ISBLOCK(oWnd:bInit)
      Eval(oWnd:bInit, oWnd)
   ENDIF

   RETURN -1

STATIC FUNCTION onMdiCommand(oWnd, wParam)

   LOCAL iParHigh
   LOCAL iParLow
   LOCAL iItem

   wParam := hwg_PtrToUlong(wParam)
   IF wParam == SC_CLOSE
      hwg_Sendmessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, oWnd:handle, 0)
   ENDIF
   iParHigh := hwg_Hiword(wParam)
   iParLow := hwg_Loword(wParam)
   IF oWnd:aEvents != NIL .AND. (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
      Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
   ENDIF

   RETURN 0

STATIC FUNCTION onMdiNcActivate(oWnd, wParam)

   wParam := hwg_PtrToUlong(wParam)
   IF wParam == 1 .AND. HB_ISBLOCK(oWnd:bGetFocus)
      Eval(oWnd:bGetFocus, oWnd)
   ELSEIF wParam == 0 .AND. HB_ISBLOCK(oWnd:bLostFocus)
      Eval(oWnd:bLostFocus, oWnd)
   ENDIF

   RETURN -1

STATIC FUNCTION onCloseQuery(o)

   IF HB_ISBLOCK(o:bCloseQuery)
      IF Eval(o:bCloseQuery)
         hwg_ReleaseAllWindows(o:handle)
      ENDIF
   ELSE
      hwg_ReleaseAllWindows(o:handle)
   ENDIF

   RETURN -1

#pragma BEGINDUMP

#define HB_OS_WIN_32_USED

#define OEMRESOURCE

#include "hwingui.h"
#include <winuser.h>
#include <hbapiitm.h>
#include <hbvm.h>
#include <hbstack.h>
#include <hbapicls.h>

/* Suppress compiler warnings */
#include "incomp_pointer.h"
#include "warnings.h"

HB_FUNC_STATIC( HWINDOW_CENTER )
{
   HWND window = static_cast<HWND>(hb_itemGetPtr(hb_objSendMsg(hb_stackSelfItem(), "HANDLE", 0)));

   RECT rect;
   int w, h, x, y;

   GetWindowRect(window, &rect);

   w = rect.right - rect.left;
   h = rect.bottom - rect.top;
   x = GetSystemMetrics(SM_CXSCREEN);
   y = GetSystemMetrics(SM_CYSCREEN);

   SetWindowPos(window, HWND_TOP, (x - w) / 2, (y - h) / 2, 0, 0, SWP_NOSIZE + SWP_NOACTIVATE + SWP_FRAMECHANGED + SWP_NOSENDCHANGING);
}

HB_FUNC_STATIC( HWINDOW_RESTORE )
{
   HWND window = static_cast<HWND>(hb_itemGetPtr(hb_objSendMsg(hb_stackSelfItem(), "HANDLE", 0)));
   hb_retnl(static_cast<LONG>(SendMessage(window, WM_SYSCOMMAND, SC_RESTORE, 0)));
}

HB_FUNC_STATIC( HWINDOW_MAXIMIZE )
{
   HWND window = static_cast<HWND>(hb_itemGetPtr(hb_objSendMsg(hb_stackSelfItem(), "HANDLE", 0)));
   hb_retnl(static_cast<LONG>(SendMessage(window, WM_SYSCOMMAND, SC_MAXIMIZE, 0)));
}

HB_FUNC_STATIC( HWINDOW_MINIMIZE )
{
   HWND window = static_cast<HWND>(hb_itemGetPtr(hb_objSendMsg(hb_stackSelfItem(), "HANDLE", 0)));
   hb_retnl(static_cast<LONG>(SendMessage(window, WM_SYSCOMMAND, SC_MINIMIZE, 0)));
}

HB_FUNC_STATIC( HWINDOW_CLOSE )
{
   HWND window = static_cast<HWND>(hb_itemGetPtr(hb_objSendMsg(hb_stackSelfItem(), "HANDLE", 0)));
   hb_retnl(static_cast<LONG>(SendMessage(window, WM_SYSCOMMAND, SC_CLOSE, 0)));
}

#pragma ENDDUMP
