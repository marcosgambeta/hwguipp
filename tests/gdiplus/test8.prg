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
   LOCAL a := {}

   // initialize GDI+
   waGdiplusStartup()

   // fill array with points (GpPoint objects)
   FillArray(a)

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600

   // draw graphic
   oDialog:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      LOCAL pPen
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(hwg_GetModalHandle(), pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipCreatePen1(0xFF00FFFF, 5, 2 /* pixel */, @pPen)
      waGdipDrawLinesI(pGraphics, pPen, a, Len(a))
      waGdipDeletePen(pPen)
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

STATIC FUNCTION FillArray(a)

   LOCAL nX := 0
   LOCAL nY := 0
   LOCAL nLine := 500
   LOCAL nDec := 10
   LOCAL n

   DO WHILE .T.
      AAdd(a, waGpPoint():new(nX, nY))
      nX += nLine
      AAdd(a, waGpPoint():new(nX, nY))
      nY += nLine
      AAdd(a, waGpPoint():new(nX, nY))
      nX -= nLine
      AAdd(a, waGpPoint():new(nX, nY))
      nLine -= nDec
      IF nLine <= 0
         EXIT
      ENDIF
      nY -= nLine
      AAdd(a, waGpPoint():new(nX, nY))
   ENDDO

RETURN NIL
