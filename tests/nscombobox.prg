#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oLabel1
   LOCAL oComboBox1
   LOCAL oLabel2
   LOCAL oComboBox2
   LOCAL oLabel3
   LOCAL oComboBox3
   LOCAL oButtonOk
   LOCAL oButtonCancel

   WITH OBJECT oDialog := HDialog():new()

      :title   := "Test"
      :nWidth  := 320
      :nHeight := 240

      WITH OBJECT oLabel1 := HStatic():new()
         :title   := "Label1"
         :nLeft   := 20
         :nTop    := 20
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oComboBox1 := HComboBox():new()
         :nLeft   := 120
         :nTop    := 20
         :nWidth  := 120
         :nHeight := 30 * 5
      ENDWITH

      WITH OBJECT oLabel2 := HStatic():new()
         :title   := "Label2"
         :nLeft   := 20
         :nTop    := 60
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oComboBox2 := HComboBox():new()
         :nLeft   := 120
         :nTop    := 60
         :nWidth  := 120
         :nHeight := 30 * 5
         :aItems  := {"Item1", "Item2", "Item3", "Item4", "Item5"}
      ENDWITH

      WITH OBJECT oLabel3 := HStatic():new()
         :title   := "Label3"
         :nLeft   := 20
         :nTop    := 100
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oComboBox3 := HComboBox():new()
         :nLeft   := 120
         :nTop    := 100
         :nWidth  := 120
         :nHeight := 30 * 5
         :aItems  := {"Item1", "Item2", "Item3", "Item4", "Item5"}
         :SetItem(3)
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
