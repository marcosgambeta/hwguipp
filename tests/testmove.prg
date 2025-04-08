#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oWindow

   INIT WINDOW oWindow TITLE "Test method MOVE" SIZE 800, 600

   @ 20, 20 BUTTON "x=100" SIZE 100, 40 ON CLICK {||oWindow:move(100)}
   @ 20, 60 BUTTON "y=100" SIZE 100, 40 ON CLICK {||oWindow:move(, 100)}
   @ 20, 100 BUTTON "width=400" SIZE 100, 40 ON CLICK {||oWindow:move(,, 400)}
   @ 20, 140 BUTTON "height=400" SIZE 100, 40 ON CLICK {||oWindow:move(,,, 400)}
   @ 20, 180 BUTTON "change all" SIZE 100, 40 ON CLICK {||oWindow:move(100, 100, 400, 400)}
   @ 20, 220 BUTTON "info" SIZE 100, 40 ON CLICK {||hwg_MsgInfo(;
      "x="+alltrim(str(oWindow:nX))+;
      "y="+alltrim(str(oWindow:nY))+;
      "w="+alltrim(str(oWindow:nWidth))+;
      "h="+alltrim(str(oWindow:nHeight)))}

   ACTIVATE WINDOW oWindow

RETURN
