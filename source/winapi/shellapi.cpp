//
// HWGUI - Harbour Win32 GUI library source code:
// Shell API wrappers
//
// Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
// www - http://www.kresin.ru
//

#include "hwingui.hpp"
#include <shlobj.h>
#include <hbapi.hpp>
#include <hbapiitm.hpp>
#include "incomp_pointer.hpp"

#define ID_NOTIFYICON 1
#define WM_NOTIFYICON WM_USER + 1000

#ifndef BIF_USENEWUI
#ifndef BIF_NEWDIALOGSTYLE
#define BIF_NEWDIALOGSTYLE 0x0040 // Use the new dialog layout with the ability to resize
#endif
#define BIF_USENEWUI (BIF_NEWDIALOGSTYLE | BIF_EDITBOX)
#endif
#ifndef BIF_EDITBOX
#define BIF_EDITBOX 0x0010 // Add an editbox to the dialog
#endif

static int(CALLBACK BrowseCallbackProc)(HWND hwnd, UINT uMsg, LPARAM lParam, LPARAM lpData)
{
  // If the BFFM_INITIALIZED message is received
  // set the path to the start path.
  lParam = TRUE;
  switch (uMsg)
  {
  case BFFM_INITIALIZED: {
    if (lpData != reinterpret_cast<LPARAM>(nullptr))
    {
      SendMessage(hwnd, BFFM_SETSELECTION, lParam, lpData);
    }
  }
  }
  return 0; // The function should always return 0.
}

// SelectFolder(cTitle)
HB_FUNC(HWG_SELECTFOLDER)
{
  BROWSEINFO bi;
  TCHAR lpBuffer[MAX_PATH];
  LPCTSTR lpResult = nullptr;
  LPITEMIDLIST pidlBrowse; // PIDL selected by user
  void *hTitle;
  void *hFolderName;
  LPCTSTR lpFolderName;

  lpFolderName = HB_PARSTR(2, &hFolderName, nullptr);
  bi.hwndOwner = GetActiveWindow();
  bi.pidlRoot = nullptr;
  bi.pszDisplayName = lpBuffer;
  bi.lpszTitle = HB_PARSTRDEF(1, &hTitle, nullptr);
  bi.ulFlags = BIF_USENEWUI | BIF_NEWDIALOGSTYLE;
  bi.lpfn = BrowseCallbackProc; // = nullptr;
  bi.lParam = lpFolderName ? reinterpret_cast<LPARAM>(lpFolderName) : 0;
  bi.iImage = 0;

  // Browse for a folder and return its PIDL.
  pidlBrowse = SHBrowseForFolder(&bi);
  if (pidlBrowse != nullptr)
  {
    if (SHGetPathFromIDList(pidlBrowse, lpBuffer))
    {
      lpResult = lpBuffer;
    }
    CoTaskMemFree(pidlBrowse);
  }
  HB_RETSTR(lpResult);
  hb_strfree(hTitle);
  hb_strfree(hFolderName);
}

// ShellNotifyIcon(lAdd, hWnd, hIcon, cTooltip)
HB_FUNC(HWG_SHELLNOTIFYICON)
{
  NOTIFYICONDATA tnid{};

  tnid.cbSize = sizeof(NOTIFYICONDATA);
  tnid.hWnd = hwg_par_HWND(2);
  tnid.uID = ID_NOTIFYICON;
  tnid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
  tnid.uCallbackMessage = WM_NOTIFYICON;
  tnid.hIcon = hwg_par_HICON(3);
  HB_ITEMCOPYSTR(hb_param(4, Harbour::Item::ANY), tnid.szTip, HB_SIZEOFARRAY(tnid.szTip));

  if ((BOOL)hb_parl(1))
  {
    Shell_NotifyIcon(NIM_ADD, &tnid);
  }
  else
  {
    Shell_NotifyIcon(NIM_DELETE, &tnid);
  }
}

// ShellModifyIcon(hWnd, hIcon, cTooltip)
HB_FUNC(HWG_SHELLMODIFYICON)
{
  NOTIFYICONDATA tnid{};

  tnid.cbSize = sizeof(NOTIFYICONDATA);
  tnid.hWnd = hwg_par_HWND(1);
  tnid.uID = ID_NOTIFYICON;
  if (HB_ISNUM(2) || HB_ISPOINTER(2))
  {
    tnid.uFlags |= NIF_ICON;
    tnid.hIcon = hwg_par_HICON(2);
  }
  if (HB_ITEMCOPYSTR(hb_param(3, Harbour::Item::ANY), tnid.szTip, HB_SIZEOFARRAY(tnid.szTip)) > 0)
  {
    tnid.uFlags |= NIF_TIP;
  }

  Shell_NotifyIcon(NIM_MODIFY, &tnid);
}

// ShellExecute(cFile, cOperation, cParams, cDir, nFlag)
HB_FUNC(HWG_SHELLEXECUTE)
{
#if defined(HB_OS_WIN_CE)
  hb_retni(-1);
#else
  void *hOperation;
  void *hFile;
  void *hParameters;
  void *hDirectory;
  LPCTSTR lpDirectory;

  lpDirectory = HB_PARSTR(4, &hDirectory, nullptr);
  if (lpDirectory == nullptr)
  {
    lpDirectory = TEXT("C:\\");
  }

  hb_retnl(reinterpret_cast<LONG>(ShellExecute(GetActiveWindow(), HB_PARSTRDEF(2, &hOperation, nullptr),
                                               HB_PARSTR(1, &hFile, nullptr), HB_PARSTR(3, &hParameters, nullptr),
                                               lpDirectory, HB_ISNUM(5) ? hb_parni(5) : SW_SHOWNORMAL)));

  hb_strfree(hOperation);
  hb_strfree(hFile);
  hb_strfree(hParameters);
  hb_strfree(hDirectory);
#endif
}
