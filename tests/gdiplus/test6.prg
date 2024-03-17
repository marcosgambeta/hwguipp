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
   LOCAL oButton

   // initialize GDI+
   waGdiplusStartup()

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600

   oDialog:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      LOCAL oP1 := waGpPoint():new(0, 0)
      LOCAL oP2 := waGpPoint():new(0, oDialog:nHeight)
      LOCAL pBrush
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(hwg_GetModalHandle(), pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipCreateLineBrushI(oP1, oP2, 0xFFFF0000, 0xFF0000FF, NIL, @pBrush)
      waGdipFillRectangleI(pGraphics, pBrush, 0, 0, oDialog:nWidth, oDialog:nHeight)
      waGdipDeleteBrush(pBrush)
      waGdipDeleteGraphics(pGraphics)
      hwg_EndPaint(hwg_GetModalHandle(), pPS)
      }

   // update window if resized
   oDialog:bSize := {|o, x, y|
      oButton:Move(x - 100 - 20, y - 32 - 20)
      hwg_RedrawWindow(oDialog:handle, RDW_ERASE + RDW_INVALIDATE)
      }

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON oButton CAPTION "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   // finalize GDI+
   waGdiplusShutdown()

RETURN
