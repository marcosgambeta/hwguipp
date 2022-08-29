#include "windows.ch"
#include "guilib.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oButton

   INIT DIALOG oDialog TITLE "Test ENABLE/DISABLE" SIZE 800,600

   @ 20, 20 BUTTON "Enable" SIZE 100,40 ON CLICK {||oButton:Enable()}
   @ 20, 60 BUTTON "Disable" SIZE 100,40 ON CLICK {||oButton:Disable()}
   @ 20,100 BUTTON "info" SIZE 100,40 ON CLICK {||hwg_MsgInfo(iif(oButton:Enabled(),"enabled","disabled"))}

   @ 20,180 BUTTON oButton CAPTION "Test Button" SIZE 100,40 ON CLICK {||NIL}

   ACTIVATE DIALOG oDialog

RETURN
