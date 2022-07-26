/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C level controls functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#define HB_OS_WIN_32_USED

#define OEMRESOURCE
#include "hwingui.h"
#include <commctrl.h>
#include <winuser.h>

#include "hbapiitm.h"
#include "hbvm.h"
#include "hbdate.h"
#include "hbtrace.h"

/* Suppress compiler warnings */
#include "incomp_pointer.h"
#include "warnings.h"

/*
TODO: parametro 8 ?
HWG_CREATECOMBO(hParentWIndow, nComboID, nStyle, x, y, nWidth, nHeight, cInitialString) --> hCombo
*/
HB_FUNC( HWG_CREATECOMBO )
{
   HWND hCombo = CreateWindow(TEXT("COMBOBOX"),
                              TEXT(""),
                              WS_CHILD | WS_VISIBLE | hb_parnl(3),
                              hwg_par_int(4),
                              hwg_par_int(5),
                              hwg_par_int(6),
                              hwg_par_int(7),
                              hwg_par_HWND(1),
                              reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),
                              GetModuleHandle(nullptr),
                              nullptr);

   HB_RETHANDLE(hCombo);
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
