#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oButtonOk
   LOCAL oButtonCancel

   WITH OBJECT oDialog := HDialog():new()

      :title   := "Test"
      :nWidth  := 640
      :nHeight := 480

      WITH OBJECT oButtonOk := HButton():new()
         :title  := "&OK"
         :nLeft  := 20
         :nTop   := 20
         :bClick := {||hwg_MsgInfo("OK clicked", "Information")}
      ENDWITH

      WITH OBJECT oButtonCancel := HButton():new()
         :title  := "&Cancel"
         :nLeft  := 120
         :nTop   := 20
         :bClick := {||hwg_MsgInfo("Cancel clicked", "Information")}
      ENDWITH

      :activate()

   ENDWITH

RETURN
