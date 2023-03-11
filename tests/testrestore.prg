#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Test RESTORE" SIZE 800, 600

   @ 20,20 BUTTON "&Restore" SIZE 100,32 ON CLICK {||oMainWindow:restore()}

   ACTIVATE WINDOW oMainWindow ON ACTIVATE {||oMainWindow:maximize()}

RETURN
