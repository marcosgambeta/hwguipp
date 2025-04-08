#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Test CLOSE" SIZE 800, 600

   @ 20, 20 BUTTON "&Close" SIZE 100, 32 ON CLICK {||oMainWindow:close()}

   ACTIVATE WINDOW oMainWindow

RETURN
