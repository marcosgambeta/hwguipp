/*
 * HWGUI++/GDI+ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// for MS-Windows only

#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oButton
   LOCAL pImage

   // initialize GDI+
   waGdiplusStartup()

   // load image
   waGdipLoadImageFromFile("harbour.gif", @pImage)

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600

   oDialog:bPaint := {||
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

   // update window if resized
   oDialog:bSize := {|o, x, y|
      oButton:Move(x - 100 - 20, y - 32 - 20, 100, 32)
      hwg_RedrawWindow(oDialog:handle, RDW_ERASE + RDW_INVALIDATE)
      }

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON oButton CAPTION "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   // dispose image
   waGdipDisposeImage(pImage)

   // finalize GDI+
   waGdiplusShutdown()

RETURN
