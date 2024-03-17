/*
 * HWGUI++/GDI+ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// for MS-Windows only

#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog

   // initialize GDI+
   waGdiplusStartup()

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600 ;

   oDialog:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      LOCAL pImage
      LOCAL nWidth
      LOCAL nHeight
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(oDialog:handle, pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipLoadImageFromFile("harbour.gif", @pImage)
      waGdipGetImageDimension(pImage, @nWidth, @nHeight)
      waGdipDrawImage(pGraphics, pImage, (oDialog:nWidth - nWidth) / 2, (oDialog:nHeight - nHeight) / 2)
      waGdipDisposeImage(pImage)
      waGdipDeleteGraphics(pGraphics)
      hwg_EndPaint(oDialog:handle, pPS)
      }

   // update window if resized
   oDialog:bSize := {||hwg_Redrawwindow(oDialog:handle, RDW_ERASE + RDW_INVALIDATE)}

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   // finalize GDI+
   waGdiplusShutdown()

RETURN
