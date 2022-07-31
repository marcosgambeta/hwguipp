#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oLabelId
   LOCAL oLabelName
   LOCAL oLabelPhone
   LOCAL oButtonOk
   LOCAL oButtonCancel

   WITH OBJECT oDialog := HDialog():new()

      :title   := "Test"
      :nWidth  := 320
      :nHeight := 240

      WITH OBJECT oLabelId := HStatic():new()
         :title   := "Id"
         :nLeft   := 20
         :nTop    := 20
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oLabelName := HStatic():new()
         :title   := "Name"
         :nLeft   := 20
         :nTop    := 60
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oLabelPhone := HStatic():new()
         :title   := "Phone"
         :nLeft   := 20
         :nTop    := 100
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oButtonOk := HButton():new()
         :title  := "&OK"
         :nLeft  := 20
         :nTop   := 140
         :bClick := {||hwg_MsgInfo("OK clicked", "Information")}
      ENDWITH

      WITH OBJECT oButtonCancel := HButton():new()
         :title  := "&Cancel"
         :nLeft  := 120
         :nTop   := 140
         :bClick := {||hwg_MsgInfo("Cancel clicked", "Information")}
      ENDWITH

      :activate()

   ENDWITH

RETURN
