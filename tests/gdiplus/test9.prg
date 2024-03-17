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
   LOCAL oListBox
   LOCAL oButton
   LOCAL aHatches := {}

   FillArray(aHatches)

   // initialize GDI+
   waGdiplusStartup()

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600

   oDialog:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      LOCAL pBrush
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(hwg_GetModalHandle(), pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipCreateHatchBrush(oCombo:value - 1, 0xFFFF0000, 0xFF80FFFF, @pBrush)
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

   @ 20, 20 LISTBOX oCombo ITEMS aHatches SIZE 300, 560 INIT 1 ;
      ON CHANGE {||hwg_RedrawWindow(oDialog:handle, RDW_ERASE + RDW_INVALIDATE)}

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON oButton CAPTION "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   // finalize GDI+
   waGdiplusShutdown()

RETURN

STATIC FUNCTION FillArray(a)

   AAdd(a, "Horizontal")
   AAdd(a, "Vertical")
   AAdd(a, "ForwardDiagonal")
   AAdd(a, "BackwardDiagonal")
   AAdd(a, "Cross | LargeGrid")
   AAdd(a, "DiagonalCross")
   AAdd(a, "05Percent")
   AAdd(a, "10Percent")
   AAdd(a, "20Percent")
   AAdd(a, "25Percent")
   AAdd(a, "30Percent")
   AAdd(a, "40Percent")
   AAdd(a, "50Percent")
   AAdd(a, "60Percent")
   AAdd(a, "70Percent")
   AAdd(a, "75Percent")
   AAdd(a, "80Percent")
   AAdd(a, "90Percent")
   AAdd(a, "LightDownwardDiagonal")
   AAdd(a, "LightUpwardDiagonal")
   AAdd(a, "DarkDownwardDiagonal")
   AAdd(a, "DarkUpwardDiagonal")
   AAdd(a, "WideDownwardDiagonal")
   AAdd(a, "WideUpwardDiagonal")
   AAdd(a, "LightVertical")
   AAdd(a, "LightHorizontal")
   AAdd(a, "NarrowVertical")
   AAdd(a, "NarrowHorizontal")
   AAdd(a, "DarkVertical")
   AAdd(a, "DarkHorizontal")
   AAdd(a, "DashedDownwardDiagonal")
   AAdd(a, "DashedUpwardDiagonal")
   AAdd(a, "DashedHorizontal")
   AAdd(a, "DashedVertical")
   AAdd(a, "SmallConfetti")
   AAdd(a, "LargeConfetti")
   AAdd(a, "ZigZag")
   AAdd(a, "Wave")
   AAdd(a, "DiagonalBrick")
   AAdd(a, "HorizontalBrick")
   AAdd(a, "Weave")
   AAdd(a, "Plaid")
   AAdd(a, "Divot")
   AAdd(a, "DottedGrid")
   AAdd(a, "DottedDiamond")
   AAdd(a, "Shingle")
   AAdd(a, "Trellis")
   AAdd(a, "Sphere")
   AAdd(a, "SmallGrid")
   AAdd(a, "SmallCheckerBoard")
   AAdd(a, "LargeCheckerBoard")
   AAdd(a, "OutlinedDiamond")
   AAdd(a, "SolidDiamond")

RETURN NIL
