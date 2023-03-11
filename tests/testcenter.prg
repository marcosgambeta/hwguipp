#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow TITLE "Test CENTER" SIZE 800, 600

   oMainWindow:center()

   ACTIVATE WINDOW oMainWindow

RETURN
