/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C level controls functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 */

#define HB_OS_WIN_32_USED

#define OEMRESOURCE

#include "hwingui.hpp"
#include <commctrl.h>
#include <winuser.h>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbdate.hpp>
#include <hbtrace.hpp>
/* Suppress compiler warnings */
#include "incomp_pointer.hpp"
#include "warnings.hpp"

LRESULT APIENTRY TreeViewSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static WNDPROC wpOrigTreeViewProc;

/*
HWG_CREATETREE(hParent, nControlId, nStyle, nX, nY, nWidth, nHeight) --> nCtrl
*/
HB_FUNC(HWG_CREATETREE)
{
  auto hCtrl =
      CreateWindowEx(WS_EX_CLIENTEDGE, WC_TREEVIEW, 0, WS_CHILD | WS_VISIBLE | WS_TABSTOP | hb_parnl(3), hwg_par_int(4),
                     hwg_par_int(5), hwg_par_int(6), hwg_par_int(7), hwg_par_HWND(1),
                     reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))), GetModuleHandle(nullptr), nullptr);

  if (!HB_ISNIL(8))
  {
    SendMessage(hCtrl, TVM_SETTEXTCOLOR, 0, hwg_par_LPARAM(8));
  }
  if (!HB_ISNIL(9))
  {
    SendMessage(hCtrl, TVM_SETBKCOLOR, 0, hwg_par_LPARAM(9));
  }

  hb_retptr(hCtrl);
}

HB_FUNC(HWG_TREEADDNODE)
{
  TV_ITEM tvi;
  TV_INSERTSTRUCT is;

  auto nPos = hb_parni(5);
  auto pObject = hb_param(1, Harbour::Item::OBJECT);
  void *hStr;

  tvi.iImage = 0;
  tvi.iSelectedImage = 0;

  tvi.mask = TVIF_TEXT | TVIF_PARAM;
  tvi.pszText = const_cast<LPTSTR>(HB_PARSTR(6, &hStr, nullptr));
  tvi.lParam = reinterpret_cast<LPARAM>(hb_itemNew(pObject));
  if (hb_pcount() > 6 && !HB_ISNIL(7))
  {
    tvi.iImage = hb_parni(7);
    tvi.mask |= TVIF_IMAGE;
    if (hb_pcount() > 7 && !HB_ISNIL(8))
    {
      tvi.iSelectedImage = hb_parni(8);
      tvi.mask |= TVIF_SELECTEDIMAGE;
    }
  }

#if !defined(__BORLANDC__) || (__BORLANDC__ > 1424)
  is.item = tvi;
#else
  is.DUMMYUNIONNAME.item = tvi;
#endif

  is.hParent = (HB_ISNIL(3) ? nullptr : static_cast<HTREEITEM>(hb_parptr(3)));

  switch (nPos)
  {
  case 0:
    is.hInsertAfter = static_cast<HTREEITEM>(hb_parptr(4));
    break;
  case 1:
    is.hInsertAfter = TVI_FIRST;
    break;
  case 2:
    is.hInsertAfter = TVI_LAST;
  }

  hb_retptr(reinterpret_cast<void *>(SendMessage(hwg_par_HWND(2), TVM_INSERTITEM, 0, reinterpret_cast<LPARAM>(&is))));

  if (tvi.mask & TVIF_IMAGE)
  {
    if (tvi.iImage)
    {
      DeleteObject(reinterpret_cast<HGDIOBJ>(static_cast<UINT_PTR>(tvi.iImage)));
    }
  }
  if (tvi.mask & TVIF_SELECTEDIMAGE)
  {
    if (tvi.iSelectedImage)
    {
      DeleteObject(reinterpret_cast<HGDIOBJ>(static_cast<UINT_PTR>(tvi.iSelectedImage)));
    }
  }

  hb_strfree(hStr);
}

/*
HB_FUNC( HWG_TREEDELNODE )
{
   hb_parl(TreeView_DeleteItem(hwg_par_HWND(1), static_cast<HTREEITEM>(hb_parptr(2))));
}

HB_FUNC( HWG_TREEDELALLNODES )
{
   TreeView_DeleteAllItems(hwg_par_HWND(1));
}
*/

HB_FUNC(HWG_TREEGETSELECTED)
{
  TV_ITEM TreeItem{};

  TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
  TreeItem.hItem = TreeView_GetSelection(hwg_par_HWND(1));

  if (TreeItem.hItem)
  {
    SendMessage(hwg_par_HWND(1), TVM_GETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
    auto oNode = reinterpret_cast<PHB_ITEM>(TreeItem.lParam);
    hb_itemReturn(oNode);
  }
}

/*
HB_FUNC( HWG_TREENODEHASCHILDREN )
{
   TV_ITEM TreeItem{};

   TreeItem.mask = TVIF_HANDLE | TVIF_CHILDREN;
   TreeItem.hItem = static_cast<HTREEITEM>(hb_parptr(2));

   SendMessage(hwg_par_HWND(1), TVM_GETITEM, 0, static_cast<LPARAM>(&TreeItem));
   hb_retni(TreeItem.cChildren);
}
*/

HB_FUNC(HWG_TREEGETNODETEXT)
{
  TV_ITEM TreeItem{};
  TCHAR ItemText[256] = {0};

  TreeItem.mask = TVIF_HANDLE | TVIF_TEXT;
  TreeItem.hItem = static_cast<HTREEITEM>(hb_parptr(2));
  TreeItem.pszText = ItemText;
  TreeItem.cchTextMax = 256;

  SendMessage(hwg_par_HWND(1), TVM_GETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
  HB_RETSTR(TreeItem.pszText);
}

#define TREE_SETITEM_TEXT 1
#define TREE_SETITEM_CHECK 2

HB_FUNC(HWG_TREESETITEM)
{
  TV_ITEM TreeItem{};
  auto iType = hb_parni(3);
  void *hStr = nullptr;

  TreeItem.mask = TVIF_HANDLE;
  TreeItem.hItem = static_cast<HTREEITEM>(hb_parptr(2));

  switch (iType)
  {
  case TREE_SETITEM_TEXT:
    TreeItem.mask |= TVIF_TEXT;
    TreeItem.pszText = const_cast<LPTSTR>(HB_PARSTR(4, &hStr, nullptr));
    break;
  case TREE_SETITEM_CHECK:
    TreeItem.mask |= TVIF_STATE;
    TreeItem.stateMask = TVIS_STATEIMAGEMASK;
    TreeItem.state = hb_parni(4);
    TreeItem.state = TreeItem.state << 12;
  }

  SendMessage(hwg_par_HWND(1), TVM_SETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
  hb_strfree(hStr);
}

#define TREE_GETNOTIFY_HANDLE 1
#define TREE_GETNOTIFY_PARAM 2
#define TREE_GETNOTIFY_EDIT 3
#define TREE_GETNOTIFY_EDITPARAM 4
#define TREE_GETNOTIFY_ACTION 5
#define TREE_GETNOTIFY_OLDPARAM 6

HB_FUNC(HWG_TREEGETNOTIFY)
{
  auto iType = hb_parni(2);

  switch (iType)
  {
  case TREE_GETNOTIFY_HANDLE: {
    hb_retptr(static_cast<HTREEITEM>((static_cast<NM_TREEVIEW *>(hb_parptr(1)))->itemNew.hItem));
    break;
  }
  case TREE_GETNOTIFY_ACTION: {
    hb_retni(static_cast<UINT>((static_cast<NM_TREEVIEW *>(hb_parptr(1)))->action));
    break;
  }
  case TREE_GETNOTIFY_PARAM: {
    auto oNode = reinterpret_cast<PHB_ITEM>(((static_cast<NM_TREEVIEW *>(hb_parptr(1)))->itemNew.lParam));
    hb_itemReturn(oNode);
    break;
  }
  case TREE_GETNOTIFY_EDITPARAM: {
    auto oNode = reinterpret_cast<PHB_ITEM>((static_cast<TV_DISPINFO *>(hb_parptr(1)))->item.lParam);
    hb_itemReturn(oNode);
    break;
  }
  case TREE_GETNOTIFY_OLDPARAM: {
    auto oNode = reinterpret_cast<PHB_ITEM>((static_cast<NM_TREEVIEW *>(hb_parptr(1)))->itemOld.lParam);
    hb_itemReturn(oNode);
    break;
  }
  case TREE_GETNOTIFY_EDIT: {
    auto tv = static_cast<TV_DISPINFO *>(hb_parptr(1));
    HB_RETSTR((tv->item.pszText) ? tv->item.pszText : TEXT(""));
  }
  }
}

/*
 * Tree_Hittest(hTree, x, y) --> oNode
 */
HB_FUNC(HWG_TREEHITTEST)
{
  TV_HITTESTINFO ht;
  auto hTree = hwg_par_HWND(1);

  if (hb_pcount() > 1 && HB_ISNUM(2) && HB_ISNUM(3))
  {
    ht.pt.x = hb_parni(2);
    ht.pt.y = hb_parni(3);
  }
  else
  {
    GetCursorPos(&(ht.pt));
    ScreenToClient(hTree, &(ht.pt));
  }

  SendMessage(hTree, TVM_HITTEST, 0, reinterpret_cast<LPARAM>(&ht));

  if (ht.hItem)
  {
    TV_ITEM TreeItem{};

    TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
    TreeItem.hItem = ht.hItem;

    SendMessage(hTree, TVM_GETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
    auto oNode = reinterpret_cast<PHB_ITEM>(TreeItem.lParam);
    hb_itemReturn(oNode);
    if (hb_pcount() > 3)
    {
      hb_storni(static_cast<int>(ht.flags), 4);
    }
  }
  else
  {
    hb_ret();
  }
}

HB_FUNC(HWG_TREERELEASENODE)
{
  TV_ITEM TreeItem{};

  TreeItem.mask = TVIF_HANDLE | TVIF_PARAM;
  TreeItem.hItem = static_cast<HTREEITEM>(hb_parptr(2));

  if (TreeItem.hItem)
  {
    SendMessage(hwg_par_HWND(1), TVM_GETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
    hb_itemRelease(reinterpret_cast<PHB_ITEM>(TreeItem.lParam));
    TreeItem.lParam = 0;
    SendMessage(hwg_par_HWND(1), TVM_SETITEM, 0, reinterpret_cast<LPARAM>(&TreeItem));
  }
}

HB_FUNC(HWG_INITTREEVIEW)
{
  wpOrigTreeViewProc = reinterpret_cast<WNDPROC>(
      SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(TreeViewSubclassProc)));
}

LRESULT APIENTRY TreeViewSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
  auto pObject = reinterpret_cast<PHB_ITEM>(GetWindowLongPtr(hWnd, GWLP_USERDATA));

  if (!pSym_onEvent)
  {
    pSym_onEvent = hb_dynsymFindName("ONEVENT");
  }

  if (pSym_onEvent && pObject)
  {
    hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
    hb_vmPush(pObject);
    hb_vmPushLong(static_cast<LONG>(message));
    //      hb_vmPushLong(static_cast<LONG>(wParam));
    //      hb_vmPushLong(static_cast<LONG>(lParam));
    hb_vmPushPointer(reinterpret_cast<void *>(wParam));
    hb_vmPushPointer(reinterpret_cast<void *>(lParam));
    hb_vmSend(3);
    if (HB_ISPOINTER(-1))
    {
      return reinterpret_cast<LRESULT>(hb_parptr(-1));
    }
    else
    {
      long int res = hb_parnl(-1);
      if (res == -1)
      {
        return (CallWindowProc(wpOrigTreeViewProc, hWnd, message, wParam, lParam));
      }
      else
      {
        return res;
      }
    }
  }
  else
  {
    return (CallWindowProc(wpOrigTreeViewProc, hWnd, message, wParam, lParam));
  }
}
