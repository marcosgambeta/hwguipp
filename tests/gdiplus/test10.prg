/*
 * HWGUI++/GDI+ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// for MS-Windows only

// texture.png generated with:
// https://cpetry.github.io/TextureGenerator-Online/

#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   // initialize GDI+
   waGdiplusStartup()

   INIT WINDOW oMainWindow TITLE "Test" SIZE 1024, 768

   oMainWindow:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      LOCAL pImage
      LOCAL pTexture
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(oMainWindow:handle, pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipLoadImageFromFile("texture.png", @pImage)
      waGdipCreateTexture(pImage, /*Tile*/ 0, @pTexture)
      waGdipFillRectangleI(pGraphics, pTexture, 0, 0, oMainWindow:nWidth, oMainWindow:nHeight)
      waGdipDeleteBrush(pTexture)
      waGdipDisposeImage(pImage)
      waGdipDeleteGraphics(pGraphics)
      hwg_EndPaint(oMainWindow:handle, pPS)
      }

   // update window if resized
   //oMainWindow:bSize := {||hwg_RedrawWindow(oMainWindow:handle, RDW_ERASE + RDW_INVALIDATE)}

   ACTIVATE WINDOW oMainWindow MAXIMIZED

   // finalize GDI+
   waGdiplusShutdown()

RETURN
