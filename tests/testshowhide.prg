#include "windows.ch"
#include "guilib.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oButton

   INIT DIALOG oDialog TITLE "Test SHOW/HIDE" SIZE 800,600

   @ 20, 20 BUTTON "Show" SIZE 100,40 ON CLICK {||oButton:Show()}
   @ 20, 60 BUTTON "Hide" SIZE 100,40 ON CLICK {||oButton:Hide()}
   @ 20,100 BUTTON "info" SIZE 100,40 ON CLICK {||hwg_MsgInfo(iif(oButton:lHide,"invisible","visible"))}

   @ 20,180 BUTTON oButton CAPTION "Test Button" SIZE 100,40 ON CLICK {||NIL}

   ACTIVATE DIALOG oDialog

RETURN
