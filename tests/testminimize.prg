#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Test MINIMIZE" SIZE 800, 600

   ACTIVATE WINDOW oMainWindow ON ACTIVATE {||oMainWindow:minimize()}

RETURN
