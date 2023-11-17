/*
 * HWGUI - Harbour Win32 GUI library source code:
 *
 *
 * Copyright 2003 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
 * www - http://sites.uol.com.br/culikr/
*/

#include "hwingui.hpp"
#include <commctrl.h>
#include <hbapiitm.hpp>
#include <hbvm.hpp>
#include <hbstack.hpp>
#include "incomp_pointer.hpp"

#ifndef GRADIENT_FILL_RECT_H

#define GRADIENT_FILL_RECT_H 0
#define GRADIENT_FILL_RECT_V 1

#if !defined(__MINGW32__) && !defined(__MINGW64__)
typedef struct _GRADIENT_RECT
{
   ULONG UpperLeft;
   ULONG LowerRight;
} GRADIENT_RECT, *PGRADIENT_RECT, *LPGRADIENT_RECT;
#endif

#endif

LRESULT CALLBACK NiceButtProc(HWND, UINT, WPARAM, LPARAM);

void Draw_Gradient(HDC hdc, int x, int y, int w, int h, int r, int g, int b)
{
   TRIVERTEX Vert[2];
   GRADIENT_RECT Rect;
   HB_SYMBOL_UNUSED(x);
   HB_SYMBOL_UNUSED(y);
   // ******************************************************
   Vert[0].x = 0;
   Vert[0].y = 0;
   Vert[0].Red = 65535 - ( 65535 - ( r * 256 ) );
   Vert[0].Green = 65535 - ( 65535 - ( g * 256 ) );
   Vert[0].Blue = 65535 - ( 65535 - ( b * 256 ) );
   Vert[0].Alpha = 0;
   // ******************************************************
   Vert[1].x = w;
   Vert[1].y = h / 2;
   Vert[1].Red = 65535 - ( 65535 - ( 255 * 256 ) );
   Vert[1].Green = 65535 - ( 65535 - ( 255 * 256 ) );
   Vert[1].Blue = 65535 - ( 65535 - ( 255 * 256 ) );
   Vert[1].Alpha = 0;
   // ******************************************************
   Rect.UpperLeft = 0;
   Rect.LowerRight = 1;
   // ******************************************************
   GradientFill(hdc, Vert, 2, &Rect, 1, GRADIENT_FILL_RECT_V);
   // ******************************************************
   Vert[0].x = 0;
   Vert[0].y = h / 2;
   Vert[0].Red = 65535 - ( 65535 - ( 255 * 256 ) );
   Vert[0].Green = 65535 - ( 65535 - ( 255 * 256 ) );
   Vert[0].Blue = 65535 - ( 65535 - ( 255 * 256 ) );
   Vert[0].Alpha = 0;
   // ******************************************************
   Vert[1].x = w;
   Vert[1].y = h;
   Vert[1].Red = 65535 - ( 65535 - ( r * 256 ) );
   Vert[1].Green = 65535 - ( 65535 - ( g * 256 ) );
   Vert[1].Blue = 65535 - ( 65535 - ( b * 256 ) );
   Vert[1].Alpha = 0;
   // ******************************************************
   Rect.UpperLeft = 0;
   Rect.LowerRight = 1;
   // ******************************************************
   GradientFill(hdc, Vert, 2, &Rect, 1, GRADIENT_FILL_RECT_V);
}

void Gradient(HDC hdc, int x, int y, int w, int h, int color1, int color2, int nmode) // int, int g, int b, int nMode)
{
   TRIVERTEX Vert[2];
   GRADIENT_RECT Rect;
   int r, g, b, r2, g2, b2;
   HB_SYMBOL_UNUSED(x);
   HB_SYMBOL_UNUSED(y);

   r = color1 % 256;
   g = color1 / 256 % 256;
   b = color1 / 256 / 256 % 256;
   r2 = color2 % 256;
   g2 = color2 / 256 % 256;
   b2 = color2 / 256 / 256 % 256;


   // ******************************************************
   Vert[0].x = 0;
   Vert[0].y = 0;
   Vert[0].Red = 65535 - ( 65535 - ( r * 256 ) );
   Vert[0].Green = 65535 - ( 65535 - ( g * 256 ) );
   Vert[0].Blue = 65535 - ( 65535 - ( b * 256 ) );
   Vert[0].Alpha = 0;
   // ******************************************************
   Vert[1].x = w;
   Vert[1].y = h;
   Vert[1].Red = 65535 - ( 65535 - ( r2 * 256 ) );
   Vert[1].Green = 65535 - ( 65535 - ( g2 * 256 ) );
   Vert[1].Blue = 65535 - ( 65535 - ( b2 * 256 ) );
   Vert[1].Alpha = 0;
   // ******************************************************
   Rect.UpperLeft = 0;
   Rect.LowerRight = 1;
   // ******************************************************
   GradientFill(hdc, Vert, 2, &Rect, 1, nmode);    //GRADIENT_FILL_RECT_H );
}

LRESULT CALLBACK NiceButtProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
   long int res;
   PHB_DYNS pSymTest;
   if( ( pSymTest = hb_dynsymFind("HWG_NICEBUTTPROC") ) != nullptr ) {
      hb_vmPushSymbol(hb_dynsymSymbol(pSymTest));
      hb_vmPushNil();         /* places NIL at self */
      //hb_vmPushLong(static_cast<LONG>(hWnd));   /* pushes parameters on to the hvm stack */
      hb_vmPushPointer(hWnd);
      hb_vmPushLong(static_cast<LONG>(message));
      hb_vmPushLong(static_cast<LONG>(wParam));
      hb_vmPushLong(static_cast<LONG>(lParam));
      hb_vmDo(4);             /* where iArgCount is the number of pushed parameters */
      res = hb_parl(-1);
      if( res ) {
         return 0;
      } else {
         return ( DefWindowProc(hWnd, message, wParam, lParam) );
      }
   } else {
      return ( DefWindowProc(hWnd, message, wParam, lParam) );
   }
}

HB_FUNC( HWG_CREATEROUNDRECTRGN )
{
   HRGN Res = CreateRoundRectRgn(hb_parni(1), hb_parni(2), hb_parni(3), hb_parni(4), hb_parni(5), hb_parni(6));
   hb_retptr(Res);
}

HB_FUNC( HWG_SETWINDOWRGN ) // TODO: reinterpret_cast<HRGN>(hb_parnl(2)) ?
{
   hb_retni(SetWindowRgn(hwg_par_HWND(1), reinterpret_cast<HRGN>(hb_parnl(2)), hb_parl(3)));
}

HB_FUNC( HWG_REGNICE )
{
   // **********[DLL Declarations]**********
   static LPCTSTR s_szAppName = TEXT("NICEBUTT");
   static BOOL s_bRegistered = 0;

   if( !s_bRegistered ) {
      WNDCLASS wc;

      wc.style = CS_HREDRAW | CS_VREDRAW | CS_GLOBALCLASS;
      wc.hInstance = GetModuleHandle(0);
      wc.hbrBackground = reinterpret_cast<HBRUSH>(COLOR_BTNFACE + 1);
      wc.lpszClassName = s_szAppName;
      wc.lpfnWndProc = NiceButtProc;
      wc.cbClsExtra = 0;
      wc.cbWndExtra = 0;
      wc.hIcon = nullptr;
      wc.hCursor = nullptr;
      wc.lpszMenuName = 0;

      RegisterClass(&wc);
      s_bRegistered = 1;
   }
}


HB_FUNC( HWG_CREATENICEBTN )
{
   ULONG ulStyle =
         HB_ISNUM(3) ? hb_parnl(3) : WS_CLIPCHILDREN | WS_CLIPSIBLINGS;
   void * hTitle;

   auto hWndPanel = CreateWindowEx(hb_parni(8), TEXT("NICEBUTT"),       /* predefined class  */
         HB_PARSTR(9, &hTitle, nullptr), /* no window title   */
         WS_CHILD | WS_VISIBLE | ulStyle,       /* style  */
         hwg_par_int(4), hwg_par_int(5),  /* x, y       */
         hwg_par_int(6), hwg_par_int(7),  /* nWidth, nHeight */
         hwg_par_HWND(1),    /* parent window    */
         reinterpret_cast<HMENU>(static_cast<UINT_PTR>(hb_parni(2))),       /* control ID  */
         GetModuleHandle(nullptr), nullptr);
   hb_strfree(hTitle);

   hb_retptr(hWndPanel);
}

HB_FUNC( HWG_ISMOUSEOVER )
{
   RECT Rect;
   POINT Pt;
   GetWindowRect(hwg_par_HWND(1), &Rect);
   GetCursorPos(&Pt);
   hb_retl(PtInRect(&Rect, Pt));
}

HB_FUNC( HWG_DRAW_GRADIENT )
{
   Draw_Gradient(hwg_par_HDC(1), hb_parni(2), hb_parni(3), hb_parni(4), hb_parni(5), hb_parni(6), hb_parni(7), hb_parni(8));
}

HB_FUNC( HWG_GRADIENT )
{
   //void Gradient(HDC hdc, int x, int y, int w, int h, int color1, int color2, int nmode)

   Gradient(hwg_par_HDC(1), hb_parni(2), hb_parni(3),
         hb_parni(4), hb_parni(5),
         ( hb_pcount() > 5 && !HB_ISNIL(6) ) ? hb_parni(6) : 16777215,
         ( hb_pcount() > 6 && !HB_ISNIL(7) ) ? hb_parni(7) : 16777215,
         ( hb_pcount() > 7 && !HB_ISNIL(8) ) ? hb_parni(8) : 0);
}

HB_FUNC( HWG_MAKELONG )
{
   hb_retnl(static_cast<LONG>(MAKELONG(static_cast<WORD>(hb_parnl(1)), static_cast<WORD>(hb_parnl(2)))));
}

HB_FUNC( HWG_GETWINDOWLONG )
{
   hb_retnl(GetWindowLongPtr(hwg_par_HWND(1), hb_parni(2)));
}

HB_FUNC( HWG_SETBKMODE )
{
   hb_retni(SetBkMode(hwg_par_HDC(1), hb_parni(2)));
}
