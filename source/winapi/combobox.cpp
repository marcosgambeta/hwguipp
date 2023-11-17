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

/*
TODO: parametro 8 ?
HWG_CREATECOMBO(hParentWIndow, nComboID, nStyle, x, y, nWidth, nHeight, cInitialString) --> hCombo
*/
HB_FUNC( HWG_CREATECOMBO )
{
   auto hCombo = CreateWindowEx(0,
                                TEXT("COMBOBOX"),
                                TEXT(""),
                                WS_CHILD | WS_VISIBLE | hwg_par_DWORD(3),
                                hwg_par_int(4),
                                hwg_par_int(5),
                                hwg_par_int(6),
                                hwg_par_int(7),
                                hwg_par_HWND(1),
                                reinterpret_cast<HMENU>(hb_parni(2)),
                                GetModuleHandle(nullptr),
                                nullptr);

   hb_retptr(hCombo);
}

/*
HWG_COMBOBOXGETITEMDATA(hWnd, nPar2) --> numeric
*/
HB_FUNC( HWG_COMBOBOXGETITEMDATA )
{
   hb_retnl(static_cast<DWORD_PTR>(SendMessage(hwg_par_HWND(1), CB_GETITEMDATA, hb_parnl(2), 0)));
}

/*
HWG_COMBOBOXSETITEMDATA(hWnd, nPar2, nPar3) --> numeric
*/
HB_FUNC( HWG_COMBOBOXSETITEMDATA )
{
   hb_retnl(SendMessage(hwg_par_HWND(1), CB_SETITEMDATA, hb_parnl(2), static_cast<LPARAM>(static_cast<DWORD_PTR>(hb_parnl(3)))));
}

/*
HWG_COMBOBOXGETLBTEXT(hWnd, nPar2, @cPar3) --> numeric
*/
HB_FUNC( HWG_COMBOBOXGETLBTEXT )
{
   TCHAR lpszText[255] = {0};
   hb_retni(SendMessage(hwg_par_HWND(1), CB_GETLBTEXT, hb_parnl(2), reinterpret_cast<LPARAM>(lpszText)));
   HB_STORSTR(lpszText, 3);
}

/*
HWG_COMBOADDSTRING(hWnd, cString) --> NIL
*/
HB_FUNC( HWG_COMBOADDSTRING )
{
   void * hText;
   SendMessage(hwg_par_HWND(1), CB_ADDSTRING, 0, reinterpret_cast<LPARAM>(HB_PARSTR(2, &hText, nullptr)));
   hb_strfree(hText);
}

/*
HWG_COMBOINSERTSTRING(hWnd, nPar2, cString) --> NIL
*/
HB_FUNC( HWG_COMBOINSERTSTRING )
{
   void * hText;
   SendMessage(hwg_par_HWND(1), CB_INSERTSTRING, hwg_par_WPARAM(2), reinterpret_cast<LPARAM>(HB_PARSTR(3, &hText, nullptr)));
   hb_strfree(hText);
}

/*
HWG_COMBOSETSTRING(hWnd, nPar2) --> NIL
*/
HB_FUNC( HWG_COMBOSETSTRING )
{
   SendMessage(hwg_par_HWND(1), CB_SETCURSEL, hwg_par_WPARAM(2) - 1, 0);
}
