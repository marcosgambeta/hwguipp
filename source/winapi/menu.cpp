/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C level menu functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 */

#define OEMRESOURCE

#include "hwingui.hpp"
#include <commctrl.h>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbapicls.hpp>
#include <hbstack.hpp>

#define FLAG_DISABLED 1

/*
HWG__CREATEMENU() --> hMenu
*/
HB_FUNC(HWG__CREATEMENU)
{
  HMENU hMenu = CreateMenu();
  hb_retptr(hMenu);
}

/*
HWG__CREATEPOPUPMENU() --> hMenu
*/
HB_FUNC(HWG__CREATEPOPUPMENU)
{
  HMENU hMenu = CreatePopupMenu();
  hb_retptr(hMenu);
}

/*
 *  AddMenuItem(hMenu, cCaption, nPos, fByPosition, nId, fState, lSubMenu) --> lResult
 */
/*
HWG__ADDMENUITEM(hMenu, cCaption, nPos, par4, nId, fState, lSubMenu) --> hSubMenu|0
*/
HB_FUNC(HWG__ADDMENUITEM)
{
  UINT uFlags = MF_BYPOSITION;
  void *hNewItem;
  LPCTSTR lpNewItem;
  int nPos;
  MENUITEMINFO mii;

  if (!HB_ISNIL(6) && (hb_parni(6) & FLAG_DISABLED))
  {
    uFlags |= MFS_DISABLED;
  }

  lpNewItem = HB_PARSTR(2, &hNewItem, nullptr);
  if (lpNewItem)
  {
    BOOL lString = 0;
    LPCTSTR ptr = lpNewItem;

    while (*ptr)
    {
      if (*ptr != ' ' && *ptr != '-')
      {
        lString = 1;
        break;
      }
      ptr++;
    }
    uFlags |= (lString) ? MF_STRING : MF_SEPARATOR;
  }
  else
  {
    uFlags |= MF_SEPARATOR;
  }

  if (!HB_ISNIL(7) && hb_parl(7))
  {
    HMENU hSubMenu = CreateMenu();

    uFlags |= MF_POPUP;
    InsertMenu(hwg_par_HMENU(1), hwg_par_UINT(3), uFlags, reinterpret_cast<UINT_PTR>(hSubMenu), lpNewItem);
    hb_retptr(hSubMenu);

    // Code to set the ID of submenus, the API seems to assume that you wouldn't really want to,
    // but if you are used to getting help via IDs for popups in 16bit, then this will help you.
    nPos = GetMenuItemCount(hwg_par_HMENU(1));
    mii.cbSize = sizeof(MENUITEMINFO);
    mii.fMask = MIIM_ID;
    if (GetMenuItemInfo(hwg_par_HMENU(1), nPos - 1, TRUE, &mii))
    {
      mii.wID = hb_parni(5);
      SetMenuItemInfo(hwg_par_HMENU(1), nPos - 1, TRUE, &mii);
    }
  }
  else
  {
    InsertMenu(hwg_par_HMENU(1), hwg_par_UINT(3), uFlags, static_cast<UINT_PTR>(hb_parni(5)), lpNewItem);
    hb_retnl(0);
  }
  hb_strfree(hNewItem);
}

/*
HB_FUNC( HWG__ADDMENUITEM )
{

   MENUITEMINFO mii;
   BOOL fByPosition = (HB_ISNIL(4)) ? 0 : ( BOOL ) hb_parl(4);
   void * hData;

   mii.cbSize = sizeof(MENUITEMINFO);
   mii.fMask = MIIM_TYPE | MIIM_STATE | MIIM_ID;
   mii.fState = (HB_ISNIL(6) || hb_parl(6)) ? 0 : MFS_DISABLED;
   mii.wID = hb_parni(5);
   if( HB_ISCHAR(2) ) {
      mii.dwTypeData = ( LPTSTR ) HB_PARSTR(2, &hData, nullptr);
      mii.cch = strlen(mii.dwTypeData);
      mii.fType = MFT_STRING;
   } else {
      mii.fType = MFT_SEPARATOR;
   }

   hb_retl(InsertMenuItem(hwg_par_HMENU(1), hb_parni(3), fByPosition, &mii));
   hb_strfree(hData);
}
*/

/*
HWG__CREATESUBMENU(hMenu, nMenuId) --> hSubMenu
*/
HB_FUNC(HWG__CREATESUBMENU)
{
  MENUITEMINFO mii;
  HMENU hSubMenu = CreateMenu();

  mii.cbSize = sizeof(MENUITEMINFO);
  mii.fMask = MIIM_SUBMENU;
  mii.hSubMenu = hSubMenu;

  if (SetMenuItemInfo(hwg_par_HMENU(1), hwg_par_UINT(2), FALSE, &mii))
  {
    hb_retptr(hSubMenu);
  }
  else
  {
    hb_retptr(nullptr);
  }
}

/*
HWG__SETMENU(hWnd, hMenu) --> .T.|.F.
*/
HB_FUNC(HWG__SETMENU)
{
  hb_retl(SetMenu(hwg_par_HWND(1), hwg_par_HMENU(2)));
}

/*
HWG_GETMENUHANDLE(hWnd) --> lHandle
*/
HB_FUNC(HWG_GETMENUHANDLE)
{
  HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? hwg_par_HWND(1) : MDIFrameWindow;
  hb_retptr(GetMenu(handle));
}

// hwg_CheckMenuItem(xMenu, idItem, lCheck)
// xMenu: oMenu - context menu object OR hWnd - handle of a window OR hMenu - menu handle
/*
HWG_CHECKMENUITEM(oMenu|hMenu|hWnd, nIdItem, lCheck) --> NIL
*/
HB_FUNC(HWG_CHECKMENUITEM)
{
  HMENU hMenu;
  UINT uCheck = (hb_pcount() < 3 || !HB_ISLOG(3) || hb_parl(3)) ? MF_CHECKED : MF_UNCHECKED;

  if (HB_ISOBJECT(1))
  {
    hMenu = static_cast<HMENU>(hb_objDataGetPtr(hb_param(1, Harbour::Item::OBJECT), "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : MDIFrameWindow;
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    MessageBox(GetActiveWindow(), TEXT(""), TEXT("No Menu!"), MB_OK | MB_ICONINFORMATION);
  }
  else
  {
    CheckMenuItem(hMenu, hwg_par_UINT(2), MF_BYCOMMAND | uCheck);
  }
}

/*
HWG_ISCHECKEDMENUITEM() --> .T.|.F.
*/
HB_FUNC(HWG_ISCHECKEDMENUITEM)
{
  HMENU hMenu;
  UINT uCheck;

  if (HB_ISOBJECT(1))
  {
    hMenu = static_cast<HMENU>(hb_objDataGetPtr(hb_param(1, Harbour::Item::OBJECT), "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : MDIFrameWindow;
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    hb_retl(false);
  }
  else
  {
    uCheck = GetMenuState(hMenu, hwg_par_UINT(2), MF_BYCOMMAND);
    hb_retl(uCheck & MF_CHECKED);
  }
}

/*
HWG_ENABLEMENUITEM(oMenu|hMenu|hWnd, nId, lEnable, lFlag) --> .T.|.F.
*/
HB_FUNC(HWG_ENABLEMENUITEM)
{
  HMENU hMenu;
  UINT uEnable = (hb_pcount() < 3 || !HB_ISLOG(3) || hb_parl(3)) ? MF_ENABLED : MF_GRAYED;
  UINT uFlag = (hb_pcount() < 4 || !HB_ISLOG(4) || hb_parl(4)) ? MF_BYCOMMAND : MF_BYPOSITION;

  if (HB_ISOBJECT(1))
  {
    hMenu = static_cast<HMENU>(hb_objDataGetPtr(hb_param(1, Harbour::Item::OBJECT), "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : MDIFrameWindow;
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    MessageBox(GetActiveWindow(), TEXT(""), TEXT("No Menu!"), MB_OK | MB_ICONINFORMATION);
    hb_retl(false);
  }
  else
  {
    hb_retl(EnableMenuItem(hMenu, hwg_par_UINT(2), uFlag | uEnable));
  }
}

/*
HWG_ISENABLEDMENUITEM(oMenu|hMenu|hWnd, nId, lFlag) --> .T.|.F.
*/
HB_FUNC(HWG_ISENABLEDMENUITEM)
{
  HMENU hMenu;
  UINT uCheck;
  UINT uFlag = (hb_pcount() < 3 || !HB_ISLOG(3) || hb_parl(3)) ? MF_BYCOMMAND : MF_BYPOSITION;

  if (HB_ISOBJECT(1))
  {
    hMenu = static_cast<HMENU>(hb_objDataGetPtr(hb_param(1, Harbour::Item::OBJECT), "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : MDIFrameWindow;
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    hb_retl(false);
  }
  else
  {
    uCheck = GetMenuState(hMenu, hwg_par_UINT(2), uFlag);
    hb_retl(!(uCheck & MF_GRAYED));
  }
}

/*
HWG_DELETEMENU(hMenu, nPosition) --> NIL
*/
HB_FUNC(HWG_DELETEMENU)
{
  HMENU hMenu = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HMENU(1)) : GetMenu(MDIFrameWindow);

  if (hMenu)
  {
    DeleteMenu(hMenu, hwg_par_UINT(2), MF_BYCOMMAND);
  }
}

/*
HWG_TRACKMENU(hMenu, nX, nY, hWnd, nFlags) --> .T.|.F.
*/
HB_FUNC(HWG_TRACKMENU)
{
  auto hWnd = hwg_par_HWND(4);
  SetForegroundWindow(hWnd);
  hb_retl(TrackPopupMenu(hwg_par_HMENU(1), HB_ISNIL(5) ? TPM_RIGHTALIGN : hwg_par_UINT(5), hwg_par_int(2),
                         hwg_par_int(3), 0, hWnd, nullptr));
  PostMessage(hWnd, 0, 0, 0);
}

/*
HWG_DESTROYMENU(hMenu) --> .T.|.F.
*/
HB_FUNC(HWG_DESTROYMENU)
{
  hb_retl(DestroyMenu(hwg_par_HMENU(1)));
}

/*
HWG_CREATEACCELERATORTABLE(aAccel) --> hAccel
*/
HB_FUNC(HWG_CREATEACCELERATORTABLE)
{
  auto pArray = hb_param(1, Harbour::Item::ARRAY);
  PHB_ITEM pSubArr;
  ULONG ulEntries = hb_arrayLen(pArray);
  auto lpaccl = static_cast<LPACCEL>(hb_xgrab(sizeof(ACCEL) * ulEntries));
  for (ULONG ul = 1; ul <= ulEntries; ul++)
  {
    pSubArr = hb_arrayGetItemPtr(pArray, ul);
    lpaccl[ul - 1].fVirt = static_cast<BYTE>(hb_arrayGetNL(pSubArr, 1)) | FNOINVERT | FVIRTKEY;
    lpaccl[ul - 1].key = static_cast<WORD>(hb_arrayGetNL(pSubArr, 2));
    lpaccl[ul - 1].cmd = static_cast<WORD>(hb_arrayGetNL(pSubArr, 3));
  }
  HACCEL h = CreateAcceleratorTable(lpaccl, static_cast<int>(ulEntries));
  hb_xfree(lpaccl);
  hb_retptr(h);
}

/*
HWG_DESTROYACCELERATORTABLE(hAccel) --> .T.|.F.
*/
HB_FUNC(HWG_DESTROYACCELERATORTABLE)
{
  hb_retl(DestroyAcceleratorTable(static_cast<HACCEL>(hb_parptr(1))));
}

/*
HWG_DRAWMENUBAR(hWnd) --> .T.|.F.
*/
HB_FUNC(HWG_DRAWMENUBAR)
{
  hb_retl(DrawMenuBar(hwg_par_HWND(1)));
}

/*
 *  GetMenuCaption(hWnd | oWnd, nMenuId)
 */
/*
HWG_GETMENUCAPTION(oMenu|hMenu|hWnd, nItem) --> cCaption|.T.|.F.
*/
HB_FUNC(HWG_GETMENUCAPTION)
{
  HMENU hMenu;

  if (HB_ISOBJECT(1))
  {
    hMenu = static_cast<HMENU>(hb_objDataGetPtr(hb_param(1, Harbour::Item::OBJECT), "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : MDIFrameWindow;
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    MessageBox(GetActiveWindow(), TEXT(""), TEXT("No Menu!"), MB_OK | MB_ICONINFORMATION);
    hb_retl(false);
  }
  else
  {
    MENUITEMINFO mii{};

    mii.cbSize = sizeof(MENUITEMINFO);
    mii.fMask = MIIM_TYPE;
    mii.fType = MFT_STRING;
    GetMenuItemInfo(hMenu, hwg_par_UINT(2), FALSE, &mii);
    mii.cch++;
    auto lpBuffer = static_cast<LPTSTR>(hb_xgrab(mii.cch * sizeof(TCHAR)));
    lpBuffer[0] = '\0';
    mii.dwTypeData = lpBuffer;
    if (GetMenuItemInfo(hMenu, hwg_par_UINT(2), FALSE, &mii))
    {
      HB_RETSTR(mii.dwTypeData);
    }
    else
    {
      hb_retc("Error");
    }
    hb_xfree(lpBuffer);
  }
}

/*
HWG_SETMENUCAPTION(oMenu|hMenu|hWnd, nItem, cCaption) --> .T.|.F.
*/
HB_FUNC(HWG_SETMENUCAPTION)
{
  HMENU hMenu;

  if (HB_ISOBJECT(1))
  {
    hMenu = static_cast<HMENU>(hb_objDataGetPtr(hb_param(1, Harbour::Item::OBJECT), "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : MDIFrameWindow;
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    MessageBox(GetActiveWindow(), TEXT(""), TEXT("No Menu!"), MB_OK | MB_ICONINFORMATION);
    hb_retl(false);
  }
  else
  {
    MENUITEMINFO mii;
    void *hData;
    mii.cbSize = sizeof(MENUITEMINFO);
    mii.fMask = MIIM_TYPE;
    mii.fType = MFT_STRING;
    mii.dwTypeData = const_cast<LPTSTR>(HB_PARSTR(3, &hData, nullptr));

    if (SetMenuItemInfo(hMenu, hwg_par_UINT(2), FALSE, &mii))
    {
      hb_retl(true);
    }
    else
    {
      hb_retl(false);
    }
    hb_strfree(hData);
  }
}

/*
HWG__SETMENUITEMBITMAPS(hMenu, nItem, hBitmap, hBitmapUnchecked, hBitmapChecked) --> .T.|.F.
*/
HB_FUNC(HWG__SETMENUITEMBITMAPS)
{
  hb_retl(SetMenuItemBitmaps(hwg_par_HMENU(1), hwg_par_UINT(2), MF_BYCOMMAND, hwg_par_HBITMAP(3), hwg_par_HBITMAP(4)));
}

/*
HWG_GETMENUCHECKMARKDIMENSIONS() --> numeric
*/
HB_FUNC(HWG_GETMENUCHECKMARKDIMENSIONS)
{
  // TODO:
  // GetMenuCheckMarkDimensions é obsoleta.
  // usar GetSystemMetrics(CXMENUCHECK) e GetSystemMetrics(CYMENUCHECK).
  hb_retnl(GetMenuCheckMarkDimensions());
}

/*
HWG_GETMENUBITMAPWIDTH() --> nWidth
*/
HB_FUNC(HWG_GETMENUBITMAPWIDTH)
{
  hb_retni(GetSystemMetrics(SM_CXMENUSIZE));
}

/*
HWG_GETMENUBITMAPHEIGHT() --> nHeight
*/
HB_FUNC(HWG_GETMENUBITMAPHEIGHT)
{
  hb_retni(GetSystemMetrics(SM_CYMENUSIZE));
}

/*
HWG_GETMENUCHECKMARKWIDTH() --> nWidth
*/
HB_FUNC(HWG_GETMENUCHECKMARKWIDTH)
{
  hb_retni(GetSystemMetrics(SM_CXMENUCHECK));
}

/*
HWG_GETMENUCHECKMARKHEIGHT() --> nHeight
*/
HB_FUNC(HWG_GETMENUCHECKMARKHEIGHT)
{
  hb_retni(GetSystemMetrics(SM_CYMENUCHECK));
}

/*
HWG_STRETCHBLT(hdcDest, nxDest, nyDest, nwDest, nhDest, hdcSrc, nxSrc, nySrc, nwSrc, nhSrc, nROP) --> .T.|.F.
*/
HB_FUNC(
    HWG_STRETCHBLT) // TODO: mover esta função para arquivo .cpp mais adequado, pois não tem ligação direta com menus
{
  hb_retl(StretchBlt(hwg_par_HDC(1), hwg_par_int(2), hwg_par_int(3), hwg_par_int(4), hwg_par_int(5), hwg_par_HDC(6),
                     hwg_par_int(7), hwg_par_int(8), hwg_par_int(9), hwg_par_int(10), hwg_par_DWORD(11)));
}

/*
HWG__INSERTBITMAPMENU(hMenu, nItem, hBitmap) --> .T.|.F.
*/
HB_FUNC(HWG__INSERTBITMAPMENU)
{
  MENUITEMINFO mii;
  mii.cbSize = sizeof(MENUITEMINFO);
  mii.fMask = MIIM_ID | MIIM_BITMAP | MIIM_DATA;
  mii.hbmpItem = hwg_par_HBITMAP(3);
  hb_retl(SetMenuItemInfo(hwg_par_HMENU(1), hwg_par_UINT(2), FALSE, &mii));
}

/*
HWG_CHANGEMENU(hMENU, nPar2, cPar3, nPar4, nPar5) --> .T.|.F.
*/
HB_FUNC(HWG_CHANGEMENU)
{
  void *hStr;
  hb_retl(
      ChangeMenu(hwg_par_HMENU(1), hwg_par_UINT(2), HB_PARSTR(3, &hStr, nullptr), hwg_par_UINT(4), hwg_par_UINT(5)));
  hb_strfree(hStr);
}

/*
HWG_MODIFYMENU(hMenu, nItem, nFlags, nIdNewItem, cNewItem) --> .T.|.F.
*/
HB_FUNC(HWG_MODIFYMENU)
{
  void *hStr;
  hb_retl(
      ModifyMenu(hwg_par_HMENU(1), hwg_par_UINT(2), hwg_par_UINT(3), hwg_par_UINT(4), HB_PARSTR(5, &hStr, nullptr)));
  hb_strfree(hStr);
}

/*
HWG_ENABLEMENUSYSTEMITEM(hWnd, nItem, lEnable, lFlag) --> .T.|.F.
*/
HB_FUNC(HWG_ENABLEMENUSYSTEMITEM)
{
  UINT uEnable = (hb_pcount() < 3 || !HB_ISLOG(3) || hb_parl(3)) ? MF_ENABLED : MF_GRAYED;
  UINT uFlag = (hb_pcount() < 4 || !HB_ISLOG(4) || hb_parl(4)) ? MF_BYCOMMAND : MF_BYPOSITION;
  auto hMenu = static_cast<HMENU>(GetSystemMenu(hwg_par_HWND(1), 0));
  if (!hMenu)
  {
    hb_retl(false);
  }
  else
  {
    hb_retl(EnableMenuItem(hMenu, hwg_par_UINT(2), uFlag | uEnable));
  }
}

/*
HWG_SETMENUBACKCOLOR(oObject|hMenu|hWnd, nColor, lApplyToSubMenus) --> NIL
*/
HB_FUNC(HWG_SETMENUBACKCOLOR)
{
  HMENU hMenu;
  MENUINFO mi;
  HBRUSH hbrush;

  if (HB_ISOBJECT(1))
  {
    hMenu = static_cast<HMENU>(hb_objDataGetPtr(hb_param(1, Harbour::Item::OBJECT), "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : MDIFrameWindow;
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }
  if (hMenu)
  {
    hbrush = hb_pcount() > 1 && !HB_ISNIL(2) ? CreateSolidBrush(hwg_par_COLORREF(2)) : nullptr;
    mi.cbSize = sizeof(mi);
    mi.fMask = MIM_BACKGROUND | ((HB_ISLOG(3) && !hb_parl(3)) ? 0 : MIM_APPLYTOSUBMENUS);
    mi.hbrBack = hbrush;
    SetMenuInfo(hMenu, &mi);
  }
}
