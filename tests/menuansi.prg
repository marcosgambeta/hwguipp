#include "hwgui.ch"

REQUEST HB_CODEPAGE_PTISO

PROCEDURE Main()

   LOCAL oMainWindow

   hb_cdpSelect("PTISO")

   INIT WINDOW oMainWindow TITLE "Teste com codifição em ANSI" SIZE 800, 600

   MENU OF oMainWindow
      MENU TITLE "Menu A"
         MENUITEM "Opção A1" ACTION hwg_MsgInfo("Opção A1")
         MENUITEM "Opção A2" ACTION hwg_MsgInfo("Opção A2")
         MENUITEM "Opção A3" ACTION hwg_MsgInfo("Opção A3")
         SEPARATOR
         MENUITEM "Saída" ACTION hwg_EndWindow()
      ENDMENU
      MENU TITLE "Menu B"
         MENUITEM "Opção B1" ACTION hwg_MsgInfo("Opção B1")
         MENUITEM "Opção B2" ACTION hwg_MsgInfo("Opção B2")
         MENUITEM "Opção B3" ACTION hwg_MsgInfo("Opção B3")
      ENDMENU
      MENU TITLE "Menu C"
         MENUITEM "Opção C1" ACTION hwg_MsgInfo("Opção C1")
         MENUITEM "Opção C2" ACTION hwg_MsgInfo("Opção C2")
         MENUITEM "Opção C3" ACTION hwg_MsgInfo("Opção C3")
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN
