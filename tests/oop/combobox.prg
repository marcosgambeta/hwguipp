#include "hwguipp.ch"

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
         :nX      := 20
         :nY      := 20
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oComboBox1 := HComboBox():new()
         :nX      := 120
         :nY      := 20
         :nWidth  := 120
         :nHeight := 30 * 5
      ENDWITH

      WITH OBJECT oLabel2 := HStatic():new()
         :title   := "Label2"
         :nX      := 20
         :nY      := 60
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oComboBox2 := HComboBox():new()
         :nX      := 120
         :nY      := 60
         :nWidth  := 120
         :nHeight := 30 * 5
         :aItems  := {"Item1", "Item2", "Item3", "Item4", "Item5"}
      ENDWITH

      WITH OBJECT oLabel3 := HStatic():new()
         :title   := "Label3"
         :nX      := 20
         :nY      := 100
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oComboBox3 := HComboBox():new()
         :nX      := 120
         :nY      := 100
         :nWidth  := 120
         :nHeight := 30 * 5
         :aItems  := {"Item1", "Item2", "Item3", "Item4", "Item5"}
         :SetItem(3)
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
