/*
 * HWGUI++ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// for MS-Windows only

#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oDialog

   waGdiplusStartup()

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600

   oDialog:bPaint := {||
      LOCAL pGraphics
      LOCAL pImage
      waGdipCreateFromHWND(oDialog:handle, @pGraphics)
      waGdipLoadImageFromFile("harbour.gif", @pImage)
      waGdipDrawImage(pGraphics, pImage, 0, 0)
      waGdipDisposeImage(pImage)
      waGdipDeleteGraphics(pGraphics)
      }

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   waGdiplusShutdown()

RETURN
