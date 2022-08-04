#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oLabel1
   LOCAL oCheckButton1
   LOCAL oLabel2
   LOCAL oCheckButton2
   LOCAL oLabel3
   LOCAL oCheckButton3
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

      WITH OBJECT oCheckButton1 := HCheckButton():new()
         :title   := "checkbutton1"
         :nLeft   := 120
         :nTop    := 20
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oLabel2 := HStatic():new()
         :title   := "Label2"
         :nLeft   := 20
         :nTop    := 60
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oCheckButton2 := HCheckButton():new()
         :title   := "checkbutton2"
         :nLeft   := 120
         :nTop    := 60
         :nWidth  := 120
         :nHeight := 30
         :lValue  := .T.
      ENDWITH

      WITH OBJECT oLabel3 := HStatic():new()
         :title   := "Label3"
         :nLeft   := 20
         :nTop    := 100
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oCheckButton3 := HCheckButton():new()
         :title   := "checkbutton3"
         :nLeft   := 120
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
