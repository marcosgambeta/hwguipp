#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow TITLE "Test" SIZE 800, 600

   MENU OF oMainWindow
      MENU TITLE "Menu A"
         MENUITEM "Option A1" ACTION hwg_MsgInfo("A1")
         MENUITEM "Option A2" ACTION hwg_MsgInfo("A2")
         MENUITEM "Option A3" ACTION hwg_MsgInfo("A3")
         SEPARATOR
         MENUITEM "Exit" ACTION hwg_EndWindow()
      ENDMENU
      MENU TITLE "Menu B"
         MENUITEM "Option B1" ACTION hwg_MsgInfo("B1")
         MENUITEM "Option B2" ACTION hwg_MsgInfo("B2")
         MENUITEM "Option B3" ACTION hwg_MsgInfo("B3")
      ENDMENU
      MENU TITLE "Menu C"
         MENUITEM "Option C1" ACTION hwg_MsgInfo("C1")
         MENUITEM "Option C2" ACTION hwg_MsgInfo("C2")
         MENUITEM "Option C3" ACTION hwg_MsgInfo("C3")
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN
