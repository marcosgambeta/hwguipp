#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oWindow

   INIT WINDOW oWindow MAIN SIZE 640, 480

   @ 20,  20 NICEBUTTON "button1" OF oWindow ID 100 SIZE 120, 40 RED  52 GREEN  10 BLUE  60 ON CLICK {||hwg_MsgInfo("button1 clicked")}
   @ 20, 120 NICEBUTTON "button2" OF oWindow ID 101 SIZE 120, 40 RED 215 GREEN  76 BLUE 108 ON CLICK {||hwg_MsgInfo("button2 clicked")}

   ACTIVATE WINDOW oWindow

RETURN
