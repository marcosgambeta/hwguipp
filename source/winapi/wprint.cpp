/*
 * HWGUI - Harbour Win32 GUI library source code:
 * C++ level print functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#define OEMRESOURCE

#include "hwingui.hpp"
#include <commctrl.h>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include "incomp_pointer.hpp"

/*
HWG_OPENPRINTER(cDevice) --> HDC
*/
HB_FUNC( HWG_OPENPRINTER )
{
   void * hText;
   hb_retptr(CreateDC(nullptr, HB_PARSTR(1, &hText, nullptr), nullptr, nullptr));
   hb_strfree(hText);
}

/*
HWG_OPENDEFAULTPRINTER() --> HDC
*/
HB_FUNC( HWG_OPENDEFAULTPRINTER )
{
   DWORD dwNeeded, dwReturned;
   EnumPrinters(PRINTER_ENUM_LOCAL, nullptr, 4, nullptr, 0, &dwNeeded, &dwReturned);
   auto pinfo4 = static_cast<PRINTER_INFO_4*>(hb_xgrab(dwNeeded));
   EnumPrinters(PRINTER_ENUM_LOCAL, nullptr, 4, reinterpret_cast<PBYTE>(pinfo4), dwNeeded, &dwNeeded, &dwReturned);
   auto hDC = CreateDC(nullptr, pinfo4->pPrinterName, nullptr, nullptr);
   if( hb_pcount() > 0 ) {
      HB_STORSTR(pinfo4->pPrinterName, 1);
   }

   hb_xfree(pinfo4);
   hb_retptr(hDC);
}

/*
HWG_GETDEFAULTPRINTER() --> defaultPrinter
*/
HB_FUNC( HWG_GETDEFAULTPRINTER )
{
   TCHAR PrinterDefault[256] = {0};
   DWORD BuffSize = 256;
   GetDefaultPrinter(PrinterDefault, &BuffSize);
   PrinterDefault[HB_SIZEOFARRAY(PrinterDefault) - 1] = 0;
   HB_RETSTR(PrinterDefault);
}

/*
HWG_GETPRINTERS() --> array
*/
HB_FUNC( HWG_GETPRINTERS )
{
   PBYTE pBuffer = nullptr;
   PRINTER_INFO_4 * pinfo4 = nullptr;

   DWORD dwNeeded, dwReturned;
   EnumPrinters(PRINTER_ENUM_LOCAL, nullptr, 4, nullptr, 0, &dwNeeded, &dwReturned);

   if( dwNeeded ) {
      pBuffer = static_cast<PBYTE>(hb_xgrab(dwNeeded));
      pinfo4 = reinterpret_cast<PRINTER_INFO_4*>(pBuffer);
      EnumPrinters(PRINTER_ENUM_LOCAL, nullptr, 4, pBuffer, dwNeeded, &dwNeeded, &dwReturned);
   }

   if( dwReturned ) {
      auto aMetr = hb_itemArrayNew(dwReturned);
      PHB_ITEM temp = nullptr;

      for( int i = 0; i < static_cast<int>(dwReturned); i++ ) {
         if( pinfo4 != nullptr ) {
            temp = HB_ITEMPUTSTR(nullptr, pinfo4->pPrinterName);
            pinfo4++;
         }
         hb_itemArrayPut(aMetr, i + 1, temp);
         hb_itemRelease(temp);
      }
      hb_itemReturn(aMetr);
      hb_itemRelease(aMetr);
   } else {
      hb_ret();
   }

   if( pBuffer != nullptr ) {
      hb_xfree(pBuffer);
   }
}

/*
HWG_SETPRINTERMODE(printerName, HANDLE, orientation, duplex) --> NIL
*/
HB_FUNC( HWG_SETPRINTERMODE )
{
   void * hPrinterName;
   LPCTSTR lpPrinterName = HB_PARSTR(1, &hPrinterName, nullptr);
   HANDLE hPrinter = HB_ISNIL(2) ? nullptr : static_cast<HANDLE>(hb_parptr(2));

   if( hPrinter == nullptr ) {
      OpenPrinter(const_cast<LPTSTR>(lpPrinterName), &hPrinter, nullptr);
   }

   if( hPrinter != nullptr ) {
      /* Determine the size of DEVMODE structure */
      long int nSize = DocumentProperties(nullptr, hPrinter, const_cast<LPTSTR>(lpPrinterName), nullptr, nullptr, 0);
      auto pdm = static_cast<PDEVMODE>(GlobalAlloc(GPTR, nSize));

      /* Get the printer mode */
      DocumentProperties(nullptr, hPrinter, const_cast<LPTSTR>(lpPrinterName), pdm, nullptr, DM_OUT_BUFFER);

      /* Changing of values */
      if( !HB_ISNIL(3) ) {
         pdm->dmOrientation = hb_parni(3);
         pdm->dmFields = pdm->dmFields | DM_ORIENTATION;
      }
      if( !HB_ISNIL(4) ) {
         pdm->dmDuplex = hb_parni(4);
         pdm->dmFields = pdm->dmFields | DM_DUPLEX;
      }

      // Call DocumentProperties() to change the values
      DocumentProperties(nullptr, hPrinter, const_cast<LPTSTR>(lpPrinterName), pdm, pdm, DM_OUT_BUFFER | DM_IN_BUFFER);

      // создадим контекст устройства принтера
      hb_retptr(CreateDC(nullptr, lpPrinterName, nullptr, pdm));
      HB_STOREHANDLE(hPrinter, 2);
      GlobalFree(pdm);
   }

   hb_strfree(hPrinterName);
}

/*
HWG_CLOSEPRINTER(HANDLE) --> NIL
*/
HB_FUNC( HWG_CLOSEPRINTER )
{
   ClosePrinter(static_cast<HANDLE>(hb_parptr(1)));
}

/*
HWG_STARTDOC(HDC) --> numeric
*/
HB_FUNC( HWG_STARTDOC )
{
   void * hText;
   DOCINFO di;
   di.cbSize = sizeof(DOCINFO);
   di.lpszDocName = HB_PARSTR(2, &hText, nullptr);
   di.lpszOutput = nullptr;
   di.lpszDatatype = nullptr;
   di.fwType = 0;
   hb_retnl(static_cast<LONG>(StartDoc(hwg_par_HDC(1), &di)));
   hb_strfree(hText);
}

/*
HWG_ENDDOC(HDC) --> numeric
*/
HB_FUNC( HWG_ENDDOC )
{
   hb_retnl(static_cast<LONG>(EndDoc(hwg_par_HDC(1))));
}

/*
HWG_ABORTDOC(HDC) --> NIL
*/
HB_FUNC( HWG_ABORTDOC )
{
   AbortDoc(hwg_par_HDC(1));
}

/*
HWG_STARTPAGE(HDC) --> numeric
*/
HB_FUNC( HWG_STARTPAGE )
{
   hb_retnl(static_cast<LONG>(StartPage(hwg_par_HDC(1))));
}

/*
HWG_ENDPAGE(HDC) --> numeric
*/
HB_FUNC( HWG_ENDPAGE )
{
   hb_retnl(static_cast<LONG>(EndPage(hwg_par_HDC(1))));
}

/*
 * HORZRES	Width, in pixels, of the screen.
 * VERTRES	Height, in raster lines, of the screen.
 * HORZSIZE	Width, in millimeters, of the physical screen.
 * VERTSIZE	Height, in millimeters, of the physical screen.
 * LOGPIXELSX	Number of pixels per logical inch along the screen width.
 * LOGPIXELSY	Number of pixels per logical inch along the screen height.
 */

/*
HWG_GETDEVICEAREA() --> array
*/
HB_FUNC( HWG_GETDEVICEAREA )
{
   auto hDC = hwg_par_HDC(1);
   auto aMetr = hb_itemArrayNew(11);

   auto temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, HORZRES));
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, VERTRES));
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, HORZSIZE));
   hb_itemArrayPut(aMetr, 3, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, VERTSIZE));
   hb_itemArrayPut(aMetr, 4, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, LOGPIXELSX));
   hb_itemArrayPut(aMetr, 5, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, LOGPIXELSY));
   hb_itemArrayPut(aMetr, 6, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, RASTERCAPS));
   hb_itemArrayPut(aMetr, 7, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, PHYSICALWIDTH));
   hb_itemArrayPut(aMetr, 8, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, PHYSICALHEIGHT));
   hb_itemArrayPut(aMetr, 9, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, PHYSICALOFFSETY));
   hb_itemArrayPut(aMetr, 10, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNL(nullptr, GetDeviceCaps(hDC, PHYSICALOFFSETX));
   hb_itemArrayPut(aMetr, 11, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);
}

/*
HWG_CREATEENHMETAFILE(HWND, fileName) --> HDC
*/
HB_FUNC( HWG_CREATEENHMETAFILE )
{
   auto hWnd = hwg_par_HWND(1);
   auto hDCref = GetDC(hWnd);
   void * hFileName;

   // Determine the picture frame dimensions.
   int iWidthMM    = GetDeviceCaps(hDCref, HORZSIZE); // iWidthMM is the display width in millimeters.
   int iHeightMM   = GetDeviceCaps(hDCref, VERTSIZE); // iHeightMM is the display height in millimeters.
   int iWidthPels  = GetDeviceCaps(hDCref, HORZRES);  // iWidthPels is the display width in pixels.
   int iHeightPels = GetDeviceCaps(hDCref, VERTRES);  // iHeightPels is the display height in pixels.

   RECT rc;
   GetClientRect(hWnd, &rc); // Retrieve the coordinates of the client rectangle, in pixels.

   /*
    * Convert client coordinates to .01-mm units. Use iWidthMM, iWidthPels, iHeightMM, and
    * iHeightPels to determine the number of .01-millimeter units per pixel in the x- and y-directions.
    */

   rc.left = ( rc.left * iWidthMM * 100 ) / iWidthPels;
   rc.top = ( rc.top * iHeightMM * 100 ) / iHeightPels;
   rc.right = ( rc.right * iWidthMM * 100 ) / iWidthPels;
   rc.bottom = ( rc.bottom * iHeightMM * 100 ) / iHeightPels;

   auto hDCmeta = CreateEnhMetaFile(hDCref, HB_PARSTR(2, &hFileName, nullptr), &rc, nullptr);
   ReleaseDC(hWnd, hDCref);
   hb_retptr(hDCmeta);
   hb_strfree(hFileName);
}

/*
HWG_CREATEMETAFILE(HDC, fileName) --> HDC
*/
HB_FUNC( HWG_CREATEMETAFILE )
{
   auto hDCref = hwg_par_HDC(1);
   void * hFileName;

   /* Determine the picture frame dimensions.
    * iWidthMM is the display width in millimeters.
    * iHeightMM is the display height in millimeters.
    * iWidthPels is the display width in pixels.
    * iHeightPels is the display height in pixels
    */

   int iWidthMM = GetDeviceCaps(hDCref, HORZSIZE);
   int iHeightMM = GetDeviceCaps(hDCref, VERTSIZE);

   /*
    * Convert client coordinates to .01-mm units.
    * Use iWidthMM, iWidthPels, iHeightMM, and
    * iHeightPels to determine the number of
    * .01-millimeter units per pixel in the x-
    *  and y-directions.
    */

   RECT rc{0, 0, iWidthMM * 100, iHeightMM * 100};

   auto hDCmeta = CreateEnhMetaFile(hDCref, HB_PARSTR(2, &hFileName, nullptr), &rc, nullptr);
   hb_retptr(hDCmeta);
   hb_strfree(hFileName);
}

/*
HWG_CLOSEENHMETAFILE(HDC) --> HANDLE
*/
HB_FUNC( HWG_CLOSEENHMETAFILE )
{
   hb_retptr(CloseEnhMetaFile(hwg_par_HDC(1)));
}

/*
HWG_DELETEENHMETAFILE(HENHMETAFILE) --> HANDLE
*/
HB_FUNC( HWG_DELETEENHMETAFILE )
{
   hb_retptr(reinterpret_cast<void*>(static_cast<LONG>(DeleteEnhMetaFile(static_cast<HENHMETAFILE>(hb_parptr(1))))));
}

/*
HWG_PLAYENHMETAFILE(HDC, HENHMETAFILE, left, top, right, bottom) --> numeric
*/
HB_FUNC( HWG_PLAYENHMETAFILE )
{
   auto hDC = hwg_par_HDC(1);
   RECT rc;

   if( hb_pcount() > 2 ) {
      rc.left = hb_parni(3);
      rc.top = hb_parni(4);
      rc.right = hb_parni(5);
      rc.bottom = hb_parni(6);
   } else {
      GetClientRect(WindowFromDC(hDC), &rc);
   }

   hb_retnl(static_cast<LONG>(PlayEnhMetaFile(hDC, static_cast<HENHMETAFILE>(hb_parptr(2)), &rc)));
}

/*
HWG_PRINTENHMETAFILE(HDC, HENHMETAFILE) --> numeric
*/
HB_FUNC( HWG_PRINTENHMETAFILE )
{
   auto hDC = hwg_par_HDC(1);

   RECT rc;
   SetRect(&rc, 0, 0, GetDeviceCaps(hDC, HORZRES), GetDeviceCaps(hDC, VERTRES));

   StartPage(hDC);
   hb_retnl(static_cast<LONG>(PlayEnhMetaFile(hDC, static_cast<HENHMETAFILE>(hb_parptr(2)), &rc)));
   EndPage(hDC);
}

/*
HWG_SETDOCUMENTPROPERTIES(HDC, printerName, formName|paperSize, orientation, copies, defaultSource, duplex, printQuality, paperLength, paperWidth) -->
*/
HB_FUNC( HWG_SETDOCUMENTPROPERTIES )
{
   bool Result = false;
   auto hDC = hwg_par_HDC(1);

   if( hDC != nullptr ) {
      HANDLE hPrinter;
      void * hPrinterName;
      LPCTSTR lpPrinterName = HB_PARSTR(2, &hPrinterName, nullptr);

      if( OpenPrinter(const_cast<LPTSTR>(lpPrinterName), &hPrinter, nullptr) ) {
         PDEVMODE pDevMode = nullptr;
         LONG lSize = DocumentProperties(0, hPrinter, const_cast<LPTSTR>(lpPrinterName), pDevMode, pDevMode, 0);

         if( lSize > 0 ) {
            pDevMode = static_cast<PDEVMODE>(hb_xgrab(lSize));

            if( pDevMode && DocumentProperties(0, hPrinter, const_cast<LPTSTR>(lpPrinterName), pDevMode, pDevMode, DM_OUT_BUFFER) == IDOK ) { // Get the current settings
               bool bAskUser = HB_ISBYREF(3) || HB_ISBYREF(4) || HB_ISBYREF(5) || HB_ISBYREF(6) || HB_ISBYREF(7) || HB_ISBYREF(8) || HB_ISBYREF(9) || HB_ISBYREF(10); // x 20070421
               DWORD dInit = 0; // x 20070421
               bool bCustomFormSize = (HB_ISNUM(9) && hb_parnl(9) > 0) && (HB_ISNUM(10) && hb_parnl(10) > 0); // Must set both Length & Width

               if( bCustomFormSize ) {
                  pDevMode->dmPaperLength = hb_parnl(9);
                  dInit |= DM_PAPERLENGTH;

                  pDevMode->dmPaperWidth = hb_parnl(10);
                  dInit |= DM_PAPERWIDTH;

                  pDevMode->dmPaperSize = DMPAPER_USER;
                  dInit |= DM_PAPERSIZE;
               } else {
                  if( HB_ISCHAR(3) ) { // this doesn't work for Win9X
                     void * hFormName;
                     HB_SIZE len;
                     LPCTSTR lpFormName = HB_PARSTR(3, &hFormName, &len);

                     if( lpFormName && len && len < CCHFORMNAME ) {
                        memcpy(pDevMode->dmFormName, lpFormName, (len + 1) * sizeof(TCHAR));
                        dInit |= DM_FORMNAME;
                     }
                     hb_strfree(hFormName);
                  } else if( HB_ISNUM(3) && hb_parnl(3) ) { // 22/02/2007 don't change if 0
                     pDevMode->dmPaperSize = hb_parnl(3);
                     dInit |= DM_PAPERSIZE;
                  }
               }

               if( HB_ISLOG(4) ) {
                  pDevMode->dmOrientation = hb_parl(4) ? 2 : 1;
                  dInit |= DM_ORIENTATION;
               }

               if( HB_ISNUM(5) && hb_parnl(5) > 0 ) {
                  pDevMode->dmCopies = hb_parnl(5);
                  dInit |= DM_COPIES;
               }

               if( HB_ISNUM(6) && hb_parnl(6) ) { // 22/02/2007 don't change if 0
                  pDevMode->dmDefaultSource = hb_parnl(6);
                  dInit |= DM_DEFAULTSOURCE;
               }

               if( HB_ISNUM(7) && hb_parnl(7) ) { // 22/02/2007 don't change if 0
                  pDevMode->dmDuplex = hb_parnl(7);
                  dInit |= DM_DUPLEX;
               }

               if( HB_ISNUM(8) && hb_parnl(8) ) { // 22/02/2007 don't change if 0
                  pDevMode->dmPrintQuality = hb_parnl(8);
                  dInit |= DM_PRINTQUALITY;
               }

               DWORD fMode = DM_IN_BUFFER | DM_OUT_BUFFER;

               if( bAskUser ) {
                  fMode |= DM_IN_PROMPT;
               }

               pDevMode->dmFields = dInit;

               if( DocumentProperties(0, hPrinter, const_cast<LPTSTR>(lpPrinterName), pDevMode, pDevMode, fMode) == IDOK ) {
                  if( HB_ISBYREF(3) && !bCustomFormSize ) {
                     if( HB_ISCHAR(3) ) {
                        HB_STORSTR(reinterpret_cast<LPCTSTR>(pDevMode->dmFormName), 3);
                     } else {
                        hb_stornl(static_cast<LONG>(pDevMode->dmPaperSize), 3);
                     }
                  }
                  if( HB_ISBYREF(4) ) {
                     hb_storl(pDevMode->dmOrientation == 2, 4);
                  }
                  if( HB_ISBYREF(5) ) {
                     hb_stornl(static_cast<LONG>(pDevMode->dmCopies), 5);
                  }
                  if( HB_ISBYREF(6) ) {
                     hb_stornl(static_cast<LONG>(pDevMode->dmDefaultSource), 6);
                  }
                  if( HB_ISBYREF(7) ) {
                     hb_stornl(static_cast<LONG>(pDevMode->dmDuplex), 7);
                  }
                  if( HB_ISBYREF(8) ) {
                     hb_stornl(static_cast<LONG>(pDevMode->dmPrintQuality), 8);
                  }
                  if( HB_ISBYREF(9) ) {
                     hb_stornl(static_cast<LONG>(pDevMode->dmPaperLength), 9);
                  }
                  if( HB_ISBYREF(10) ) {
                     hb_stornl(static_cast<LONG>(pDevMode->dmPaperWidth), 10);
                  }

                  Result = ResetDC(hDC, pDevMode) ? true : false;
               }

               hb_xfree(pDevMode);
            }
         }

         ClosePrinter(hPrinter);
      }

      hb_strfree(hPrinterName);
   }

   hb_retl(Result);
}
