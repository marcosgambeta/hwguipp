/*
 * HWGUI++ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// for MS-Windows only

#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL pImage

   waGdiplusStartup()

   waGdipLoadImageFromFile("harbour.gif", @pImage)

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600 ;
      ON PAINT {||
         LOCAL pPS
         LOCAL pDC
         LOCAL pGraphics
         pPS := hwg_DefinePaintStru()
         pDC := hwg_BeginPaint(hwg_GetModalHandle(), pPS)
         waGdipCreateFromHDC(pDC, @pGraphics)
         waGdipDrawImageRect(pGraphics, pImage, 0, 0, oDialog:nWidth, oDialog:nHeight)
         waGdipDeleteGraphics(pGraphics)
         hwg_EndPaint(hwg_GetModalHandle(), pPS)
      }

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   waGdipDisposeImage(pImage)

   waGdiplusShutdown()

RETURN
