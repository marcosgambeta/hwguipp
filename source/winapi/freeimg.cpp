/*
 * FreeImage wrappers for Harbour/HwGUI
 *
 * Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hwingui.hpp"
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include "freeimage.hpp"
#include "incomp_pointer.hpp"

// parameters
#define hwg_par_FIBITMAP(n) reinterpret_cast<FIBITMAP*>(hb_parnl(n))

using FREEIMAGE_GETVERSION = char *(WINAPI *)(void);
#if defined(__cplusplus)
using FREEIMAGE_LOADFROMHANDLE = FIBITMAP *(WINAPI *)(FREE_IMAGE_FORMAT fif, FreeImageIO * io, fi_handle handle, int flags);
using FREEIMAGE_LOAD = FIBITMAP *(WINAPI *)(FREE_IMAGE_FORMAT fif, const char * filename, int flags);
using FREEIMAGE_SAVE = BOOL(WINAPI *)(FREE_IMAGE_FORMAT fif, FIBITMAP * dib, const char * filename, int flags);
using FREEIMAGE_ALLOCATE = FIBITMAP *(WINAPI *)(int width, int height, int bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask);
using FREEIMAGE_CONVERTFROMRAWBITS = FIBITMAP *(WINAPI *)(BYTE * bits, int width, int height, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown);
using FREEIMAGE_CONVERTTORAWBITS = void(WINAPI *)(BYTE * bits, FIBITMAP * dib, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown);
#else
typedef FIBITMAP *(WINAPI * FREEIMAGE_LOADFROMHANDLE)(FREE_IMAGE_FORMAT fif, FreeImageIO * io, fi_handle handle, int flags FI_DEFAULT(0));
typedef FIBITMAP *(WINAPI * FREEIMAGE_LOAD)(FREE_IMAGE_FORMAT fif, const char *filename, int flags FI_DEFAULT(0));
typedef FIBITMAP *(WINAPI * FREEIMAGE_ALLOCATE)(int width, int height, int bpp, unsigned red_mask FI_DEFAULT(0), unsigned green_mask FI_DEFAULT(0), unsigned blue_mask FI_DEFAULT(0));
typedef BOOL(WINAPI * FREEIMAGE_SAVE)(FREE_IMAGE_FORMAT fif, FIBITMAP * dib, const char *filename, int flags FI_DEFAULT(0));
typedef FIBITMAP *(WINAPI * FREEIMAGE_CONVERTFROMRAWBITS)(BYTE * bits, int width, int height, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown FI_DEFAULT(FALSE));
typedef void (WINAPI * FREEIMAGE_CONVERTTORAWBITS)(BYTE * bits, FIBITMAP * dib, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown FI_DEFAULT(FALSE));
#endif
using FREEIMAGE_UNLOAD = void(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETFIFFROMFILENAME = FREE_IMAGE_FORMAT(WINAPI *)(const char * filename);
using FREEIMAGE_GETWIDTH = ULONG(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETHEIGHT = ULONG(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETBITS = BYTE *(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETINFO = BITMAPINFO *(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETINFOHEADER = BITMAPINFOHEADER *(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_RESCALE = FIBITMAP *(WINAPI *)(FIBITMAP * dib, int dst_width, int dst_height, FREE_IMAGE_FILTER filter);
using FREEIMAGE_GETPALETTE = RGBQUAD *(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETBPP = ULONG(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_SETCHANNEL = BOOL(WINAPI *)(FIBITMAP * dib, FIBITMAP * dib8, FREE_IMAGE_COLOR_CHANNEL channel);
using FREEIMAGE_GETSCANLINE = BYTE *(WINAPI *)(FIBITMAP * dib, int scanline);
using FREEIMAGE_GETPITCH = unsigned(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETIMAGETYPE = short(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETCOLORSUSED = unsigned(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_ROTATECLASSIC = FIBITMAP *(WINAPI *)(FIBITMAP * dib, double angle);
using FREEIMAGE_GETDOTSPERMETERX = unsigned(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_GETDOTSPERMETERY = unsigned(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_SETDOTSPERMETERX = void(WINAPI *)(FIBITMAP * dib, unsigned res);
using FREEIMAGE_SETDOTSPERMETERY = void(WINAPI *)(FIBITMAP * dib, unsigned res);
using FREEIMAGE_PASTE = BOOL(WINAPI *)(FIBITMAP * dst, FIBITMAP * src, int left, int top, int alpha);
using FREEIMAGE_COPY = FIBITMAP *(WINAPI *)(FIBITMAP * dib, int left, int top, int right, int bottom);
using FREEIMAGE_SETBACKGROUNDCOLOR = BOOL(WINAPI *)(FIBITMAP * dib, RGBQUAD * bkcolor);
using FREEIMAGE_INVERT = BOOL(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_CONVERTTO8BITS = FIBITMAP *(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_CONVERTTOGREYSCALE = FIBITMAP *(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_FLIPVERTICAL = BOOL(WINAPI *)(FIBITMAP * dib);
using FREEIMAGE_THRESHOLD = FIBITMAP *(WINAPI *)(FIBITMAP * dib, BYTE T);
using FREEIMAGE_GETPIXELINDEX = BOOL(WINAPI *)(FIBITMAP * dib, unsigned x, unsigned y, BYTE * value);
using FREEIMAGE_GETPIXELCOLOR = BOOL(WINAPI *)(FIBITMAP * dib, unsigned x, unsigned y, RGBQUAD * value);
using FREEIMAGE_SETPIXELINDEX = BOOL(WINAPI *)(FIBITMAP * dib, unsigned x, unsigned y, BYTE * value);
using FREEIMAGE_SETPIXELCOLOR = BOOL(WINAPI *)(FIBITMAP * dib, unsigned x, unsigned y, RGBQUAD * value);

static HINSTANCE hFreeImageDll = nullptr;
static FREEIMAGE_LOAD pLoad = nullptr;
static FREEIMAGE_LOADFROMHANDLE pLoadFromHandle = nullptr;
static FREEIMAGE_UNLOAD pUnload = nullptr;
static FREEIMAGE_ALLOCATE pAllocate = nullptr;
static FREEIMAGE_SAVE pSave = nullptr;
static FREEIMAGE_GETFIFFROMFILENAME pGetfiffromfile = nullptr;
static FREEIMAGE_GETWIDTH pGetwidth = nullptr;
static FREEIMAGE_GETHEIGHT pGetheight = nullptr;
static FREEIMAGE_GETBITS pGetbits = nullptr;
static FREEIMAGE_GETINFO pGetinfo = nullptr;
static FREEIMAGE_GETINFOHEADER pGetinfoHead = nullptr;
static FREEIMAGE_CONVERTFROMRAWBITS pConvertFromRawBits = nullptr;
static FREEIMAGE_RESCALE pRescale = nullptr;
static FREEIMAGE_GETPALETTE pGetPalette = nullptr;
static FREEIMAGE_GETBPP pGetBPP = nullptr;
static FREEIMAGE_SETCHANNEL pSetChannel = nullptr;
static FREEIMAGE_GETSCANLINE pGetScanline = nullptr;
static FREEIMAGE_CONVERTTORAWBITS pConvertToRawBits = nullptr;
static FREEIMAGE_GETPITCH pGetPitch = nullptr;
static FREEIMAGE_GETIMAGETYPE pGetImageType = nullptr;
static FREEIMAGE_GETCOLORSUSED pGetColorsUsed = nullptr;
static FREEIMAGE_ROTATECLASSIC pRotateClassic = nullptr;
static FREEIMAGE_GETDOTSPERMETERX pGetDotsPerMeterX = nullptr;
static FREEIMAGE_GETDOTSPERMETERY pGetDotsPerMeterY = nullptr;
static FREEIMAGE_SETDOTSPERMETERX pSetDotsPerMeterX = nullptr;
static FREEIMAGE_SETDOTSPERMETERY pSetDotsPerMeterY = nullptr;
static FREEIMAGE_PASTE pPaste = nullptr;
static FREEIMAGE_COPY pCopy = nullptr;
static FREEIMAGE_SETBACKGROUNDCOLOR pSetBackgroundColor = nullptr;
static FREEIMAGE_INVERT pInvert = nullptr;
static FREEIMAGE_CONVERTTO8BITS pConvertTo8Bits = nullptr;
static FREEIMAGE_CONVERTTOGREYSCALE pConvertToGreyscale = nullptr;
static FREEIMAGE_FLIPVERTICAL pFlipVertical = nullptr;
static FREEIMAGE_THRESHOLD pThreshold = nullptr;
static FREEIMAGE_GETPIXELINDEX pGetPixelIndex = nullptr;
static FREEIMAGE_GETPIXELCOLOR pGetPixelColor = nullptr;
static FREEIMAGE_SETPIXELINDEX pSetPixelIndex = nullptr;
static FREEIMAGE_SETPIXELCOLOR pSetPixelColor = nullptr;

static void SET_FREEIMAGE_MARKER(BITMAPINFOHEADER * bmih, FIBITMAP * dib);

fi_handle g_load_address;

BOOL s_freeImgInit(void)
{
   if( !hFreeImageDll ) {
      hFreeImageDll = LoadLibrary(TEXT("FreeImage.dll"));
      if( !hFreeImageDll ) {
         MessageBox(GetActiveWindow(), TEXT("Library not loaded"), TEXT("FreeImage.dll"), MB_OK | MB_ICONSTOP);
         return 0;
      }
   }
   return 1;
}

static FARPROC s_getFunction(FARPROC h, LPCSTR funcname)
{
   if( !h ) {
      if( !hFreeImageDll && !s_freeImgInit() ) {
         return nullptr;
      } else {
         return GetProcAddress(hFreeImageDll, funcname);
      }
   } else {
      return h;
   }
}

HB_FUNC( HWG_FI_INIT )
{
   hb_retl(s_freeImgInit());
}

HB_FUNC( HWG_FI_END )
{
   if( hFreeImageDll ) {
      FreeLibrary(hFreeImageDll);
      hFreeImageDll = nullptr;
      pLoad = nullptr;
      pUnload = nullptr;
      pAllocate = nullptr;
      pSave = nullptr;
      pGetfiffromfile = nullptr;
      pGetwidth = nullptr;
      pGetheight = nullptr;
      pGetbits = nullptr;
      pGetinfo = nullptr;
      pGetinfoHead = nullptr;
      pConvertFromRawBits = nullptr;
      pRescale = nullptr;
      pGetPalette = nullptr;
      pGetBPP = nullptr;
      pSetChannel = nullptr;
      pGetScanline = nullptr;
      pConvertToRawBits = nullptr;
      pGetPitch = nullptr;
      pGetImageType = nullptr;
      pGetColorsUsed = nullptr;
      pRotateClassic = nullptr;
      pGetDotsPerMeterX = nullptr;
      pGetDotsPerMeterY = nullptr;
      pSetDotsPerMeterX = nullptr;
      pSetDotsPerMeterY = nullptr;
      pPaste = nullptr;
      pCopy = nullptr;
      pSetBackgroundColor = nullptr;
      pInvert = nullptr;
      pConvertTo8Bits = nullptr;
      pConvertToGreyscale = nullptr;
      pFlipVertical = nullptr;
      pThreshold = nullptr;
      pGetPixelIndex = nullptr;
      pGetPixelColor = nullptr;
      pSetPixelIndex = nullptr;
      pSetPixelColor = nullptr;
   }
}

HB_FUNC( HWG_FI_VERSION )
{
   FREEIMAGE_GETVERSION pFunc = reinterpret_cast<FREEIMAGE_GETVERSION>(s_getFunction(nullptr, "_FreeImage_GetVersion@0"));

   hb_retc(pFunc ? pFunc() : "");
}

HB_FUNC( HWG_FI_UNLOAD )
{
   pUnload = reinterpret_cast<FREEIMAGE_UNLOAD>(s_getFunction(reinterpret_cast<FARPROC>(pUnload), "_FreeImage_Unload@4"));

   if( pUnload ) {
      pUnload(hwg_par_FIBITMAP(1));
   }
}

HB_FUNC( HWG_FI_LOAD )
{
   pLoad = reinterpret_cast<FREEIMAGE_LOAD>(s_getFunction(reinterpret_cast<FARPROC>(pLoad), "_FreeImage_Load@12"));
   pGetfiffromfile = reinterpret_cast<FREEIMAGE_GETFIFFROMFILENAME>(s_getFunction(reinterpret_cast<FARPROC>(pGetfiffromfile), "_FreeImage_GetFIFFromFilename@4"));

   if( pGetfiffromfile && pLoad ) {
      auto name = hb_parc(1);
      hb_retnl(reinterpret_cast<ULONG>(pLoad(pGetfiffromfile(name), name, (hb_pcount() > 1) ? hb_parni(2) : 0)));
   } else {
      hb_retnl(0);
   }
}

/* 24/03/2006 - <maurilio.longo@libero.it>
                As the original freeimage's fi_Load() that has the filetype as first parameter
*/
HB_FUNC( HWG_FI_LOADTYPE )
{
   pLoad = reinterpret_cast<FREEIMAGE_LOAD>(s_getFunction(reinterpret_cast<FARPROC>(pLoad), "_FreeImage_Load@12"));

   if( pLoad ) {
      auto name = hb_parc(2);
      hb_retnl(reinterpret_cast<ULONG>(pLoad(static_cast<enum FREE_IMAGE_FORMAT>(hb_parni(1)), name, (hb_pcount() > 2) ? hb_parni(3) : 0)));
   } else {
      hb_retnl(0);
   }
}

HB_FUNC( HWG_FI_SAVE )
{
   pSave = reinterpret_cast<FREEIMAGE_SAVE>(s_getFunction(reinterpret_cast<FARPROC>(pSave), "_FreeImage_Save@16"));
   pGetfiffromfile = reinterpret_cast<FREEIMAGE_GETFIFFROMFILENAME>(s_getFunction(reinterpret_cast<FARPROC>(pGetfiffromfile), "_FreeImage_GetFIFFromFilename@4"));

   if( pGetfiffromfile && pSave ) {
      auto name = hb_parc(2);
      hb_retl(pSave(pGetfiffromfile(name), hwg_par_FIBITMAP(1), name, (hb_pcount() > 2) ? hb_parni(3) : 0));
   } else {
      hb_retl(false);
   }
}

/* 24/03/2006 - <maurilio.longo@libero.it>
                As the original freeimage's fi_Save() that has the filetype as first parameter
*/
HB_FUNC( HWG_FI_SAVETYPE )
{
   pSave = reinterpret_cast<FREEIMAGE_SAVE>(s_getFunction(reinterpret_cast<FARPROC>(pSave), "_FreeImage_Save@16"));

   if( pSave ) {
      auto name = hb_parc(3);
      hb_retl(pSave(static_cast<FREE_IMAGE_FORMAT>(hb_parni(1)), hwg_par_FIBITMAP(2), name, (hb_pcount() > 3) ? hb_parni(4) : 0));
   } else {
      hb_retl(false);
   }
}

HB_FUNC( HWG_FI_GETWIDTH )
{
   pGetwidth = reinterpret_cast<FREEIMAGE_GETWIDTH>(s_getFunction(reinterpret_cast<FARPROC>(pGetwidth), "_FreeImage_GetWidth@4"));

   hb_retnl(pGetwidth ? pGetwidth(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC( HWG_FI_GETHEIGHT )
{
   pGetheight = reinterpret_cast<FREEIMAGE_GETHEIGHT>(s_getFunction(reinterpret_cast<FARPROC>(pGetheight), "_FreeImage_GetHeight@4"));

   hb_retnl(pGetheight ? pGetheight(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC( HWG_FI_GETBPP )
{
   pGetBPP = reinterpret_cast<FREEIMAGE_GETBPP>(s_getFunction(reinterpret_cast<FARPROC>(pGetBPP), "_FreeImage_GetBPP@4"));

   hb_retnl(pGetBPP ? pGetBPP(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC( HWG_FI_GETIMAGETYPE )
{
   pGetImageType = reinterpret_cast<FREEIMAGE_GETIMAGETYPE>(s_getFunction(reinterpret_cast<FARPROC>(pGetImageType), "_FreeImage_GetImageType@4"));

   hb_retnl(pGetImageType ? pGetImageType(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC( HWG_FI_2BITMAP )
{
   FIBITMAP * dib = hwg_par_FIBITMAP(1);
   HDC hDC = GetDC(0);

   pGetbits = reinterpret_cast<FREEIMAGE_GETBITS>(s_getFunction(reinterpret_cast<FARPROC>(pGetbits), "_FreeImage_GetBits@4"));
   pGetinfo = reinterpret_cast<FREEIMAGE_GETINFO>(s_getFunction(reinterpret_cast<FARPROC>(pGetinfo), "_FreeImage_GetInfo@4"));
   pGetinfoHead = reinterpret_cast<FREEIMAGE_GETINFOHEADER>(s_getFunction(reinterpret_cast<FARPROC>(pGetinfoHead), "_FreeImage_GetInfoHeader@4"));

   hb_retnl(reinterpret_cast<LONG>(CreateDIBitmap(hDC, pGetinfoHead(dib), CBM_INIT, pGetbits(dib), pGetinfo(dib), DIB_RGB_COLORS)));

   ReleaseDC(0, hDC);
}

/* 24/02/2005 - <maurilio.longo@libero.it>
  from internet, possibly code from win32 sdk
*/
static HANDLE CreateDIB(DWORD dwWidth, DWORD dwHeight, WORD wBitCount)
{
   // Make sure bits per pixel is valid
   if( wBitCount <= 1 ) {
      wBitCount = 1;
   } else if( wBitCount <= 4 ) {
      wBitCount = 4;
   } else if( wBitCount <= 8 ) {
      wBitCount = 8;
   } else if( wBitCount <= 24 ) {
      wBitCount = 24;
   } else {
      wBitCount = 4;            // set default value to 4 if parameter is bogus
   }

   // initialize BITMAPINFOHEADER
   BITMAPINFOHEADER bi;         // bitmap header
   bi.biSize = sizeof(BITMAPINFOHEADER);
   bi.biWidth = dwWidth;        // fill in width from parameter
   bi.biHeight = dwHeight;      // fill in height from parameter
   bi.biPlanes = 1;             // must be 1
   bi.biBitCount = wBitCount;   // from parameter
   bi.biCompression = BI_RGB;
   bi.biSizeImage = 0;          // 0's here mean "default"
   bi.biXPelsPerMeter = 0;
   bi.biYPelsPerMeter = 0;
   bi.biClrUsed = 0;
   bi.biClrImportant = 0;

   // calculate size of memory block required to store the DIB.  This
   // block should be big enough to hold the BITMAPINFOHEADER, the color
   // table, and the bits
   DWORD dwBytesPerLine = (((wBitCount * dwWidth) + 31) / 32 * 4); // Number of bytes per scanline

   /*  only 24 bit DIBs supported */
   DWORD dwLen = bi.biSize + 0 /* PaletteSize((LPSTR)&bi) */  + (dwBytesPerLine * dwHeight); // size of memory block

   /* 24/02/2005 - <maurilio.longo@libero.it>
      needed to copy bits afterward */
   bi.biSizeImage = dwBytesPerLine * dwHeight;

   // alloc memory block to store our bitmap
   HANDLE hDIB = GlobalAlloc(GHND, dwLen);

   // major bummer if we couldn't get memory block
   if( !hDIB ) {
      return nullptr;
   }

   // lock memory and get pointer to it
   LPBITMAPINFOHEADER lpbi = static_cast<LPBITMAPINFOHEADER>(GlobalLock(hDIB)); // pointer to BITMAPINFOHEADER

   // use our bitmap info structure to fill in first part of
   // our DIB with the BITMAPINFOHEADER
   *lpbi = bi;

   // Since we don't know what the colortable and bits should contain,
   // just leave these blank.  Unlock the DIB and return the HDIB.
   GlobalUnlock(hDIB);

   //return handle to the DIB
   return hDIB;
}

#define FI_RGBA_RED_MASK    0x00FF0000
#define FI_RGBA_GREEN_MASK  0x0000FF00
#define FI_RGBA_BLUE_MASK   0x000000FF

/* 24/02/2005 - <maurilio.longo@libero.it>
    Converts a FIBITMAP into a DIB, works OK only for 24bpp images, though
*/
HB_FUNC( HWG_FI_FI2DIB )
{
   FIBITMAP *dib = hwg_par_FIBITMAP(1);
   HANDLE hdib;

   pGetwidth = reinterpret_cast<FREEIMAGE_GETWIDTH>(s_getFunction(reinterpret_cast<FARPROC>(pGetwidth), "_FreeImage_GetWidth@4"));
   pGetheight = reinterpret_cast<FREEIMAGE_GETHEIGHT>(s_getFunction(reinterpret_cast<FARPROC>(pGetheight), "_FreeImage_GetHeight@4"));
   pGetBPP = reinterpret_cast<FREEIMAGE_GETBPP>(s_getFunction(reinterpret_cast<FARPROC>(pGetBPP), "_FreeImage_GetBPP@4"));
   pGetPitch = reinterpret_cast<FREEIMAGE_GETPITCH>(s_getFunction(reinterpret_cast<FARPROC>(pGetBPP), "_FreeImage_GetPitch@4"));
   pGetbits = reinterpret_cast<FREEIMAGE_GETBITS>(s_getFunction(reinterpret_cast<FARPROC>(pGetbits), "_FreeImage_GetBits@4"));

   hdib = CreateDIB(static_cast<WORD>(pGetwidth(dib)), static_cast<WORD>(pGetheight(dib)), static_cast<WORD>(pGetBPP(dib)));

   if( hdib ) {
      /* int scan_width = pGetPitch(dib); unused */
      LPBITMAPINFO lpbi = static_cast<LPBITMAPINFO>(GlobalLock(hdib));
      memcpy(static_cast<LPBYTE>(reinterpret_cast<BYTE*>(lpbi)) + lpbi->bmiHeader.biSize, pGetbits(dib), lpbi->bmiHeader.biSizeImage);
      GlobalUnlock(hdib);
      hb_retnl(reinterpret_cast<LONG>(hdib));
   } else {
      hb_retnl(0);
   }
}

/* 24/02/2005 - <maurilio.longo@libero.it>
  This comes straight from freeimage fipWinImage::copyToHandle()
*/
static void SET_FREEIMAGE_MARKER(BITMAPINFOHEADER * bmih, FIBITMAP * dib)
{
   pGetImageType = reinterpret_cast<FREEIMAGE_GETIMAGETYPE>(s_getFunction(reinterpret_cast<FARPROC>(pGetImageType), "_FreeImage_GetImageType@4"));

   // Windows constants goes from 0L to 5L
   // Add 0xFF to avoid conflicts
   bmih->biCompression = 0xFF + pGetImageType(dib);
}

HB_FUNC( HWG_FI_FI2DIBEX )
{
   FIBITMAP *_dib = hwg_par_FIBITMAP(1);
   HANDLE hMem = nullptr;

   pGetColorsUsed = reinterpret_cast<FREEIMAGE_GETCOLORSUSED>(s_getFunction(reinterpret_cast<FARPROC>(pGetColorsUsed), "_FreeImage_GetColorsUsed@4"));
   pGetwidth = reinterpret_cast<FREEIMAGE_GETWIDTH>(s_getFunction(reinterpret_cast<FARPROC>(pGetwidth), "_FreeImage_GetWidth@4"));
   pGetheight = reinterpret_cast<FREEIMAGE_GETHEIGHT>(s_getFunction(reinterpret_cast<FARPROC>(pGetheight), "_FreeImage_GetHeight@4"));
   pGetBPP = reinterpret_cast<FREEIMAGE_GETBPP>(s_getFunction(reinterpret_cast<FARPROC>(pGetBPP), "_FreeImage_GetBPP@4"));
   pGetPitch = reinterpret_cast<FREEIMAGE_GETPITCH>(s_getFunction(reinterpret_cast<FARPROC>(pGetPitch), "_FreeImage_GetPitch@4"));
   pGetinfoHead = reinterpret_cast<FREEIMAGE_GETINFOHEADER>(s_getFunction(reinterpret_cast<FARPROC>(pGetinfoHead), "_FreeImage_GetInfoHeader@4"));
   pGetinfo = reinterpret_cast<FREEIMAGE_GETINFO>(s_getFunction(reinterpret_cast<FARPROC>(pGetinfo), "_FreeImage_GetInfo@4"));
   pGetbits = reinterpret_cast<FREEIMAGE_GETBITS>(s_getFunction(reinterpret_cast<FARPROC>(pGetbits), "_FreeImage_GetBits@4"));
   pGetPalette = reinterpret_cast<FREEIMAGE_GETPALETTE>(s_getFunction(reinterpret_cast<FARPROC>(pGetPalette), "_FreeImage_GetPalette@4"));
   pGetImageType = reinterpret_cast<FREEIMAGE_GETIMAGETYPE>(s_getFunction(reinterpret_cast<FARPROC>(pGetImageType), "_FreeImage_GetImageType@4"));

   if( _dib ) {
      // Get equivalent DIB size
      long dib_size = sizeof(BITMAPINFOHEADER);
      BYTE *dib;
      BYTE *p_dib, *bits;
      BITMAPINFOHEADER *bih;
      RGBQUAD *pal;

      dib_size += pGetColorsUsed(_dib) * sizeof(RGBQUAD);
      dib_size += pGetPitch(_dib) * pGetheight(_dib);

      // Allocate a DIB
      hMem = GlobalAlloc(GHND, dib_size);
      dib = static_cast<BYTE*>(GlobalLock(hMem));

      memset(dib, 0, dib_size);

      p_dib = static_cast<BYTE*>(dib);

      // Copy the BITMAPINFOHEADER
      bih = pGetinfoHead(_dib);
      memcpy(p_dib, bih, sizeof(BITMAPINFOHEADER));

      if( pGetImageType(_dib) != 1 /*FIT_BITMAP */ ) {
         // this hack is used to store the bitmap type in the biCompression member of the BITMAPINFOHEADER
         SET_FREEIMAGE_MARKER(reinterpret_cast<BITMAPINFOHEADER*>(p_dib), _dib);
      }
      p_dib += sizeof(BITMAPINFOHEADER);

      // Copy the palette
      pal = pGetPalette(_dib);
      memcpy(p_dib, pal, pGetColorsUsed(_dib) * sizeof(RGBQUAD));
      p_dib += pGetColorsUsed(_dib) * sizeof(RGBQUAD);

      // Copy the bitmap
      bits = pGetbits(_dib);
      memcpy(p_dib, bits, pGetPitch(_dib) * pGetheight(_dib));

      GlobalUnlock(hMem);
   }

   hb_retnl(reinterpret_cast<LONG>(hMem));
}

HB_FUNC( HWG_FI_DRAW )
{
   FIBITMAP *dib = hwg_par_FIBITMAP(1);
   HDC hDC = hwg_par_HDC(2);
   int nWidth = static_cast<int>(hb_parnl(3)), nHeight = static_cast<int>(hb_parnl(4));
   int nDestWidth, nDestHeight;
   POINT pp[2];
   // char cres[40];
   // BOOL l;

   if( hb_pcount() > 6 && !HB_ISNIL(7) ) {
      nDestWidth = hb_parni(7);
      nDestHeight = hb_parni(8);
   } else {
      nDestWidth = nWidth;
      nDestHeight = nHeight;
   }

   pp[0].x = hb_parni(5);
   pp[0].y = hb_parni(6);
   pp[1].x = pp[0].x + nDestWidth;
   pp[1].y = pp[0].y + nDestHeight;
   // sprintf(cres,"\n %d %d %d %d",pp[0].x,pp[0].y,pp[1].x,pp[1].y);
   // writelog(cres);
   // l = DPtoLP(hDC, pp, 2);
   // sprintf(cres,"\n %d %d %d %d %d",pp[0].x,pp[0].y,pp[1].x,pp[1].y,l);
   // writelog(cres);

   pGetbits = reinterpret_cast<FREEIMAGE_GETBITS>(s_getFunction(reinterpret_cast<FARPROC>(pGetbits), "_FreeImage_GetBits@4"));
   pGetinfo = reinterpret_cast<FREEIMAGE_GETINFO>(s_getFunction(reinterpret_cast<FARPROC>(pGetinfo), "_FreeImage_GetInfo@4"));

   if( pGetbits && pGetinfo ) {
      SetStretchBltMode(hDC, COLORONCOLOR);
      StretchDIBits(hDC, pp[0].x, pp[0].y, pp[1].x - pp[0].x, pp[1].y - pp[0].y, 0, 0, nWidth, nHeight, pGetbits(dib), pGetinfo(dib), DIB_RGB_COLORS, SRCCOPY);
   }
}

HB_FUNC( HWG_FI_BMP2FI )
{
   HBITMAP hbmp = hwg_par_HBITMAP(1);

   if( hbmp ) {
      FIBITMAP *dib;
      BITMAP bm;

      pAllocate = reinterpret_cast<FREEIMAGE_ALLOCATE>(s_getFunction(reinterpret_cast<FARPROC>(pAllocate), "_FreeImage_Allocate@24"));
      pGetbits = reinterpret_cast<FREEIMAGE_GETBITS>(s_getFunction(reinterpret_cast<FARPROC>(pGetbits), "_FreeImage_GetBits@4"));
      pGetinfo = reinterpret_cast<FREEIMAGE_GETINFO>(s_getFunction(reinterpret_cast<FARPROC>(pGetinfo), "_FreeImage_GetInfo@4"));
      pGetheight = reinterpret_cast<FREEIMAGE_GETHEIGHT>(s_getFunction(reinterpret_cast<FARPROC>(pGetheight), "_FreeImage_GetHeight@4"));

      if( pAllocate && pGetbits && pGetinfo && pGetheight ) {
         HDC hDC = GetDC(nullptr);

         GetObject(hbmp, sizeof(BITMAP), static_cast<LPVOID>(&bm));
         dib = pAllocate(bm.bmWidth, bm.bmHeight, bm.bmBitsPixel, 0, 0, 0);
         GetDIBits(hDC, hbmp, 0, pGetheight(dib), pGetbits(dib), pGetinfo(dib), DIB_RGB_COLORS);
         ReleaseDC(nullptr, hDC);
         hb_retnl(reinterpret_cast<LONG>(dib));
         return;
      }
   }
   hb_retnl(0);
}

/* Next three from EZTwain.c ( http://www.twain.org ) */
static int ColorCount(int bpp)
{
   return 0xFFF & (1 << bpp);
}

static int BmiColorCount(LPBITMAPINFOHEADER lpbi)
{
   if( lpbi->biSize == sizeof(BITMAPCOREHEADER) ) {
      LPBITMAPCOREHEADER lpbc = reinterpret_cast<LPBITMAPCOREHEADER>(lpbi);
      return 1 << lpbc->bcBitCount;
   } else if( lpbi->biClrUsed == 0 ) {
      return ColorCount(lpbi->biBitCount);
   } else {
      return static_cast<int>(lpbi->biClrUsed);
   }
}                               // BmiColorCount

static int DibNumColors(VOID FAR * pv)
{
   return BmiColorCount(static_cast<LPBITMAPINFOHEADER>(pv));
}                               // DibNumColors

static LPBYTE DibBits(LPBITMAPINFOHEADER lpdib)
// Given a pointer to a locked DIB, return a pointer to the actual bits (pixels)
{
   DWORD dwColorTableSize = static_cast<DWORD>(DibNumColors(lpdib) * sizeof(RGBQUAD));
   LPBYTE lpBits = reinterpret_cast<LPBYTE>(lpdib) + lpdib->biSize + dwColorTableSize;

   return lpBits;
}                               // end DibBits

/* 19/05/2005 - <maurilio.longo@libero.it>
  Convert a windows DIB into a FIBITMAP
*/
HB_FUNC( HWG_FI_DIB2FI )
{
   HANDLE hdib = reinterpret_cast<HANDLE>(hb_parnl(1));

   if( hdib ) {
      FIBITMAP *dib;
      LPBITMAPINFOHEADER lpbi = static_cast<LPBITMAPINFOHEADER>(GlobalLock(hdib));

      pConvertFromRawBits = reinterpret_cast<FREEIMAGE_CONVERTFROMRAWBITS>(s_getFunction(reinterpret_cast<FARPROC>(pConvertFromRawBits), "_FreeImage_ConvertFromRawBits@36"));
      pGetPalette = reinterpret_cast<FREEIMAGE_GETPALETTE>(s_getFunction(reinterpret_cast<FARPROC>(pGetPalette), "_FreeImage_GetPalette@4"));
      pGetBPP = reinterpret_cast<FREEIMAGE_GETBPP>(s_getFunction(reinterpret_cast<FARPROC>(pGetBPP), "_FreeImage_GetBPP@4"));

      if( pConvertFromRawBits && lpbi ) {
         //int pitch = (((( lpbi->biWidth * lpbi->biBitCount) + 31) &~31) >> 3);
         int pitch = ((((lpbi->biBitCount * lpbi->biWidth) + 31) / 32) * 4);

         dib = pConvertFromRawBits(DibBits(lpbi), lpbi->biWidth, lpbi->biHeight, pitch, lpbi->biBitCount, FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK, hb_parl(2));

         /* I can't print it with FI_DRAW, though, and I don't know why */
         if( pGetBPP(dib) <= 8 ) {
            // Convert palette entries
            RGBQUAD *pal = pGetPalette(dib);
            RGBQUAD *dibpal = reinterpret_cast<RGBQUAD*>(reinterpret_cast<LPBYTE>(lpbi) + lpbi->biSize);

            for( int i = 0; i < BmiColorCount(lpbi); i++ ) {
               pal[i].rgbRed      = dibpal[i].rgbRed;
               pal[i].rgbGreen    = dibpal[i].rgbGreen;
               pal[i].rgbBlue     = dibpal[i].rgbBlue;
               pal[i].rgbReserved = 0;
            }
         }

         GlobalUnlock(hdib);
         hb_retnl(reinterpret_cast<LONG>(dib));
         return;

      } else {
         GlobalUnlock(hdib);
      }
   }
   hb_retnl(0);
}

HB_FUNC( HWG_FI_RESCALE )
{
   pRescale = reinterpret_cast<FREEIMAGE_RESCALE>(s_getFunction(reinterpret_cast<FARPROC>(pRescale), "_FreeImage_Rescale@16"));

   hb_retnl(pRescale ? reinterpret_cast<LONG>(pRescale(hwg_par_FIBITMAP(1), hb_parnl(2), hb_parnl(3), static_cast<FREE_IMAGE_FILTER>(hb_parni(4)))) : 0);
}

/* Channel is an enumerated type from freeimage.h passed as second parameter */
HB_FUNC( HWG_FI_REMOVECHANNEL )
{
   FIBITMAP *dib = hwg_par_FIBITMAP(1);
   FIBITMAP *dib8;

   pAllocate = reinterpret_cast<FREEIMAGE_ALLOCATE>(s_getFunction(reinterpret_cast<FARPROC>(pAllocate), "_FreeImage_Allocate@24"));
   pGetwidth = reinterpret_cast<FREEIMAGE_GETWIDTH>(s_getFunction(reinterpret_cast<FARPROC>(pGetwidth), "_FreeImage_GetWidth@4"));
   pGetheight = reinterpret_cast<FREEIMAGE_GETHEIGHT>(s_getFunction(reinterpret_cast<FARPROC>(pGetheight), "_FreeImage_GetHeight@4"));
   pSetChannel = reinterpret_cast<FREEIMAGE_SETCHANNEL>(s_getFunction(reinterpret_cast<FARPROC>(pSetChannel), "_FreeImage_SetChannel@12"));
   pUnload = reinterpret_cast<FREEIMAGE_UNLOAD>(s_getFunction(reinterpret_cast<FARPROC>(pUnload), "_FreeImage_Unload@4"));

   dib8 = pAllocate(pGetwidth(dib), pGetheight(dib), 8, 0, 0, 0);

   if( dib8 ) {
      hb_retl(pSetChannel(dib, dib8, static_cast<FREE_IMAGE_COLOR_CHANNEL>(hb_parni(2))));
      pUnload(dib8);
   } else {
      hb_retl(false);
   }
}

/*
 * Set of functions for loading the image from memory
 */

unsigned DLL_CALLCONV _ReadProc(void *buffer, unsigned size, unsigned count, fi_handle handle)
{
   BYTE *tmp = static_cast<BYTE*>(buffer);
   HB_SYMBOL_UNUSED(handle);

   for( unsigned u = 0; u < count; u++ ) {
      memcpy(tmp, g_load_address, size);
      g_load_address = static_cast<BYTE*>(g_load_address) + size;
      tmp += size;
   }
   return count;
}

unsigned DLL_CALLCONV _WriteProc(void *buffer, unsigned size, unsigned count, fi_handle handle)
{
   HB_SYMBOL_UNUSED(buffer);
   HB_SYMBOL_UNUSED(count);
   HB_SYMBOL_UNUSED(handle);

   return size;
}

int DLL_CALLCONV _SeekProc(fi_handle handle, long offset, int origin)
{
   /* assert(origin != SEEK_END); */

   g_load_address = ((origin == SEEK_SET) ? static_cast<BYTE*>(handle) : static_cast<BYTE*>(g_load_address)) + offset;
   return 0;
}

long DLL_CALLCONV _TellProc(fi_handle handle)
{
   /* assert(static_cast<long int>(handle) >= static_cast<long int>(g_load_address)); */

   return (reinterpret_cast<long int>(g_load_address) - reinterpret_cast<long int>(handle));
}

HB_FUNC( HWG_FI_LOADFROMMEM )
{
   pLoadFromHandle = reinterpret_cast<FREEIMAGE_LOADFROMHANDLE>(s_getFunction(reinterpret_cast<FARPROC>(pLoadFromHandle), "_FreeImage_LoadFromHandle@16"));

   if( pLoadFromHandle ) {
      auto image = hb_parc(1);
      FREE_IMAGE_FORMAT fif;
      FreeImageIO io;

      io.read_proc = _ReadProc;
      io.write_proc = _WriteProc;
      io.tell_proc = _TellProc;
      io.seek_proc = _SeekProc;

      auto cType = hb_parc(2);
      if( cType ) {
         if( !hb_stricmp(cType, "jpg") ) {
            fif = FIF_JPEG;
         } else if( !hb_stricmp(cType, "bmp") ) {
            fif = FIF_BMP;
         } else if( !hb_stricmp(cType, "png") ) {
            fif = FIF_PNG;
         } else if( !hb_stricmp(cType, "tiff") ) {
            fif = FIF_TIFF;
         } else {
            fif = FIF_UNKNOWN;
         }
      } else {
         fif = FIF_UNKNOWN;
      }

      g_load_address = static_cast<fi_handle>(const_cast<char*>(image));
      hb_retnl(reinterpret_cast<LONG>(pLoadFromHandle(fif, &io, static_cast<fi_handle>(const_cast<char*>(image)), (hb_pcount() > 2) ? hb_parni(3) : 0)));
   } else {
      hb_retnl(0);
   }
}

HB_FUNC( HWG_FI_ROTATECLASSIC )
{
   pRotateClassic = reinterpret_cast<FREEIMAGE_ROTATECLASSIC>(s_getFunction(reinterpret_cast<FARPROC>(pRotateClassic), "_FreeImage_RotateClassic@12"));

   hb_retnl(pRotateClassic ? reinterpret_cast<LONG>(pRotateClassic(hwg_par_FIBITMAP(1), hb_parnd(2))) : 0);
}

HB_FUNC( HWG_FI_GETDOTSPERMETERX )
{
   pGetDotsPerMeterX = reinterpret_cast<FREEIMAGE_GETDOTSPERMETERX>(s_getFunction(reinterpret_cast<FARPROC>(pGetDotsPerMeterX), "_FreeImage_GetDotsPerMeterX@4"));

   hb_retnl(pGetDotsPerMeterX ? pGetDotsPerMeterX(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC( HWG_FI_GETDOTSPERMETERY )
{
   pGetDotsPerMeterY = reinterpret_cast<FREEIMAGE_GETDOTSPERMETERY>(s_getFunction(reinterpret_cast<FARPROC>(pGetDotsPerMeterY), "_FreeImage_GetDotsPerMeterY@4"));

   hb_retnl(pGetDotsPerMeterY ? pGetDotsPerMeterY(hwg_par_FIBITMAP(1)) : 0);
}

HB_FUNC( HWG_FI_SETDOTSPERMETERX )
{
   pSetDotsPerMeterX = reinterpret_cast<FREEIMAGE_SETDOTSPERMETERX>(s_getFunction(reinterpret_cast<FARPROC>(pSetDotsPerMeterX), "_FreeImage_SetDotsPerMeterX@8"));

   if( pSetDotsPerMeterX ) {
      pSetDotsPerMeterX(hwg_par_FIBITMAP(1), hb_parnl(2));
   }

   hb_ret();
}

HB_FUNC( HWG_FI_SETDOTSPERMETERY )
{
   pSetDotsPerMeterY = reinterpret_cast<FREEIMAGE_SETDOTSPERMETERY>(s_getFunction(reinterpret_cast<FARPROC>(pSetDotsPerMeterY), "_FreeImage_SetDotsPerMeterY@8"));

   if( pSetDotsPerMeterY ) {
      pSetDotsPerMeterY(hwg_par_FIBITMAP(1), hb_parnl(2));
   }

   hb_ret();
}

/*
HWG_FI_ALLOCATE(nX, nY, nDepth) --> numerical
*/
HB_FUNC( HWG_FI_ALLOCATE )
{
   pAllocate = reinterpret_cast<FREEIMAGE_ALLOCATE>(s_getFunction(reinterpret_cast<FARPROC>(pAllocate), "_FreeImage_Allocate@24"));

   hb_retnl(reinterpret_cast<ULONG>(pAllocate(hb_parnl(1), hb_parnl(2), hb_parnl(3), 0, 0, 0)));
}

/*
HWG_FI_PASTE(nDes, nSrc, nTop, nLeft, nAlpha) --> logical
*/
HB_FUNC( HWG_FI_PASTE )
{
   pPaste = reinterpret_cast<FREEIMAGE_PASTE>(s_getFunction(reinterpret_cast<FARPROC>(pPaste), "_FreeImage_Paste@20"));

   hb_retl(pPaste(hwg_par_FIBITMAP(1), hwg_par_FIBITMAP(2), hb_parnl(3), hb_parnl(4), hb_parnl(5)));
}

/*
HWG_FI_COPY(nDib, nLeft, nTop, nRight, nBottom) --> numeric
*/
HB_FUNC( HWG_FI_COPY )
{
   pCopy = reinterpret_cast<FREEIMAGE_COPY>(s_getFunction(reinterpret_cast<FARPROC>(pCopy), "_FreeImage_Copy@20"));

   hb_retnl(reinterpret_cast<ULONG>(pCopy(hwg_par_FIBITMAP(1), hb_parnl(2), hb_parnl(3), hb_parnl(4), hb_parnl(5))));
}

/* just a test, should receive a RGBQUAD structure, a xharbour array */
HB_FUNC( HWG_FI_SETBACKGROUNDCOLOR )
{
   RGBQUAD rgbquad = {255, 255, 255, 255};

   pSetBackgroundColor = reinterpret_cast<FREEIMAGE_SETBACKGROUNDCOLOR>(s_getFunction(reinterpret_cast<FARPROC>(pSetBackgroundColor), "_FreeImage_SetBackgroundColor@8"));

   hb_retl(pSetBackgroundColor(hwg_par_FIBITMAP(1), &rgbquad));
}

HB_FUNC( HWG_FI_INVERT )
{
   pInvert = reinterpret_cast<FREEIMAGE_INVERT>(s_getFunction(reinterpret_cast<FARPROC>(pInvert), "_FreeImage_Invert@4"));

   hb_retl(pInvert(hwg_par_FIBITMAP(1)));
}

HB_FUNC( HWG_FI_GETBITS )
{
   pGetbits = reinterpret_cast<FREEIMAGE_GETBITS>(s_getFunction(reinterpret_cast<FARPROC>(pGetbits), "_FreeImage_GetBits@4"));

   hb_retptr(pGetbits(hwg_par_FIBITMAP(1)));
}

HB_FUNC( HWG_FI_CONVERTTO8BITS )
{
   pConvertTo8Bits = reinterpret_cast<FREEIMAGE_CONVERTTO8BITS>(s_getFunction(reinterpret_cast<FARPROC>(pConvertTo8Bits), "_FreeImage_ConvertTo8Bits@4"));

   hb_retnl(reinterpret_cast<LONG>(pConvertTo8Bits(hwg_par_FIBITMAP(1))));
}

HB_FUNC( HWG_FI_CONVERTTOGREYSCALE )
{
   pConvertToGreyscale = reinterpret_cast<FREEIMAGE_CONVERTTOGREYSCALE>(s_getFunction(reinterpret_cast<FARPROC>(pConvertToGreyscale), "_FreeImage_ConvertToGreyscale@4"));

   hb_retnl(reinterpret_cast<LONG>(pConvertToGreyscale(hwg_par_FIBITMAP(1))));
}

HB_FUNC( HWG_FI_THRESHOLD )
{
   pThreshold = reinterpret_cast<FREEIMAGE_THRESHOLD>(s_getFunction(reinterpret_cast<FARPROC>(pThreshold), "_FreeImage_Threshold@8"));

   hb_retnl(reinterpret_cast<LONG>(pThreshold(hwg_par_FIBITMAP(1), hwg_par_BYTE(2))));
}

HB_FUNC( HWG_FI_FLIPVERTICAL )
{
   pFlipVertical = reinterpret_cast<FREEIMAGE_FLIPVERTICAL>(s_getFunction(reinterpret_cast<FARPROC>(pFlipVertical), "_FreeImage_FlipVertical@4"));

   hb_retl(pFlipVertical(hwg_par_FIBITMAP(1)));
}

HB_FUNC( HWG_FI_GETPIXELINDEX )
{
   BYTE value = static_cast<BYTE>(-1);
   pGetPixelIndex = reinterpret_cast<FREEIMAGE_GETPIXELINDEX>(s_getFunction(reinterpret_cast<FARPROC>(pGetPixelIndex), "_FreeImage_GetPixelIndex@16"));

   BOOL lRes = pGetPixelIndex(hwg_par_FIBITMAP(1), hb_parni(2), hb_parni(3), &value);

   if( lRes ) {
      hb_stornl(static_cast<ULONG>(value), 4);
   }

   hb_retl(lRes);
}

HB_FUNC( HWG_FI_SETPIXELINDEX )
{
   BYTE value = hb_parni(4);
   pSetPixelIndex = reinterpret_cast<FREEIMAGE_SETPIXELINDEX>(s_getFunction(reinterpret_cast<FARPROC>(pSetPixelIndex), "_FreeImage_SetPixelIndex@16"));

   hb_retl(pSetPixelIndex(hwg_par_FIBITMAP(1), hb_parni(2), hb_parni(3), &value));
}

/* todo
typedef BOOL ( WINAPI *FREEIMAGE_GETPIXELCOLOR )(FIBITMAP *dib, unsigned x, unsigned y, RGBQUAD *value);
typedef BOOL ( WINAPI *FREEIMAGE_SETPIXELCOLOR )(FIBITMAP *dib, unsigned x, unsigned y, RGBQUAD *value);
*/
