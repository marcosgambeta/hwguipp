/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C level richedit control functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#define _RICHEDIT_VER	0x0200

#include "hwingui.hpp"
#if defined(__MINGW32__) || defined(__MINGW64__)
#include <prsht.h>
#endif
#include <commctrl.h>
#include <richedit.h>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include <hbdate.hpp>
#include "incomp_pointer.hpp"

LRESULT APIENTRY RichSubclassProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static HINSTANCE hRichEd = 0;
static WNDPROC wpOrigRichProc;

HB_FUNC( HWG_INITRICHEDIT )
{
   if( !hRichEd ) {
      hRichEd = LoadLibrary(TEXT("riched20.dll"));
   }
}

HB_FUNC( HWG_CREATERICHEDIT )
{
   HWND hCtrl;
   void * hText;
   LPCTSTR lpText;

   if( !hRichEd ) {
      hRichEd = LoadLibrary(TEXT("riched20.dll"));
   }

   hCtrl = CreateWindowEx(0,   /* extended style    */
#ifdef UNICODE
         TEXT("RichEdit20W"), /* predefined class  */
#else
         TEXT("RichEdit20A"), /* predefined class  */
#endif
         nullptr,                  /* title   */
         WS_CHILD | WS_VISIBLE | hb_parnl(3), /* style  */
         hwg_par_int(4), hwg_par_int(5),  /* x, y   */
         hwg_par_int(6), hwg_par_int(7),  /* nWidth, nHeight */
         hwg_par_HWND(1),    /* parent window    */
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),       /* control ID  */
         GetModuleHandle(nullptr), nullptr);

   lpText = HB_PARSTR(8, &hText, nullptr);
   if( lpText ) {
      SendMessage(hCtrl, WM_SETTEXT, 0, reinterpret_cast<LPARAM>(lpText));
   }
   hb_strfree(hText);

   HB_RETHANDLE(hCtrl);
}

/*
 * re_SetCharFormat(hCtrl, n1, n2, nColor, cName, nHeight, lBold, lItalic,
           lUnderline, nCharset, lSuperScript/lSubscript(.T./.F.), lProtected)
 */
HB_FUNC( HWG_RE_SETCHARFORMAT )
{
   auto hCtrl = hwg_par_HWND(1);
   CHARRANGE chrOld, chrNew;
   CHARFORMAT2 cf;
   PHB_ITEM pArr;

   SendMessage(hCtrl, EM_EXGETSEL, 0, reinterpret_cast<LPARAM>(&chrOld));
   SendMessage(hCtrl, EM_HIDESELECTION, 1, 0);

   if( HB_ISARRAY(2) ) {
      ULONG ulLen, ulLen1;
      PHB_ITEM pArr1;
      pArr = hb_param(2, Harbour::Item::ARRAY);
      ulLen = hb_arrayLen(pArr);
      for( ULONG ul = 1; ul <= ulLen; ul++ ) {
         pArr1 = hb_arrayGetItemPtr(pArr, ul);
         ulLen1 = hb_arrayLen(pArr1);
         chrNew.cpMin = hb_arrayGetNL(pArr1, 1) - 1;
         chrNew.cpMax = hb_arrayGetNL(pArr1, 2) - 1;
         SendMessage(hCtrl, EM_EXSETSEL, 0, reinterpret_cast<LPARAM>(&chrNew));

         memset(&cf, 0, sizeof(CHARFORMAT2));
         cf.cbSize = sizeof(CHARFORMAT2);
         if( hb_itemType(hb_arrayGetItemPtr(pArr1, 3)) != Harbour::Item::NIL ) {
            cf.crTextColor = static_cast<COLORREF>(hb_arrayGetNL(pArr1, 3));
            cf.dwMask |= CFM_COLOR;
         }
         if( ulLen1 > 3 && hb_itemType(hb_arrayGetItemPtr(pArr1, 4)) != Harbour::Item::NIL ) {
            HB_ITEMCOPYSTR(hb_arrayGetItemPtr(pArr1, 4), cf.szFaceName, HB_SIZEOFARRAY(cf.szFaceName));
            cf.szFaceName[HB_SIZEOFARRAY(cf.szFaceName) - 1] = '\0';
            cf.dwMask |= CFM_FACE;
         }
         if( ulLen1 > 4 && hb_itemType(hb_arrayGetItemPtr(pArr1, 5)) != Harbour::Item::NIL ) {
            cf.yHeight = hb_arrayGetNL(pArr1, 5);
            cf.dwMask |= CFM_SIZE;
         }
         if( ulLen1 > 5 && hb_itemType(hb_arrayGetItemPtr(pArr1, 6)) != Harbour::Item::NIL && hb_arrayGetL(pArr1, 6) ) {
            cf.dwEffects |= CFE_BOLD;
         }
         if( ulLen1 > 6 && hb_itemType(hb_arrayGetItemPtr(pArr1, 7)) != Harbour::Item::NIL && hb_arrayGetL(pArr1, 7) ) {
            cf.dwEffects |= CFE_ITALIC;
         }
         if( ulLen1 > 7 && hb_itemType(hb_arrayGetItemPtr(pArr1, 8)) != Harbour::Item::NIL && hb_arrayGetL(pArr1, 8) ) {
            cf.dwEffects |= CFE_UNDERLINE;
         }
         if( ulLen1 > 8 && hb_itemType(hb_arrayGetItemPtr(pArr1, 9)) != Harbour::Item::NIL ) {
            cf.bCharSet = static_cast<BYTE>(hb_arrayGetNL(pArr1, 9));
            cf.dwMask |= CFM_CHARSET;
         }
         if( ulLen1 > 9 && hb_itemType(hb_arrayGetItemPtr(pArr1, 10)) != Harbour::Item::NIL ) {
            if( hb_arrayGetL(pArr1, 10) ) {
               cf.dwEffects |= CFE_SUPERSCRIPT;
            } else {
               cf.dwEffects |= CFE_SUBSCRIPT;
            }
            cf.dwMask |= CFM_SUPERSCRIPT;
         }
         if( ulLen1 > 10 && hb_itemType(hb_arrayGetItemPtr(pArr1, 11)) != Harbour::Item::NIL && hb_arrayGetL(pArr1, 11) ) {
            cf.dwEffects |= CFE_PROTECTED;
         }
         cf.dwMask |= ( CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE | CFM_PROTECTED );
         SendMessage(hCtrl, EM_SETCHARFORMAT, SCF_SELECTION, reinterpret_cast<LPARAM>(&cf));
      }
   } else {
      /*   Set new selection   */
      chrNew.cpMin = hb_parnl(2) - 1;
      chrNew.cpMax = hb_parnl(3) - 1;
      SendMessage(hCtrl, EM_EXSETSEL, 0, reinterpret_cast<LPARAM>(&chrNew));

      memset(&cf, 0, sizeof(CHARFORMAT2));
      cf.cbSize = sizeof(CHARFORMAT2);

      if( !HB_ISNIL(4) ) {
         cf.crTextColor = hwg_par_COLORREF(4);
         cf.dwMask |= CFM_COLOR;
      }
      if( !HB_ISNIL(5) ) {
         HB_ITEMCOPYSTR(hb_param(5, Harbour::Item::ANY), cf.szFaceName, HB_SIZEOFARRAY(cf.szFaceName));
         cf.szFaceName[HB_SIZEOFARRAY(cf.szFaceName) - 1] = '\0';
         cf.dwMask |= CFM_FACE;
      }
      if( !HB_ISNIL(6) ) {
         cf.yHeight = hb_parnl(6);
         cf.dwMask |= CFM_SIZE;
      }
      if( !HB_ISNIL(7) ) {
         cf.dwEffects |= ( hb_parl(7) ) ? CFE_BOLD : 0;
         cf.dwMask |= CFM_BOLD;
      }
      if( !HB_ISNIL(8) ) {
         cf.dwEffects |= ( hb_parl(8) ) ? CFE_ITALIC : 0;
         cf.dwMask |= CFM_ITALIC;
      }
      if( !HB_ISNIL(9) ) {
         cf.dwEffects |= ( hb_parl(9) ) ? CFE_UNDERLINE : 0;
         cf.dwMask |= CFM_UNDERLINE;
      }
      if( !HB_ISNIL(10) ) {
         cf.bCharSet = hwg_par_BYTE(10);
         cf.dwMask |= CFM_CHARSET;
      }
      if( !HB_ISNIL(11) ) {
         if( hb_parl(9) ) {
            cf.dwEffects |= CFE_SUPERSCRIPT;
         } else {
            cf.dwEffects |= CFE_SUBSCRIPT;
         }
         cf.dwMask |= CFM_SUPERSCRIPT;
      }
      if( !HB_ISNIL(12) ) {
         cf.dwEffects |= CFE_PROTECTED;
         cf.dwMask |= CFM_PROTECTED;
      }

      SendMessage(hCtrl, EM_SETCHARFORMAT, SCF_SELECTION, reinterpret_cast<LPARAM>(&cf));
   }

   /*   Restore selection   */
   SendMessage(hCtrl, EM_EXSETSEL, 0, reinterpret_cast<LPARAM>(&chrOld));
   SendMessage(hCtrl, EM_HIDESELECTION, 0, 0);

}

/*
 * re_SetDefault(hCtrl, nColor, cName, nHeight, lBold, lItalic, lUnderline, nCharset)
 */
HB_FUNC( HWG_RE_SETDEFAULT )
{
   auto hCtrl = hwg_par_HWND(1);
   CHARFORMAT2 cf{};

   cf.cbSize = sizeof(CHARFORMAT2);

   if( HB_ISNUM(2) ) {
      cf.crTextColor = hwg_par_COLORREF(2);
      cf.dwMask |= CFM_COLOR;
   }
   if( HB_ISCHAR(3) ) {
      HB_ITEMCOPYSTR(hb_param(3, Harbour::Item::ANY), cf.szFaceName, HB_SIZEOFARRAY(cf.szFaceName));
      cf.szFaceName[HB_SIZEOFARRAY(cf.szFaceName) - 1] = '\0';
      cf.dwMask |= CFM_FACE;
   }

   if( HB_ISNUM(4) ) {
      cf.yHeight = hb_parnl(4);
      cf.dwMask |= CFM_SIZE;
   }

   if( !HB_ISNIL(5) ) {
      cf.dwEffects |= ( hb_parl(5) ) ? CFE_BOLD : 0;
   }
   if( !HB_ISNIL(6) ) {
      cf.dwEffects |= ( hb_parl(6) ) ? CFE_ITALIC : 0;
   }
   if( !HB_ISNIL(7) ) {
      cf.dwEffects |= ( hb_parl(7) ) ? CFE_UNDERLINE : 0;
   }

   if( HB_ISNUM(8) ) {
      cf.bCharSet = hwg_par_BYTE(8);
      cf.dwMask |= CFM_CHARSET;
   }

   cf.dwMask |= ( CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE );
   SendMessage(hCtrl, EM_SETCHARFORMAT, SCF_ALL, reinterpret_cast<LPARAM>(&cf));
}

/*
 * re_CharFromPos(hEdit, xPos, yPos) --> nPos
 */
HB_FUNC( HWG_RE_CHARFROMPOS )
{
   auto hCtrl = hwg_par_HWND(1);
   auto x = hb_parni(2);
   auto y = hb_parni(3);
   ULONG ul;
   POINTL pp;

   pp.x = x;
   pp.y = y;
   ul = SendMessage(hCtrl, EM_CHARFROMPOS, 0, reinterpret_cast<LPARAM>(&pp));
   hb_retnl(ul);
}

/*
 * re_GetTextRange(hEdit, n1, n2)
 */
HB_FUNC( HWG_RE_GETTEXTRANGE )
{
   auto hCtrl = hwg_par_HWND(1);
   TEXTRANGE tr;
   ULONG ul;

   tr.chrg.cpMin = hb_parnl(2) - 1;
   tr.chrg.cpMax = hb_parnl(3) - 1;

   tr.lpstrText = ( LPTSTR ) hb_xgrab((tr.chrg.cpMax - tr.chrg.cpMin + 2) * sizeof(TCHAR));
   ul = SendMessage(hCtrl, EM_GETTEXTRANGE, 0, reinterpret_cast<LPARAM>(&tr));
   HB_RETSTRLEN(tr.lpstrText, ul);
   hb_xfree(tr.lpstrText);
}

/*
 * re_GetLine(hEdit, nLine)
 */
HB_FUNC( HWG_RE_GETLINE )
{
   auto hCtrl = hwg_par_HWND(1);
   auto nLine = hb_parni(2);
   ULONG uLineIndex = SendMessage(hCtrl, EM_LINEINDEX, static_cast<WPARAM>(nLine), 0);
   ULONG ul = SendMessage(hCtrl, EM_LINELENGTH, static_cast<WPARAM>(uLineIndex), 0);
   LPTSTR lpBuf = ( LPTSTR ) hb_xgrab((ul + 4) * sizeof(TCHAR));

   *(reinterpret_cast<ULONG*>(lpBuf)) = ul;
   ul = SendMessage(hCtrl, EM_GETLINE, nLine, reinterpret_cast<LPARAM>(lpBuf));
   HB_RETSTRLEN(lpBuf, ul);
   hb_xfree(lpBuf);
}

HB_FUNC( HWG_RE_INSERTTEXT )
{
   void * hString;
   SendMessage(hwg_par_HWND(1), EM_REPLACESEL, 0, reinterpret_cast<LPARAM>(HB_PARSTR(2, &hString, nullptr)));
   hb_strfree(hString);
}

/*
 * re_FindText(hEdit, cFind, nStart, bCase, bWholeWord, bSearchUp)
 */
HB_FUNC( HWG_RE_FINDTEXT )
{
   auto hCtrl = hwg_par_HWND(1);
   FINDTEXTEX ft;
   LONG lFlag = ((HB_ISNIL(4) || !hb_parl(4)) ? 0 : FR_MATCHCASE) |
         ((HB_ISNIL(5) || !hb_parl(5)) ? 0 : FR_WHOLEWORD) |
         ((HB_ISNIL(6) || !hb_parl(6)) ? FR_DOWN : 0);
   void * hString;

   ft.chrg.cpMin = (HB_ISNIL(3)) ? 0 : hb_parnl(3);
   ft.chrg.cpMax = -1;
   ft.lpstrText = ( LPTSTR ) HB_PARSTR(2, &hString, nullptr);

   auto lPos = static_cast<LONG>(SendMessage(hCtrl, EM_FINDTEXTEX, static_cast<WPARAM>(lFlag), reinterpret_cast<LPARAM>(&ft)));
   hb_strfree(hString);
   hb_retnl(lPos);
}

HB_FUNC( HWG_RE_SETZOOM )
{
   auto hwnd = hwg_par_HWND(1);
   auto nNum = hb_parni(2);
   auto nDen = hb_parni(3);
   hb_retnl(( BOOL ) SendMessage(hwnd, EM_SETZOOM, nNum, nDen));
}


HB_FUNC( HWG_RE_ZOOMOFF )
{
   auto hwnd = hwg_par_HWND(1);
   hb_retnl(( BOOL ) SendMessage(hwnd, EM_SETZOOM, 0, 0L));
}

HB_FUNC( HWG_RE_GETZOOM )
{
   auto hwnd = hwg_par_HWND(1);
   auto nNum = hb_parni(2);
   auto nDen = hb_parni(3);
   hb_retnl(( BOOL ) SendMessage(hwnd, EM_GETZOOM, reinterpret_cast<WPARAM>(&nNum), reinterpret_cast<LPARAM>(&nDen)));
   hb_storni(nNum, 2);
   hb_storni(nDen, 3);
}

HB_FUNC( HWG_PRINTRTF )
{
   auto hwnd = hwg_par_HWND(1);
   auto hdc = hwg_par_HDC(2);
   FORMATRANGE fr;
   BOOL fSuccess = TRUE;
   int cxPhysOffset = GetDeviceCaps(hdc, PHYSICALOFFSETX);
   int cyPhysOffset = GetDeviceCaps(hdc, PHYSICALOFFSETY);
   int cxPhys = GetDeviceCaps(hdc, PHYSICALWIDTH);
   int cyPhys = GetDeviceCaps(hdc, PHYSICALHEIGHT);
   int ppi_x = GetDeviceCaps(hdc, LOGPIXELSX);
   int ppi_y = GetDeviceCaps(hdc, LOGPIXELSX);
   int cpMin;

   SendMessage(hwnd, EM_SETTARGETDEVICE, reinterpret_cast<WPARAM>(hdc), cxPhys / 2);
   fr.hdc = hdc;
   fr.hdcTarget = hdc;
   fr.rc.left = 1440 * cxPhysOffset / ppi_x;
   fr.rc.right = 1440 * ( cxPhysOffset + cxPhys ) / ppi_x;
   fr.rc.top = 1440 * cyPhysOffset / ppi_y;
   fr.rc.bottom = 1440 * ( cyPhysOffset + cyPhys ) / ppi_y;

   SendMessage(hwnd, EM_SETSEL, 0, static_cast<LPARAM>(-1));
   SendMessage(hwnd, EM_EXGETSEL, 0, reinterpret_cast<LPARAM>(&fr.chrg));
   while( fr.chrg.cpMin < fr.chrg.cpMax && fSuccess ) {
      fSuccess = StartPage(hdc) > 0;
      if( !fSuccess ) {
         break;
      }
      cpMin = SendMessage(hwnd, EM_FORMATRANGE, TRUE, reinterpret_cast<LPARAM>(&fr));
      if( cpMin <= fr.chrg.cpMin ) {
         fSuccess = FALSE;
         break;
      }
      fr.chrg.cpMin = cpMin;
      fSuccess = EndPage(hdc) > 0;
   }
   SendMessage(hwnd, EM_FORMATRANGE, FALSE, 0);
   SendMessage(hwnd, EM_EXSETSEL, 0, reinterpret_cast<LPARAM>(&fr.chrg));
   SendMessage(hwnd, EM_HIDESELECTION, 0, 0);
   hb_retnl(( BOOL ) fSuccess);
}

HB_FUNC( HWG_INITRICHPROC )
{
   wpOrigRichProc = reinterpret_cast<WNDPROC>(SetWindowLongPtr(hwg_par_HWND(1), GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(RichSubclassProc)));
}

LRESULT APIENTRY RichSubclassProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   long int res;
   PHB_ITEM pObject = ( PHB_ITEM ) GetWindowLongPtr(hWnd, GWLP_USERDATA);

   if( !pSym_onEvent ) {
      pSym_onEvent = hb_dynsymFindName("ONEVENT");
   }

   if( pSym_onEvent && pObject ) {
      hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
      hb_vmPush(pObject);
      hb_vmPushLong(static_cast<LONG>(message));
      hb_vmPushLong(static_cast<LONG>(wParam));
      hb_vmPushLong(static_cast<LONG>(lParam));
      hb_vmSend(3);
      res = hb_parnl(-1);
      if( res == -1 ) {
         return (CallWindowProc(wpOrigRichProc, hWnd, message, wParam, lParam));
      } else {
         return res;
      }
   } else {
      return (CallWindowProc(wpOrigRichProc, hWnd, message, wParam, lParam));
   }
}

static DWORD CALLBACK RichStreamOutCallback(DWORD_PTR dwCookie, LPBYTE pbBuff, LONG cb, LONG * pcb)
{
   auto pFile = reinterpret_cast<HANDLE>(dwCookie);
   DWORD dwW;
   HB_SYMBOL_UNUSED(pcb);

   if( pFile == INVALID_HANDLE_VALUE ) {
      return 0;
   }

   WriteFile(pFile, pbBuff, cb, &dwW, nullptr);
   return 0;
}

static DWORD CALLBACK EditStreamCallback(DWORD_PTR dwCookie, LPBYTE lpBuff, LONG cb, PLONG pcb)
{
   auto hFile = reinterpret_cast<HANDLE>(dwCookie);
   return !ReadFile(hFile, lpBuff, cb, reinterpret_cast<DWORD*>(pcb), nullptr);
}

HB_FUNC( HWG_SAVERICHEDIT )
{

   auto hWnd = hwg_par_HWND(1);
   HANDLE hFile;
   EDITSTREAM es;
   void * hFileName;
   LPCTSTR lpFileName;
   HB_SIZE nSize;

   lpFileName = HB_PARSTR(2, &hFileName, &nSize);
   hFile = CreateFile(lpFileName, GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
   if( hFile == INVALID_HANDLE_VALUE ) {
      hb_retni(0);
      return;
   }
   es.dwCookie = reinterpret_cast<DWORD>(hFile);
   es.pfnCallback = RichStreamOutCallback;

   SendMessage(hWnd, EM_STREAMOUT, static_cast<WPARAM>(SF_RTF), reinterpret_cast<LPARAM>(&es));
   CloseHandle(hFile);
   HB_RETHANDLE(hFile);

}

HB_FUNC( HWG_LOADRICHEDIT )
{

   auto hWnd = hwg_par_HWND(1);
   HANDLE hFile;
   EDITSTREAM es;
   void * hFileName;
   LPCTSTR lpFileName;
   HB_SIZE nSize;

   lpFileName = HB_PARSTR(2, &hFileName, &nSize);
   hFile = CreateFile(lpFileName, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, nullptr);
   if( hFile == INVALID_HANDLE_VALUE ) {
      hb_retni(0);
      return;
   }
   es.dwCookie = reinterpret_cast<DWORD_PTR>(hFile);
   es.pfnCallback = EditStreamCallback;
   SendMessage(hWnd, EM_STREAMIN, static_cast<WPARAM>(SF_RTF), reinterpret_cast<LPARAM>(&es));
   CloseHandle(hFile);
   HB_RETHANDLE(hFile);
}
