/*
 * HWGUI++/GDI+ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// for MS-Windows only

#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   // initialize GDI+
   waGdiplusStartup()

   INIT WINDOW oMainWindow MAIN TITLE "Test" SIZE 800, 600 ON EXIT {||hwg_MsgYesNo("Confirm exit ?")}

   oMainWindow:bPaint := {||
      LOCAL pPS
      LOCAL pDC
      LOCAL pGraphics
      LOCAL oP1 := waGpPoint():new(0, 0)
      LOCAL oP2 := waGpPoint():new(0, oMainWindow:nHeight)
      LOCAL pBrush
      pPS := hwg_DefinePaintStru()
      pDC := hwg_BeginPaint(oMainWindow:handle, pPS)
      waGdipCreateFromHDC(pDC, @pGraphics)
      waGdipCreateLineBrushI(oP1, oP2, 0xFF0F2027, 0xFF2C5364, NIL, @pBrush)
      waGdipFillRectangleI(pGraphics, pBrush, 0, 0, oMainWindow:nWidth, oMainWindow:nHeight)
      waGdipDeleteBrush(pBrush)
      waGdipDeleteGraphics(pGraphics)
      hwg_EndPaint(oMainWindow:handle, pPS)
      }

   //oMainWindow:bOther := {|o, msg, w, l|
   //   IF msg == WM_ERASEBKGND
   //      RETURN 1
   //   ENDIF
   //   RETURN -1
   //   }

   MENU OF oMainWindow
      MENU TITLE "&Menu"
         MENUITEM "Dialog &1" ACTION Dialog1()
         MENUITEM "Dialog &2" ACTION Dialog2()
         SEPARATOR
         MENUITEM "E&xit" ACTION oMainWindow:Close()
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow MAXIMIZED

   // finalize GDI+
   waGdiplusShutdown()

RETURN

STATIC FUNCTION Dialog1()

   LOCAL oDialog
   LOCAL oEdit1
   LOCAL oEdit2
   LOCAL oEdit3
   LOCAL oEdit4
   LOCAL oEdit5

   INIT DIALOG oDialog TITLE "Dialog 1" SIZE 640, 480 ;
      FONT HFont():Add("Courier New", 0, -14) ;
      STYLE DS_CENTER ;
      ON EXIT {||hwg_MsgYesNo("Confirm exit ?")} ;
      ON PAINT {||
         LOCAL pPS
         LOCAL pDC
         LOCAL pGraphics
         LOCAL oP1 := waGpPoint():new(0, 0)
         LOCAL oP2 := waGpPoint():new(0, oDialog:nHeight)
         LOCAL pBrush
         pPS := hwg_DefinePaintStru()
         pDC := hwg_BeginPaint(hwg_GetModalHandle(), pPS)
         waGdipCreateFromHDC(pDC, @pGraphics)
         waGdipCreateLineBrushI(oP1, oP2, 0xFF1F4037, 0xFF99F2C8, NIL, @pBrush)
         waGdipFillRectangleI(pGraphics, pBrush, 0, 0, oDialog:nWidth, oDialog:nHeight)
         waGdipDeleteBrush(pBrush)
         waGdipDeleteGraphics(pGraphics)
         hwg_EndPaint(hwg_GetModalHandle(), pPS)
      }

   @ 20, 40 SAY "Field&1 (ALT+1):" SIZE 130, 26 TRANSPARENT
   @ 160, 40 EDITBOX oEdit1 CAPTION "" SIZE 300, 26

   @ 20, 80 SAY "Field&2 (ALT+2):" SIZE 130, 26 TRANSPARENT
   @ 160, 80 EDITBOX oEdit2 CAPTION "" SIZE 300, 26

   @ 20, 120 SAY "Field&3 (ALT+3):" SIZE 130, 26 TRANSPARENT
   @ 160, 120 EDITBOX oEdit3 CAPTION "" SIZE 300, 26

   @ 20, 160 SAY "Field&4 (ALT+4):" SIZE 130, 26 TRANSPARENT
   @ 160, 160 EDITBOX oEdit4 CAPTION "" SIZE 300, 26

   @ 20, 200 SAY "Field&5 (ALT+5):" SIZE 130, 26 TRANSPARENT
   @ 160, 200 EDITBOX oEdit5 CAPTION "" SIZE 300, 26

   @ (320 - 100) / 2, 280 BUTTON "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTON "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

RETURN NIL

STATIC FUNCTION Dialog2()

   LOCAL oDialog
   LOCAL oEdit1
   LOCAL oEdit2
   LOCAL oEdit3
   LOCAL oEdit4
   LOCAL oEdit5

   INIT DIALOG oDialog TITLE "Dialog 2" SIZE 640, 480 ;
      FONT HFont():Add("Tahoma", 0, -14, 400) ;
      STYLE DS_CENTER ;
      ON EXIT {||hwg_MsgYesNo("Confirm exit ?")} ;
      ON PAINT {||
         LOCAL pPS
         LOCAL pDC
         LOCAL pGraphics
         LOCAL oP1 := waGpPoint():new(0, 0)
         LOCAL oP2 := waGpPoint():new(0, oDialog:nHeight)
         LOCAL pBrush
         pPS := hwg_DefinePaintStru()
         pDC := hwg_BeginPaint(hwg_GetModalHandle(), pPS)
         waGdipCreateFromHDC(pDC, @pGraphics)
         waGdipCreateLineBrushI(oP1, oP2, 0xFFDBE6F6, 0xFFC5796D, NIL, @pBrush)
         waGdipFillRectangleI(pGraphics, pBrush, 0, 0, oDialog:nWidth, oDialog:nHeight)
         waGdipDeleteBrush(pBrush)
         waGdipDeleteGraphics(pGraphics)
         hwg_EndPaint(hwg_GetModalHandle(), pPS)
      }

   @ 20, 40 SAY "Field&1 (ALT+1):" SIZE 130, 26 TRANSPARENT
   @ 160, 40 EDITBOX oEdit1 CAPTION "" SIZE 300, 26

   @ 20, 80 SAY "Field&2 (ALT+2):" SIZE 130, 26 TRANSPARENT
   @ 160, 80 EDITBOX oEdit2 CAPTION "" SIZE 300, 26

   @ 20, 120 SAY "Field&3 (ALT+3):" SIZE 130, 26 TRANSPARENT
   @ 160, 120 EDITBOX oEdit3 CAPTION "" SIZE 300, 26

   @ 20, 160 SAY "Field&4 (ALT+4):" SIZE 130, 26 TRANSPARENT
   @ 160, 160 EDITBOX oEdit4 CAPTION "" SIZE 300, 26

   @ 20, 200 SAY "Field&5 (ALT+5):" SIZE 130, 26 TRANSPARENT
   @ 160, 200 EDITBOX oEdit5 CAPTION "" SIZE 300, 26

   @ (320 - 100) / 2, 280 BUTTON "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTON "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

RETURN NIL
