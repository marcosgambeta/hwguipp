#include "windows.ch"
#include "guilib.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oButton
   LOCAL oIcon
   
   oIcon := HIcon():addFile("../image/cancel.ico", 32, 32)

   INIT DIALOG oDialog TITLE "Test HICON:DRAW" SIZE 800,600

   @ 20, 20 BUTTON "Draw Icon" SIZE 100,40 ON CLICK {||oIcon:Draw(hwg_Getdc(oDialog:handle), (800 - 32) / 2, (600 - 32) / 2)}

   ACTIVATE DIALOG oDialog

RETURN
