#include "hwguipp.ch"

FUNCTION Main()

   LOCAL oDialog
   LOCAL oTB
   LOCAL oSay

   INIT DIALOG oDialog TITLE "Test TrackBar Control" AT 100,100 SIZE 640,480

   @ 20, 20 TRACKBAR oTB SIZE 300,50 RANGE 0,10 INIT 5 AUTOTICKS ON CHANGE {||oSay:SetText(AllTrim(Str(oTB:Value)))}

   @ 300, 200 BUTTON "Get Value" ON CLICK {||hwg_Msginfo(Str(oTB:Value))} SIZE 100, 40
   @ 300, 300 BUTTON "Set Value" ON CLICK {||oTB:Value := 5, oSay:SetText(AllTrim(Str(oTB:Value)))} SIZE 100, 40

   @ 100, 100 SAY oSay CAPTION "5" SIZE 40, 40

   ACTIVATE DIALOG oDialog

RETURN NIL
