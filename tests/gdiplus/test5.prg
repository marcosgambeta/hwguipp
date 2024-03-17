/*
 * HWGUI++/GDI+ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// for MS-Windows only

#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oMainWindow
   LOCAL pImage

   // initialize GDI+
   waGdiplusStartup()

   // load image
   waGdipLoadImageFromFile("harbour.gif", @pImage)

   INIT WINDOW oMainWindow MAIN TITLE "Test" SIZE 800, 600

   oMainWindow:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(oMainWindow:handle, pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipDrawImageRect(pGraphics, pImage, 0, 0, oMainWindow:nWidth, oMainWindow:nHeight)
      waGdipDeleteGraphics(pGraphics)
      hwg_EndPaint(oMainWindow:handle, pPS)
      }

   // update window if resized
   oMainWindow:bSize := {||hwg_RedrawWindow(oMainWindow:handle, RDW_ERASE + RDW_INVALIDATE)}

   ACTIVATE WINDOW oMainWindow

   // dispose image
   waGdipDisposeImage(pImage)

   // finalize GDI+
   waGdiplusShutdown()

RETURN
