#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Test" SIZE 800, 600

   @ 20, 20 BUTTON "Center" SIZE 100, 32 ON CLICK {||oMainWindow:center()}
   @ 20, 60 BUTTON "Maximize" SIZE 100, 32 ON CLICK {||oMainWindow:maximize()}
   @ 20, 100 BUTTON "Minimize" SIZE 100, 32 ON CLICK {||oMainWindow:minimize()}
   @ 20, 140 BUTTON "Restore" SIZE 100, 32 ON CLICK {||oMainWindow:restore()}
   @ 20, 180 BUTTON "Close" SIZE 100, 32 ON CLICK {||oMainWindow:close()}
   @ 20, 220 BUTTON "info" SIZE 100, 40 ON CLICK {||hwg_MsgInfo(;
      "x="+alltrim(str(oMainWindow:nX))+;
      "y="+alltrim(str(oMainWindow:nY))+;
      "w="+alltrim(str(oMainWindow:nWidth))+;
      "h="+alltrim(str(oMainWindow:nHeight)))}

   ACTIVATE WINDOW oMainWindow

RETURN
