//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HDialog class
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

REQUEST HWG_ENDWINDOW

STATIC s_aMessModalDlg := { ;
      { WM_COMMAND, { |o,w,l|hwg_DlgCommand( o,w,l ) } },     ;
      { WM_SIZE, { |o,w,l|hwg_onWndSize( o,w,l ) } },         ;
      { WM_MOVE, { |o,w,l|hwg_onMove( o,w,l ) } },            ;
      { WM_INITDIALOG, { |o,w,l|InitModalDlg( o,w,l ) } },    ;
      { WM_DESTROY, { |o|onDestroy( o ) } },                  ;
      { WM_SETFOCUS, { |o,w,l|onGetFocus( o,w,l ) } }         ;
      }

STATIC FUNCTION onDestroy( oDlg )

   LOCAL i
   LOCAL lRes

   IF hb_IsBlock(oDlg:bDestroy)
      IF ValType( lRes := Eval( oDlg:bDestroy, oDlg ) ) == "L" .AND. !lRes
         RETURN .F.
      ENDIF
      oDlg:bDestroy := NIL
   ENDIF

   IF ( i := Ascan( HTimer():aTimers,{ |o|hwg_Isptreq( o:oParent:handle,oDlg:handle ) } ) ) != 0
      HTimer():aTimers[i]:End()
   ENDIF

   oDlg:Super:onEvent( WM_DESTROY )
   HDialog():DelItem( oDlg, .T. )
   IF oDlg:lModal
      hwg_gtk_exit()
   ENDIF

   RETURN .T.

   // Class HDialog

CLASS HDialog INHERIT HWindow

   CLASS VAR aDialogs SHARED INIT {}
   CLASS VAR aModalDialogs SHARED INIT {}

   DATA fbox
   DATA lResult INIT .F.     // Becomes TRUE if the OK button is pressed
   DATA lUpdated INIT .F.     // TRUE, if any GET is changed
   DATA lExitOnEnter INIT .T. // Set it to False, if dialog shouldn't be ended after pressing ENTER key,
   // Added by Sandro Freire
   DATA lExitOnEsc INIT .T. // Set it to False, if dialog shouldn't be ended after pressing ENTER key,
   // Added by Sandro Freire
   DATA oIcon
   DATA oBmp
   DATA xResourceID
   DATA lModal

   METHOD New(lType, nStyle, x, y, width, height, cTitle, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, lClipper, oBmp, oIcon, lExitOnEnter, nHelpId, xResourceID, lExitOnEsc, bColor)
   METHOD Activate(lNoModal, lMaximized, lMinimized, lCentered, bActivate)
   METHOD onEvent( msg, wParam, lParam )
   METHOD AddItem( oWnd, lModal )
   METHOD DelItem( oWnd, lModal )
   METHOD FindDialog( hWnd )
   METHOD GetActive()
   METHOD CLOSE() INLINE hwg_EndDialog(::handle)

ENDCLASS

METHOD HDialog:New(lType, nStyle, x, y, width, height, cTitle, oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, lClipper, oBmp, oIcon, lExitOnEnter, nHelpId, xResourceID, lExitOnEsc, bColor)

   HB_SYMBOL_UNUSED(nHelpId)

   ::oDefaultParent := Self
   ::xResourceID := xResourceID
   ::type := lType
   ::title := cTitle
   ::style := iif(nStyle == NIL, 0, nStyle)
   ::bColor := bColor
   ::oBmp := oBmp
   ::oIcon := oIcon
   ::nY := iif(y == NIL, 0, y)
   ::nX := iif(x == NIL, 0, x)
   ::nWidth := iif(width == NIL, 0, width)
   ::nHeight := iif(height == NIL, 0, Abs( height ))
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
   ::lClipper := iif(lClipper == NIL, .F., lClipper)
   ::lExitOnEnter := iif(lExitOnEnter == NIL, .T., !lExitOnEnter)
   ::lExitOnEsc := iif(lExitOnEsc == NIL, .T., !lExitOnEsc)

   IF ::style > 0 .AND. hb_bitand(::style, DS_CENTER) > 0
      ::nX := Int( ( hwg_Getdesktopwidth() - ::nWidth ) / 2 )
      ::nY := Int( ( hwg_Getdesktopheight() - ::nHeight ) / 2 )
   ENDIF
   ::handle := Hwg_CreateDlg( Self )

   RETURN Self

/* Added: lMaximized, lMinimized, lCentered, bActivate */
METHOD HDialog:Activate( lNoModal, lMaximized, lMinimized, lCentered, bActivate )

   LOCAL hParent
   LOCAL oWnd
   LOCAL aCoors
   LOCAL aRect

   hwg_CreateGetList( Self )

   IF lNoModal == NIL
      lNoModal := .F.
   ENDIF
   ::lModal := !lNoModal
   ::lResult := .F.
   IF ::oParent == NIL
      ::oParent := hwg_GetModalDlg()
   ENDIF
   ::AddItem( Self, !lNoModal )

   IF !lNoModal
      hParent := iif(::oParent != NIL .AND. __ObjHasMsg(::oParent, "HANDLE") ;
         .AND. !Empty(::oParent:handle), ::oParent:handle, ;
         iif((oWnd := HWindow():GetMain()) != NIL, oWnd:handle, NIL ) )
      hwg_Set_Modal(::handle, hParent)
   ENDIF

   IF ::style < 0 .AND. hb_bitand( Abs(::style), Abs(WND_NOTITLE) ) != 0
      hwg_WindowSetDecorated(::handle, 0)
   ENDIF

   hwg_ShowAll(::handle)
   InitModalDlg( Self )
   ::lActivated := .T.

   IF ::style < 0 .AND. hb_bitand( Abs(::style), Abs(WND_NOSIZEBOX) ) != 0
      hwg_WindowSetResize(::handle, 0)
   ENDIF

   IF ::nAdjust == 1
      ::nAdjust := 2
      aCoors := hwg_Getwindowrect(::handle)
      aRect := hwg_GetClientRect(::handle)
      //hwg_writelog( str(::nheight)+"/"+str(aCoors[4]-aCoors[2])+"/"+str(arect[4]) )
      IF aCoors[4] - aCoors[2] == aRect[4]
         ::nAdjust := 0
      ELSE
         ::Move(NIL, NIL, ::nWidth + (aCoors[3] - aCoors[1] - aRect[3]), ::nHeight + (aCoors[4] - aCoors[2] - aRect[4]))
      ENDIF
   ENDIF
   IF !Empty(lMinimized)
      ::Minimize()
   ELSEIF !Empty(lMaximized)
      ::Maximize()
   ELSEIF !Empty(lCentered) .OR. (::style > 0 .AND. hb_bitand(::style, DS_CENTER) > 0)
      ::Center()
   ELSEIF ::oParent != NIL .AND. __ObjHasMsg(::oParent, "nX")
      hwg_MoveWindow(::handle, ::oParent:nX + ::nX, ::oParent:nY + ::nY)
   ENDIF
   IF hb_IsBlock( bActivate )
      ::bActivate := bActivate
   ENDIF
   IF hb_IsBlock(::bActivate)
      Eval(::bActivate, Self)
   ENDIF

   hwg_HideHidden( Self )

   hwg_ActivateDialog(::handle, lNoModal)

   RETURN NIL

METHOD HDialog:onEvent( msg, wParam, lParam )
   
   LOCAL i

   IF ( i := Ascan( s_aMessModalDlg, { |a|a[1] == msg } ) ) != 0
      RETURN Eval( s_aMessModalDlg[i,2], Self, wParam, lParam )
   ELSE
      Return ::Super:onEvent( msg, wParam, lParam )
   ENDIF

   RETURN 0

METHOD HDialog:AddItem( oWnd, lModal )

   AAdd(iif(lModal, ::aModalDialogs, ::aDialogs), oWnd)

   RETURN NIL

METHOD HDialog:DelItem( oWnd, lModal )
   
   LOCAL i

   IF lModal
      IF (i := Ascan(::aModalDialogs, {|o|o == oWnd})) > 0
         ADel(::aModalDialogs, i)
         ASize(::aModalDialogs, Len(::aModalDialogs) - 1)
      ENDIF
   ELSE
      IF (i := Ascan(::aDialogs, {|o|o == oWnd})) > 0
         ADel(::aDialogs, i)
         ASize(::aDialogs, Len(::aDialogs) - 1)
      ENDIF
   ENDIF

   RETURN NIL

METHOD HDialog:FindDialog( hWnd )

   RETURN hwg_Getwindowobject( hWnd )

METHOD HDialog:GetActive()
   
   LOCAL handle := hwg_Getfocus()
   LOCAL i := Ascan(::Getlist, {|o|o:handle == handle})

   RETURN iif(i == 0, NIL, ::Getlist[i])

   // End of class
   // ------------------------------------

STATIC FUNCTION InitModalDlg( oDlg )
   
   // Variables not used
   // LOCAL iCont

   // hwg_WriteLog( str(oDlg:handle)+" "+oDlg:title )
   IF HB_ISARRAY(oDlg:menu)
      hwg__SetMenu( oDlg:handle, oDlg:menu[5] )
   ENDIF
   IF oDlg:Title != NIL
      hwg_Setwindowtext( oDlg:Handle, oDlg:Title )
   ENDIF
   IF oDlg:bColor != NIL
      hwg_SetBgColor( oDlg:handle, oDlg:bColor )
   ENDIF
   IF hb_IsBlock(oDlg:bInit)
      Eval( oDlg:bInit, oDlg )
   ENDIF

   RETURN 1

FUNCTION hwg_DlgCommand( oDlg, wParam, lParam )

   LOCAL iParHigh := hwg_Hiword(wParam)
   LOCAL iParLow := hwg_Loword(wParam)
   LOCAL aMenu
   LOCAL i
   LOCAL hCtrl

   HB_SYMBOL_UNUSED(lParam)

   // hwg_WriteLog( Str(iParHigh,10)+"|"+Str(iParLow,10)+"|"+Str(wParam,10)+"|"+Str(lParam,10) )
   IF iParHigh == 0
      IF iParLow == IDOK
         hCtrl := hwg_Getfocus()
         FOR i := Len(oDlg:GetList) TO 1 STEP - 1
            IF !oDlg:GetList[i]:lHide .AND. hwg_Iswindowenabled( oDlg:Getlist[i]:Handle )
               EXIT
            ENDIF
         NEXT
         IF i != 0 .AND. oDlg:GetList[i]:handle == hCtrl
            IF __ObjHasMsg( oDlg:GetList[i], "BVALID" )
               IF Eval( oDlg:GetList[i]:bValid, oDlg:GetList[i] ) .AND. ;
                     oDlg:lExitOnEnter
                  oDlg:lResult := .T.
                  hwg_EndDialog( oDlg:handle )
               ENDIF
               RETURN 1
            ENDIF
         ENDIF
         IF oDlg:lClipper
            IF !hwg_GetSkip( oDlg, hCtrl, 1 )
               IF oDlg:lExitOnEnter
                  oDlg:lResult := .T.
                  hwg_EndDialog( oDlg:handle )
               ENDIF
            ENDIF
            RETURN 1
         ENDIF
      ELSEIF iParLow == IDCANCEL .AND. oDlg:lExitOnEsc
         oDlg:nLastKey := 27
      ENDIF
   ENDIF

   IF oDlg:aEvents != NIL .AND. ;
         ( i := Ascan( oDlg:aEvents, { |a|a[1] == iParHigh .AND. a[2] == iParLow } ) ) > 0
      Eval( oDlg:aEvents[i, 3], oDlg, iParLow )
   ELSEIF iParHigh == 0 .AND. ( ;
         ( iParLow == IDOK .AND. oDlg:FindControl( IDOK ) != NIL ) .OR. ;
         iParLow == IDCANCEL )
      IF iParLow == IDOK
         oDlg:lResult := .T.
      ENDIF
      //Replaced by Sandro
      IF oDlg:lExitOnEsc
         hwg_EndDialog( oDlg:handle )
      ENDIF
   ELSEIF __ObjHasMsg( oDlg, "MENU" ) .AND. HB_ISARRAY(oDlg:menu) .AND. ;
         ( aMenu := Hwg_FindMenuItem( oDlg:menu,iParLow,@i ) ) != NIL ;
         .AND. aMenu[1, i, 1] != NIL
      Eval( aMenu[1, i, 1] )
   ELSEIF __ObjHasMsg( oDlg, "OPOPUP" ) .AND. oDlg:oPopup != NIL .AND. ;
         ( aMenu := Hwg_FindMenuItem( oDlg:oPopup:aMenu,wParam,@i ) ) != NIL ;
         .AND. aMenu[1, i, 1] != NIL
      Eval( aMenu[1, i, 1] )
   ENDIF

   RETURN 1

STATIC FUNCTION onGetFocus( oDlg, w, l )

   HB_SYMBOL_UNUSED(w)
   HB_SYMBOL_UNUSED(l)

   IF hb_IsBlock(oDlg:bGetFocus)
      Eval( oDlg:bGetFocus, oDlg )
   ENDIF

   RETURN 0

FUNCTION hwg_GetModalDlg

   LOCAL i := Len(HDialog():aModalDialogs)

   RETURN iif(i > 0, HDialog():aModalDialogs[i], NIL)

FUNCTION hwg_GetModalHandle

   LOCAL i := Len(HDialog():aModalDialogs)

   RETURN iif(i > 0, HDialog():aModalDialogs[i]:handle, 0)

FUNCTION hwg_EndDialog( handle )

   LOCAL oDlg

   IF handle == NIL
      IF ( oDlg := Atail( HDialog():aModalDialogs ) ) == NIL
         RETURN NIL
      ENDIF
   ELSE
      oDlg := hwg_Getwindowobject( handle )
   ENDIF

   IF !onDestroy( oDlg )
      RETURN .F.
   ENDIF

   RETURN  hwg_DestroyWindow( oDlg:handle )

FUNCTION hwg_SetDlgKey( oDlg, nctrl, nkey, block, lGlobal )

   LOCAL i
   LOCAL aKeys

   IF oDlg == NIL
      oDlg := HCustomWindow():oDefaultParent
   ENDIF
   IF nctrl == NIL
      nctrl := 0
   ENDIF

   IF Empty(lGlobal)
      IF !__ObjHasMsg( oDlg, "KEYLIST" )
         RETURN .F.
      ENDIF
      aKeys := oDlg:KeyList
   ELSE
      aKeys := HWindow():aKeysGlobal
   ENDIF

   IF block == NIL

      IF ( i := Ascan( aKeys,{ |a|a[1] == nctrl .AND. a[2] == nkey } ) ) == 0
         RETURN .F.
      ELSE
         ADel( aKeys, i )
         ASize( aKeys, Len(aKeys) - 1 )
      ENDIF
   ELSE
      IF ( i := Ascan( aKeys,{ |a|a[1] == nctrl .AND. a[2] == nkey } ) ) == 0
         AAdd(aKeys, {nctrl, nkey, block})
      ELSE
         aKeys[i,3] := block
      ENDIF
   ENDIF

   RETURN .T.
