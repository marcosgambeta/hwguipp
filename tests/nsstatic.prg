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
         :nX      := 20
         :nY      := 20
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oLabelName := HStatic():new()
         :title   := "Name"
         :nX      := 20
         :nY      := 60
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oLabelPhone := HStatic():new()
         :title   := "Phone"
         :nX      := 20
         :nY      := 100
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oButtonOk := HButton():new()
         :title  := "&OK"
         :nX     := 20
         :nY     := 140
         :bClick := {||hwg_MsgInfo("OK clicked", "Information")}
      ENDWITH

      WITH OBJECT oButtonCancel := HButton():new()
         :title  := "&Cancel"
         :nX     := 120
         :nY     := 140
         :bClick := {||hwg_MsgInfo("Cancel clicked", "Information")}
      ENDWITH

      :activate()

   ENDWITH

RETURN
