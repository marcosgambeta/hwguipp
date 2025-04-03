//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// Prg level menu functions
//
// Copyright 2004 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

#define  MENU_FIRST_ID   32000
#define  CONTEXTMENU_FIRST_ID   32900
#define  FLAG_DISABLED   1
#define  FLAG_CHECK      2

STATIC s__aMenuDef, s__oWnd, s__aAccel, s__nLevel, s__Id, s__oMenu, s__oBitmap, s__lContext, s_hLast
/*
STATIC aKeysTable := { { VK_F1,GDK_F1 }, { VK_F2,GDK_F2 }, { VK_F3,GDK_F3 }, ;
      { VK_F4, GDK_F4 }, { VK_F5, GDK_F5 }, { VK_F6, GDK_F6 }, { VK_F7, GDK_F7 }, ;
      { VK_F8, GDK_F8 }, { VK_F9, GDK_F9 }, { VK_F10, GDK_F10 }, { VK_F11, GDK_F11 }, ;
      { VK_F12, GDK_F12 }, { VK_HOME, GDK_Home }, { VK_LEFT, GDK_Left }, { VK_END, GDK_End }, ;
      { VK_RIGHT, GDK_Right }, { VK_DOWN, GDK_Down }, { VK_UP, GDK_Up } }
*/
CLASS HMenu INHERIT HObject

   DATA handle
   DATA aMenu

   METHOD New() INLINE Self
   METHOD End() INLINE Hwg_DestroyMenu(::handle)
   METHOD Show(oWnd)

ENDCLASS

/* Removed: xPos, yPos, lWnd */
METHOD HMenu:Show( oWnd )

   IF !Empty(HWindow():GetMain())
      oWnd := HWindow():GetMain()
   ENDIF
   oWnd:oPopup := Self
   Hwg_trackmenu(::handle)

   RETURN NIL

FUNCTION Hwg_CreateMenu
   
   LOCAL hMenu

   IF ( Empty(hMenu := hwg__CreateMenu()) )
      RETURN NIL
   ENDIF

   RETURN { {}, NIL, NIL, hMenu }

FUNCTION Hwg_SetMenu( oWnd, aMenu )

   IF !Empty(oWnd:handle)
      IF hwg__SetMenu( oWnd:handle, aMenu[5] )
         oWnd:menu := aMenu
      ELSE
         RETURN .F.
      ENDIF
   ELSE
      oWnd:menu := aMenu
   ENDIF

   RETURN .T.

/*
 *  AddMenuItem( aMenu,cItem,nMenuId,lSubMenu,[bItem] [,nPos] ) --> aMenuItem
 *
 *  If nPos is omitted, the function adds menu item to the end of menu,
 *  else it inserts menu item in nPos position.
 */

FUNCTION Hwg_AddMenuItem( aMenu, cItem, nMenuId, lSubMenu, bItem, nPos, hWnd )
   
   LOCAL hSubMenu

   IF nPos == NIL
      nPos := Len(aMenu[1]) + 1
   ENDIF

   hSubMenu := s_hLast := aMenu[5]
   hSubMenu := hwg__AddMenuItem(hSubMenu, cItem, nPos - 1, IIf(Empty(hWnd), 0, hWnd), nMenuId, NIL, lSubMenu)

   IF nPos > Len(aMenu[1])
      IF Empty(lSubmenu)
         AAdd(aMenu[1], {bItem, cItem, nMenuId, 0, hSubMenu})
      ELSE
         AAdd(aMenu[1], {{}, cItem, nMenuId, 0, hSubMenu})
      ENDIF
      RETURN ATail( aMenu[1] )
   ELSE
      AAdd(aMenu[1], NIL)
      AIns( aMenu[1], nPos )
      IF Empty(lSubmenu)
         aMenu[1, nPos] := { bItem, cItem, nMenuId, 0, hSubMenu }
      ELSE
         aMenu[1, nPos] := { {}, cItem, nMenuId, 0, hSubMenu }
      ENDIF
      RETURN aMenu[1, nPos]
   ENDIF

   RETURN NIL

FUNCTION Hwg_FindMenuItem( aMenu, nId, nPos )
   
   LOCAL nPos1
   LOCAL aSubMenu

   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF aMenu[1, npos, 3] == nId
         RETURN aMenu
      ELSEIF HB_ISARRAY(aMenu[1, npos, 1])
         IF ( aSubMenu := Hwg_FindMenuItem( aMenu[1, nPos] , nId, @nPos1 ) ) != NIL
            nPos := nPos1
            RETURN aSubMenu
         ENDIF
      ENDIF
      nPos ++
   ENDDO

   RETURN NIL

FUNCTION Hwg_GetSubMenuHandle( aMenu, nId )
   
   LOCAL aSubMenu := Hwg_FindMenuItem( aMenu, nId )

   RETURN IIf(aSubMenu == NIL, 0, aSubMenu[5])

FUNCTION hwg_BuildMenu( aMenuInit, hWnd, oWnd, nPosParent, lPopup )

   LOCAL hMenu
   LOCAL nPos
   LOCAL aMenu
   // Variables not used
   // LOCAL i, oBmp

   IF nPosParent == NIL
      IF lPopup == NIL .OR. !lPopup
         hMenu := hwg__CreateMenu()
      ELSE
         hMenu := hwg__CreatePopupMenu()
      ENDIF
      aMenu := { aMenuInit, NIL, NIL, NIL, hMenu }
   ELSE
      hMenu := aMenuInit[5]
      nPos := Len(aMenuInit[1])
      aMenu := aMenuInit[1, nPosParent]
      hMenu := hwg__AddMenuItem( hMenu, aMenu[2], nPos + 1, hWnd, aMenu[3], aMenu[4], .T. )
      IF Len(aMenu) < 5
         AAdd(aMenu, hMenu)
      ELSE
         aMenu[5] := hMenu
      ENDIF
   ENDIF

   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF HB_ISARRAY(aMenu[1, nPos, 1])
         hwg_BuildMenu( aMenu, hWnd, NIL, nPos )
      ELSE
         IF aMenu[1, nPos, 1] == NIL .OR. aMenu[1, nPos, 2] != NIL
            IF Len(aMenu[1,npos]) == 4
               AAdd(aMenu[1, npos], NIL)
            ENDIF
            aMenu[1, npos, 5] := hwg__AddMenuItem(hMenu, aMenu[1, npos, 2], nPos, hWnd, aMenu[1, nPos, 3], aMenu[1, npos, 4], .F.)
         ENDIF
      ENDIF
      nPos ++
   ENDDO
   IF Empty(s__lContext) .AND. hWnd != NIL .AND. oWnd != NIL
      Hwg_SetMenu( oWnd, aMenu )
   ELSEIF s__oMenu != NIL
      s__oMenu:handle := aMenu[5]
      s__oMenu:aMenu := aMenu
   ENDIF

   RETURN NIL

FUNCTION Hwg_BeginMenu( oWnd, nId, cTitle )
   
   LOCAL aMenu
   LOCAL i

   IF oWnd != NIL
      s__lContext := .F.
      s__aMenuDef := {}
      s__aAccel := {}
      s__oBitmap := {}
      s__oWnd := oWnd
      s__oMenu := NIL
      s__nLevel := 0
      s__Id := IIf(nId == NIL, MENU_FIRST_ID, nId)
   ELSE
      nId := IIf(nId == NIL, ++ s__Id, nId)
      aMenu := s__aMenuDef
      FOR i := 1 TO s__nLevel
         aMenu := Atail( aMenu )[1]
      NEXT
      s__nLevel ++
      IF !Empty(cTitle)
         cTitle := StrTran( cTitle, "\t", "" )
         cTitle := StrTran( cTitle, "&", "_" )
      ENDIF
      AAdd(aMenu, {{}, cTitle, nId, 0})
   ENDIF

   RETURN .T.

FUNCTION Hwg_ContextMenu()

   s__lContext := .T.
   s__aMenuDef := {}
   s__oBitmap := {}
   s__oWnd := NIL
   s__nLevel := 0
   s__Id := CONTEXTMENU_FIRST_ID
   s__oMenu := HMenu():New()

   RETURN s__oMenu

FUNCTION Hwg_EndMenu()

   IF s__nLevel > 0
      s__nLevel --
   ELSE
      hwg_BuildMenu(AClone(s__aMenuDef), IIf(s__oWnd != NIL, s__oWnd:handle, 0), s__oWnd, NIL, s__lContext)
      IF s__oWnd != NIL .AND. !Empty(s__aAccel)
         s__oWnd:hAccel := hwg_Createacceleratortable( s__oWnd )
      ENDIF
      s__aMenuDef := NIL
      s__oBitmap := NIL
      s__aAccel := NIL
      s__oWnd := NIL
      s__oMenu := NIL
   ENDIF

   RETURN .T.

FUNCTION Hwg_DefineMenuItem( cItem, nId, bItem, lDisabled, accFlag, accKey, lBitmap, lResource, lCheck )

   LOCAL aMenu
   LOCAL i
   LOCAL nFlag
   // Variables not used
   // LOCAL oBmp

   HB_SYMBOL_UNUSED(lBitmap)
   HB_SYMBOL_UNUSED(lResource)

   lCheck := IIf(lCheck == NIL, .F. , lCheck)
   lDisabled := IIf(lDisabled == NIL, .T. , !lDisabled)
   nFlag := hb_bitor(IIf(lCheck, FLAG_CHECK, 0), IIf(lDisabled, 0, FLAG_DISABLED))

   aMenu := s__aMenuDef
   FOR i := 1 TO s__nLevel
      aMenu := Atail( aMenu )[1]
   NEXT
   nId := IIf(nId == NIL .AND. cItem != NIL, ++ s__Id, nId)
   IF !Empty(cItem)
      cItem := StrTran( cItem, "\t", "" )
      cItem := StrTran( cItem, "&", "_" )
   ENDIF
   AAdd(aMenu, {bItem, cItem, nId, nFlag, 0})

   IF accFlag != NIL .AND. accKey != NIL
      AAdd(s__aAccel, {accFlag, accKey, nId})
   ENDIF

   /*
   IF lBitmap!=NIL .or. !Empty(lBitmap)
      if lResource==NIL
         lResource:=.F.
      Endif
      if !lResource
         oBmp:=HBitmap():AddFile(lBitmap)
      else
         oBmp:=HBitmap():AddResource(lBitmap)
      endif
      Aadd(s__oBitmap, {.t., oBmp:Handle, cItem, nId})
   Else
      Aadd(s__oBitmap, {.F., "", cItem, nID})
   Endif
   */

   RETURN .T.

FUNCTION Hwg_DefineAccelItem( nId, bItem, accFlag, accKey )
   
   LOCAL aMenu
   LOCAL i

   aMenu := s__aMenuDef
   FOR i := 1 TO s__nLevel
      aMenu := Atail( aMenu )[1]
   NEXT
   nId := IIf(nId == NIL, ++ s__Id, nId)
   AAdd(aMenu, {bItem, NIL, nId, .T., 0})
   AAdd(s__aAccel, {accFlag, accKey, nId})

   RETURN .T.

STATIC FUNCTION hwg_Createacceleratortable( oWnd )
   
   LOCAL hTable := hwg__Createacceleratortable( oWnd:handle )
   LOCAL i
   LOCAL nPos
   LOCAL aSubMenu
   LOCAL nKey
   // Variables not used
   // LOCAL n

   FOR i := 1 TO Len(s__aAccel)
      IF ( aSubMenu := Hwg_FindMenuItem( oWnd:menu, s__aAccel[i,3], @nPos ) ) != NIL
         IF ( nKey := s__aAccel[i,2] ) >= 65 .AND. nKey <= 90
            nKey += 32
         ELSE
            nKey := hwg_gtk_convertkey( nKey )
         ENDIF
         hwg__AddAccelerator( hTable, aSubmenu[1,nPos,5], s__aAccel[i,1], nKey )
      ENDIF
   NEXT

   RETURN hTable

STATIC FUNCTION GetMenuByHandle( hWnd )
   
   LOCAL i
   LOCAL aMenu
   LOCAL oDlg

   IF hWnd == NIL
      aMenu := HWindow():GetMain():menu
   ELSEIF Valtype(hWnd) == "O"
      IF __ObjHasMsg( hWnd, "MENU" )
         RETURN hWnd:menu
      ELSEIF __ObjHasMsg( hWnd, "AMENU" )
         RETURN hWnd:amenu
      ENDIF
   ELSE
      IF ( oDlg := HDialog():FindDialog( hWnd ) ) != NIL
         aMenu := oDlg:menu
      ELSEIF ( i := Ascan( HDialog():aModalDialogs,{ |o|Valtype(o:handle)==Valtype(hwnd) .AND. o:handle == hWnd } ) ) != 0
         aMenu := HDialog():aModalDialogs[i]:menu
      ELSEIF ( i := Ascan( HWindow():aWindows,{ |o|Valtype(o:handle)==Valtype(hwnd) .AND. o:handle==hWnd } ) ) != 0
         aMenu := HWindow():aWindows[i]:menu
      ENDIF
   ENDIF

   RETURN aMenu

// hwg_CheckMenuItem( xMenu, idItem, lCheck )
// xMenu: oMenu - context menu object OR window object 
//   OR hWnd - handle of a window OR hMenu - menu handle
FUNCTION hwg_CheckMenuItem( hWnd, nId, lValue )

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos

   aMenu := GetMenuByHandle( hWnd )
   IF aMenu != NIL
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         hwg__CheckMenuItem( aSubmenu[1,nPos,5], lValue )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_IsCheckedMenuItem( hWnd, nId )

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos
   LOCAL lRes := .F.

   aMenu := GetMenuByHandle( hWnd )
   IF aMenu != NIL
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         lRes := hwg__IsCheckedMenuItem( aSubmenu[1,nPos,5] )
      ENDIF
   ENDIF

   RETURN lRes

FUNCTION hwg_EnableMenuItem( hWnd, nId, lValue )

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos

   aMenu := GetMenuByHandle( hWnd )
   IF aMenu != NIL
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         hwg__EnableMenuItem( aSubmenu[1,nPos,5], lValue )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_IsEnabledMenuItem( hWnd, nId )

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos

   aMenu := GetMenuByHandle( hWnd )
   IF aMenu != NIL
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         hwg__IsEnabledMenuItem( aSubmenu[1,nPos,5] )
      ENDIF
   ENDIF

   RETURN NIL

/*
 *  hwg_SetMenuCaption( hMenu, nMenuId, cCaption )
 */

FUNCTION hwg_SetMenuCaption( hWnd, nId, cText )

   LOCAL aMenu
   LOCAL aSubMenu
   LOCAL nPos

   aMenu := GetMenuByHandle( hWnd )
   IF aMenu != NIL
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         hwg__SetMenuCaption( aSubmenu[1,nPos,5], cText )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_DeleteMenuItem( oWnd, nId )

   LOCAL aSubMenu
   LOCAL nPos

   IF ( aSubMenu := Hwg_FindMenuItem( oWnd:menu, nId, @nPos ) ) != NIL
      hwg__DeleteMenu( aSubmenu[1,nPos,5], nId )
      ADel( aSubMenu[1], nPos )
      ASize( aSubMenu[1], Len(aSubMenu[1] ) - 1)
   ENDIF

   RETURN NIL

FUNCTION hwg_gtk_convertkey( nKey )

   // Variables not used
   // LOCAL n

   IF nKey >= 65 .AND. nKey <= 90
      nKey += 32
/*
   ELSEIF ( n := Ascan( aKeysTable, { |a|a[1] == nKey } ) ) > 0
      nKey := aKeysTable[n,2]
   ELSE
      nKey += 0xFF00
*/
   ENDIF

   RETURN nKey
