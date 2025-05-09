//
// HWGUI - Harbour Win32 GUI library source code:
// Prg level menu functions
//
// Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include <hbclass.ch>
#include "hwguipp.ch"

#define MENU_FIRST_ID   32000
#define CONTEXTMENU_FIRST_ID   32900
#define FLAG_DISABLED   1
#define FLAG_CHECK      2

STATIC s__aMenuDef, s__oWnd, s__aAccel, s__nLevel, s__Id, s__oMenu, s__oBitmap

CLASS HMenu INHERIT HObject
   DATA handle
   DATA aMenu
   METHOD New() INLINE Self
   METHOD END() INLINE Hwg_DestroyMenu(::handle)
   METHOD Show(oWnd, xPos, yPos, lWnd)
ENDCLASS

METHOD HMenu:Show(oWnd, xPos, yPos, lWnd)
   
   LOCAL aCoor

   oWnd:oPopup := Self
   IF PCount() == 1 .OR. lWnd == NIL .OR. !lWnd
      IF PCount() == 1
         aCoor := hwg_GetCursorPos()
         xPos := aCoor[1]
         yPos := aCoor[2]
      ENDIF
      Hwg_trackmenu(::handle, xPos, yPos, oWnd:handle)
   ELSE
      aCoor := hwg_Clienttoscreen(oWnd:handle, xPos, yPos)
      Hwg_trackmenu(::handle, aCoor[1], aCoor[2], oWnd:handle)
   ENDIF

   RETURN NIL

FUNCTION Hwg_CreateMenu
   
   LOCAL hMenu

   IF Empty(hMenu := hwg__CreateMenu())
      RETURN NIL
   ENDIF

   RETURN { {}, NIL, NIL, hMenu }

FUNCTION Hwg_SetMenu(oWnd, aMenu)

   IF !Empty(oWnd:handle)
      IF hwg__SetMenu(oWnd:handle, aMenu[5])
         oWnd:menu := aMenu
      ELSE
         RETURN .F.
      ENDIF
   ELSE
      oWnd:menu := aMenu
   ENDIF

   RETURN .T.

/*
 *  AddMenuItem(aMenu, cItem, nMenuId, lSubMenu, [bItem] [, nPos]) --> aMenuItem
 *
 *  If nPos is omitted, the function adds menu item to the end of menu,
 *  else it inserts menu item in nPos position.
 */
FUNCTION Hwg_AddMenuItem(aMenu, cItem, nMenuId, lSubMenu, bItem, nPos)
   
   LOCAL hSubMenu

   IF nPos == NIL
      nPos := Len(aMenu[1]) + 1
   ENDIF

   hSubMenu := aMenu[5]
   hSubMenu := hwg__AddMenuItem(hSubMenu, cItem, nPos - 1, .T., nMenuId, NIL, lSubMenu)

   IF nPos > Len(aMenu[1])
      IF Empty(lSubMenu)
         AAdd(aMenu[1], {bItem, cItem, nMenuId, 0})
      ELSE
         AAdd(aMenu[1], {{}, cItem, nMenuId, 0, hSubMenu})
      ENDIF
      RETURN ATail(aMenu[1])
   ELSE
      AAdd(aMenu[1], NIL)
      AIns(aMenu[1], nPos)
      IF Empty(lSubMenu)
         aMenu[1, nPos] := { bItem, cItem, nMenuId, 0 }
         
      ELSE
         aMenu[1, nPos] := { {}, cItem, nMenuId, 0, hSubMenu }
      ENDIF
      RETURN aMenu[1, nPos]
   ENDIF

   RETURN NIL

FUNCTION Hwg_FindMenuItem(aMenu, nId, nPos)
   
   LOCAL nPos1
   LOCAL aSubMenu
   
   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF aMenu[1, nPos, 3] == nId
         RETURN aMenu
      ELSEIF Len(aMenu[1, nPos]) > 4
         IF (aSubMenu := Hwg_FindMenuItem(aMenu[1, nPos], nId, @nPos1)) != NIL
            nPos := nPos1
            RETURN aSubMenu
         ENDIF
      ENDIF
      nPos++
   ENDDO
   RETURN NIL

FUNCTION Hwg_GetSubMenuHandle(aMenu, nId)
   
   LOCAL aSubMenu := Hwg_FindMenuItem(aMenu, nId)

   RETURN IIf(aSubMenu == NIL, 0, aSubMenu[5])

FUNCTION hwg_BuildMenu(aMenuInit, hWnd, oWnd, nPosParent, lPopup)

   LOCAL hMenu
   LOCAL nPos
   LOCAL aMenu
   LOCAL oBmp

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
      /* This code just for sure menu runtime hfrmtmpl.prg is enable */
      IIf(HB_ISLOGICAL(aMenu[4]), aMenu[4] := .F., NIL)
      hMenu := hwg__AddMenuItem(hMenu, aMenu[2], nPos + 1, .T., aMenu[3], aMenu[4], .T.)
      IF Len(aMenu) < 5
         AAdd(aMenu, hMenu)
      ELSE
         aMenu[5] := hMenu
      ENDIF
   ENDIF

   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF HB_ISARRAY(aMenu[1, nPos, 1])
         hwg_BuildMenu(aMenu, NIL, NIL, nPos)
      ELSE
         IF aMenu[1, nPos, 1] == NIL .OR. aMenu[1, nPos, 2] != NIL
            /* This code just for sure menu runtime hfrmtmpl.prg is enable */
            IIf(HB_ISLOGICAL(aMenu[1, nPos, 4]), aMenu[1, nPos, 4] := .F., NIL)
            hwg__AddMenuItem(hMenu, aMenu[1, nPos, 2], nPos, .T., aMenu[1, nPos, 3], aMenu[1, nPos, 4], .F.)
            oBmp := SearchPosBitmap(aMenu[1, nPos, 3])
            IF oBmp[1]
               hwg__Setmenuitembitmaps(hMenu, aMenu[1, nPos, 3], oBmp[2], "")
            ENDIF

         ENDIF
      ENDIF
      nPos++
   ENDDO
   IF hWnd != NIL .AND. oWnd != NIL
      Hwg_SetMenu(oWnd, aMenu)
   ELSEIF s__oMenu != NIL
      s__oMenu:handle := aMenu[5]
      s__oMenu:aMenu := aMenu
   ENDIF
   RETURN NIL

FUNCTION Hwg_BeginMenu(oWnd, nId, cTitle)
   
   LOCAL aMenu
   LOCAL i
   
   IF oWnd != NIL
      s__aMenuDef := {}
      s__aAccel := {}
      s__oBitmap := {}
      s__oWnd := oWnd
      s__oMenu := NIL
      s__nLevel := 0
      s__Id := IIf(nId == NIL, MENU_FIRST_ID, nId)
   ELSE
      nId := IIf(nId == NIL, ++s__Id, nId)
      aMenu := s__aMenuDef
      FOR i := 1 TO s__nLevel
         aMenu := ATail(aMenu)[1]
      NEXT
      s__nLevel++
      AAdd(aMenu, {{}, cTitle, nId, 0})
   ENDIF
   RETURN .T.

FUNCTION Hwg_ContextMenu()
   s__aMenuDef := {}
   s__oBitmap := {}
   s__oWnd := NIL
   s__nLevel := 0
   s__Id := CONTEXTMENU_FIRST_ID
   s__oMenu := HMenu():New()
   RETURN s__oMenu

FUNCTION Hwg_EndMenu()
   IF s__nLevel > 0
      s__nLevel--
   ELSE
      hwg_BuildMenu(AClone(s__aMenuDef), IIf(s__oWnd != NIL, s__oWnd:handle, NIL), s__oWnd, NIL, IIf(s__oWnd != NIL, .F., .T.))
      IF s__oWnd != NIL .AND. s__aAccel != NIL .AND. !Empty(s__aAccel)
         s__oWnd:hAccel := hwg_Createacceleratortable(s__aAccel)
      ENDIF
      s__aMenuDef := NIL
      s__oBitmap := NIL
      s__aAccel := NIL
      s__oWnd := NIL
      s__oMenu := NIL
   ENDIF
   RETURN .T.

FUNCTION Hwg_DefineMenuItem(cItem, nId, bItem, lDisabled, accFlag, accKey, lBitmap, lResource, lCheck)
   
   LOCAL aMenu
   LOCAL i
   LOCAL oBmp
   LOCAL nFlag

   lCheck := IIf(lCheck == NIL, .F., lCheck)
   lDisabled := IIf(lDisabled == NIL, .F., lDisabled)
   nFlag := hb_bitor(IIf(lCheck, FLAG_CHECK, 0), IIf(lDisabled, FLAG_DISABLED, 0))

   aMenu := s__aMenuDef
   FOR i := 1 TO s__nLevel
      aMenu := ATail(aMenu)[1]
   NEXT
   IF !Empty(cItem)
      cItem := StrTran(cItem, "\t", Chr(9))
   ENDIF
   nId := IIf(nId == NIL .AND. cItem != NIL, ++s__Id, nId)
   AAdd(aMenu, {bItem, cItem, nId, nFlag})
   IF lBitmap != NIL .OR. !Empty(lBitmap)
      IF lResource == NIL
         lResource := .F.
      ENDIF
      IF !lResource
         oBmp := HBitmap():AddFile(lBitmap)
      ELSE
         oBmp := HBitmap():AddResource(lBitmap)
      ENDIF
      AAdd(s__oBitmap, {.T., oBmp:Handle, cItem, nId})
   ELSE
      AAdd(s__oBitmap, {.F., "", cItem, nId})
   ENDIF
   IF accFlag != NIL .AND. accKey != NIL
      AAdd(s__aAccel, {accFlag, accKey, nId})
   ENDIF
   RETURN .T.

FUNCTION Hwg_DefineAccelItem(nId, bItem, accFlag, accKey)
   
   LOCAL aMenu
   LOCAL i

   aMenu := s__aMenuDef
   FOR i := 1 TO s__nLevel
      aMenu := ATail(aMenu)[1]
   NEXT
   nId := IIf(nId == NIL, ++s__Id, nId)
   AAdd(aMenu, {bItem, NIL, nId, 0})
   AAdd(s__aAccel, {accFlag, accKey, nId})
   RETURN .T.


FUNCTION Hwg_SetMenuItemBitmaps(aMenu, nId, abmp1, abmp2)
   
   LOCAL aSubMenu := Hwg_FindMenuItem(aMenu, nId)
   LOCAL oMenu  // := aSubMenu

   oMenu := IIf(aSubMenu == NIL, 0, aSubMenu[5])
   hwg__Setmenuitembitmaps(oMenu, nId, abmp1, abmp2)
   RETURN NIL

FUNCTION Hwg_InsertBitmapMenu(aMenu, nId, lBitmap, oResource)
   
   LOCAL aSubMenu := Hwg_FindMenuItem(aMenu, nId)
   LOCAL oBmp
   LOCAL oMenu // := aSubMenu, oBmp

   //Serge(seohic) sugest
   IF oResource == NIL .OR. !oResource
      oBmp := HBitmap():AddFile(lBitmap)
   ELSE
      oBmp := HBitmap():AddResource(lBitmap)
   ENDIF
   oMenu := IIf(aSubMenu == NIL, 0, aSubMenu[5])
   HWG__InsertBitmapMenu(oMenu, nId, oBmp:handle)
   RETURN NIL

STATIC FUNCTION SearchPosBitmap(nPos_Id)

   LOCAL nPos := 1
   LOCAL lBmp := { .F., "" }

   IF s__oBitmap != NIL
      DO WHILE nPos <= Len(s__oBitmap)

         IF s__oBitmap[nPos][4] == nPos_Id
            lBmp := { s__oBitmap[nPos][1], s__oBitmap[nPos][2], s__oBitmap[nPos][3] }
         ENDIF

         nPos++

      ENDDO
   ENDIF

   RETURN lBmp

FUNCTION hwg_DeleteMenuItem(oWnd, nId)

   LOCAL aSubMenu
   LOCAL nPos

   IF (aSubMenu := Hwg_FindMenuItem(oWnd:menu, nId, @nPos)) != NIL
      ADel(aSubMenu[1], nPos)
      ASize(aSubMenu[1], Len(aSubMenu[1]) - 1)

      hwg_DeleteMenu(hwg_Getmenuhandle(oWnd:handle), nId)
   ENDIF
   RETURN NIL
