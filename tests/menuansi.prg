#include "hwgui.ch"

REQUEST HB_CODEPAGE_PTISO

PROCEDURE Main()

   LOCAL oMainWindow

   hb_cdpSelect("PTISO")

   INIT WINDOW oMainWindow TITLE "Teste com codifi��o em ANSI" SIZE 800, 600

   MENU OF oMainWindow
      MENU TITLE "Menu A"
         MENUITEM "Op��o A1" ACTION hwg_MsgInfo("Op��o A1")
         MENUITEM "Op��o A2" ACTION hwg_MsgInfo("Op��o A2")
         MENUITEM "Op��o A3" ACTION hwg_MsgInfo("Op��o A3")
         SEPARATOR
         MENUITEM "Sa�da" ACTION hwg_EndWindow()
      ENDMENU
      MENU TITLE "Menu B"
         MENUITEM "Op��o B1" ACTION hwg_MsgInfo("Op��o B1")
         MENUITEM "Op��o B2" ACTION hwg_MsgInfo("Op��o B2")
         MENUITEM "Op��o B3" ACTION hwg_MsgInfo("Op��o B3")
      ENDMENU
      MENU TITLE "Menu C"
         MENUITEM "Op��o C1" ACTION hwg_MsgInfo("Op��o C1")
         MENUITEM "Op��o C2" ACTION hwg_MsgInfo("Op��o C2")
         MENUITEM "Op��o C3" ACTION hwg_MsgInfo("Op��o C3")
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN
