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
   LOCAL oButton

   waGdiplusStartup()

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600

   oDialog:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      LOCAL pImage
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(oDialog:handle, pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipLoadImageFromFile("harbour.gif", @pImage)
      waGdipDrawImageRect(pGraphics, pImage, 0, 0, oDialog:nWidth, oDialog:nHeight)
      waGdipDisposeImage(pImage)
      waGdipDeleteGraphics(pGraphics)
      hwg_EndPaint(oDialog:handle, pPS)
   }

   oDialog:bSize := {|o, x, y|
      oButton:Move(x - 100 - 20, y - 32 - 20, 100, 32)
      hwg_RedrawWindow(oDialog:handle, RDW_ERASE + RDW_INVALIDATE)
      }

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON oButton CAPTION "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   waGdiplusShutdown()

RETURN
