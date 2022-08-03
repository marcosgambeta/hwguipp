/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C level common dialogs functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#define OEMRESOURCE
#include "hwingui.h"
#include "hbapiitm.h"
#include "hbvm.h"

/*
HWG_SELECTFONT(oPar1) --> array
*/
HB_FUNC( HWG_SELECTFONT )
{
   CHOOSEFONT cf;
   LOGFONT lf;
   HFONT hfont;
   PHB_ITEM pObj = HB_ISNIL(1) ? nullptr : hb_param(1, Harbour::Item::OBJECT);
   PHB_ITEM temp1;
   PHB_ITEM aMetr = hb_itemArrayNew(9), temp;

   /* Initialize members of the CHOOSEFONT structure. */
   if( pObj )
   {
      memset(&lf, 0, sizeof(LOGFONT));
      temp1 = GetObjectVar(pObj, "NAME");
      HB_ITEMCOPYSTR(temp1, lf.lfFaceName, HB_SIZEOFARRAY(lf.lfFaceName));
      lf.lfFaceName[HB_SIZEOFARRAY(lf.lfFaceName) - 1] = '\0';
      temp1 = GetObjectVar(pObj, "WIDTH");
      lf.lfWidth = hb_itemGetNI(temp1);
      temp1 = GetObjectVar(pObj, "HEIGHT");
      lf.lfHeight = hb_itemGetNI(temp1);
      temp1 = GetObjectVar(pObj, "WEIGHT");
      lf.lfWeight = hb_itemGetNI(temp1);
      temp1 = GetObjectVar(pObj, "CHARSET");
      lf.lfCharSet = hb_itemGetNI(temp1);
      temp1 = GetObjectVar(pObj, "ITALIC");
      lf.lfItalic = hb_itemGetNI(temp1);
      temp1 = GetObjectVar(pObj, "UNDERLINE");
      lf.lfUnderline = hb_itemGetNI(temp1);
      temp1 = GetObjectVar(pObj, "STRIKEOUT");
      lf.lfStrikeOut = hb_itemGetNI(temp1);
   }

   cf.lStructSize = sizeof(CHOOSEFONT);
   cf.hwndOwner = nullptr;
   cf.hDC = nullptr;
   cf.lpLogFont = &lf;
   cf.iPointSize = 0;
   cf.Flags = CF_SCREENFONTS | (pObj ? CF_INITTOLOGFONTSTRUCT : 0);
   cf.rgbColors = RGB(0, 0, 0);
   cf.lCustData = 0L;
   cf.lpfnHook = nullptr;
   cf.lpTemplateName = nullptr;

   cf.hInstance = nullptr;
   cf.lpszStyle = nullptr;
   cf.nFontType = SCREEN_FONTTYPE;
   cf.nSizeMin = 0;
   cf.nSizeMax = 0;

   /* Display the CHOOSEFONT common-dialog box. */

   if( !ChooseFont(&cf) )
   {
      hb_itemRelease(aMetr);
      hb_ret();
      return;
   }

   /* Create a logical font based on the user's   */
   /* selection and return a handle identifying   */
   /* that font.                                  */

   hfont = CreateFontIndirect(cf.lpLogFont);

   temp = HB_PUTHANDLE(nullptr, hfont);
   hb_itemArrayPut(aMetr, 1, temp);

   HB_ITEMPUTSTR(temp, lf.lfFaceName);
   hb_itemArrayPut(aMetr, 2, temp);

   hb_itemPutNL(temp, lf.lfWidth);
   hb_itemArrayPut(aMetr, 3, temp);

   hb_itemPutNL(temp, lf.lfHeight);
   hb_itemArrayPut(aMetr, 4, temp);

   hb_itemPutNL(temp, lf.lfWeight);
   hb_itemArrayPut(aMetr, 5, temp);

   hb_itemPutNI(temp, lf.lfCharSet);
   hb_itemArrayPut(aMetr, 6, temp);

   hb_itemPutNI(temp, lf.lfItalic);
   hb_itemArrayPut(aMetr, 7, temp);

   hb_itemPutNI(temp, lf.lfUnderline);
   hb_itemArrayPut(aMetr, 8, temp);

   hb_itemPutNI(temp, lf.lfStrikeOut);
   hb_itemArrayPut(aMetr, 9, temp);

   hb_itemRelease(temp);

   hb_itemRelease(hb_itemReturn(aMetr));
}

/*
HWG_SELECTFILE(cPar1|aPar1, cPar2|aPar2, cInitDir, cTitle) --> character
*/
HB_FUNC( HWG_SELECTFILE )
{
   OPENFILENAME ofn;
   TCHAR buffer[1024];
   LPTSTR lpFilter;
   void * hTitle, * hInitDir;

   if( HB_ISCHAR(1) && HB_ISCHAR(2) )
   {
      void * hStr1, * hStr2;
      LPCTSTR lpStr1, lpStr2;
      HB_SIZE nLen1, nLen2;

      lpStr1 = HB_PARSTRDEF(1, &hStr1, &nLen1);
      lpStr2 = HB_PARSTRDEF(2, &hStr2, &nLen2);

      lpFilter = static_cast<LPTSTR>(hb_xgrab((nLen1 + nLen2 + 4) * sizeof(TCHAR)));
      memset(lpFilter, 0, (nLen1 + nLen2 + 4) * sizeof(TCHAR));
      memcpy(lpFilter, lpStr1, nLen1 * sizeof(TCHAR));
      memcpy(lpFilter + nLen1 + 1, lpStr2, nLen2 * sizeof(TCHAR));

      hb_strfree(hStr1);
      hb_strfree(hStr2);
   }
   else if( HB_ISARRAY(1) && HB_ISARRAY(2) )
   {
      struct _hb_arrStr
      {
         void * hStr1;
         LPCTSTR lpStr1;
         HB_SIZE nLen1;
         void * hStr2;
         LPCTSTR lpStr2;
         HB_SIZE nLen2;
      } *pArrStr;
      PHB_ITEM pArr1 = hb_param(1, Harbour::Item::ARRAY);
      PHB_ITEM pArr2 = hb_param(2, Harbour::Item::ARRAY);
      HB_SIZE n, nArrLen = hb_arrayLen(pArr1), nSize;
      LPTSTR ptr;

      pArrStr = static_cast<struct _hb_arrStr*>(hb_xgrab(nArrLen * sizeof(struct _hb_arrStr)));
      nSize = 4;
      for( n = 0; n < nArrLen; n++ )
      {
         pArrStr[n].lpStr1 = HB_ARRAYGETSTR(pArr1, n + 1, &pArrStr[n].hStr1, &pArrStr[n].nLen1);
         pArrStr[n].lpStr2 = HB_ARRAYGETSTR(pArr2, n + 1, &pArrStr[n].hStr2, &pArrStr[n].nLen2);
         nSize += pArrStr[n].nLen1 + pArrStr[n].nLen2 + 2;
      }
      lpFilter = static_cast<LPTSTR>(hb_xgrab(nSize * sizeof(TCHAR)));
      ptr = lpFilter;
      for( n = 0; n < nArrLen; n++ )
      {
         memcpy(ptr, pArrStr[n].lpStr1, pArrStr[n].nLen1 * sizeof(TCHAR));
         ptr += pArrStr[n].nLen1;
         *ptr++ = 0;
         memcpy(ptr, pArrStr[n].lpStr2, pArrStr[n].nLen2 * sizeof(TCHAR));
         ptr += pArrStr[n].nLen2;
         *ptr++ = 0;
         hb_strfree(pArrStr[n].hStr1);
         hb_strfree(pArrStr[n].hStr2);
      }
      *ptr++ = 0;
      *ptr = 0;
      hb_xfree(pArrStr);
   }
   else
   {
      hb_retc(nullptr);
      return;
   }

   memset(static_cast<void*>(&ofn), 0, sizeof(OPENFILENAME));
   ofn.lStructSize = sizeof(ofn);
   ofn.hwndOwner = GetActiveWindow();
   ofn.lpstrFilter = lpFilter;
   ofn.lpstrFile = buffer;
   buffer[0] = 0;
   ofn.nMaxFile = 1024;
   ofn.lpstrInitialDir = HB_PARSTR(3, &hInitDir, nullptr);
   ofn.lpstrTitle = HB_PARSTR(4, &hTitle, nullptr);
   ofn.Flags = OFN_FILEMUSTEXIST | OFN_EXPLORER;

   if( GetOpenFileName(&ofn) )
   {
      HB_RETSTR(ofn.lpstrFile);
   }
   else
   {
      hb_retc(nullptr);
   }
   hb_xfree(lpFilter);

   hb_strfree(hInitDir);
   hb_strfree(hTitle);
}

/*
HWG_SAVEFILE(cFilename, cPar2, cPar3, cInitDir, cTitle, lOFN_OVERWRITEPROMPT) --> character
*/
HB_FUNC( HWG_SAVEFILE )
{
   OPENFILENAME ofn;
   TCHAR buffer[1024];
   void * hFileName, * hStr1, * hStr2, * hTitle, * hInitDir;
   LPCTSTR lpFileName, lpStr1, lpStr2;
   HB_SIZE nSize, nLen1, nLen2;
   LPTSTR lpFilter, lpFileBuff;

   lpFileName = HB_PARSTR(1, &hFileName, &nSize);
   if( nSize < 1024 )
   {
      memcpy(buffer, lpFileName, nSize * sizeof(TCHAR));
      memset(&buffer[nSize], 0, (1024 - nSize) * sizeof(TCHAR));
      lpFileBuff = buffer;
      nSize = 1024;
   }
   else
   {
      lpFileBuff = HB_STRUNSHARE(&hFileName, lpFileName, nSize);
   }

   lpStr1 = HB_PARSTRDEF(2, &hStr1, &nLen1);
   lpStr2 = HB_PARSTRDEF(3, &hStr2, &nLen2);

   lpFilter = static_cast<LPTSTR>(hb_xgrab((nLen1 + nLen2 + 4) * sizeof(TCHAR)));
   memset(lpFilter, 0, (nLen1 + nLen2 + 4) * sizeof(TCHAR));
   memcpy(lpFilter, lpStr1, nLen1 * sizeof(TCHAR));
   memcpy(lpFilter + nLen1 + 1, lpStr2, nLen2 * sizeof(TCHAR));

   hb_strfree(hStr1);
   hb_strfree(hStr2);

   memset(static_cast<void*>(&ofn), 0, sizeof(OPENFILENAME));
   ofn.lStructSize = sizeof(ofn);
   ofn.hwndOwner = GetActiveWindow();
   ofn.lpstrFilter = lpFilter;
   ofn.lpstrFile = lpFileBuff;
   ofn.nMaxFile = nSize;
   ofn.lpstrInitialDir = HB_PARSTR(4, &hInitDir, nullptr);
   ofn.lpstrTitle = HB_PARSTR(5, &hTitle, nullptr);
   ofn.Flags = OFN_FILEMUSTEXIST | OFN_EXPLORER;
   if( HB_ISLOG(6) && hb_parl(6) )
   {
      ofn.Flags = ofn.Flags | OFN_OVERWRITEPROMPT;
   }

   if( GetSaveFileName(&ofn) )
   {
      HB_RETSTR(ofn.lpstrFile);
   }
   else
   {
      hb_retc(nullptr);
   }
   hb_xfree(lpFilter);

   hb_strfree(hFileName);
   hb_strfree(hInitDir);
   hb_strfree(hTitle);
}

/*
HWG_PRINTSETUP() --> hDC
*/
HB_FUNC( HWG_PRINTSETUP )
{
   PRINTDLG pd;

   memset(static_cast<void*>(&pd), 0, sizeof(PRINTDLG));

   pd.lStructSize = sizeof(PRINTDLG);
   // pd.hDevNames = nullptr;
   pd.Flags = PD_RETURNDC;
   pd.hwndOwner = GetActiveWindow();
   // pd.hDC = nullptr;
   pd.nFromPage = 1;
   pd.nToPage = 1;
   // pd.nMinPage = 0;
   // pd.nMaxPage = 0;
   pd.nCopies = 1;
   // pd.hInstance = nullptr;
   // pd.lCustData = 0L;
   // pd.lpfnPrintHook = nullptr;
   // pd.lpfnSetupHook = nullptr;
   // pd.lpPrintTemplateName = nullptr;
   // pd.lpSetupTemplateName = nullptr;
   // pd.hPrintTemplate = nullptr;
   // pd.hSetupTemplate = nullptr;

   if( PrintDlg(&pd) )
   {
      if( pd.hDevNames )
      {
         if( hb_pcount() > 0 )
         {
            LPDEVNAMES lpdn = static_cast<LPDEVNAMES>(GlobalLock(pd.hDevNames));
            HB_STORSTR(reinterpret_cast<LPCTSTR>(lpdn) + lpdn->wDeviceOffset, 1);
            GlobalUnlock(pd.hDevNames);
         }
         GlobalFree(pd.hDevNames);
         GlobalFree(pd.hDevMode);
      }
      HB_RETHANDLE(pd.hDC);
   }
   else
   {
      HB_RETHANDLE(nullptr);
   }
}

/*
HWG_CHOOSECOLOR(nColor|NIL, lCC_FULLOPEN|NIL) --> nColor
*/
HB_FUNC( HWG_CHOOSECOLOR )
{
   CHOOSECOLOR cc;
   COLORREF rgb[16];
   DWORD nStyle = (HB_ISLOG(2) && hb_parl(2)) ? CC_FULLOPEN : 0;

   memset(static_cast<void*>(&cc), 0, sizeof(CHOOSECOLOR));

   cc.lStructSize = sizeof(CHOOSECOLOR);
   cc.hwndOwner = GetActiveWindow();
   cc.lpCustColors = rgb;
   if( HB_ISNUM(1) )
   {
      cc.rgbResult = hwg_par_COLORREF(1);
      nStyle |= CC_RGBINIT;
   }
   cc.Flags = nStyle;

   if( ChooseColor(&cc) )
   {
      hb_retnl(static_cast<LONG>(cc.rgbResult));
   }
   else
   {
      hb_ret();
   }
}

static unsigned long Get_SerialNumber(LPCTSTR RootPathName)
{
   unsigned long SerialNumber;
   GetVolumeInformation(RootPathName, nullptr, 0, &SerialNumber, nullptr, nullptr, nullptr, 0);
   return SerialNumber;
}

/*
HWG_HDGETSERIAL(cPar) --> numeric
*/
HB_FUNC( HWG_HDGETSERIAL )
{
   void * hStr;
   hb_retnl(Get_SerialNumber(HB_PARSTR(1, &hStr, nullptr)));
   hb_strfree(hStr);
}

/*
 The functions added by extract for the Minigui Lib Open Source project
 Copyright 2002 Roberto Lopez <roblez@ciudad.com.ar>
 http://www.geocities.com/harbour_minigui/
 HB_FUNC( GETPRIVATEPROFILESTRING )
 HB_FUNC( WRITEPRIVATEPROFILESTRING )
*/

/*
HWG_GETPRIVATEPROFILESTRING(cSection, cEntry, cDefault, cFilename) --> character
*/
HB_FUNC( HWG_GETPRIVATEPROFILESTRING )
{
   TCHAR buffer[1024];
   DWORD dwLen;
   void * hSection, * hEntry, * hDefault, * hFileName;
   LPCTSTR lpDefault = HB_PARSTR(3, &hDefault, nullptr);

   dwLen = GetPrivateProfileString(HB_PARSTR(1, &hSection, nullptr), HB_PARSTR(2, &hEntry, nullptr), lpDefault, buffer,
                                   HB_SIZEOFARRAY(buffer), HB_PARSTR(4, &hFileName, nullptr));
   if( dwLen )
   {
      HB_RETSTRLEN(buffer, dwLen);
   }
   else
   {
      HB_RETSTR(lpDefault);
   }

   hb_strfree(hSection);
   hb_strfree(hEntry);
   hb_strfree(hDefault);
   hb_strfree(hFileName);
}

/*
HWG_WRITEPRIVATEPROFILESTRING(cSection, cEntry, cData, cFilename) --> logical
*/
HB_FUNC( HWG_WRITEPRIVATEPROFILESTRING )
{
   void * hSection, * hEntry, * hData, * hFileName;

   hb_retl(WritePrivateProfileString(HB_PARSTR(1, &hSection, nullptr), HB_PARSTR(2, &hEntry, nullptr), HB_PARSTR(3, &hData, nullptr),
                                     HB_PARSTR(4, &hFileName, nullptr)) ? TRUE : FALSE);

   hb_strfree(hSection);
   hb_strfree(hEntry);
   hb_strfree(hData);
   hb_strfree(hFileName);
}

static far PRINTDLG s_pd;
static far BOOL s_fInit = FALSE;
static far BOOL s_fPName = FALSE;

static void StartPrn(void)
{
   if( !s_fInit )
   {
      s_fInit = TRUE;
      memset(&s_pd, 0, sizeof(PRINTDLG));
      s_pd.lStructSize = sizeof(PRINTDLG);
      s_pd.hwndOwner = GetActiveWindow();
      s_pd.Flags = PD_RETURNDEFAULT;
      s_pd.nMinPage = 1;
      s_pd.nMaxPage = 65535;

      PrintDlg(&s_pd);

   }
}

/*
HWG_PRINTPORTNAME() --> character
*/
HB_FUNC( HWG_PRINTPORTNAME )
{
   if( !s_fPName && s_pd.hDevNames )
   {
      LPDEVNAMES lpDevNames;
      s_fPName = TRUE;
      lpDevNames = static_cast<LPDEVNAMES>(GlobalLock(s_pd.hDevNames));
      HB_RETSTR(reinterpret_cast<LPCTSTR>(lpDevNames) + lpDevNames->wOutputOffset);
      GlobalUnlock(s_pd.hDevNames);
   }
}

/*
HWG_PRINTSETUPDOS() --> hDC
*/
HB_FUNC( HWG_PRINTSETUPDOS )
{
   StartPrn();

   memset(static_cast<void*>(&s_pd), 0, sizeof(PRINTDLG));

   s_pd.lStructSize = sizeof(PRINTDLG);
   s_pd.Flags = PD_RETURNDC;
   s_pd.hwndOwner = GetActiveWindow();
   s_pd.nFromPage = 0xFFFF;
   s_pd.nToPage = 0xFFFF;
   s_pd.nMinPage = 1;
   s_pd.nMaxPage = 0xFFFF;
   s_pd.nCopies = 1;

   if( PrintDlg(&s_pd) )
   {
      s_fPName = FALSE;
      hb_stornl(s_pd.nFromPage, 1);
      hb_stornl(s_pd.nToPage, 2);
      hb_stornl(s_pd.nCopies, 3);
      HB_RETHANDLE(s_pd.hDC);
   }
   else
   {
      s_fPName = TRUE;
      HB_RETHANDLE(nullptr);
   }
}

/*
HWG_PRINTSETUPEX() --> character
*/
HB_FUNC( HWG_PRINTSETUPEX )
{
   PRINTDLG pd;
   DEVMODE *pDevMode;

   memset(static_cast<void*>(&pd), 0, sizeof(PRINTDLG));

   pd.lStructSize = sizeof(PRINTDLG);
   pd.Flags = PD_RETURNDC;
   pd.hwndOwner = GetActiveWindow();
   pd.nFromPage = 1;
   pd.nToPage = 1;
   pd.nCopies = 1;

   if( PrintDlg(&pd) )
   {
      pDevMode = static_cast<LPDEVMODE>(GlobalLock(pd.hDevMode));
      HB_RETSTR(reinterpret_cast<LPCTSTR>(pDevMode->dmDeviceName));
      GlobalUnlock(pd.hDevMode);
   }
}

/*
HWG_GETOPENFILENAME(hWnd, cFilename, cTitle, cFilter, , cInitDir, cDefExt, nFilterIndex) --> character
*/
HB_FUNC( HWG_GETOPENFILENAME )
{
   OPENFILENAME ofn;
   TCHAR buffer[1024];
   void * hFileName, * hTitle, * hFilter, * hInitDir, * hDefExt;
   HB_SIZE nSize;
   LPCTSTR lpFileName = HB_PARSTR(2, &hFileName, &nSize);
   LPTSTR lpFileBuff;

   if( nSize < 1024 )
   {
      memcpy(buffer, lpFileName, nSize * sizeof(TCHAR));
      memset(&buffer[nSize], 0, (1024 - nSize) * sizeof(TCHAR));
      lpFileBuff = buffer;
      nSize = 1024;
   }
   else
   {
      lpFileBuff = HB_STRUNSHARE(&hFileName, lpFileName, nSize);
   }

   ZeroMemory(&ofn, sizeof(ofn));
   ofn.hInstance = GetModuleHandle(nullptr);
   ofn.lStructSize = sizeof(ofn);
   ofn.hwndOwner = (HB_ISNIL(1) ? GetActiveWindow() : hwg_par_HWND(1));
   ofn.lpstrTitle = HB_PARSTR(3, &hTitle, nullptr);
   ofn.lpstrFilter = HB_PARSTR(4, &hFilter, nullptr);
   ofn.Flags = OFN_EXPLORER | OFN_ALLOWMULTISELECT;
   ofn.lpstrInitialDir = HB_PARSTR(6, &hInitDir, nullptr);
   ofn.lpstrDefExt = HB_PARSTR(7, &hDefExt, nullptr);
   ofn.nFilterIndex = hb_parni(8);
   ofn.lpstrFile = lpFileBuff;
   ofn.nMaxFile = nSize;

   if( GetOpenFileName(&ofn) )
   {
      hb_stornl(ofn.nFilterIndex, 8);
      HB_STORSTRLEN(lpFileBuff, nSize, 2);
      HB_RETSTR(ofn.lpstrFile);
   }
   else
   {
      hb_retc(nullptr);
   }

   hb_strfree(hFileName);
   hb_strfree(hTitle);
   hb_strfree(hFilter);
   hb_strfree(hInitDir);
   hb_strfree(hDefExt);
}
