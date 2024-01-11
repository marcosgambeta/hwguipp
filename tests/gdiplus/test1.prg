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
   LOCAL pGraphics
   LOCAL pImage

   waGdiplusStartup()

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600 ;
      ON PAINT {||
         LOCAL pGraphics
         LOCAL pImage
         waGdipCreateFromHWND(oDialog:handle, @pGraphics)
         waGdipLoadImageFromFile("harbour.gif", @pImage)
         waGdipDrawImage(pGraphics, pImage, 0, 0)
         waGdipDisposeImage(pImage)
         waGdipDeleteGraphics(pGraphics)
      }

   ACTIVATE DIALOG oDialog

   waGdiplusShutdown()

RETURN
