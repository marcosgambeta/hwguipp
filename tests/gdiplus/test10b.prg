/*
 * HWGUI++/GDI+ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// for MS-Windows only

// texture.png generated with:
// https://cpetry.github.io/TextureGenerator-Online/

// same as test10, but loading image and creating texture only one time

#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oMainWindow
   LOCAL pImage
   LOCAL pTexture

   // initialize GDI+
   waGdiplusStartup()

   // load image and create texture
   waGdipLoadImageFromFile("texture.png", @pImage)
   waGdipCreateTexture(pImage, /*Tile*/ 0, @pTexture)

   INIT WINDOW oMainWindow TITLE "Test" SIZE 1024, 768

   oMainWindow:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(oMainWindow:handle, pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipFillRectangleI(pGraphics, pTexture, 0, 0, oMainWindow:nWidth, oMainWindow:nHeight)
      waGdipDeleteGraphics(pGraphics)
      hwg_EndPaint(oMainWindow:handle, pPS)
      }

   // update window if resized
   //oMainWindow:bSize := {||hwg_RedrawWindow(oMainWindow:handle, RDW_ERASE + RDW_INVALIDATE)}

   ACTIVATE WINDOW oMainWindow MAXIMIZED

   // free image and texture
   waGdipDeleteBrush(pTexture)
   waGdipDisposeImage(pImage)

   // finalize GDI+
   waGdiplusShutdown()

RETURN
