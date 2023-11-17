/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HList class
 *
 * Copyright 2002 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 * Listbox class and accompanying code added Feb 22nd, 2004 by
 * Vic McClung
*/

#include "hwingui.hpp"
#if defined(__MINGW32__) || defined(__MINGW64__)
#include <prsht.h>
#endif
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>

HB_FUNC( HWG_LISTBOXADDSTRING )
{
   void * hString;

   SendMessage(hwg_par_HWND(1), LB_ADDSTRING, 0, reinterpret_cast<LPARAM>(HB_PARSTR(2, &hString, nullptr)));
   hb_strfree(hString);
}

HB_FUNC( HWG_LISTBOXSETSTRING )
{
   SendMessage(hwg_par_HWND(1), LB_SETCURSEL, hwg_par_WPARAM(2) - 1, 0);
}

/*
   CreateListbox(hParentWIndow, nListboxID, nStyle, x, y, nWidth, nHeight)
*/
HB_FUNC( HWG_CREATELISTBOX )
{
   auto hListbox = CreateWindowEx(0, TEXT("LISTBOX"),     /* predefined class  */
         TEXT(""),                    /*   */
         WS_CHILD | WS_VISIBLE | hb_parnl(3), /* style  */
         hwg_par_int(4), hwg_par_int(5),  /* x, y       */
         hwg_par_int(6), hwg_par_int(7),  /* nWidth, nHeight */
         hwg_par_HWND(1),    /* parent window    */
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),       /* listbox ID      */
         GetModuleHandle(nullptr),
         nullptr);

   hb_retptr(hListbox);
}

HB_FUNC( HWG_LISTBOXDELETESTRING )
{
   SendMessage(hwg_par_HWND(1), LB_DELETESTRING, 0, static_cast<LPARAM>(0));
}
