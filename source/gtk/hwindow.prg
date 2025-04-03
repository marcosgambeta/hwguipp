//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HWindow class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

REQUEST HWG_ENDWINDOW
#define  FIRST_MDICHILD_ID     501
#define  MAX_MDICHILD_WINDOWS   18
#define  WM_NOTIFYICON         WM_USER+1000
#define  ID_NOTIFYICON           1

FUNCTION hwg_onWndSize( oWnd, wParam, lParam )

   LOCAL aCoors := hwg_Getwindowrect( oWnd:handle )
   // LOCAL w := hwg_Loword(lParam)
   // LOCAL h := hwg_Hiword(lParam)
   LOCAL w := aCoors[3] - aCoors[1]
   LOCAL h := aCoors[4] - aCoors[2]

   IF oWnd:nWidth == w .AND. oWnd:nHeight == h
      RETURN 0
   ENDIF
   //hwg_WriteLog( "OnSize: "+Str(oWnd:nWidth)+" "+Str(oWnd:nHeight)+" "+Str(w)+" "+Str(h)+" " + str(oWnd:nAdjust) )
   IF oWnd:nAdjust == 2
      oWnd:nAdjust := 0
   ELSEIF oWnd:nAdjust == 0
      hwg_onAnchor( oWnd, oWnd:nWidth, oWnd:nHeight, w, h )
   ENDIF
   oWnd:Super:onEvent( WM_SIZE, wParam, lParam )
   //hwg_writelog( "on size "+str(oWnd:nheight)+"/"+str(hwg_Hiword(lParam)) )
   IF oWnd:nAdjust == 0
      oWnd:nWidth := w
      oWnd:nHeight := h
   ENDIF
   IF hb_IsBlock( oWnd:bSize )
      Eval( oWnd:bSize, oWnd, hwg_Loword(lParam), hwg_Hiword(lParam) )
   ENDIF

   RETURN 0

FUNCTION hwg_onMove( oWnd, wParam, lParam )

   LOCAL apos := hwg_getwindowpos( oWnd:handle )

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   //hwg_WriteLog( "onMove: "+str(oWnd:nX)+" "+str(oWnd:nY)+" -> "+str(hwg_Loword(lParam))+str(hwg_Hiword(lParam))+" "+str(apos[1])+" "+str(apos[2]) )
   oWnd:nX := apos[1] //hwg_Loword(lParam)
   oWnd:nY := apos[2] //hwg_Hiword(lParam)

   RETURN 0

FUNCTION hwg_HideHidden( oWnd )

   LOCAL i
   LOCAL aControls := oWnd:aControls

   FOR i := 1 TO Len(aControls)
      IF !Empty(aControls[i]:aControls)
         hwg_HideHidden( aControls[i] )
      ENDIF
      IF aControls[i]:lHide
         hwg_Hidewindow( aControls[i]:handle )
      ENDIF
   NEXT

   RETURN NIL

FUNCTION hwg_onAnchor( oWnd, wold, hold, wnew, hnew )

   LOCAL aControls := oWnd:aControls
   LOCAL oItem
   LOCAL w
   LOCAL h

   FOR EACH oItem IN aControls
      IF oItem:Anchor > 0
         w := oItem:nWidth
         h := oItem:nHeight
         oItem:onAnchor( wold, hold, wnew, hnew )
         hwg_onAnchor( oItem, w, h, oItem:nWidth, oItem:nHeight )
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION onDestroy( oWnd )

   LOCAL i
   LOCAL lRes

   IF hb_IsBlock(oWnd:bDestroy)
      IF ValType( lRes := Eval( oWnd:bDestroy, oWnd ) ) == "L" .AND. !lRes
         RETURN .F.
      ENDIF
      oWnd:bDestroy := NIL
   ENDIF
   IF __ObjHasMsg( oWnd, "HACCEL" ) .AND. oWnd:hAccel != NIL
      hwg_Destroyacceleratortable( oWnd:hAccel )
   ENDIF
   IF ( i := Ascan( HTimer():aTimers,{ |o|hwg_Isptreq( o:oParent:handle,oWnd:handle ) } ) ) != 0
      HTimer():aTimers[i]:End()
   ENDIF
   oWnd:Super:onEvent( WM_DESTROY )
   HWindow():DelItem( oWnd )
   //hwg_gtk_exit()

   RETURN .T.

CLASS HWindow INHERIT HCustomWindow

   CLASS VAR aWindows SHARED INIT {}
   CLASS VAR szAppName SHARED INIT "HwGUI_App"
   CLASS VAR aKeysGlobal SHARED INIT {}

   DATA fbox
   DATA menu
   DATA oPopup
   DATA hAccel
   DATA oIcon
   DATA oBmp
   DATA lUpdated INIT .F.     // TRUE, if any GET is changed
   DATA lClipper INIT .F.
   DATA GetList INIT {}      // The array of GET items in the dialog
   DATA KeyList INIT {}      // The array of keys ( as Clipper's SET KEY )
   DATA nLastKey INIT 0
   DATA bActivate
   DATA lActivated INIT .F.
   DATA nAdjust INIT 0
   DATA tColorinFocus INIT -1
   DATA bColorinFocus INIT -1
   DATA aOffset

   METHOD New( oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
      bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, cAppName, oBmp, cHelp, nHelpId )
   METHOD AddItem( oWnd )
   METHOD DelItem( oWnd )
   METHOD FindWindow( hWnd )
   METHOD GetMain()
   METHOD EvalKeyList( nKey, nctrl )
   METHOD Center() INLINE Hwg_CenterWindow(::handle)
   METHOD RESTORE() INLINE hwg_RestoreWindow(::handle)
   METHOD Maximize() INLINE hwg_WindowMaximize(::handle)
   METHOD Minimize() INLINE hwg_WindowMinimize(::handle)
   METHOD CLOSE() INLINE IIf(!onDestroy( Self ), .F. , hwg_DestroyWindow(::handle))
   METHOD SetTitle( cTitle ) INLINE hwg_Setwindowtext(::handle, ::title := cTitle)

ENDCLASS

METHOD HWindow:New( oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
      bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
      cAppName, oBmp, cHelp, nHelpId )

   HB_SYMBOL_UNUSED(clr)
   HB_SYMBOL_UNUSED(cMenu)
   HB_SYMBOL_UNUSED(cHelp)

   ::oDefaultParent := Self
   ::title := cTitle
   ::style := IIf(nStyle == NIL, 0, nStyle)
   ::oIcon := oIcon
   ::oBmp := oBmp
   ::nY := IIf(y == NIL, 0, y)
   ::nX := IIf(x == NIL, 0, x)
   ::nWidth := IIf(width == NIL, 0, width)
   ::nHeight := IIf(height == NIL, 0, Abs( height ))
   IF ::nWidth < 0
      ::nWidth := Abs(::nWidth)
      ::nAdjust := 1
   ENDIF
   ::oFont := oFont
   ::bInit := bInit
   ::bDestroy := bExit
   ::bSize := bSize
   ::bPaint := bPaint
   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus
   ::bOther := bOther
   IF cAppName != NIL
      ::szAppName := cAppName
   ENDIF
   IF hb_bitand( Abs(::style), DS_CENTER ) > 0
      ::nX := Int( ( hwg_Getdesktopwidth() - ::nWidth ) / 2 )
      ::nY := Int( ( hwg_Getdesktopheight() - ::nHeight ) / 2 )
   ENDIF
   IF nHelpId != NIL
      ::HelpId := nHelpId
   END
   ::aOffset := Array(4)
   AFill(::aOffset, 0)
   ::AddItem( Self )

   RETURN Self

METHOD HWindow:AddItem( oWnd )

   AAdd(::aWindows, oWnd)

   RETURN NIL

METHOD HWindow:DelItem( oWnd )

   LOCAL i

   IF ( i := Ascan(::aWindows, {|o|o == oWnd}) ) > 0
      ADel(::aWindows, i)
      ASize(::aWindows, Len(::aWindows) - 1)
   ENDIF

   RETURN NIL

METHOD HWindow:FindWindow( hWnd )

   // LOCAL i := Ascan(::aWindows, {|o|o:handle == hWnd})

   // Return IIf(i == 0, NIL, ::aWindows[i])
   RETURN hwg_Getwindowobject( hWnd )

METHOD HWindow:GetMain()

   RETURN IIf(Len(::aWindows) > 0, IIf(::aWindows[1]:type == WND_MAIN, ::aWindows[1], IIf(Len(::aWindows) > 1, ::aWindows[2], NIL)), NIL)

/* Added: nctrl */
METHOD HWindow:EvalKeyList( nKey, nctrl )

   LOCAL nPos

   nctrl := IIf(nctrl == 2, FCONTROL, IIf(nctrl == 1, FSHIFT, IIf(nctrl == 4,FALT,0)))
   //hwg_writelog( str(nKey)+"/"+str(nctrl) )
   IF !Empty(::KeyList)
      IF ( nPos := Ascan(::KeyList, {|a|a[1] == nctrl .AND. a[2] == nKey})) > 0
         Eval(::KeyList[nPos, 3], ::FindControl(NIL, hwg_Getfocus()))
      ENDIF
   ENDIF
   IF !Empty(::aKeysGlobal)
      IF (nPos := Ascan(::aKeysGlobal, {|a|a[1] == nctrl .AND. a[2] == nKey})) > 0
         Eval(::aKeysGlobal[nPos, 3], ::FindControl(NIL, hwg_Getfocus()))
      ENDIF
   ENDIF

   RETURN .T.

CLASS HMainWindow INHERIT HWindow

   CLASS VAR aMessages INIT { ;
      { WM_COMMAND, WM_SETFOCUS, WM_MOVE, WM_SIZE, WM_CLOSE, WM_DESTROY }, ;
      { ;
      { |o, w, l|onCommand( o, w, l ) },        ;
      { |o, w, l|onGetFocus( o, w, l ) },       ;
      { |o, w, l|hwg_onMove( o, w, l ) },       ;
      { |o, w, l|hwg_onWndSize( o, w, l ) },    ;
      { |o|hwg_ReleaseAllWindows( o:handle ) }, ;
      { |o|onDestroy( o ) }                 ;
      } ;
      }

   DATA nMenuPos
   DATA oNotifyIcon
   DATA bNotify
   DATA oNotifyMenu
   DATA lTray INIT .F.

   METHOD New( lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos,   ;
      oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
      cAppName, oBmp, cHelp, nHelpId, bColor, nExclude )
   METHOD Activate( lShow, lMaximize, lMinimize, lCentered, bActivate )
   METHOD onEvent( msg, wParam, lParam )
   METHOD InitTray()
   METHOD DEICONIFY()
   METHOD ICONIFY()

ENDCLASS

METHOD HMainWindow:New( lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos,   ;
      oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
      cAppName, oBmp, cHelp, nHelpId, bColor, nExclude )

    LOCAL  hbackground

   HB_SYMBOL_UNUSED(nPos)
   HB_SYMBOL_UNUSED(nExclude)

   IIF ( oBmp == NIL , hbackground := NIL , hbackground := oBmp:handle )

   ::Super:New( oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
      bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther,  ;
      cAppName, oBmp, cHelp, nHelpId )
   ::type := lType
   ::bColor := bColor
   IF lType == WND_MDI
   ELSEIF lType == WND_MAIN
      ::handle := Hwg_InitMainWindow( Self, ::szAppName, cTitle, cMenu, ;
         IIf(oIcon != NIL, oIcon:handle, NIL), ::Style, ::nX, ;
         ::nY, ::nWidth, ::nHeight, hbackground )
         // DF7BE: background missing, added as 11th parameter
   ENDIF
   IF ::bColor != NIL
      hwg_SetBgColor(::handle, ::bColor)
   ENDIF
   IF hb_IsBlock(::bInit)
      Eval(::bInit, Self)
   ENDIF

   RETURN Self

/* Added: lMaximize, lMinimize, lCentered, bActivate */
METHOD HMainWindow:Activate( lShow, lMaximize, lMinimize, lCentered, bActivate )

   LOCAL aCoors
   LOCAL aRect
   // Variables not used
   // LOCAL i

   HB_SYMBOL_UNUSED(lShow)

   hwg_CreateGetList( Self )

   IF ::type == WND_MAIN
      IF ::style < 0 .AND. hb_bitand(Abs(::style), Abs(WND_NOTITLE)) != 0
         hwg_WindowSetDecorated(::handle, 0)
         //hwg_WindowSetResize(::handle, 1)
      ENDIF
      hwg_ShowAll(::handle)
      IF ::style < 0 .AND. hb_bitand(Abs(::style), Abs(WND_NOSIZEBOX)) != 0
         hwg_WindowSetResize(::handle, 0)
      ENDIF
      IF ::nAdjust == 1
         ::nAdjust := 2
         aCoors := hwg_Getwindowrect(::handle)
         aRect := hwg_GetClientRect(::handle)
         IF aCoors[4] - aCoors[2] == aRect[4]
            ::nAdjust := 0
         ELSE
            //hwg_writelog( str(::nheight)+"/"+str(aCoors[4]-aCoors[2])+"/"+str(arect[4]) )
            ::Move(NIL, NIL, ::nWidth + (aCoors[3] - aCoors[1] - aRect[3]), ::nHeight + (aCoors[4] - aCoors[2] - aRect[4]))
         ENDIF
      ENDIF
      ::lActivated := .T.
      IF hb_IsBlock( bActivate )
         ::bActivate := bActivate
      ENDIF
      IF hb_IsBlock(::bActivate)
         Eval(::bActivate, Self)
      ENDIF
      IF !Empty(lMinimize)
         ::Minimize()
      ELSEIF !Empty(lMaximize)
         ::Maximize()
      ELSEIF !Empty(lCentered)
         ::Center()
      ENDIF
      hwg_HideHidden( Self )
      Hwg_ActivateMainWindow(::handle)
   ENDIF

   RETURN NIL

METHOD HMainWindow:onEvent( msg, wParam, lParam )

   LOCAL i

   // hwg_WriteLog( "On Event" + str(msg) + str(wParam) + str(lParam) )
   IF (i := Ascan(::aMessages[1], msg)) != 0
      RETURN Eval(::aMessages[2, i], Self, wParam, lParam)
   ELSE
      IF msg == WM_HSCROLL .OR. msg == WM_VSCROLL
         // hwg_onTrackScroll( Self,wParam,lParam )
      ENDIF
      Return ::Super:onEvent( msg, wParam, lParam )
   ENDIF

   RETURN 0

METHOD HMainWindow:InitTray()
   RETURN NIL
   
METHOD HMainWindow:DEICONIFY()
   hwg_deiconify(::handle)
  RETURN NIL

METHOD HMainWindow:ICONIFY()
   hwg_iconify(::handle)
  RETURN NIL

FUNCTION hwg_ReleaseAllWindows( hWnd )

   // LOCAL oItem, iCont, nCont

   HB_SYMBOL_UNUSED(hWnd)

   return -1

STATIC FUNCTION onCommand(oWnd, wParam, lParam)

   LOCAL iItem
   LOCAL iCont
   LOCAL aMenu
   LOCAL iParHigh
   LOCAL iParLow
   // Variables not used
   // LOCAL nHandle

   HB_SYMBOL_UNUSED(lParam)

   iParHigh := hwg_Hiword(wParam)
   iParLow := hwg_Loword(wParam)
   IF oWnd:aEvents != NIL .AND. ( iItem := Ascan( oWnd:aEvents, { |a|a[1] == iParHigh .AND. a[2] == iParLow } ) ) > 0
      Eval( oWnd:aEvents[iItem, 3], oWnd, iParLow )
   ELSEIF HB_ISARRAY(oWnd:menu) .AND. ( aMenu := Hwg_FindMenuItem( oWnd:menu,iParLow,@iCont ) ) != NIL .AND. aMenu[1, iCont, 1] != NIL
      Eval( aMenu[1, iCont, 1] )
   ELSEIF oWnd:oPopup != NIL .AND. ( aMenu := Hwg_FindMenuItem( oWnd:oPopup:aMenu,wParam,@iCont ) ) != NIL .AND. aMenu[1, iCont, 1] != NIL
      Eval( aMenu[1, iCont, 1] )
   ELSEIF oWnd:oNotifyMenu != NIL .AND. ( aMenu := Hwg_FindMenuItem( oWnd:oNotifyMenu:aMenu,wParam,@iCont ) ) != NIL .AND. aMenu[1, iCont, 1] != NIL
      Eval( aMenu[1, iCont, 1] )
   ENDIF

   RETURN 0

STATIC FUNCTION onGetFocus( oDlg, w, l )

   HB_SYMBOL_UNUSED(w)
   HB_SYMBOL_UNUSED(l)

   IF hb_IsBlock(oDlg:bGetFocus)
      Eval( oDlg:bGetFocus, oDlg )
   ENDIF

   RETURN 0


// Prepare for future (if available on next GTK versions)
// FUNCTION hwg_GTKShellnotifyicon( oIcon )
//       hwg_ShellModifyIcon ( IIf(oIcon != NIL, oIcon:handle, NIL) )
//   RETURN NIL
