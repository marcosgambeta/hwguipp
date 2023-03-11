#include "hwguipp.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oLabel1
   LOCAL oDatePicker1
   LOCAL oLabel2
   LOCAL oDatePicker2
   LOCAL oLabel3
   LOCAL oDatePicker3
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

      WITH OBJECT oDatePicker1 := HDatePicker():new()
         :nX      := 120
         :nY      := 20
         :nWidth  := 120
         :nHeight := 30
         :dValue := date() - 30
      ENDWITH

      WITH OBJECT oLabel2 := HStatic():new()
         :title   := "Label2"
         :nX      := 20
         :nY      := 60
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oDatePicker2 := HDatePicker():new()
         :nX      := 120
         :nY      := 60
         :nWidth  := 120
         :nHeight := 30
         :dValue  := date()
      ENDWITH

      WITH OBJECT oLabel3 := HStatic():new()
         :title   := "Label3"
         :nX      := 20
         :nY      := 100
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oDatePicker3 := HDatePicker():new()
         :nX      := 120
         :nY      := 100
         :nWidth  := 120
         :nHeight := 30
         :dValue := date() + 30
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
