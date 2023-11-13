/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C level text functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#define OEMRESOURCE

#include "hwingui.hpp"
#include <commctrl.h>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include <hbapiitm.hpp>

static PHB_ITEM aFontsList;
static PHB_ITEM pFontsItemLast, pFontsItem;

HB_FUNC( HWG_DEFINEPAINTSTRU )
{
   auto pps = static_cast<PAINTSTRUCT*>(hb_xgrab(sizeof(PAINTSTRUCT)));
   hb_retptr(pps);
}

HB_FUNC( HWG_BEGINPAINT )
{
   auto pps = static_cast<PAINTSTRUCT*>(hb_parptr(2));
   auto hDC = BeginPaint(hwg_par_HWND(1), pps);
   hb_retptr(hDC);
}

HB_FUNC( HWG_ENDPAINT )
{
   auto pps = static_cast<PAINTSTRUCT*>(hb_parptr(2));
   EndPaint(hwg_par_HWND(1), pps);
   hb_xfree(pps);
}

HB_FUNC( HWG_DELETEDC )
{
   DeleteDC(hwg_par_HDC(1));
}

HB_FUNC( HWG_TEXTOUT )
{
   void * hText;
   HB_SIZE nLen;
   LPCTSTR lpText = HB_PARSTR(4, &hText, &nLen);

   TextOut(hwg_par_HDC(1),  // handle of device context
         hb_parni(2),         // x-coordinate of starting position
         hb_parni(3),         // y-coordinate of starting position
         lpText,                // address of string
         nLen                   // number of characters in string
         );
   hb_strfree(hText);
}

HB_FUNC( HWG_DRAWTEXT )
{
   void * hText;
   HB_SIZE nLen;
   LPCTSTR lpText = HB_PARSTR(2, &hText, &nLen);
   RECT rc;
   UINT uFormat = (hb_pcount() == 4 ? hb_parni(4) : hb_parni(7));
   // int uiPos = (hb_pcount() == 4 ? 3 : hb_parni(8));
   int heigh;

   if( hb_pcount() > 4 ) {
      rc.left = hb_parni(3);
      rc.top = hb_parni(4);
      rc.right = hb_parni(5);
      rc.bottom = hb_parni(6);
   } else {
      Array2Rect(hb_param(3, Harbour::Item::ARRAY), &rc);
   }


   heigh = DrawText(hwg_par_HDC(1), // handle of device context
         lpText,                // address of string
         nLen,                  // number of characters in string
         &rc, uFormat);
   hb_strfree(hText);

   //if( HB_ISBYREF(uiPos) )
   if( HB_ISARRAY(8) ) {
      hb_storvni(rc.left, 8, 1);
      hb_storvni(rc.top, 8, 2);
      hb_storvni(rc.right, 8, 3);
      hb_storvni(rc.bottom, 8, 4);
   }
   hb_retni(heigh);

}

HB_FUNC( HWG_GETTEXTMETRIC )
{
   TEXTMETRIC tm;
   auto aMetr = hb_itemArrayNew(8);

   GetTextMetrics(hwg_par_HDC(1),   // handle of device context
         &tm                    // address of text metrics structure
         );

   auto temp = hb_itemPutNL(nullptr, tm.tmHeight);
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, tm.tmAveCharWidth);
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, tm.tmMaxCharWidth);
   hb_itemArrayPut(aMetr, 3, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, tm.tmExternalLeading);
   hb_itemArrayPut(aMetr, 4, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, tm.tmInternalLeading);
   hb_itemArrayPut(aMetr, 5, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, tm.tmAscent);
   hb_itemArrayPut(aMetr, 6, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, tm.tmDescent);
   hb_itemArrayPut(aMetr, 7, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, tm.tmWeight);
   hb_itemArrayPut(aMetr, 8, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);
}

HB_FUNC( HWG_GETTEXTSIZE )
{

   void * hText;
   HB_SIZE nLen;
   LPCTSTR lpText = HB_PARSTR(2, &hText, &nLen);
   SIZE sz;
   auto aMetr = hb_itemArrayNew(2);

   GetTextExtentPoint32(hwg_par_HDC(1), lpText, nLen, &sz);
   hb_strfree(hText);

   auto temp = hb_itemPutNL(nullptr, sz.cx);
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, sz.cy);
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);
}

HB_FUNC( HWG_GETCLIENTRECT )
{
   RECT rc;
   auto aMetr = hb_itemArrayNew(4);

   GetClientRect(hwg_par_HWND(1), &rc);

   auto temp = hb_itemPutNL(nullptr, rc.left);
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, rc.top);
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, rc.right);
   hb_itemArrayPut(aMetr, 3, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, rc.bottom);
   hb_itemArrayPut(aMetr, 4, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);
}

HB_FUNC( HWG_GETWINDOWRECT )
{
   RECT rc;
   auto aMetr = hb_itemArrayNew(4);

   GetWindowRect(hwg_par_HWND(1), &rc);

   auto temp = hb_itemPutNL(nullptr, rc.left);
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, rc.top);
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, rc.right);
   hb_itemArrayPut(aMetr, 3, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, rc.bottom);
   hb_itemArrayPut(aMetr, 4, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);
}

HB_FUNC( HWG_GETCLIENTAREA )
{
   auto pps = static_cast<PAINTSTRUCT*>(hb_parptr(1));
   auto aMetr = hb_itemArrayNew(4);

   auto temp = hb_itemPutNL(nullptr, pps->rcPaint.left);
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, pps->rcPaint.top);
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, pps->rcPaint.right);
   hb_itemArrayPut(aMetr, 3, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, pps->rcPaint.bottom);
   hb_itemArrayPut(aMetr, 4, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);
}

/*
HWG_SETTEXTCOLOR(hDC, nColor) --> numeric
*/
HB_FUNC( HWG_SETTEXTCOLOR )
{
   hb_retnl(static_cast<LONG>(SetTextColor(hwg_par_HDC(1), hwg_par_COLORREF(2))));
}

/*
HWG_SETBKCOLOR(hDC, nColor) --> numeric
*/
HB_FUNC( HWG_SETBKCOLOR )
{
   hb_retnl(static_cast<LONG>(SetBkColor(hwg_par_HDC(1), hwg_par_COLORREF(2))));
}

/*
HWG_SETTRANSPARENTMODE(hDC, lPar) --> logical
*/
HB_FUNC( HWG_SETTRANSPARENTMODE )
{
   hb_retl(SetBkMode(hwg_par_HDC(1), hb_parl(2) ? TRANSPARENT : OPAQUE) == TRANSPARENT);
}

/*
HWG_GETTEXTCOLOR(hDC) --> numeric
*/
HB_FUNC( HWG_GETTEXTCOLOR )
{
   hb_retnl(static_cast<LONG>(GetTextColor(hwg_par_HDC(1))));
}

/*
HWG_GETBKCOLOR(hDC) --> numeric
*/
HB_FUNC( HWG_GETBKCOLOR )
{
   hb_retnl(static_cast<LONG>(GetBkColor(hwg_par_HDC(1))));
}

/*
HB_FUNC( HWG_GETTEXTSIZE )
{
   auto hdc = GetDC(hwg_par_HWND(1));
   SIZE size;
   auto aMetr = hb_itemArrayNew(2);
   void * hString;

   GetTextExtentPoint32(hdc, HB_PARSTR(2, &hString, nullptr),
      lpString,         // address of text string
      strlen(cbString), // number of characters in string
      &size            // address of structure for string size
   );
   hb_strfree(hString);

   auto temp = hb_itemPutNI(nullptr, size.cx);
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNI(nullptr, size.cy);
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);
}
*/

/*
HWG_EXTTEXTOUT(hDC, nX, nY, nLeft, nTop, nRight, nBottom) --> NIL
*/
HB_FUNC( HWG_EXTTEXTOUT )
{
   RECT rc;
   void * hText;
   HB_SIZE nLen;
   LPCTSTR lpText = HB_PARSTR(8, &hText, &nLen);

   rc.left = hb_parni(4);
   rc.top = hb_parni(5);
   rc.right = hb_parni(6);
   rc.bottom = hb_parni(7);

   ExtTextOut(hwg_par_HDC(1),       // handle to device context
         hb_parni(2),         // x-coordinate of reference point
         hb_parni(3),         // y-coordinate of reference point
         ETO_OPAQUE,            // text-output options
         &rc,                   // optional clipping and/or opaquing rectangle
         lpText,                // points to string
         nLen,                  // number of characters in string
         nullptr                   // pointer to array of intercharacter spacing values
         );
   hb_strfree(hText);
}

/*
HWG_WRITESTATUSWINDOW(hWnd, nPar2, cString) --> NIL
*/
HB_FUNC( HWG_WRITESTATUSWINDOW )
{
   void * hString;
   SendMessage(hwg_par_HWND(1), SB_SETTEXT, hb_parni(2), reinterpret_cast<LPARAM>(HB_PARSTR(3, &hString, nullptr)));
   hb_strfree(hString);
}

/*
HWG_WINDOWFROMDC(hDC) --> hWnd
*/
HB_FUNC( HWG_WINDOWFROMDC )
{
   hb_retptr(WindowFromDC(hwg_par_HDC(1)));
}

/*
CreateFont(fontName, nWidth, hHeight [,fnWeight] [,fdwCharSet], [,fdwItalic] [,fdwUnderline] [,fdwStrikeOut])
*/
HB_FUNC( HWG_CREATEFONT )
{
   HFONT hFont;
   int fnWeight = (HB_ISNIL(4)) ? 0 : hb_parni(4);
   DWORD fdwCharSet = (HB_ISNIL(5)) ? 0 : hb_parni(5);
   DWORD fdwItalic = (HB_ISNIL(6)) ? 0 : hb_parni(6);
   DWORD fdwUnderline = (HB_ISNIL(7)) ? 0 : hb_parni(7);
   DWORD fdwStrikeOut = (HB_ISNIL(8)) ? 0 : hb_parni(8);
   void * hString;

   hFont = CreateFont(hb_parni(3),   // logical height of font
         hb_parni(2),         // logical average character width
         0,                     // angle of escapement
         0,                     // base-line orientation angle
         fnWeight,              // font weight
         fdwItalic,             // italic attribute flag
         fdwUnderline,          // underline attribute flag
         fdwStrikeOut,          // strikeout attribute flag
         fdwCharSet,            // character set identifier
         0,                     // output precision
         0,                     // clipping precision
         0,                     // output quality
         0,                     // pitch and family
         HB_PARSTR(1, &hString, nullptr) // pointer to typeface name string
          );
   hb_strfree(hString);
   hb_retptr(hFont);
}

/*
 * SetCtrlFont(hWnd, ctrlId, hFont)
*/
HB_FUNC( HWG_SETCTRLFONT )
{
   SendDlgItemMessage(hwg_par_HWND(1), hb_parni(2), WM_SETFONT, reinterpret_cast<WPARAM>(hb_parptr(3)), 0L);
}

HB_FUNC( HWG_CREATERECTRGN )
{
   hb_retptr(CreateRectRgn(hb_parni(1), hb_parni(2), hb_parni(3), hb_parni(4)));
}

/*
HWG_CREATERECTRGNINDIRECT(NIL, nLeft, nTop, nRight, nBottom) -> hRgn
*/
HB_FUNC( HWG_CREATERECTRGNINDIRECT )
{
   RECT rc;

   rc.left = hb_parni(2);
   rc.top = hb_parni(3);
   rc.right = hb_parni(4);
   rc.bottom = hb_parni(5);

   hb_retptr(CreateRectRgnIndirect(&rc));
}

HB_FUNC( HWG_EXTSELECTCLIPRGN )
{
   hb_retni(ExtSelectClipRgn(hwg_par_HDC(1), hwg_par_HRGN(2), hb_parni(3)));
}

HB_FUNC( HWG_SELECTCLIPRGN )
{
   hb_retni(SelectClipRgn(hwg_par_HDC(1), hwg_par_HRGN(2)));
}

HB_FUNC( HWG_CREATEFONTINDIRECT )
{
   LOGFONT lf{};
   lf.lfQuality = hb_parni(4);
   lf.lfHeight = hb_parni(3);
   lf.lfWeight = hb_parni(2);
   HB_ITEMCOPYSTR(hb_param(1, Harbour::Item::ANY), lf.lfFaceName, HB_SIZEOFARRAY(lf.lfFaceName));
   lf.lfFaceName[HB_SIZEOFARRAY(lf.lfFaceName) - 1] = '\0';

   hb_retptr(CreateFontIndirect(&lf));
}

#if __HARBOUR__ - 0 > 0x030000
int CALLBACK GetFontsCallback(ENUMLOGFONTEX *lpelfe, NEWTEXTMETRICEX *lpntme, DWORD FontType, LPARAM lParam)
{
   HB_SYMBOL_UNUSED(lpntme);
   HB_SYMBOL_UNUSED(FontType);
   HB_SYMBOL_UNUSED(lParam);

   HB_ITEMPUTSTR(pFontsItem, (LPCTSTR)lpelfe->elfFullName);
   if( !hb_itemEqual(pFontsItem, pFontsItemLast) ) {
      HB_ITEMPUTSTR(pFontsItemLast, (LPCTSTR)lpelfe->elfFullName);
      hb_arrayAdd(aFontsList, pFontsItem);
   }
   return 1;
}

HB_FUNC( HWG_GETFONTSLIST )
{
   LOGFONT lf{};
   HWND hwnd=GetDesktopWindow();
   auto hDC = GetDC(hwnd);

   lf.lfCharSet = DEFAULT_CHARSET;
   aFontsList = hb_itemArrayNew(0);
   pFontsItem = hb_itemPutC(nullptr, "");
   pFontsItemLast = hb_itemPutC(nullptr, "");

   EnumFontFamiliesEx(hDC, &lf, (FONTENUMPROC)GetFontsCallback, 0, 0);

   hb_itemRelease(pFontsItem);
   hb_itemRelease(pFontsItemLast);
   hb_itemReturnRelease(aFontsList);
}
#endif
