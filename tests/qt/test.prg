#include "hwguipp.ch"

STATIC s_oApp

FUNCTION Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Testing HWGUI++ with Qt Framework" SIZE 800, 600

   MENU OF oMainWindow
      MENU TITLE "&Menu"
         MENUITEM "&Dialog" ACTION ShowQtDialog()
         SEPARATOR
         MENUITEM "E&xit" ACTION hwg_EndWindow()
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow MAXIMIZED

RETURN NIL

STATIC FUNCTION ShowQtDialog()

   STATIC n := 0

   LOCAL oDialog

   ++n

   oDialog := QDialog():new()
   oDialog:setWindowTitle("Dialog " + AllTrim(Str(n)))
   oDialog:exec()
   oDialog:delete()

RETURN NIL

INIT PROCEDURE CreateApp()

   s_oApp := QApplication():new()

RETURN

EXIT PROCEDURE DeleteApp()

   s_oApp:delete()

RETURN
