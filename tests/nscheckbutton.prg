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
         :nX      := 20
         :nY      := 20
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oCheckButton1 := HCheckButton():new()
         :title   := "checkbutton1"
         :nX      := 120
         :nY      := 20
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oLabel2 := HStatic():new()
         :title   := "Label2"
         :nX      := 20
         :nY      := 60
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oCheckButton2 := HCheckButton():new()
         :title   := "checkbutton2"
         :nX      := 120
         :nY      := 60
         :nWidth  := 120
         :nHeight := 30
         :lValue  := .T.
      ENDWITH

      WITH OBJECT oLabel3 := HStatic():new()
         :title   := "Label3"
         :nX      := 20
         :nY      := 100
         :nWidth  := 120
         :nHeight := 30
      ENDWITH

      WITH OBJECT oCheckButton3 := HCheckButton():new()
         :title   := "checkbutton3"
         :nX      := 120
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
