#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN MDI TITLE "Test"

   MENU OF oMainWindow
      MENUITEM "&New child" ACTION NewChild()
      MENUITEM "&Exit" ACTION hwg_EndWindow()
   ENDMENU

   ACTIVATE WINDOW oMainWindow MAXIMIZED

RETURN

STATIC FUNCTION NewChild()

   STATIC nChildNum := 0

   LOCAL oChildWindow

   ++nChildNum

   INIT WINDOW oChildWindow MDICHILD TITLE "Child Window #" + alltrim(str(nChildNum)) ;
      AT 0, 0 SIZE 640, 480 STYLE WS_VISIBLE + WS_OVERLAPPEDWINDOW

   ACTIVATE WINDOW oChildWindow CENTER

RETURN NIL
