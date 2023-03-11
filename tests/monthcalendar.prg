#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oMC

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 20, 20 MONTHCALENDAR oMC SIZE 200, 200

   ACTIVATE DIALOG oDialog

RETURN
