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

   waGdiplusStartup()

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600 ;
      ON PAINT {||
         LOCAL pGraphics
         LOCAL pImage
         LOCAL nWidth
         LOCAL nHeight
         waGdipCreateFromHWND(oDialog:handle, @pGraphics)
         waGdipLoadImageFromFile("harbour.gif", @pImage)
         waGdipGetImageDimension(pImage, @nWidth, @nHeight)
         waGdipDrawImage(pGraphics, pImage, (oDialog:nWidth - nWidth) / 2, (oDialog:nHeight - nHeight) / 2)
         waGdipDisposeImage(pImage)
         waGdipDeleteGraphics(pGraphics)
      }

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   waGdiplusShutdown()

RETURN
